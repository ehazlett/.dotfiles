FROM ubuntu:16.04
MAINTAINER evan hazlett <ejhazlett@gmail.com>
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y \
    build-essential \
    bash-completion \
    gcc \
    dnsutils \
    git-core \
    make \
    bc \
    jq \
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
    libapparmor1 \
    libseccomp2 \
    apache2-utils \
    unzip \
    libcurl4-openssl-dev

# base config
ENV CONTAINER_USER hatter
RUN useradd $CONTAINER_USER
RUN echo "ALL            ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN cp /usr/share/zoneinfo/America/Indianapolis /etc/localtime

# vim
RUN git clone https://github.com/vim/vim /tmp/vim
RUN (cd /tmp/vim && ./configure --prefix=/usr/local --enable-gui=no --without-x --disable-nls --enable-multibyte --with-tlib=ncurses --enable-pythoninterp --with-features=huge && make install)

# go
ENV GO_VERSION 1.8.3
RUN wget https://storage.googleapis.com/golang/go$GO_VERSION.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
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
RUN go get -v golang.org/x/tools/present && \
    go get -v golang.org/x/tools/cmd/goimports && \
    go get -v github.com/golang/lint/golint && \
    go get -v github.com/LK4D4/vndr && \
    go get -v github.com/stevvooe/protobuild

# nvm
RUN cd $HOME && git clone https://github.com/creationix/nvm .nvm

# latest docker binary
ENV DOCKER_VERSION 17.06.0-ce
RUN curl -sSL https://download.docker.com/linux/static/edge/x86_64/docker-${DOCKER_VERSION}.tgz -o /tmp/docker-latest.tgz && \
    tar zxf /tmp/docker-latest.tgz -C /usr/local/bin --strip 1 && \
    rm -rf /tmp/docker-latest.tgz

# perms
RUN chown -R $CONTAINER_USER:$CONTAINER_USER $HOME && \
    groupadd -g 999 docker && \
    usermod -aG docker $CONTAINER_USER && \
    usermod -aG users $CONTAINER_USER

ENV COMPOSE_VERSION 1.15.0

# docker tooling
RUN curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

VOLUME /home/$CONTAINER_USER

# user
USER $CONTAINER_USER
CMD ["bash"]
