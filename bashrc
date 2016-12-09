# .bashrc
VM_PATH=~/vm
VDE_NAME=vm0

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
    fi

    eval "`dircolors -b`"
    alias ls="ls --color=auto"
fi

export EDITOR=vim
export GOROOT=/usr/local/go
export GOPATH=~/dev/gocode
export PATH=~/bin:$PATH:~/dev/gocode/bin:/usr/local/go/bin:/usr/local/sbin
export PATH=$PATH:/opt/android-studio/bin
export LIBVIRT_DEFAULT_URI=qemu:///system
# hdpi
export GDK_SCALE=2

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
    virt-clone -q -o $BASE -n $NAME --auto-clone -m $mac -f $VM_PATH/$NAME.img
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

    vm_get_addr

    # remove existing if defined
    virt-xml --remove-device --filesystem all $NAME > /dev/null

    echo " -> $NAME running"
    echo "IP: $(echo $addr | awk '{ print $4; }')"
    ip=""
    addr=""
}

create-qemu() {
    SOURCE=$1
    NAME=$2
    if [ -z "$NAME" ]; then
        echo "Usage: create-qemu <source> <name> [cpus] [memory] [disk]"
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
    DISK=$5

    if [ ! -e "$VM_PATH/$NAME.qcow2" ]; then
        echo " -> cloning $SOURCE"
        qemu-img convert -O qcow2 $VM_PATH/$SOURCE.qcow2 $VM_PATH/$NAME.qcow2
    fi

    if [ ! -z "$DISK" ]; then
        echo " -> resizing $NAME"
        qemu-img resize $VM_PATH/$NAME.qcow2 $DISK > /dev/null
    fi

    generate_mac > /dev/null

    # virtfs
    echo " -> configuring virtfs"
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

    echo " -> generating start script"
    generate_mac > /dev/null
    cat << EOF > $VM_PATH/$NAME.sh
#!/usr/bin/env bash
NAME=$NAME
CPUS=$CPUS
MEM=$MEM
MAC="$MAC"
VM_PATH=$VM_PATH
VDE_NAME=$VDE_NAME

CMD="qemu-system-x86_64 -name \$NAME \\
    -enable-kvm \\
    -net nic,model=virtio,macaddr=\$MAC \\
    -drive file=\$VM_PATH/\$NAME.qcow2 \\
    -m \$MEM \\
    -monitor unix:\$VM_PATH/\$NAME.monitor,server,nowait \\
    -smp cpus=\$CPUS \\
    -virtfs local,path=\$VM_PATH/\$NAME,mount_tag=host,security_model=passthrough \\
    -vga qxl"

if [ -e "/var/run/vde2/\$VDE_NAME.ctl" ]; then
    CMD="\$CMD -net vde,sock=/var/run/vde2/\$VDE_NAME.ctl"
else
    CMD="\$CMD -net vde,sock=/var/run/vde.ctl"
fi

if [ ! -z "\$NO_DISPLAY" ]; then
    CMD="\$CMD -nographic"
fi

if [ -e "\$VM_PATH/\$NAME.save" ]; then
    SOCK=\$VM_PATH/\$NAME.monitor
    echo " -> restoring \$NAME"
    exec \$CMD -incoming "exec:gzip -c -d \$VM_PATH/\$NAME.save" > /dev/null &
    sleep 1
    until [ ! -z "\$complete" ]; do
        status=\$(echo info status | socat - UNIX-CONNECT:\$SOCK)
        echo \$status | grep -v migrate > /dev/null
        if [ \$? = 0 ]; then
            complete=1
        fi
        sleep 1
    done

    echo cont | socat - UNIX-CONNECT:\$SOCK > /dev/null
    rm \$VM_PATH/\$NAME.save
else
    exec \$CMD &
fi
EOF
    chmod +x $VM_PATH/$NAME.sh
}

start-qemu() {
    NAME=$1
    if [ -z "$NAME" ]; then
        echo "Usage: start-qemu <name>"
        return
    fi

    if [ ! -e "$VM_PATH/$NAME.sh" ]; then
        echo "ERR: $NAME does not exist"
        return
    fi

    $VM_PATH/$NAME.sh
}

