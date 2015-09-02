FROM debian:jessie
MAINTAINER evan hazlett <ejhazlett@gmail.com>
RUN apt-get update
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get install -y \
    build-essential \
    bash-completion \
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
ENV CONTAINER_USER ehazlett
RUN useradd $CONTAINER_USER
RUN echo "ALL            ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN cp /usr/share/zoneinfo/America/Indianapolis /etc/localtime
#    dpkg-reconfigure locales && \
#    locale-gen en_US.UTF-8 && \
#    /usr/sbin/update-locale LANG=en_US
#ENV LC_ALL en_US.UTF-8

# vim
RUN hg clone https://vim.googlecode.com/hg/ /tmp/vim
RUN (cd /tmp/vim && ./configure --prefix=/usr/local --enable-gui=no --without-x --disable-nls --enable-multibyte --with-tlib=ncurses --enable-pythoninterp --with-features=huge && make install)

# go
RUN wget https://storage.googleapis.com/golang/go1.5.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
    tar -C /usr/local -xvf /tmp/go.tar.gz && rm /tmp/go.tar.gz

WORKDIR /home/$CONTAINER_USER
ENV HOME /home/$CONTAINER_USER
ENV SHELL /bin/bash
COPY . $HOME/.dotfiles
RUN (cd $HOME/.dotfiles && git submodule init && git submodule update --recursive)

# env config
RUN mkdir -p $HOME/.ssh && \
    ln -sf $HOME/.dotfiles/vim $HOME/.vim && \
    ln -sf $HOME/.dotfiles/bashrc $HOME/.bashrc && \
    ln -sf $HOME/.dotfiles/vimrc $HOME/.vimrc && \
    sed -i 's/^colorscheme.*//g' $HOME/.dotfiles/vimrc && \
    vim +PluginInstall +qall > /dev/null 2>&1

RUN (cd $HOME/.dotfiles && git checkout vimrc && \
    ln -sf $HOME/.dotfiles/gitconfig $HOME/.gitconfig && \
    ln -sf $HOME/.dotfiles/ssh_config $HOME/.ssh/config && \
    chown $CONTAINER_USER:$CONTAINER_USER $HOME/.ssh/config && \
    chmod 600 $HOME/.ssh/config && \
    ln -sf $HOME/.dotfiles/known_hosts $HOME/.ssh/known_hosts && \
    ln -sf $HOME/.dotfiles/tmux.conf $HOME/.tmux.conf)

# go config
ENV GOROOT /usr/local/go
ENV GOPATH $HOME/dev/gocode
ENV PATH /usr/local/go/bin:$GOPATH/bin:$PATH

# go tools
RUN go get github.com/tools/godep && \
    go get code.google.com/p/go.tools/cmd/present

# nvm
RUN cd $HOME && git clone https://github.com/creationix/nvm .nvm

# latest docker binary
RUN wget https://get.docker.io/builds/Linux/x86_64/docker-latest -O /usr/local/bin/docker && \
    chmod +x /usr/local/bin/docker

# perms
RUN chown -R $CONTAINER_USER:$CONTAINER_USER $HOME && \
    groupadd -g 999 vboxsf && \
    groupadd -g 1002 docker && \
    usermod -aG vboxsf $CONTAINER_USER && \
    usermod -aG docker $CONTAINER_USER

# user
USER $CONTAINER_USER
VOLUME /home/$CONTAINER_USER
CMD ["bash"]
