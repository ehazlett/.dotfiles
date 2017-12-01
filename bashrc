# .bashrc
VM_PATH=~/vm
VDE_NAME=vm0
OS=linux
export GPG_TTY=$(tty)

DOCKER_IMAGE=${DOCKER_IMAGE:-ehazlett/docker:17.06.2-ce}
DOCKER_VOLUME_PREFIX=docker-node

if [ ! -z "$ITERM_PROFILE" ]; then
    OS=osx
fi

if [ $OS = "linux" ]; then
    if [ -e /sys/class/dmi/id/sys_vendor ]; then
        VENDOR=$(cat /sys/class/dmi/id/sys_vendor)
    fi
fi

#set -o vi
if [ -e "$HOME/sync/home/scripts/vm.sh" ]; then
    source $HOME/sync/home/scripts/vm.sh
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
export PS1='\u@\h \[\033[01;32m\]\W\[\033[0m\]> '

if [ $OS = "osx" ]; then
    export CLICOLOR=1
    if [ -f $(brew --prefix)/etc/bash_completion  ]; then
        source $(brew --prefix)/etc/bash_completion
    fi
    export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
    export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
    eval "`dircolors -b`"
    alias ls="ls --color=auto"
    alias tmux="tmux -2"
else
    # set keyboard repeat rate
    if [ ! -z "$DISPLAY" ]; then
        xset r rate 200 40
    fi

    eval "`dircolors -b`"
    alias ls="ls --color=auto"
fi

export EDITOR=vim
if [ -e "$HOME/.nix-profile/share/go" ]; then
    export GOROOT=$HOME/.nix-profile/share/go
else
    export GOROOT=/usr/local/go
fi
export GOPATH=$HOME/go
export PATH=~/bin:$PATH:~/go/bin:/usr/local/go/bin:/usr/local/sbin
# chrome os
if [ ! -z "$ANDROID_ROOT" ]; then
    export GOROOT="/data/data/com.termux/usr/lib/go"
fi
# android
export PATH=$PATH:/opt/android-studio/bin:~/Android/Sdk/platform-tools
export LIBVIRT_DEFAULT_URI=qemu:///system
# hdpi
#export GDK_SCALE=2

if [ -e "$HOME/.nvm" ]; then
    source $HOME/.nvm/nvm.sh
fi

## custom delete word
#stty werase undef
#bind '"\C-w":backward-kill-word'
#bind '"\C-k":history-search-backward'
#bind '"\C-j":history-search-forward'

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

docker-cloud() {
    SWARM=$1
    if [ -z "$SWARM" ]; then
        echo "Usage: docker-cloud <SWARM-NAME>"
        return
    fi
    docker run --rm -ti -v /var/run/docker.sock:/var/run/docker.sock -e DOCKER_HOST dockercloud/client $SWARM
}

start_qemu() {
    NAME=$1
    if [ -z "$NAME" ]; then
        echo "Usage: $0 <name>"
        exit 1
    fi
    CPUS=$2
    if [ -z "$CPUS" ]; then
        CPUS=1
    fi
    MEM=$3
    if [ -z "$MEM" ]; then
        MEM=512
    fi
    generate_mac
    sudo nohup qemu-system-x86_64 -name $NAME -enable-kvm -net nic,model=virtio,macaddr=$MAC -net vde -drive file=~/vm/$NAME.img -m $MEM -smp cpus=$CPUS -vga qxl > /dev/null &
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
    MAC=$(printf '52:54:BE:EF:%02X:%02X\n' $((RANDOM%256)) $((RANDOM%256)))
    echo $MAC
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
    SOURCE=$1
    NAME=$2
    if [ -z "$NAME" ]; then
        echo "Usage: vm-create <source> <name> [cpus] [memory] [disk-size]"
        return
    fi
    CPUS=$3
    if [ -z "$CPUS" ]; then
        CPUS=1
    fi
    MEM=$4
    if [ -z "$MEM" ]; then
        MEM=512
    fi
    SIZE=$5

    # virtfs
    VIRTFS_PATH=$VM_PATH/$NAME
    mkdir -p $VIRTFS_PATH
    # set hostname in shared path
    echo "$NAME" > $VIRTFS_PATH/hostname
    # user
    echo "$USER" > $VIRTFS_PATH/username
    SSH_KEY=${SSH_KEY:-~/.ssh/id_rsa.pub}
    if [ -e "$SSH_KEY" ]; then
        cat $SSH_KEY > $VIRTFS_PATH/ssh_key
    fi

    # clone
    virt-clone -q -o $SOURCE --auto -n $NAME

    DISK=$(virsh domblklist $NAME | grep vda | awk '{ print $2;  }')
    if [ ! -z "$SIZE" ]; then
        sudo qemu-img resize $DISK $SIZE > /dev/null
    fi

    # edit
    virt-xml --add-device --filesystem source=$VIRTFS_PATH,target=host,type=mount $NAME > /dev/null

    virt-xml --edit --vcpus $CPUS $NAME > /dev/null
    virt-xml --edit --memory $MEM $NAME > /dev/null

    vm-start $NAME
}