stop-qemu() {
    NAME=$1
    if [ -z "$NAME" ]; then
        echo "Usage: stop-qemu <name>"
        return
    fi

    SOCK=$VM_PATH/$NAME.monitor
    if [ ! -e "$SOCK" ]; then
        echo "ERR: $NAME does not have monitor socket"
        return
    fi

    echo system_powerdown | socat - UNIX-CONNECT:$SOCK > /dev/null
}

quit-qemu() {
    NAME=$1
    if [ -z "$NAME" ]; then
        echo "Usage: quit-qemu <name>"
        return
    fi

    SOCK=$VM_PATH/$NAME.monitor
    if [ ! -e "$SOCK" ]; then
        echo "ERR: $NAME does not have monitor socket"
        return
    fi

    echo quit | socat - UNIX-CONNECT:$SOCK > /dev/null
}

save-qemu() {
    NAME=$1
    if [ -z "$NAME" ]; then
        echo "Usage: save-qemu <name>"
        return
    fi

    if [ ! -e "$VM_PATH/$NAME.monitor" ]; then
        echo "ERR: $NAME does not have monitor socket"
        return
    fi

    echo " -> saving $NAME"
    SOCK=$VM_PATH/$NAME.monitor
    echo stop | socat - UNIX-CONNECT:$SOCK > /dev/null
    echo "migrate_set_speed 4096m" | socat - UNIX-CONNECT:$SOCK > /dev/null
    echo "migrate \"exec:gzip -1 -c > $VM_PATH/$NAME.save\""  | socat - UNIX-CONNECT:$SOCK > /dev/null
    echo quit | socat - UNIX-CONNECT:$SOCK > /dev/null
    until [ ! -e "$SOCK" ]; do
        sleep 1
    done
}

delete-qemu() {
    NAME=$1
    if [ -z "$NAME" ]; then
        echo "Usage: delete-qemu <name>"
        return
    fi

    stop-qemu $NAME > /dev/null

    if [ -e "$VM_PATH/$NAME.qcow2" ]; then
        rm -f $VM_PATH/$NAME.qcow2
    fi
    if [ -e "$VM_PATH/$NAME.save" ]; then
        rm -f $VM_PATH/$NAME.save
    fi
    if [ -e "$VM_PATH/$NAME.sh" ]; then
        rm -f $VM_PATH/$NAME.sh
    fi
    if [ -e "$VM_PATH/$NAME" ]; then
        rm -rf $VM_PATH/$NAME
    fi
}

vm_get_addr() {
    # we wait a second time for the IP in case the networking service
    # is too fast and says the instance is up before provisioning is complete
    while [ -z "$addr" ]; do
        # super super super hacky to get the last vnet -- ¯\_(ツ)_/¯
        addr=$(virsh domifaddr $NAME | tail -2 | head -1 | grep vnet)
        sleep .25
    done
}

vm-connect() {
    NAME=$1
    USER=${2:-$USER}
    if [ -z "$NAME" ]; then
        echo "Usage: vm-connect <vm-name>"
        return
    fi

    vm-ip $NAME > /dev/null
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $USER@$ip
}

vm-app() {
    VM=$1
    APP=$2
    if [ -z "$VM" ] || [ -z "$APP" ]; then
        echo "Usage: vm-app <vm> <app>"
        return
    fi

    vm-ip $VM > /dev/null
    ssh -X -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $USER@$ip -- $APP
}

vm-ip() {
    NAME=$1
    if [ -z "$NAME" ]; then
        echo "Usage: vm-ip <vm-name>"
        return
    fi

    ip=$(host $NAME 127.0.0.1 2>/dev/null | grep address | awk '{ print $4; }')
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
    NAMES=$*
    if [ -z "$NAMES" ]; then
        echo "Usage: vm-delete <vm-name>"
        return
    fi

    for NAME in $NAMES; do
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
    done
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
    IFS=$'\n' read -rd '' -a vms <<<"$(ps aux | grep qemu-system-x86_64)"
    printf "%-15s%-10s%-10s\n" "NAME" "CPU" "MEMORY"
    for vm in "${vms[@]}"; do
        n=$(echo $vm | awk '{ print $13; }')
        c=$(echo $vm | awk '{ print $24; }' | awk -F'=' '{ print $2; }')
        m=$(echo $vm | awk '{ print $20; }')
        printf "%-15s%-10s%-10s\n" $n $c $m
    done
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

# run the following with each session
set_kb
