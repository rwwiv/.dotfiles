fish_add_path /opt/homebrew/bin

set BREW_PREFIX "$(brew --prefix)"

# manpath
set -xg MANPATH "$BREW_PREFIX/man:$MANPATH"

# language environment
set -xg LANG en_US.UTF-8

# Preferred editor for local and remote sessions
if [ -n $SSH_CONNECTION ]
    set -xg EDITOR vi
else
    set -xg EDITOR code
end

# compilation flags
if [ $(uname -m) = arm64 ]
    set -xg ARCHFLAGS "-arch aarch64"
else
    set -xg ARCHFLAGS "-arch x86_64"
end


# iterm2
# [ -f "$HOME/.iterm2_shell_integration.zsh" ] && source "$HOME/.iterm2_shell_integration.zsh"


# openssl
set -xg DYLD_FALLBACK_LIBRARY_PATH "$BREW_PREFIX/opt/openssl/lib:$DYLD_FALLBACK_LIBRARY_PATH"
set -xg PATH "$BREW_PREFIX/opt/openssl@3/bin:$PATH"
set -xg LDFLAGS "$LDFLAGS -L$BREW_PREFIX/opt/openssl@3/lib"
set -xg CPPFLAGS "$CPPFLAGS -I$BREW_PREFIX/opt/openssl@3/include"

# zlib
set -xg LDFLAGS "$LDFLAGS -L$BREW_PREFIX/opt/zlib/lib"
set -xg CFLAGS "$CPPFLAGS -I$BREW_PREFIX/opt/zlib/include"
set -xg PKG_CONFIG_PATH "$BREW_PREFIX/opt/zlib/lib/pkgconfig"

# xcrun
# set -xg LDFLAGS "$LDFLAGS -L$(xcrun --show-sdk-path)/usr/lib"
# set -xg CPPFLAGS "$CPPFLAGS -I$(xcrun --show-sdk-path)/usr/include"

# Go vars
set -xg GOPATH "$HOME/golang"
set -xg GOROOT "$BREW_PREFIX/opt/go/libexec"
set -xg PATH "$PATH:$GOPATH/bin"
set -xg PATH "$PATH:$GOROOT/bin"

# misc
set -xg PATH "$PATH:/usr/local/sbin"

#llvm
set -xg PATH "$BREW_PREFIX/opt/llvm/bin:$PATH"
set -xg LDFLAGS "$LDFLAGS -L$BREW_PREFIX/opt/llvm/lib"
set -xg CPPFLAGS "$CPPFLAGS -I$BREW_PREFIX/opt/llvm/include"

# postgres
set -xg PATH "$BREW_PREFIX/opt/libpq/bin:$PATH"
set -xg PATH "$BREW_PREFIX/opt/postgresql@14/bin:$PATH"

# homebrew
set -xg HOMEBREW_NO_ENV_HINTS true

# pico sdk
set -xg PICO_SDK_PATH "$HOME/repos/pico-sdk"

# llvm 14
set -xg PATH "$BREW_PREFIX/opt/llvm@14/bin:$PATH"
set -xg LDFLAGS "$LDFLAGS -L$BREW_PREFIX/opt/llvm@14/lib"
set -xg CPPFLAGS "$CPPFLAGS -I$BREW_PREFIX/opt/llvm@14/include"

# Python
set -xg PATH "$PATH:/Users/rwwiv/.local/bin"

# Python2 pip
set -xg PATH "$PATH:/Users/rwwiv/Library/Python/2*/bin"

# Python3 pip
set -xg PATH "$PATH:/Users/rwwiv/Library/Python/3*/bin"

# NVM
set -xg NVM_DIR "$HOME/.nvm"
starship init fish | source

# thefuck
thefuck --alias | source

# direnv
direnv hook fish | source

# pyenv
pyenv init --path | source
pyenv init - | source
# pyenv virtualenvwrapper
alias brew="env PATH=(string replace (pyenv root)/shims '' \"\$PATH\") brew"

for bindir in "$BREW_PREFIX/opt/"*"/bin"
    set -xg PATH "$bindir:$PATH"
end
for mandir in "$BREW_PREFIX/opt/"*"/libexec/gnuman"
    set -xg MANPATH "$mandir:$MANPATH"
end
for bindir in "$BREW_PREFIX/opt/"*"/libexec/gnubin"
    set -xg PATH "$bindir:$PATH"
end
for mandir in "$BREW_PREFIX/opt/"*"/share/man/man1"
    set -xg MANPATH "$mandir:$MANPATH"
end
