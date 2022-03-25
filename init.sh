#!/bin/bash

dotfiles_dir="$HOME/.dotfiles"
notice_title=".dotfiles init"

# check for root
uid="$(id -u)"
if [ "$uid" -ne 0 ]; then
	echo "This script must be run using sudo!"
	exit 1
fi

# define helper functions
notice() {
    local title text sound_name
    title="${1:-"zsh"}"
    text="${2:-"Check terminal in $TERM_PROGRAM"}"
    sound_name="${3:-"Ping"}"
    if [[ $OSTYPE == 'darwin'* ]]; then
        osascript -e "display notification \"$text\" with title \"$title\" sound name \"$sound_name\""
    else
        printf '\a'
        printf '%s\n' \
            "$title" \
            "  $text"
    fi
}

# begin script
printf '%s\n' "hi - はじめ まして" ""

read -rsp "Print init checklist? " print_init_checklist && echo ""

if [ "$print_init_checklist" = "yes" ] || [ "$print_init_checklist" == "y" ]; then
    printf "%s\n" \
        "Pre-install Checklist" \
        " - [ ] Export gpg key from old machine" \
        " - [ ] Export ssh keys from old machine "
        
fi

# brew
NONINTERACTIVE=1 which -s brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# iterm2
[ -f "$HOME/.hushlogin" ] || touch "$HOME/.hushlogin"

# mackup
cp ./mackup/.mackup.cfg "$HOME/.mackup.cfg"
mackup restore

# config
cp -r ./config/{.,}* "$HOME/.config"

# zsh
[ "$ZSH" = "$HOME/.oh-my-zsh" ] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
ln -s "$dotfiles_dir/zsh/.zshrc" "$HOME/.zshrc"

# ssh
if [ -f "$HOME/.ssh/.config" ]; then
    echo "" >>"$dotfiles_dir/ssh/config"
    cat "$HOME/.ssh/config" >>"$dotfiles_dir/ssh/.config"
    rm -f "$HOME/.ssh/.config"
fi
ln -s "$dotfiles_dir/ssh/.config" "$HOME/.ssh/config"

# git
notice "$notice_title" "Ready for gpg key import"
echo "Import gpg key now"
read -n1 -rsp $'Press key to continue...\n'
read -rsp "Enter email: " git_email && echo ""
read -rsp "Enter name: " git_name && echo ""
read -rsp "Enter gpg key fingerprint: " git_gpg_fp && echo ""
git config --global user.email "$git_email"
git config --global user.name "$git_name"
git config --global user.signingKey "$git_gpg_fp"
printf '%s\n' '[include]' 'path = ~/.dotfiles/git/.gitconfig' >"$HOME/.gitconfig"

# UI
defaults write com.apple.finder CreateDesktop false
killall Finder

# misc
notice "$notice_title" "Ready for iterm2 profile import"
echo "Import iterm2 profiles from $dotfiles_dir/iterm2/Profiles.json"
read -n1 -rsp $'Press key to continue...\n'

# end
read -rsp "Print ending checklist? " print_end_checklist && echo ""

if [ "$print_end_checklist" = "yes" ] || [ "$print_end_checklist" == "y" ]; then
    printf "%s\n" \
        "Post-install Checklist" \
        " - [ ] Set up sync in vscode" \
        " - [ ] Log in to Chrome " \
        " - [ ] Log in to Bear"
fi

printf '%s\n' "goodbye - さようなら" ""
