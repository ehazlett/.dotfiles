FROM ubuntu:14.04
MAINTAINER evan hazlett <ejhazlett@gmail.com>
RUN apt-get update
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get install -y \
    build-essential \
    gcc \
    dnsutils \
    git-core \
    make \
    bc \
    bzr \
    man-db \
    locales \
    python \
    python-dev \
    python-setuptools \
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
RUN useradd dev
RUN echo "ALL            ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN cp /usr/share/zoneinfo/America/Indianapolis /etc/localtime && \
    dpkg-reconfigure locales && \
    locale-gen en_US.UTF-8 && \
    /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# vim
RUN hg clone https://vim.googlecode.com/hg/ /tmp/vim
RUN (cd /tmp/vim && ./configure --prefix=/usr/local --enable-gui=no --without-x --disable-nls --enable-multibyte --with-tlib=ncurses --enable-pythoninterp --with-features=huge && make install)

# fish shell
RUN (cd /tmp && wget http://fishshell.com/files/2.1.1/fish-2.1.1.tar.gz && \
    tar zxf fish-2.1.1.tar.gz && \
    cd fish-2.1.1 && \
    ./configure --prefix=/usr/local && \
    make install && \
    rm /tmp/fish-2.1.1.tar.gz && \
    echo '/usr/local/bin/fish' | tee -a /etc/shells && \
    chsh -s /usr/local/bin/fish dev)

# go
RUN wget https://storage.googleapis.com/golang/go1.3.3.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
    tar -C /usr/local -xvf /tmp/go.tar.gz && rm /tmp/go.tar.gz

WORKDIR /home/dev
ENV HOME /home/dev
ENV LC_ALL en_US.UTF-8
COPY . $HOME/.dotfiles
RUN (cd $HOME/.dotfiles && git submodule init && git submodule update --recursive)

# env config
RUN mkdir -p $HOME/.ssh && \
    mkdir -p $HOME/.config/fish && \
    ln -sf $HOME/.dotfiles/vim $HOME/.vim && \
    ln -sf $HOME/.dotfiles/vimrc $HOME/.vimrc && \
    sed -i 's/^colorscheme.*//g' $HOME/.dotfiles/vimrc && \
    vim +PluginInstall +qall > /dev/null 2>&1

RUN (cd $HOME/.dotfiles && git checkout vimrc && \
    ln -sf $HOME/.dotfiles/gitconfig $HOME/.gitconfig && \
    ln -sf $HOME/.dotfiles/ssh_config $HOME/.ssh/config && \
    chown dev:dev $HOME/.ssh/config && \
    chmod 600 $HOME/.ssh/config && \
    ln -sf $HOME/.dotfiles/known_hosts $HOME/.ssh/known_hosts && \
    ln -sf $HOME/.dotfiles/tmux.conf $HOME/.tmux.conf && \
    ln -sf $HOME/.dotfiles/config.fish $HOME/.config/fish/config.fish && \
    mkdir -p $HOME/dev/gocode)

# go config
ENV GOROOT /usr/local/go
ENV GOPATH $HOME/dev/gocode
ENV PATH /usr/local/go/bin:$GOPATH/bin:$PATH

# go tools
RUN go get github.com/tools/godep && \
    go get code.google.com/p/go.tools/cmd/present

# nvm
RUN cd $HOME && git clone https://github.com/Alex7Kom/nvm-fish.git .nvm

# latest docker binary
RUN wget https://get.docker.io/builds/Linux/x86_64/docker-latest -O /usr/local/bin/docker && \
    chmod +x /usr/local/bin/docker

RUN chown -R dev:dev $HOME && \
    groupadd -g 999 vboxsf && \
    groupadd -g 1002 docker && \
    usermod -aG vboxsf dev && \
    usermod -aG docker dev
USER dev
CMD ["/usr/local/bin/fish"]
