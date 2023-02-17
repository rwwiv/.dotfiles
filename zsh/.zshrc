# secrets
source "$HOME/.dotfiles/zsh/secrets"

unsetopt BEEP

# antigen
{
  source ${HOME}/.antigen.zsh

  export COMPLETION_WAITING_DOTS="true"
  export DISABLE_UNTRACKED_FILES_DIRTY="true"
  export NVM_LAZY_LOAD=true
  export NVM_COMPLETION=true
  export NVM_AUTO_USE=true


  if type brew &>/dev/null; then
    BREW_PREFIX="$(brew --prefix)"  # Set homebrew prefix once
    FPATH="${BREW_PREFIX}/share/zsh/site-functions:${FPATH}"
  fi

  antigen init ${HOME}/.antigenrc
}

zstyle ':completion:*' menu select

# misc functions
{
  timezsh() {
    local shell
    shell=${1-$SHELL}
    for _ in $(seq 1 10); do /usr/bin/time $shell -i -c exit; done
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
}

# manpath
export MANPATH="${BREW_PREFIX}/man:$MANPATH"

# language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vi'
else
  export EDITOR='code'
fi

# iterm2
[[ -f "$HOME/.iterm2_shell_integration.zsh" ]] && source "$HOME/.iterm2_shell_integration.zsh"

# pico sdk
export PICO_SDK_PATH="$HOME/projects/pico-sdk"

# Python
export PATH="$PATH:/Users/rwwiv/.local/bin"

# Python2 pip
export PATH="$PATH:/Users/rwwiv/Library/Python/2*/bin"

# Python3 pip
export PATH="$PATH:/Users/rwwiv/Library/Python/3*/bin"

# esp-rs
[[ -f "$HOME/export-esp.sh" ]] && . "$HOME/export-esp.sh"

# NVM
export NVM_DIR="$HOME/.nvm"
# Keep JIC, but load nvm using zsh-nvm which can lazy load nvm
# [ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"

if type brew &>/dev/null; then
  # openssl
  export DYLD_FALLBACK_LIBRARY_PATH="${BREW_PREFIX}/opt/openssl/lib:$DYLD_FALLBACK_LIBRARY_PATH"
  export PATH="${BREW_PREFIX}/opt/openssl@3/bin:$PATH"
  export LDFLAGS="$LDFLAGS -L${BREW_PREFIX}/opt/openssl@3/lib"
  export CPPFLAGS="$CPPFLAGS -I${BREW_PREFIX}/opt/openssl@3/include"

  # zlib
  export LDFLAGS="$LDFLAGS -L${BREW_PREFIX}/opt/zlib/lib"
  export CFLAGS="$CPPFLAGS -I${BREW_PREFIX}/opt/zlib/include"
  export PKG_CONFIG_PATH="${BREW_PREFIX}/opt/zlib/lib/pkgconfig"

  # xcrun
  # export LDFLAGS="$LDFLAGS -L$(xcrun --show-sdk-path)/usr/lib"
  # export CPPFLAGS="$CPPFLAGS -I$(xcrun --show-sdk-path)/usr/include"

  # Go vars
  export GOPATH="$HOME/golang"
  export PATH="$PATH:$GOPATH/bin"

  # misc
  export PATH="$PATH:/usr/local/sbin"

  #llvm
  export PATH="${BREW_PREFIX}/opt/llvm/bin:$PATH"
  export LDFLAGS="$LDFLAGS -L${BREW_PREFIX}/opt/llvm/lib"
  export CPPFLAGS="$CPPFLAGS -I${BREW_PREFIX}/opt/llvm/include"

  # postgres
  export PATH="${BREW_PREFIX}/opt/libpq/bin:$PATH"
  export PATH="${BREW_PREFIX}/opt/postgresql@14/bin:$PATH"

  # homebrew
  export HOMEBREW_NO_ENV_HINTS="true"

  # avr-gcc 8
  export PATH="${BREW_PREFIX}/opt/avr-gcc@8/bin:$PATH"

  # gnu tools
  # for bindir in "${BREW_PREFIX}/opt/"*"/bin"; do export PATH="$bindir:$PATH"; done
  # for mandir in "${BREW_PREFIX}/opt/"*"/share/man/man1"; do export MANPATH="$mandir:$MANPATH"; done

  for mandir in "${BREW_PREFIX}/opt/"*"/libexec/gnuman"; do export MANPATH="$mandir:$MANPATH"; done
  for bindir in "${BREW_PREFIX}/opt/"*"/libexec/gnubin"; do export PATH="$bindir:$PATH"; done

  # sdkman
  export SDKMAN_DIR="${BREW_PREFIX}/opt/sdkman-cli/libexec"
  [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
fi

# pyenv
_evalcache "pyenv" "init" "-"
if type brew &>/dev/null; then alias brew='env PATH="${PATH//$(pyenv root)\/shims:/}" brew'; fi

# direnv
_evalcache "direnv" "hook" "zsh"

# thefuck
_evalcache "thefuck" "--alias"

# starship
export STARSHIP_LOG="error"
_evalcache "starship" "init" "zsh"

# aliases
alias zshconfig="code ~/.zshrc"
alias ohmyzsh="code ~/.oh-my-zsh"
alias reloadzsh="exec zsh"
# alias code="code -n"
alias clear='clear && printf "\e[3J"';

# autocomplete
autoload -Uz compinit && compinit

# KEEP AT END
# export any unexported $PATH stuff
typeset -U PATH
