FROM alpine:latest
MAINTAINER evan hazlett <ejhazlett@gmail.com>

RUN apk add --no-cache -U \
    gcc \
    git \
    make \
    jq \
    tmux \
    htop \
    sudo \
    curl \
    bash \
    vim \
    go \
    perl \
    socat

# base config
ENV CONTAINER_USER ehazlett
RUN adduser -D $CONTAINER_USER
RUN echo "ALL            ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers

## vim
#RUN git clone https://github.com/vim/vim /tmp/vim
#RUN (cd /tmp/vim && ./configure --prefix=/usr/local --enable-gui=no --without-x --disable-nls --enable-multibyte --with-tlib=ncurses --enable-pythoninterp --with-features=huge && make install)

## go
#RUN curl -sSL https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz -o /tmp/go.tar.gz && \
#    cd /usr/local && \
#    tar zxf /tmp/go.tar.gz && \
#    rm /tmp/go.tar.gz

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
ENV GOROOT /usr/lib/go
ENV GOPATH $HOME/dev/gocode
ENV PATH /usr/local/go/bin:$GOPATH/bin:$PATH

# go tools
RUN go get github.com/tools/godep && \
    go get golang.org/x/tools/present && \
    go get github.com/google/git-appraise/git-appraise

# nvm
RUN cd $HOME && git clone https://github.com/creationix/nvm .nvm

# latest docker binary
RUN curl -sSL https://get.docker.com/builds/Linux/x86_64/docker-1.10.2 -o /usr/local/bin/docker && \
    chmod +x /usr/local/bin/docker

# perms
RUN chown -R $CONTAINER_USER:$CONTAINER_USER $HOME && \
    addgroup docker && \
    addgroup staff

ENV DOCKER_VERSION 1.10.2
ENV MACHINE_VERSION v0.6.0
ENV COMPOSE_VERSION 1.6.0

RUN curl -sL https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION} > /usr/local/bin/docker && \
    chmod +x /usr/local/bin/docker && \
    curl -sSL https://github.com/docker/machine/releases/download/${MACHINE_VERSION}/docker-machine-`uname -s`-`uname -m` -o /usr/local/bin/docker-machine && \
    chmod +x /usr/local/bin/docker-machine && \
    ln -sf /usr/local/bin/docker-machine /usr/local/bin/machine && \
    curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# user
USER $CONTAINER_USER
CMD ["bash"]
