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
	    libcurl4-openssl-dev \
            btrfs-progs \
	    libseccomp-dev \
            pkg-config
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
		httpd-tools \
		curl-devel
fi

export USER_NAME=$USER_NAME
export USER_HOME=/home/$USER_NAME

useradd -d $USER_HOME $USER_NAME
mkdir -p $USER_HOME
cd $USER_HOME

git clone https://github.com/ehazlett/.dotfiles
cd .dotfiles
git submodule init
git submodule update --recursive

export HOME=$USER_HOME

/bin/bash config.sh
