#!/bin/zsh

# colors
red=$(tput setaf 1)
green=$(tput setaf 2)
blue=$(tput setaf 4)
bold=$(tput bold)
reset_format=$(tput sgr0)

# constants
DOTFILES_DIR="$HOME/.dotfiles"
SCRIPT_PATH="${0:a}"
HOME="$HOME"
NOTICE_TITLE=".dotfiles init"
MSG_PREFIX="[${bold}${green}dotfile init${reset_format}] - "
PYENV_VER="3.10"

set -e
exit_trap() {
    set +e
    local exit_code err_msg line_no line
    exit_code="$1"
    line_no="$2"
    line=$(sed -n "${line_no}"p "$SCRIPT_PATH" | sed 's/^[[:space:]]*//')
    if [ "$exit_code" -gt 0 ]; then 
        err_msg="[${red}NOTICE${reset_format}] - command '${line}' failed"
    fi
    [[ -n "$err_msg" ]] && echo "$err_msg"
    echo 'Removing password from Keychain...'
    printf '%s' " > "
    /usr/bin/security delete-generic-password -s 'dotfiles' -a "$USER" 1>/dev/null
    echo 'Deleting temp SUDO_ASKPASS script...'
    rm -f "${SUDO_ASKPASS}"
}

# define helper functions
notice() {
    local title text sound_name
    title="${1:-"zsh"}"
    text="${2:-"Check terminal in $TERM_PROGRAM"}"
    sound_name="${3:-"Ping"}"
    osascript -e "display notification \"$text\" with title \"$title\" sound name \"$sound_name\""
}

msg() {
    local msg
    msg="$1"
    echo "${MSG_PREFIX}${msg}..."
}

# begin script
printf '%s\n' "hi - はじめ まして" ""

trap 'exit_trap $? $LINENO' EXIT

read -rs "print_init_checklist?Print init checklist? (y/N) "; echo ""

if [[ "$print_init_checklist" =~ [yY][eE]?[sS]? ]]; then
    printf "%s\n" \
        "Pre-install Checklist" \
        " - [ ] Export gpg key(s) from old machine" \
        " - [ ] Export ssh key(s) from old machine "
    read -k1 -q "?Press any key to continue..."    
fi


# create temp SUDO_ASKPASS
export SUDO_ASKPASS="$DOTFILES_DIR/tmp_askpass"

/bin/bash ./init/pw.sh
printf "\n"

printf '%s\n' \
    '#!/bin/bash' \
    "/usr/bin/security find-generic-password -s 'dotfiles' -a '${USER}' -w" > "$SUDO_ASKPASS"

chmod +x "${SUDO_ASKPASS}"

echo "Testing password, ignore try again message(s)..."
if ! (sudo -A -k -v) &>/dev/null; then
    echo "${red}ERROR${reset_format} - Incorrect password" 1>&2
    exit 1
fi
# end SUDO_ASKPASS creation

msg "Running"

msg "Making UI changes"
defaults write com.apple.finder CreateDesktop false
killall Finder

if [ "$(uname -m)" = "arm64" ] && ! pgrep oahd &>/dev/null; then
    msg "Installing rosetta"
    softwareupdate --install-rosetta --agree-to-license
fi

msg "Installing xcode command line tool"
xcode-select -p 1>/dev/null || xcode-select --install

if ! (type brew &>/dev/null); then
    msg "Installing homebrew"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/rwwiv/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    msg "Updating homebrew"
    brew update
fi

msg "Installing from Brewfile"
brew bundle --file="$DOTFILES_DIR/brew/Brewfile"

msg "Configuring zsh"
[ -d "$HOME/.oh-my-zsh" ] && rm -rf "$HOME/.oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
ln -s "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

msg "Configuring pyenv"
pyenv versions | grep -m1 "${PYENV_VER}" &>/dev/null || pyenv install "${PYENV_VER}:latest"
pyenv_ver="$(pyenv versions | grep -m1 "${PYENV_VER}" | awk '{print $1}')"
[ "$pyenv_ver" != "*" ] && pyenv global "$pyenv_ver"

msg "Sourcing $HOME/.zshrc"
set +e
source "$HOME/.zshrc"
set -e

msg "Configuring nvm"
nvm install "lts/*"
nvm use default

msg "Configuring ssh"
if [ -f "$HOME/.ssh/.config" ]; then
    echo "" >>"$DOTFILES_DIR/mackup/.ssh/config"
    cat "$HOME/.ssh/config" >>"$DOTFILES_DIR/mackup/.ssh/config"
fi

msg "Restoring mackup backup"
[ -f "$HOME/.mackup.cfg" ] || cp ./mackup/.mackup.cfg "$HOME/.mackup.cfg"
mackup restore -f

msg "Configuring git"
printf '%s\n' '[include]' 'path = ~/.dotfiles/git/.gitconfig' >"$HOME/.gitconfig"

notice "$NOTICE_TITLE" "Ready for gpg key import"
echo "Import gpg key now"
read -k1 -q "?Press any key to continue..."
read -rs "git_email?Enter email: "; echo ""
read -rs "git_name?Enter name: "; echo ""
read -rs "git_gpg_fp?Enter gpg key fingerprint: "; echo ""
git config --global user.email "$git_email"
git config --global user.name "$git_name"
git config --global user.signingKey "$git_gpg_fp"



msg "Installing fonts"
# Hack Nerd Mono
curl -L -o hack.zip https://github.com/ryanoasis/nerd-fonts/releases/download/2.2.0-RC/Hack.zip
unzip ./hack.zip -d hack
rm hack/*Windows*
cp hack/*Mono.ttf "$HOME/Library/Fonts/"
# Fira Code
curl -L -o fira.zip https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip
unzip ./fira.zip -d fira
cp fira/variable_ttf/* "$HOME/Library/Fonts/"

msg "Misc changes"
# iterm2
[ -f "$HOME/.hushlogin" ] || touch "$HOME/.hushlogin"
notice "$NOTICE_TITLE" "Ready for iterm2 profile import"
echo "Import iterm2 profiles from $DOTFILES_DIR/iterm2/Profiles.json"
read -k1 -q "?Press any key to continue..."

# END
read -rs "print_end_checklist?Print ending checklist? (y/N) "; echo ""
if [[ "$print_end_checklist" =~ [yY][eE]?[sS]? ]]; then
    printf "%s\n" \
        "Post-install Checklist" \
        " - [ ] Set up sync in vscode" \
        " - [ ] Log in to Chrome " \
        " - [ ] Log in to Bear" \
        " - [ ] Install/set default nvm version" \
        " - [ ] Install/set default pyenv version"
    read -k1 -q "?Press any key to continue..."
fi

printf '%s\n' "goodbye - さようなら" ""