vm-start() {
    NAME=$1
    if [ -z "$NAME" ]; then
        echo "Usage: vm-start <name>"
        return
    fi

    virsh start $NAME
}

vm-stop() {
    NAME=$1
    if [ -z "$NAME" ]; then
        echo "Usage: vm-stop <name>"
        return
    fi

    virsh shutdown $NAME
}

vm-kill() {
    NAME=$1
    if [ -z "$NAME" ]; then
        echo "Usage: vm-kill <name>"
        return
    fi

    virsh destroy $NAME
}

vm-delete() {
    NAME=$1
    if [ -z "$NAME" ]; then
        echo "Usage: vm-delete <name>"
        return
    fi

    $(virsh dumpxml $NAME > /dev/null 2>&1)
    if [ $? -ne 0 ]; then
        return
    fi

    echo -n "Delete $NAME (VM and all content will be removed)? (y/n): "
    read CONFIRM
    if [ "$CONFIRM" != "y" ]; then
        return
    fi

    virsh destroy $NAME > /dev/null 2>&1

    SNAPSHOTS=$(virsh snapshot-list --name $NAME)
    readarray -t snaps <<<"$SNAPSHOTS"
    for snap in "${snaps[@]}";  do
        # HACK to work around empty line in snapshot list output
        if [ ! -z "$snap" ]; then
            virsh snapshot-delete --snapshotname "$snap" $NAME > /dev/null
        fi
    done

    DISK=$(virsh domblklist $NAME | grep vda | awk '{ print $2;  }')

    virsh undefine $NAME > /dev/null

    if [ ! -z "$DISK" ] && [ -f $DISK ]; then
        sudo rm -rf $DISK
    fi
}

vm-connect() {
    NAME=$1
    APP_USER=${APP_USER:-root}
    if [ -z "$NAME" ]; then
        echo "Usage: vm-connect <vm-name>"
        return
    fi

    ssh -t -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $APP_USER@$NAME.vm.int
    unset APP_USER
}

vm-app() {
    NAME=$1
    APP=$2
    APP_USER=${APP_USER:-user}
    if [ -z "$NAME" ] || [ -z "$APP" ]; then
        echo "Usage: vm-app <vm-name> <app>"
        return
    fi

    ssh -t -Y -o StrictHostKeyChecking=no -o Compression=no -o UserKnownHostsFile=/dev/null $APP_USER@$NAME.vm.int -- PULSE_SERVER=192.168.100.1 $APP
    unset APP_USER
}

mem-free() {
    echo $(free -m | sed 1d | head -1 | awk '{ $1 = ($7 / $2) * 100; print $1  }') %
}

runsteam() {
    LD_PRELOAD='/usr/$LIB/libstdc++.so.6 /usr/$LIB/libgcc_s.so.1 /usr/$LIB/libxcb.so.1 /usr/$LIB/libgpg-error.so' steam
}

switch_theme() {
    color=$1
    font="Inconsolata 10"

    if [ "$VENDOR" = "Dell Inc." ]; then
        font="Inconsolata 12"
    fi

    xfcetarget=~/.config/xfce4/terminal/terminalrc
    tmpname=/tmp/terminalrc.tmp

    case $color in
        dark)
            cp -f ~/.dotfiles/xfce4-terminal.dark.terminalrc $tmpname
            sed -i 's/colorscheme.*/colorscheme Tomorrow-Night/g' ~/.dotfiles/vimrc
            ;;
        light)
            cp -f ~/.dotfiles/xfce4-terminal.terminalrc $tmpname
            sed -i 's/colorscheme.*/colorscheme Tomorrow/g' ~/.dotfiles/vimrc
            ;;
        *)
            echo "Specify either 'dark' or 'light'"
            return
            ;;
    esac
    # set the font based upon vendor; this is due to the different resolutions
    # of each machine. sigh.
    sed -i "s/FontName=.*/FontName=$font/g" $tmpname
    mv $tmpname $xfcetarget

    # do a final touch as there is a race in the config detection where
    # you get a bad theme and have to refresh
    sleep 0.250
    touch ~/.config/xfce4/terminal/terminalrc
}

wm-vm() {
    VM=$1

    if [ -z "$VM" ]; then
        echo "Usage: vm-vm <name>"
        exit 1
    fi

    for i in $(seq 2 20); do
        $(Xephyr :${i} -ac -noreset -dpi 200 -screen 3200x1800 -query $(vm-ip ${VM}))
        if [ $? -eq 0  ]; then
            break
        fi
    done
}

