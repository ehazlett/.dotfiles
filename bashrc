# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# prompt
export PS1="\[$(tput setaf 7)\]\u \[$(tput setaf 2)\]\W\[$(tput setaf 7)\]>\[$(tput sgr0)\] "

if [ ! -z "$ITERM_PROFILE" ]; then
    export CLICOLOR=1
    if [ -f $(brew --prefix)/etc/bash_completion  ]; then
        source $(brew --prefix)/etc/bash_completion
    fi
fi

export GOROOT=/usr/local/go
export GOPATH=~/dev/gocode
export PATH=~/bin:$PATH:~/dev/gocode/bin:/usr/local/go/bin
