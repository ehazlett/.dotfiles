#!/bin/bash
USER_NAME=${1:-hatter}

if [ -e "/usr/bin/apt-get" ] ; then
	apt-get update
	DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
	DEBIAN_FRONTEND=noninteractive apt-get install -y \
	    build-essential \
	    gcc \
	    bc \
	    bzr \
	    git-core \
	    make \
	    autoconf \
            automake \
	    gawk \
	    libncurses5-dev \
	    libssl-dev \
	    mercurial \
	    aufs-tools \
            libtool \
            unzip \
            file \
	    libbz2-dev \
	    libreadline-dev \
	    gettext \
	    htop \
	    tmux \
	    wget \
	    sysstat \
	    curl \
	    socat \
	    libsqlite3-dev \
	    libdevmapper-dev \
            fonts-inconsolata \
	    rng-tools \
	    s3cmd \
	    libcurl4-openssl-dev \
            btrfs-tools
fi

if [ -e "/usr/bin/yum" ] ; then
	yum -y update
	yum -y install \
		kernel-devel \
		gcc \
		gcc-c++ \
		make \
		dyninst \
		elfutils-libs \
		python-devel \
		setuptools \
		gawk \
		ncurses-devel \
		openssl-devel \
		mercurial \
		bzip2-devel \
		readline-devel \
	        tmux \
		gettext \
		htop \
		wget \
		curl \
		sqlite3-devel \
		device-mapper-devel \
		rng-tools \
		s3cmd \
		httpd-tools \
		curl-devel
fi

export USER_NAME=$USER_NAME
export HOME=/home/$USER_NAME
mkdir -p $HOME
cd $HOME

git clone https://github.com/ehazlett/.dotfiles
cd .dotfiles
git submodule init
git submodule update --recursive

/bin/bash config.sh
