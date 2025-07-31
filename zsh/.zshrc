# secrets
source "$HOME/.dotfiles/zsh/secrets"
source "$HOME/.dotfiles/zsh/local.zsh"

# set max open files
FD_LIMIT=10240
ulimit -S -n $FD_LIMIT

unsetopt BEEP

export ZSH_CUSTOM="${HOME}/.dotfiles/zsh/custom"

if type brew &>/dev/null; then
  BREW_PREFIX="$(brew --prefix)"  # Set homebrew prefix once
  FPATH="${BREW_PREFIX}/share/zsh/site-functions:${FPATH}"
fi

export COMPLETION_WAITING_DOTS="true"
export DISABLE_UNTRACKED_FILES_DIRTY="true"
# export NVM_LAZY_LOAD=true
# export NVM_COMPLETION=true
# export NVM_AUTO_USE=true

# antigen
source "${HOME}/.dotfiles/zsh/.antigen.zsh"
antigen init "${HOME}/.antigenrc"

zstyle ':completion:*' menu select

# misc functions
{
  timezsh() {
    local shell
    shell=${1-$SHELL}
    for _ in $(seq 1 10); do /usr/bin/time "$shell" -i -c exit; done
  }

  notice() {
    local title text sound_name
    title="${1:-"zsh"}"
    text="${2:-"Check terminal in $TERM_PROGRAM"}"
    sound_name="${3:-"Ping"}"
    osascript -e "display notification \"$text\" with title \"$title\" sound name \"$sound_name\""
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
  export EDITOR='code --wait'
fi

# iterm2
[[ -f "$HOME/.iterm2_shell_integration.zsh" ]] && source "$HOME/.iterm2_shell_integration.zsh"

# pico sdk
export PICO_SDK_PATH="$HOME/projects/pico-sdk"

# esp-rs
[[ -f "$HOME/export-esp.sh" ]] && . "$HOME/export-esp.sh"

# NVM
# export NVM_DIR="$HOME/.nvm"
# Keep JIC, but load nvm using zsh-nvm which can lazy load nvm
# [ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"

if type brew &>/dev/null; then
  # brew dependent functions
  {
    minify_img() {
      local source dest
      source="$1"
      dest="$2"
      [ -z "$source" ] && echo "Missing source" && return 1
      [ -z "$dest" ] && dest="$source"

      magick "$source" -sampling-factor 4:2:0 -quality 95% -resize 500 -define jpeg:dct-method=float "$dest"
    }

    create_dev_db() {
      local user db
      user="$1"
      pass="$2"
      db="$3"
      [ -z "$user" ] && echo "Missing user" && return 1
      [ -z "$pass" ] && echo "Missing password" && return 1
      [ -z "$db" ] && db="$user"

      psql -c "create role ${user} with createdb encrypted password '${pass}' login;"
      psql -c "alter user ${user} superuser;"
      psql -c "create database ${db} with owner ${user};"
    }

    use_go() {
      local version
      version="$1"
      if [[ "$version" == "" ]] || [[ "$version" == "default" ]]; then {
        version=""
      }; else {
        version="@${version}"
      }; fi

      export GOROOT="${BREW_PREFIX}/opt/go${version}/libexec"
      export PATH="$GOROOT/bin:$PATH"
    }
  }

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
  export GOROOT="${BREW_PREFIX}/opt/go/libexec"
  export PATH="$GOPATH/bin:$PATH"
  export PATH="$GOROOT/bin:$PATH"

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

  # lunarvim
  export PATH="$HOME/.local/bin":"$PATH"

  # dotnet
  export DOTNET_ROOT="/opt/homebrew/opt/dotnet/libexec"

  # gcloud
  source "${BREW_PREFIX}/share/google-cloud-sdk/path.zsh.inc"
  source "${BREW_PREFIX}/share/google-cloud-sdk/completion.zsh.inc"

  if command -v drone &> /dev/null; then
    export DRONE_SERVER=https://drone.grafana.net
    export DRONE_TOKEN=HpcEIzIbty1ummbXfdqG3CfB0E2ozOBB
  fi

  # aliases
  alias zshconfig="code ~/.zshrc"
  alias ohmyzsh="code ~/.oh-my-zsh"
  alias reloadzsh="exec zsh"
  # alias code="code -n"
  alias gpg="gpg2"
  alias lg="lazygit"

  # fnm
  eval "$(fnm env)" > /dev/null

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

  alias jsonnet="jrsonnet"
fi

# aliases
alias clear='clear && printf "\e[3J"';

# autocomplete
fpath+="/opt/homebrew/share/zsh/site-functions"
autoload -Uz compinit && compinit


# KEEP AT END
# export any unexported $PATH stuff
typeset -U PATH

