# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export GOROOT=/usr/local/go
export GOPATH=~/dev/gocode
export PATH=~/bin:$PATH:~/dev/gocode/bin:/usr/local/go/bin
