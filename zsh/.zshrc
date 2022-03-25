export ZSH="$HOME/.oh-my-zsh"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"

[ -d "$HOME/.dotfiles/zsh/custom" ] && export ZSH_CUSTOM="$HOME/.dotfiles/zsh/custom"

# zsh-nvm (must set before loading plugins)
export NVM_LAZY_LOAD=true
export NVM_COMPLETION=true
export NVM_AUTO_USE=true

plugins=(
  aliases
  autoswitch_virtualenv
  alias-finder
  direnv
  encode64
  multi-evalcache
  extract
  git
  git-flow
  macos
  python
  rsync
  safe-paste
  zsh-nvm
  zsh-syntax-highlighting
  # load h-s-s after z-s-h for compat
  history-substring-search
  zsh-autosuggestions
)

# load oh-my-zsh
source $ZSH/oh-my-zsh.sh

# manpath
export MANPATH="/usr/local/man:$MANPATH"

# language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vi'
else
  export EDITOR='code'
fi

# compilation flags
# export ARCHFLAGS="-arch x86_64"

# iterm2
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# openssl
export DYLD_FALLBACK_LIBRARY_PATH=/usr/local/opt/openssl/lib:$DYLD_FALLBACK_LIBRARY_PATH

# Go vars
export GOPATH=$HOME/golang
export GOROOT=/usr/local/opt/go/libexec
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/binexport

# Python2 pip
export PATH="$PATH:"/Users/rwwiv/Library/Python/2*/bin

# Python3 pip
export PATH="$PATH:"/Users/rwwiv/Library/Python/3*/bin

# NVM
export NVM_DIR="$HOME/.nvm"
# Keep JIC, but load nvm using zsh-nvm which can lazy load nvm
# [ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"

# virtualenvwrapper
export WORKON_HOME="$HOME/.virtualenvs"
export VIRTUAL_ENV_DISABLE_PROMPT=0
export PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV="true"

# pyenv
_multi_ec_start "pyenv"
_multi_ec "pyenv" "init" "--path"
_multi_ec "pyenv" "init" "-"
# _multi_ec "pyenv" "virtualenv-init" "-"
_multi_ec_end "pyenv"
pyenv virtualenvwrapper
alias brew='env PATH="${PATH//$(pyenv root)\/shims:/}" brew'

# direnv
_evalcache "direnv" "hook" "zsh"

# thefuck
_evalcache "thefuck" "--alias"

# starship
export STARSHIP_LOG="error"
_evalcache "starship" "init" "zsh"

# misc
export PATH="$PATH:/usr/local/sbin"

# sed
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"

# homebrew
export HOMEBREW_GITHUB_API_TOKEN="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"
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

#llvm
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"

# aliases
alias zshconfig="code ~/.zshrc"
alias ohmyzsh="code ~/.oh-my-zsh"
alias reloadzsh="exec zsh"

# autocomplete
autoload -Uz compinit
compinit

# misc
timezsh() {
  shell=${1-$SHELL}
  for i in $(seq 1 10); do /usr/bin/time $shell -i -c exit; done
}

notice() {
    local title text sound_name
    title="${1:-"zsh"}"
    text="${2:-"Check terminal in $TERM_PROGRAM"}"
    sound_name="${3:-"Ping"}"
    osascript -e "display notification \"$text\" with title \"$title\" sound name \"$sound_name\""
}

# END, to export $PATH
typeset -U PATH