vm-update() {
    UPGRADE=""
    case $1 in
        "")
            UPGRADE="upgrade"
            ;;
        "dist-upgrade")
            UPGRADE="dist-upgrade"
            ;;
        *)
            echo "Usage: $0 [dist-upgrade]"
            exit 1
            ;;
    esac
    NAMES=$(virsh list --state-running --name)
    hosts_arg=""
    for NAME in $NAMES; do
        if [ ! -z "$NAME" ]; then
            ip=$(vm-ip $NAME)
            hosts_arg="$hosts_arg --host $ip"
        fi
    done

    slex -u root $hosts_arg apt update
    slex -u root $hosts_arg apt -y $UPGRADE
}

vm-list() {
    virsh list --all
}

vm-cmd() {
    NAMES=$(virsh list --state-running --name)
    hosts_arg=""
    for NAME in $NAMES; do
        if [ ! -z "$NAME" ]; then
            ip=$(vm-ip $NAME)
            hosts_arg="$hosts_arg --host $ip"
        fi
    done

    slex -u root $hosts_arg $*
}


set_kb() {
    if [ -z "$DISPLAY" ]; then
        return
    fi
    MODE=$1
    # caps to control
    XKB=$(which setxkbmap)
    if [ ! -z "$XKB" ]; then
        $XKB -layout us
        $XKB -option ctrl:nocaps
    fi

    if [ "$MODE" = "hhkb" ] || [ -e $HOME/.hhkb ] || [ ! -z "$HHKB" ]; then
        xmodmap -e 'clear mod1'
        xmodmap -e 'clear mod4'
        xmodmap -e 'keycode 133 = Alt_L Meta_L'
        xmodmap -e 'keycode 64 = Super_L'
        xmodmap -e 'add mod1 = Alt_L Meta_L'
        xmodmap -e 'add mod4 = Super_L'
    fi
}

set_display() {
    xrandr --newmode "2560x1440" 311.31  2560 2744 3024 3488  1440 1441 1444 1490  -HSync +Vsync
    xrandr --addmode eDP-1 2560x1440
    xrandr --output eDP-1 --mode 2560x1440
    xrandr --dpi 160
    i3-msg reload > /dev/null
    i3-msg restart > /dev/null
    feh --bg-scale ~/.wallpaper
}

dev-container() {
    NAME=$1
    if [ -z "$NAME" ]; then
        echo "Usage: dev-container <NAME>"
        return
    fi
    echo "Creating volume for $NAME"
    docker volume create -d local $NAME > /dev/null 2>&1
    echo "Starting container for $NAME"
    docker run -d \
        -ti \
        --name $NAME \
        --privileged \
        -v $NAME:/home/hatter \
        -v /var/run/docker.sock:/var/run/docker.sock \
        --net=host \
        ehazlett/dev bash
    echo "$NAME created.  To use, run"
    echo "  docker exec -ti $NAME bash"
}

start-docker-node() {
    NODE=$1
    NETWORK=$2
    if [ -z "$NODE" ]; then
        echo "Usage: start-docker-node <name> [network]"
        return
    fi

    if [ -z "$NETWORK" ]; then
        NETWORK=${NODE}
        docker network create ${NETWORK}
    fi

    VOL_NAME=${DOCKER_VOLUME_PREFIX}-${NODE}
    docker volume create -d local ${VOL_NAME}
    docker run \
        --privileged \
        --net ${NETWORK} \
        --name ${NODE} \
        --hostname ${NODE} \
        --tmpfs /run \
        -v /lib/modules:/lib/modules:ro \
        -v ${VOL_NAME}:/var/lib/docker \
        -d \
        ${DOCKER_IMAGE} -H unix:// -s overlay2 ${DOCKER_ARGS}
    while true; do
        RES=$(docker exec -ti ${NODE} docker -v)
        if [ $? -eq 0 ]; then
            break
        fi
        sleep .5
    done
}

stop-docker-node() {
    NODE=$1
    NETWORK=$2
    if [ -z "$NODE" ]; then
        echo "Usage: stop-docker-node <name> [network]"
        return
    fi

    if [ -z "$NETWORK" ]; then
        NETWORK=${NODE}
    fi

    VOL_NAME=${DOCKER_VOLUME_PREFIX}-${NODE}
    docker rm -fv ${NODE}
    docker volume rm ${VOL_NAME}
    docker network rm $NETWORK
}

alias alert='notify-send -t 5000 --urgency=low -i "$([ $? = 0  ] && echo terminal || echo error)" "Finished" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# run the following with each session
set_kb
