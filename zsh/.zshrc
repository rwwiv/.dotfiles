# secrets
source "$HOME/.dotfiles/zsh/secrets"

export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/.dotfiles/zsh/custom"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"

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
  zle-line-init
  zsh-autosuggestions
)

# run this before oh-my-zsh.sh
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

# load oh-my-zsh
source $ZSH/oh-my-zsh.sh

# misc functions
timezsh() {
  local shell
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

minify_img() {
  local source dest
  source="$1"
  dest="$2"
  [ -z $source ] && echo "Missing source" && return 1
  [ -z $dest ] && dest="$source"
  magick "$1" -sampling-factor 4:2:0 -quality 95% -resize 500 -define jpeg:dct-method=float "$2"
}

export_multiple() {
  val="${@[-1]}"
  arr=($@)
  unset 'arr[-1]'

  for var in "${arr[@]}"; do
    [ "$var" = "" ] && continue
    eval "export ${var}=${val}"
  done
}

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
[ -f "$HOME/.iterm2_shell_integration.zsh" ] && source "$HOME/.iterm2_shell_integration.zsh"

# openssl
export DYLD_FALLBACK_LIBRARY_PATH=/usr/local/opt/openssl/lib:$DYLD_FALLBACK_LIBRARY_PATH

# Go vars
if [ "$(uname -p)" = "arm" ]; then
  export GOPATH="$HOME/golang"
  export GOROOT=/opt/homebrew/opt/go/libexec
  export PATH="$PATH:$GOPATH/bin"
  export PATH="$PATH:$GOROOT/bin"
else
  export GOPATH="$HOME/golang"
  export GOROOT=/usr/local/opt/go/libexec
  export PATH="$PATH:$GOPATH/bin"
  export PATH="$PATH:$GOROOT/binexport"
fi

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

# gnu tools
export PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"

#llvm
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"

# java
export JAVA_DEFAULT_HOME=$(/usr/libexec/java_home)
export JAVA_11_HOME=$(/usr/libexec/java_home -v 11.0.11)
export JAVA_8_HOME=$(/usr/libexec/java_home -v 1.8.0_242)
alias java_default="export_multiple JAVA_HOME JDK_HOME $JAVA_DEFAULT_HOME"
alias java11="export_multiple JAVA_HOME JDK_HOME $JAVA_11_HOME"
alias java8="export_multiple JAVA_HOME JDK_HOME $JAVA_8_HOME"
#set default to Java 17
java_default

# aliases
alias zshconfig="code ~/.zshrc"
alias ohmyzsh="code ~/.oh-my-zsh"
alias reloadzsh="exec zsh"

# autocomplete
autoload -Uz compinit
compinit

# KEEP AT END
# export any unexported $PATH stuff
typeset -U PATH
