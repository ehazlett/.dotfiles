FROM ubuntu:18.04
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
    libtool \
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
ENV GO_VERSION 1.11.1
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
    go get -v golang.org/x/lint/golint && \
    go get -v github.com/LK4D4/vndr && \
    go get -v github.com/stevvooe/protobuild && \
    go get -v github.com/mdempsky/gocode

# proto
RUN git clone https://github.com/google/protobuf /tmp/protobuf && \
    cd /tmp/protobuf && \
    ./autogen.sh && \
    ./configure && make install
RUN go get -v github.com/golang/protobuf/protoc-gen-go
RUN go get -v github.com/gogo/protobuf/protoc-gen-gofast
RUN go get -v github.com/gogo/protobuf/proto
RUN go get -v github.com/gogo/protobuf/gogoproto
RUN go get -v github.com/gogo/protobuf/protoc-gen-gogo
RUN go get -v github.com/gogo/protobuf/protoc-gen-gogofast

# nvm
RUN cd $HOME && git clone https://github.com/creationix/nvm .nvm

# latest docker binary
ENV DOCKER_VERSION 18.06.1-ce
RUN curl -sSL https://download.docker.com/linux/static/edge/x86_64/docker-${DOCKER_VERSION}.tgz -o /tmp/docker-latest.tgz && \
    tar zxf /tmp/docker-latest.tgz -C /usr/local/bin --strip 1 && \
    rm -rf /tmp/docker-latest.tgz

# perms
RUN chown -R $CONTAINER_USER:$CONTAINER_USER $HOME && \
    groupadd -g 2000 docker && \
    usermod -aG docker $CONTAINER_USER && \
    usermod -aG users $CONTAINER_USER && \
    usermod -aG staff $CONTAINER_USER

VOLUME /home/$CONTAINER_USER

# user
USER $CONTAINER_USER
CMD ["bash"]
