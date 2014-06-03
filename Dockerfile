from ubuntu:14.04
maintainer evan hazlett <ejhazlett@gmail.com>
run apt-get update
env DEBIAN_FRONTEND noninteractive
run apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    dnsutils \
    git-core \
    make \
    bc \
    man-db \
    python \
    python-dev \
    autoconf \
    gawk \
    libncurses5-dev \
    libssl-dev \
    mercurial \
    aufs-tools \
    libbz2-dev \
    libreadline-dev \
    gettext \
    htop \
    tmux \
    wget \
    sysstat \
    curl \
    sudo \
    socat \
    ctags \
    libsqlite3-dev \
    libdevmapper-dev \
    rng-tools \
    s3cmd \
    apache2-utils \
    libcurl4-openssl-dev

# base config
run useradd dev
run echo "ALL            ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers
run echo "US/Eastern" > /etc/timezone
run dpkg-reconfigure locales && locale-gen C.UTF-8 && /usr/sbin/update-locale LANG=C.UTF-8

# vim
run hg clone https://vim.googlecode.com/hg/ /tmp/vim
run (cd /tmp/vim && ./configure --prefix=/usr/local --enable-gui=no --without-x --disable-nls --enable-multibyte --with-tlib=ncurses --enable-pythoninterp --with-features=huge && make install)

# fish shell
run (cd /tmp && wget http://fishshell.com/files/2.1.0/fish-2.1.0.tar.gz)
run (cd /tmp && tar zxf fish-2.1.0.tar.gz && cd fish-2.1.0 && ./configure --prefix=/usr/local && make install)
run echo '/usr/local/bin/fish' | tee -a /etc/shells
run chsh -s /usr/local/bin/fish dev

# go
run wget http://go.googlecode.com/files/go1.2.1.linux-amd64.tar.gz -O /tmp/go.tar.gz
run tar -C /usr/local -xvf /tmp/go.tar.gz

workdir /home/dev
env HOME /home/dev
env LC_ALL C.UTF-8
add . $HOME/.dotfiles
run (cd $HOME/.dotfiles && git submodule init)
run (cd $HOME/.dotfiles && git submodule update --recursive)

# env config
run mkdir -p $HOME/.ssh
run mkdir -p $HOME/.config/fish
run ln -sf $HOME/.dotfiles/vim $HOME/.vim
run ln -sf $HOME/.dotfiles/vimrc $HOME/.vimrc
# HACK: need to sed out the colorscheme to prevent the vim launch errors to install plugins
run sed -i 's/^colorscheme.*//g' $HOME/.dotfiles/vimrc
run vim +PluginInstall +qall > /dev/null 2>&1
run (cd $HOME/.dotfiles && git checkout vimrc)
run ln -sf $HOME/.dotfiles/gitconfig $HOME/.gitconfig
run ln -sf $HOME/.dotfiles/ssh_config $HOME/.ssh/config
run chown dev:dev $HOME/.ssh/config
run chmod 600 $HOME/.ssh/config
run ln -sf $HOME/.dotfiles/known_hosts $HOME/.ssh/known_hosts
run ln -sf $HOME/.dotfiles/tmux.conf $HOME/.tmux.conf
run ln -sf $HOME/.dotfiles/config.fish $HOME/.config/fish/config.fish
run mkdir -p $HOME/dev/gocode

# go config
env GOROOT /usr/local/go
env GOPATH $HOME/dev/gocode
env PATH /usr/local/go/bin:$GOPATH/bin:$PATH

# go tools
run go get github.com/tools/godep

# latest docker binary
run wget https://get.docker.io/builds/Linux/x86_64/docker-latest -O /usr/local/bin/docker
run chmod +x /usr/local/bin/docker

run chown -R dev:dev $HOME/
user dev
cmd ["/usr/local/bin/fish"]
