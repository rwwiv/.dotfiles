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
PYENV_VER="3.11"

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
    msg "$text"
}

msg() {
    local msg
    msg="$1"
    echo "${MSG_PREFIX}${msg}..."
}

# begin script
printf '%s\n' "hi - はじめ まして" ""

trap 'exit_trap $? $LINENO' EXIT

read -r "print_init_checklist?Print optional init checklist? (y/N) "; echo ""

if [[ "$print_init_checklist" =~ [yY][eE]?[sS]? ]]; then
    printf "%s\n" \
        " - [ ] Export gpg key(s) from old machine" \
        " - [ ] Export ssh key(s) and config from old machine "
    read -k1 -q "?Press any key to continue..." || true
fi

# Make sure git submodules are initialized
git submodule update --init --recursive

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

msg "Creating .zshrc secrets file"
echo "#!/bin/zsh" > "$DOTFILES_DIR/zsh/secrets"

msg "Making UI changes"
# disable desktop
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
    if [ "$(grep -c "GITHUB_API_TOKEN" "$DOTFILES_DIR/zsh/secrets")" -eq 0 ]; then
        notice "$NOTICE_TITLE" "Ready for Homebrew GitHub token"
        read -rs "homebrew_github_api_token?Paste token here: "; echo ""
        echo "export HOMEBREW_GITHUB_API_TOKEN=\"$homebrew_github_api_token\"" >> "$DOTFILES_DIR/zsh/secrets"
    fi
else
    msg "Updating homebrew"
    brew update
fi

msg "Installing from Brewfile"
brew bundle --file="$DOTFILES_DIR/brew/Brewfile"

msg "Configuring zsh"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
ln -s "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

mv "$HOME/.antigenrc" "$HOME/.antigenrc.bak"
ln -s "$DOTFILES_DIR/zsh/.antigenrc" "$HOME/.antigenrc"

msg "Configuring pyenv"
pyenv versions | grep -m1 "${PYENV_VER}" &>/dev/null || pyenv install "${PYENV_VER}:latest"
pyenv_ver="$(pyenv versions | grep -m1 "${PYENV_VER}" | awk '{print $1}')"
[ "$pyenv_ver" != "*" ] && pyenv global "$pyenv_ver"

msg "Installing poetry"
curl -sSL https://install.python-poetry.org | python3 -
ZSH_CUSTOM="$HOME/.dotfiles/zsh/custom"
[[ -f $ZSH_CUSTOM/plugins/poetry ]] || mkdir -p $ZSH_CUSTOM/plugins/poetry
$HOME/.local/bin/poetry completions zsh > $ZSH_CUSTOM/plugins/poetry/_poetry

msg "Sourcing $HOME/.zshrc"
set +e
source "$HOME/.zshrc"
set -e

msg "Starting colima"
colima start

msg "Configuring docker buildx"
mkdir -p ~/.docker/cli-plugins
ln -sfn "${BREW_PREFIX}/opt/docker-buildx/bin/docker-buildx" ~/.docker/cli-plugins/docker-buildx
docker buildx install

notice "$NOTICE_TITLE" "Ready to copy ssh config and keys"
read -k1 -q "?Press any key to continue..." || true

msg "Configuring nvm"
nvm install "lts/*"
nvm use default

msg "Restoring mackup backup"
[[ -f "$HOME/.mackup.cfg" ]] && rm -f "$HOME/.mackup.cfg"
cp ./mackup/.mackup.cfg "$HOME/.mackup.cfg"
mackup restore -f

msg "Configuring git"
printf '%s\n' '[include]' 'path = ~/.dotfiles/git/.gitconfig' >"$HOME/.gitconfig"

notice "$NOTICE_TITLE" "Ready for git name & email"

read -r "git_name?Enter name: "
read -r "git_email?Enter email: "
git config --global user.name "$git_name"
git config --global user.email "$git_email"

read -r "use_gpg?Import gpg signing key? (y/N) "; echo ""
if [[ "$use_gpg" =~ [yY][eE]?[sS]? ]]; then
    echo "Import gpg key now"
    read -k1 -q "?Press any key to continue..." || true
    read -rs "git_gpg_fp?Enter gpg key fingerprint: "; echo ""
    git config --global user.signingkey "$git_gpg_fp"
fi

msg "Installing fonts"
mkdir -p ./fonts

# Hack Nerd Mono
if [[ ! -d ./fonts/hack ]]; then
    curl -L -o ./fonts/hack.zip https://github.com/ryanoasis/nerd-fonts/releases/download/2.2.0-RC/Hack.zip
    unzip ./fonts/hack.zip -d ./fonts/hack
fi
find ./fonts/hack -iname '*Windows*' | grep . && rm -rf ./fonts/hack/*Windows*
cp ./fonts/hack/*Mono.ttf "$HOME/Library/Fonts/"

# Fira Code
if [[ ! -d ./fonts/fira ]]; then
    curl -L -o ./fonts/fira.zip https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip
    unzip ./fonts/fira.zip -d ./fonts/fira
fi
cp ./fonts/fira/variable_ttf/* "$HOME/Library/Fonts/"

# Dank Mono
if [[ ! -d ./fonts/dank ]]; then
    curl -L -o ./fonts/dank.zip https://github.com/cancng/fonts/raw/master/DankMono.zip
    unzip ./fonts/dank.zip -d ./fonts/dank
fi
cp ./fonts/dank/*.otf "$HOME/Library/Fonts/"

msg "Misc changes"
# iterm2
[ -f "$HOME/.hushlogin" ] || touch "$HOME/.hushlogin"

# END
printf '%s\n' "goodbye - さようなら" ""
