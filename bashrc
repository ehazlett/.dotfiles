# .bashrc
VM_PATH=/var/data/vm

#set -o vi
if [ -e "$HOME/Sync/home/scripts/vm.sh" ]; then
    source $HOME/Sync/home/scripts/vm.sh
fi

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# source completion
if [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
fi

# prompt
export PS1="\[$(tput setaf 7)\]\h:\u \[$(tput setaf 2)\]\W\[$(tput setaf 7)\]>\[$(tput sgr0)\] "

if [ ! -z "$ITERM_PROFILE" ]; then
    export CLICOLOR=1
    if [ -f $(brew --prefix)/etc/bash_completion  ]; then
        source $(brew --prefix)/etc/bash_completion
    fi
else
    # set keyboard repeat rate
    if [ ! -z "$DISPLAY" ]; then
        xset r rate 200 40
        xrandr --dpi 160 > /dev/null 2>&1
    fi

    eval "`dircolors -b`"
    alias ls="ls --color=auto"

    # caps to control
    XKB=$(which setxkbmap)
    if [ ! -z "$XKB" ]; then
        $XKB -option ctrl:nocaps
    fi
fi

export EDITOR=vim
export GOROOT=/usr/local/go
export GOPATH=~/dev/gocode
export PATH=~/bin:$PATH:~/dev/gocode/bin:/usr/local/go/bin
export PATH=$PATH:/opt/android-studio/bin
export LIBVIRT_DEFAULT_URI=qemu:///system

if [ -e "$HOME/.nvm" ]; then
    source $HOME/.nvm/nvm.sh
fi

# custom delete word
stty werase undef
bind '"\C-w":backward-kill-word'
bind '"\C-k":history-search-backward'
bind '"\C-j":history-search-forward'

set_wifi() {
    if [ -z "$1" ]; then
        echo "Usage: $0 <name>"
        return
    fi

    local device="wlan0"
    if [ ! -z "$2" ]; then
        device="$2"
    fi

    sudo pkill wpa_supplicant
    sudo pkill dhclient
    sudo wpa_supplicant -B -i$device -c ~/.wpa-$1.conf
    sudo dhclient -r
    sudo dhclient $device
}

switch_graphics() {
    echo "Activating..."
    updated="0"
    if [ "$1" = "nvidia" ]; then
        sudo mv /etc/modprobe.d/nvidia.disabled /etc/modprobe.d/nvidia.conf > /dev/null 2>&1
        sudo ln -sf /etc/X11/xorg.conf.nvidia /etc/X11/xorg.conf
        updated="1"
    fi

    if [ "$1" = "nouveau" ]; then
        sudo mv /etc/modprobe.d/nvidia.conf /etc/modprobe.d/nvidia.disabled > /dev/null 2>&1
        sudo ln -sf /etc/X11/xorg.conf.nouveau /etc/X11/xorg.conf
        updated="1"
    fi

    if [ $updated = "1" ]; then
        sudo update-initramfs -u > /dev/null
        echo "Updated.  Please reboot."
    fi
}

randomstr() {
    LEN=${1:-32}
    echo `date +%s%N | sha256sum | base64 | head -c $LEN | tr '[:upper:]' '[:lower:]'; echo`
}

if [ -e $HOME/google-cloud-sdk ]; then
    # The next line updates PATH for the Google Cloud SDK.
    source "$HOME/google-cloud-sdk/path.bash.inc"

    # The next line enables bash completion for gcloud.
    source "$HOME/google-cloud-sdk/completion.bash.inc"
fi

rainbowstream() {
    docker run -ti --rm \
        -v $HOME/Sync/home/config/rainbowstream/.rainbow_oauth:/root/.rainbow_oauth \
        -v $HOME/Sync/home/config/rainbowstream/.rainbow_config.json:/root/.rainbow_config.json \
        --name rainbowstream \
        jess/rainbowstream
}

rebuild_dkms() {
    ls /var/lib/initramfs-tools | sudo xargs -n1 /usr/lib/dkms/dkms_autoinstaller start
}

set_wallpaper() {
    feh --bg-scale $1
}

start_shared_dev() {
    NAME=$1
    if [ -z "$NAME" ]; then
        NAME=shared-dev
    fi
    docker run -ti \
        --name $NAME \
        -d \
        -v ~/.tmux.conf:/home/dev/.tmux.conf:ro \
        -v ~/.ssh:/home/dev/.ssh:ro \
        -v ~/.vim:/home/dev/.vim:ro \
        tmate

    # wait until ready
    sleep 3

    docker logs $NAME
}

ambassador() {
    UPSTREAM=${1:-}
    PORT=${2:-}
    NET=${3:-}
    if [ -z "$UPSTREAM" ] || [ -z "$PORT" ] || [ -z "$NET" ]; then
        echo "Usage: <CONTAINER:PORT> <PUBLIC-PORT> <NET>"
        return
    fi

    parts=(${UPSTREAM//:/ })
    CONTAINER=${parts[0]}
    CONTAINER_PORT=${parts[1]}

    if [ -z "CONTAINER" ] || [ -z "$CONTAINER_PORT" ]; then
        echo "You must specify <CONTAINER:PORT>; i.e. foo:8080"
        return
    fi

    CNT_HOST=$(docker inspect -f "{{.Config.Hostname}}" $CONTAINER)
    docker run --name ambassador-$CONTAINER-$CONTAINER_PORT -ti -d -p $PORT:$PORT --net=$NET ehazlett/ambassador -D -u $CNT_HOST:$CONTAINER_PORT -l :$PORT
}

dev() {
    CMD=${2:-/bin/bash}
    set_title "dev : $1"
    local name=dev-$1
    local dockergroup=$(cat /etc/group | grep docker | cut -d':' -f3)

    EXTRA_ARGS=""
    if [ ! -z "$SSH_AUTH_SOCK" ]; then
        EXTRA_ARGS="-v $SSH_AUTH_SOCK:$SSH_AUTH_SOCK -e SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
    fi

    docker inspect $name > /dev/null 2>&1
    if [ $? = 0 ]; then
        docker attach $name
    else
        docker run -ti --restart=always \
            -e PROJECT=$1 \
            --hostname $1 \
            --net=host \
            --name=$name \
            -v $HOME/.vim:/home/ehazlett/.vim \
            -v $HOME/.vimrc:/home/ehazlett/.vimrc \
            -v $HOME/.bashrc:/home/ehazlett/.bashrc \
            -v $HOME/.ssh/config:/home/ehazlett/.ssh/config \
            -v ~/Sync:/home/ehazlett/Sync \
            -v ~/.docker:/home/ehazlett/.docker \
            -v /var/run/docker.sock:/var/run/docker.sock $EXTRA_ARGS \
            -u $(whoami):$dockergroup \
            ehazlett/devbox $CMD
    fi
}

macdev() {
    CMD=${2:-/bin/bash}
    set_title "dev : $1"
    local name=dev-$1
    docker inspect $name > /dev/null 2>&1
    if [ $? = 0 ]; then
        docker attach $name
    else
        docker run -ti --restart=always \
            -e PROJECT=$1 \
            --net=host \
            --name=$name \
            -v $HOME/.vim:/home/ehazlett/.vim \
            -v $HOME/.vimrc:/home/ehazlett/.vimrc \
            -v $HOME/.bashrc:/home/ehazlett/.bashrc \
            -v $HOME/.ssh/config:/home/ehazlett/.ssh/config \
            -v ~/Sync:/home/ehazlett/Sync \
            -v ~/.docker:/home/ehazlett/.docker \
            -v /var/run/docker.sock:/var/run/docker.sock \
            --group-add staff \
            ehazlett/devbox $CMD
    fi
}

set_title() {
    echo -en "\033]0;$1\a"
}

# docker
lastpass() {
    echo $@
    docker run -ti --rm \
        -v $HOME/Sync/home/config/lastpass:/root/.lpass \
        --log-driver none \
        --entrypoint /bin/bash \
        ehazlett/lastpass-cli -l
}

stream_twitch() {
    INRES="1920x1080"
    OUTRES="1920x1080"
    FPS="15"
    GOP="30" # i-frame interval, should be double of FPS,
    GOPMIN="15" # min i-frame interval, should be equal to fps,
    THREADS="2"
    CBR="1000k" # constant bitrate (should be between 1000k - 3000k)
    QUALITY="libx264-ultrafast"  # one of the many FFMPEG preset
    AUDIO_RATE="44100"
    STREAM_KEY="$TWITCH_KEY"
    AUDIO="-acodec libmp3lame -ar $AUDIO_RATE"
    if [ ! -z "$DISABLE_AUDIO" ]; then
        AUDIO="$AUDIO -af \"volume=0.0\""
    fi
    SERVER="live-ord" # twitch server in Chicago, see http://bashtech.net/twitch/ingest.php for list

    ffmpeg -f x11grab -s "$INRES" -r "$FPS" -i :0.0 -f alsa -i pulse -f flv -ac 2 \
      -vcodec libx264 -g $GOP -keyint_min $GOPMIN -b:v $CBR -minrate $CBR -maxrate $CBR -pix_fmt yuv420p\
      -s $OUTRES $AUDIO -threads $THREADS -strict normal \
      -bufsize $CBR "rtmp://$SERVER.twitch.tv/app/$STREAM_KEY"
}

battery() {
    upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E 'percentage|state|to\ empty'  | sed 's/ //g' | sed 's/:/: /g'
}

photobooth() {
     fswebcam -r 1280x720 --jpeg 100 -D 1 --no-shadow --no-timestamp --no-overlay --no-banner ~/Sync/media/photo_booth/$(date +%Y-%m-%d_%H%M%S).jpg
}

generate_mac() {
    printf 'DE:AD:BE:EF:%02X:%02X\n' $((RANDOM%256)) $((RANDOM%256))
}

chrome() {
    google-chrome --high-dpi-support=1 --force-device-scale-factor=1
}

new-project() {
    NAME=$1
    if [ -z "$NAME" ]; then
        echo "Usage: new-project <username>/<project-name> (i.e. ehazlett/demo)"
        return
    fi

    parts=(${NAME//\// })
    USER=${parts[0]}
    PROJECT=${parts[1]}

    if [ -z "$PROJECT" ]; then
        echo "Usage: new-project <username>/<project-name> (i.e. ehazlett/demo)"
        return
    fi

    git clone git@github.com:ehazlett/project-base.git $PROJECT

    find $PROJECT -type f -exec sed -i "s/ehazlett/$USER/g" {} \;
    find $PROJECT -type f -exec sed -i "s/project-base/$PROJECT/g" {} \;
    mv $PROJECT/cmd/project-base $PROJECT/cmd/$PROJECT
    echo "$PROJECT" > $PROJECT/cmd/$PROJECT/.gitignore
}

docker-machine() {
    PATH=$HOME/.docker-machine-plugins:$PATH /usr/local/bin/docker-machine "$@"
}

godev() {
    NAME=$1
    export GOPATH=~/go/$NAME
    export PATH=$PATH:$GOPATH/bin
    export PROJECT=$NAME
    mkdir -p $GOPATH/{src,bin}
    echo "Go env setup: $GOPATH"
    cd $GOPATH
    set_title $NAME
}

wait_for_instance() {
    NAME=$1
    if [ -z "$NAME" ]; then
        echo "ERR: you must specify a name"
        return
    fi
    echo " -> waiting for instance to become available..."
    local up=""
    while [ -z "$up" ]; do
        up=$(virsh domifaddr $NAME | tail -2 | head -1| grep vnet)
        sleep .25
    done
}

vm-create() {
    BASE=$1
    NAME=$2
    MEM=$3
    DISK_SIZE=$4
    if [ -z "$BASE" ] || [ -z "$NAME" ]; then
        echo "Usage: vm-create <base-vm-to-clone> <name> [mem-in-mb] [disk_size]"
        return
    fi

    echo " -> cloning $BASE -> $NAME"
    mac=$(printf 'DE:AD:BE:EF:%02X:%02X\n' $((RANDOM%256)) $((RANDOM%256)))
    virt-clone -q -o $BASE -n $NAME --auto-clone -m $mac
    if [ $? != 0 ]; then
        return
    fi

    if [ ! -z "$MEM" ]; then
        echo " -> setting memory: $MEM"
        o=$(virt-xml --edit --memory $MEM $NAME)
    fi

    if [ ! -z "$DISK_SIZE" ]; then
        disk=$(virsh domblklist $NAME | grep -E "vda|hda" | awk '{ print $2;  }')
        echo " -> resizing disk: $disk -> $DISK_SIZE"
        o=$(sudo qemu-img resize $disk $DISK_SIZE)
        if [ $? != 0 ]; then
            echo " -> ERR: error resizing disk: $o"
            return
        fi
    fi

    echo " -> creating and attaching virtfs"
    host_path=$VM_PATH/$NAME
    mkdir -p $host_path

    # set hostname in shared path
    echo "$NAME" > $host_path/hostname
    # user
    echo "$USER" > $host_path/username
    SSH_KEY=${SSH_KEY:-~/.ssh/id_rsa.pub}
    if [ -e "$SSH_KEY" ]; then
        cat $SSH_KEY > $host_path/ssh_key
    fi

    # remove existing if defined
    virt-xml --remove-device --filesystem all $NAME > /dev/null

    # add new virtfs
    virt-xml --add-device --filesystem $host_path,host,type=mount,mode=passthrough $NAME > /dev/null

    echo " -> starting $NAME"
    o=$(virsh start $NAME)

    wait_for_instance $NAME

    local addr=""
    # we wait a second time for the IP in case the networking service
    # is too fast and says the instance is up before provisioning is complete
    while [ -z "$addr" ]; do
        # super super super hacky to get the last vnet -- ¯\_(ツ)_/¯
        addr=$(virsh domifaddr $NAME | tail -2 | head -1 | grep vnet)
        sleep .25
    done

    ipmask=$(echo $addr | awk '{ print $4; }')
    parts=(${ipmask//\// })

    ip=${parts[0]}
    echo " -> $NAME running"
    echo "IP: $ip"
    ip=""
    addr=""
}

vm-connect() {
    NAME=$1
    USER=${2:-$USER}
    if [ -z "$NAME" ]; then
        echo "Usage: vm-connect <vm-name>"
        return
    fi

    addr=$(virsh domifaddr $NAME | tail -2 | head -1 | grep vnet)
    ipmask=$(echo $addr | awk '{ print $4; }')
    parts=(${ipmask//\// })

    ip=${parts[0]}
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $USER@$ip
}

vm-app() {
    VM=$1
    APP=$2
    if [ -z "$VM" ] || [ -z "$APP" ]; then
        echo "Usage: vm-app <vm> <app>"
        return
    fi

    addr=$(virsh domifaddr $NAME | tail -2 | head -1 | grep vnet)
    ipmask=$(echo $addr | awk '{ print $4; }')
    parts=(${ipmask//\// })
    ip=${parts[0]}

    ssh -X -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $USER@$ip -- $APP
}

vm-ip() {
    NAME=$1
    if [ -z "$NAME" ]; then
        echo "Usage: vm-ip <vm-name>"
        return
    fi

    addr=$(virsh domifaddr $NAME | tail -2 | head -1 | grep vnet)
    ipmask=$(echo $addr | awk '{ print $4; }')
    parts=(${ipmask//\// })

    ip=${parts[0]}

    echo "$ip"
}

vm-start() {
    NAME=$1
    if [ -z "$NAME" ]; then
        echo "Usage: vm-start <vm-name>"
        return
    fi

    echo " -> starting $NAME"
    o=$(virsh start $NAME > /dev/null 2>&1)

    wait_for_instance $NAME
}

vm-stop() {
    NAME=$1
    if [ -z "$NAME" ]; then
        echo "Usage: vm-stop <vm-name>"
        return
    fi

    echo " -> stopping $NAME"
    o=$(virsh destroy $NAME > /dev/null 2>&1)
}

vm-delete() {
    NAME=$1
    if [ -z "$NAME" ]; then
        echo "Usage: vm-delete <vm-name>"
        return
    fi

    echo " -> stopping $NAME"
    o=$(virsh destroy $NAME > /dev/null 2>&1)

    echo " -> removing $NAME"
    disk_path=$(virsh domblklist $NAME | grep -E "vda|hda" | awk '{ print $2; }')
    o=$(virsh vol-delete $disk_path)
    o=$(virsh undefine $NAME)

    host_path=$VM_PATH/$NAME
    if [ -e "$host_path" ]; then
        rm -rf $host_path
    fi
}

mem-free() {
    echo $(free -m | sed 1d | head -1 | awk '{ $1 = ($7 / $2) * 100; print $1  }') %
}

runsteam() {
    LD_PRELOAD='/usr/$LIB/libstdc++.so.6 /usr/$LIB/libgcc_s.so.1 /usr/$LIB/libxcb.so.1 /usr/$LIB/libgpg-error.so' steam
}

switch_theme() {
    color=$1

    case $color in
        dark)
            cp -f ~/.dotfiles/xfce4-terminal.dark.terminalrc ~/.config/xfce4/terminal/terminalrc
            sed -i 's/set background=.*/set background=dark/g' ~/.dotfiles/vimrc
            sed -i 's/colorscheme.*/colorscheme Tomorrow-Night/g' ~/.dotfiles/vimrc
            ;;
        light)
            cp -f ~/.dotfiles/xfce4-terminal.terminalrc ~/.config/xfce4/terminal/terminalrc
            sed -i 's/set background=.*/set background=light/g' ~/.dotfiles/vimrc
            sed -i 's/colorscheme.*/colorscheme Tomorrow/g' ~/.dotfiles/vimrc
            ;;
        *)
            echo "Specify either 'dark' or 'light'"
            return
            ;;
    esac
}
