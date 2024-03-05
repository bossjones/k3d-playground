#syntax=docker/dockerfile:1.3
ARG DOCKER_CHEZMOI_VERSION="latest"
#--------------------------------------------#
#--------Build Custom Argo Image-------------#
#--------------------------------------------#

# quay.io/argoproj/argocd:v2.7.0
FROM bossjones/docker-chezmoi:$DOCKER_CHEZMOI_VERSION as base

# Switch to root for the ability to perform install
USER root

ENV DEBIAN_FRONTEND=noninteractive \
    TERM=xterm \
    ZSH_DOTFILES_PREP_CI=1 \
    ZSH_DOTFILES_PREP_DEBUG=1 \
    ZSH_DOTFILES_PREP_GITHUB_USER=bossjones \
    ZSH_DOTFILES_PREP_SKIP_BREW_BUNDLE=1


RUN apt-get --yes update && \
  apt-get --yes install curl gcc g++ git golang-go make openssl xz-utils unzip jsonnet jq wget pass gnupg && \
  curl https://raw.githubusercontent.com/kadwanev/retry/master/retry -o /usr/local/bin/retry && chmod +x /usr/local/bin/retry



# chezmoi init -R --debug -v --apply https://github.com/bossjones/zsh-dotfiles.git
# --promptString email=me@home.org


# add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe security" && \
# install locales package and set default locale to 'UTF-8' for the test execution environment
RUN \
    set -xe && apt-get update -y && \
    apt-get install -y \
    python3 sudo bash ca-certificates \
    locales \
    lsb-release \
    openssh-server \
    software-properties-common && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    update-locale LANG=en_US.UTF-8 && \
    mkdir -p /var/run/sshd && \
    apt-get update -y && \
    apt-get -y install gdebi-core sshpass cron netcat net-tools iproute2 && \
    apt-get -y install \
    apt-utils \
    autoconf \
    bash \
    bash-completion \
    binutils-dev \
    bison \
    bridge-utils \
    build-essential \
    ca-certificates \
    ccache \
    ccze \
    dhcping \
    ethtool \
    fping \
    direnv \
    dnsutils \
    dstat \
    elfutils \
    fasd \
    file \
    fontconfig \
    gcc \
    git \
    iptables \
    iptraf-ng \
    htop \
    httpie \
    iftop \
    iotop \
    iperf \
    iperf3 \
    iputils-ping \
    jq \
    libevent-dev \
    libffi-dev \
    libncurses-dev \
    libncurses5-dev \
    libreadline6-dev \
    libssl-dev \
    libyaml-dev \
    locales \
    lsb-release \
    lsof \
    ltrace \
    make \
    mlocate \
    mtr \
    ncdu \
    nftables \
    net-tools \
    netperf \
    tcptrack \
    ngrep \
    nmap \
    openssh-server \
    patch \
    peco \
    perf-tools-unstable \
    procps \
    silversearcher-ag \
    socat \
    software-properties-common \
    strace \
    openssl \
    scapy \
    tcptraceroute \
    util-linux \
    tcpdump \
    tmux \
    traceroute \
    tree \
    vim \
    wget \
    zlib1g-dev \
    && \
    apt-get install -y \
    zsh && \
    apt-get install apt-utils \
    python-setuptools \
    python-pip \
    software-properties-common \
    sudo -y && \
    echo "install netshoot deps" && \
    apt-get install -y \
    apache2-utils \
    bash \
    bird \
    bridge-utils \
    curl \
    dhcping \
    ethtool \
    file\
    fping \
    iftop \
    iperf \
    iperf3 \
    iproute2 \
    ipset \
    iptables \
    iptraf-ng \
    ipvsadm \
    jq \
    liboping-dev \
    ltrace \
    mtr \
    snmp \
    netcat-openbsd \
    nftables \
    ngrep \
    nmap \
    openssl \
    scapy \
    socat \
    speedtest-cli \
    strace \
    tcpdump \
    tcptraceroute \
    tshark \
    util-linux \
    vim \
    git \
    zsh \
    swaks \
    && \
    sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


ENV LANG en_US.UTF-8

# 1. small fix for SSH in ubuntu 13.10 (that's harmless everywhere else)
# 2. permit root logins and set simple password password and pubkey
# 3. change requiretty to !requiretty in /etc/sudoers
RUN sed -ri 's/^session\s+required\s+pam_loginuid.so$/session optional pam_loginuid.so/' /etc/pam.d/sshd && \
    sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -ri 's/^#?PubkeyAuthentication\s+.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -ri 's/requiretty/!requiretty/' /etc/sudoers && \
    echo 'root:root' | chpasswd

ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

# tmux stuff

RUN mkdir -p $HOME/.fonts $HOME/.config/fontconfig/conf.d \
    && wget -P $HOME/.fonts https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf \
    && wget -P $HOME/.config/fontconfig/conf.d/ https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf \
    && fc-cache -vf $HOME/.fonts/

RUN set -x; export PATH="~/.bin:~/bin:~/.local/bin:$PATH" && \
    wget https://raw.githubusercontent.com/bossjones/zsh-dotfiles-prep/main/bin/zsh-dotfiles-prereq-installer \
    && chmod +x zsh-dotfiles-prereq-installer \
    && retry -t 4  -- ./zsh-dotfiles-prereq-installer --debug \
    && ~/.bin/chezmoi init \
    --promptString name=bossjones \
    --promptString email=bossjones@theblacktonystark.com \
    --promptString computer_name=zsh-netshoot \
    --promptString hostname=zsh-netshoot \
    --promptString ruby=false \
    --promptString pyenv=false \
    --promptString nodejs=false \
    --promptString k8s=false \
    --promptString opencv=false \
    --promptString fnm=true \
    -R --debug -v --branch feature-dl-twitter --apply https://github.com/bossjones/zsh-dotfiles.git && \
    chsh -s $(which zsh)


# 87.31 E: Unable to locate package liboping
# 87.31 E: Unable to locate package net-snmp-tools
# 87.31 E: Unable to locate package nmap-nping
# 87.31 E: Unable to locate package nmap-scripts
# 87.31 E: Unable to locate package py3-pip
# 87.31 E: Unable to locate package py3-setuptools
# 87.31 E: Unable to locate package openssh
# 87.31 E: Unable to locate package websocat
# 87.31 E: Unable to locate package perl-crypt-ssleay
# 87.31 E: Unable to locate package perl-net-ssleay
# 84.02 E: Unable to locate package bind-tools
# 84.02 E: Unable to locate package busybox-extras
# 84.02 E: Unable to locate package conntrack-tools
# 84.02 E: Unable to locate package drill
# 84.02 E: Unable to locate package grpcurl
# 84.02 E: Unable to locate package iputils
# 84.02 E: Unable to locate package libc6-compat
