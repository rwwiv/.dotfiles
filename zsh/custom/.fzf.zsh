# Set homebrew prefix once
if type brew &>/dev/null; then BREW_PREFIX="$(brew --prefix)"; fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "${BREW_PREFIX}/opt/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "${BREW_PREFIX}/opt/fzf/shell/key-bindings.zsh"
