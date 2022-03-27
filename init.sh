#!/bin/bash

# constants
DOTFILES_DIR="$HOME/.dotfiles"
NOTICE_TITLE=".dotfiles init"
PREFIX="${bold}[${green}dotfile init${reset_format}] - "
PYENV_VER="3.10"

set -e
exit_trap() {
    set +e
    local exit_code err_msg
    exit_code="$1"
    if [ "$exit_code" -gt 0 ]; then 
        err_msg="${blue}NOTICE${reset_format} - Script failed, check above for errors"
    fi
    [[ -n "$err_msg" ]] && echo "$err_msg"
    echo 'Removing password from Keychain...'
    printf '%s' " > "
    /usr/bin/security delete-generic-password -s 'dotfiles' -a "$USER" 1>/dev/null
    echo 'Deleting temp SUDO_ASKPASS script...'
    rm -f "${SUDO_ASKPASS}"
}

# colors
red=$(tput setaf 1)
green=$(tput setaf 2)
blue=$(tput setaf 4)
bold=$(tput bold)
reset_format=$(tput sgr0)

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
    echo "${PREFIX}${msg}..."
}

# begin script
printf '%s\n' "hi - はじめ まして" ""

trap 'exit_trap $?' EXIT

read -rsp "Print init checklist? (y/N) " print_init_checklist; echo ""

if [[ "$print_init_checklist" =~ [yY][eE]?[sS]? ]]; then
    printf "%s\n" \
        "Pre-install Checklist" \
        " - [ ] Export gpg key(s) from old machine" \
        " - [ ] Export ssh key(s) from old machine "
        
fi

# create temp SUDO_ASKPASS
export SUDO_ASKPASS="$DOTFILES_DIR/tmp_askpass"

(
    read -rsp "Enter password for $USER: " < /dev/tty
    echo "add-generic-password -U -s 'dotfiles' -a '${USER}' -w '${REPLY}'"
) | /usr/bin/security -i
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

if [ "$(uname -m)" = "arm64" ]; then
    msg "Installing rosetta"
    softwareupdate --install-rosetta --agree-to-license
fi

msg "Installing xcode command line tool"
xcode-select --install

if ! (type brew &>/dev/null); then
    msg "Installing homebrew"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    msg "Updating homebrew"
    brew update
fi

msg "Installing from Brewfile"
brew bundle --file="$DOTFILES_DIR/brew/Brewfile"

msg "Restoring mackup backup"
cp ./mackup/.mackup.cfg "$HOME/.mackup.cfg"
mackup restore

msg "Copying other config files"
cp -r ./config/{.,}* "$HOME/.config"

msg "Configuring zsh"
[ "$ZSH" = "$HOME/.oh-my-zsh" ] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
ln -s "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
# shellcheck source=/dev/null
source "$HOME/.zshrc"

msg "Configuring ssh"
if [ -f "$HOME/.ssh/.config" ]; then
    echo "" >>"$DOTFILES_DIR/ssh/config"
    cat "$HOME/.ssh/config" >>"$DOTFILES_DIR/ssh/.config"
    rm -f "$HOME/.ssh/.config"
fi
ln -s "$DOTFILES_DIR/ssh/.config" "$HOME/.ssh/config"

msg "Configuring git"
printf '%s\n' '[include]' 'path = ~/.dotfiles/git/.gitconfig' >"$HOME/.gitconfig"

notice "$NOTICE_TITLE" "Ready for gpg key import"
echo "Import gpg key now"
read -n1 -rsp $'Press key to continue...\n'
read -rsp "Enter email: " git_email; echo ""
read -rsp "Enter name: " git_name; echo ""
read -rsp "Enter gpg key fingerprint: " git_gpg_fp; echo ""
git config --global user.email "$git_email"
git config --global user.name "$git_name"
git config --global user.signingKey "$git_gpg_fp"

msg "Configuring nvm"
nvm install "lts/*"
nvm use default

msg "Configuring pyenv"
pyenv install "${PYENV_VER}:latest"
pyenv global "$(pyenv versions | grep -m1 "${PYENV_VER}" | awk '{print $1}')"

msg "Misc changes"
# iterm2
[ -f "$HOME/.hushlogin" ] || touch "$HOME/.hushlogin"
notice "$NOTICE_TITLE" "Ready for iterm2 profile import"
echo "Import iterm2 profiles from $DOTFILES_DIR/iterm2/Profiles.json"
read -n1 -rsp $'Press key to continue...\n'

# END
read -rsp "Print ending checklist? (y/N) " print_end_checklist; echo ""
if [[ "$print_end_checklist" =~ [yY][eE]?[sS]? ]]; then
    printf "%s\n" \
        "Post-install Checklist" \
        " - [ ] Set up sync in vscode" \
        " - [ ] Log in to Chrome " \
        " - [ ] Log in to Bear" \
        " - [ ] Install/set default nvm version" \
        " - [ ] Install/set default pyenv version"
fi

printf '%s\n' "goodbye - さようなら" ""
