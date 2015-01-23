# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# prompt
export PS1="\[$(tput setaf 7)\]\u \[$(tput setaf 2)\]\W\[$(tput setaf 7)\]>\[$(tput sgr0)\] "

if [ ! -z "$ITERM_PROFILE" ]; then
    export CLICOLOR=1
fi

export GOROOT=/usr/local/go
export GOPATH=~/dev/gocode
export PATH=~/bin:$PATH:~/dev/gocode/bin:/usr/local/go/bin

function set_wifi() {
    if [ -z "$1" ]; then
        echo "Usage: $0 <name>"
        return
    fi

    sudo wpa_supplicant -B -iwlan0 -c ~/.wpa-$1.conf
    sudo dhclient wlan0 &
}
