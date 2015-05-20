FROM ubuntu

MAINTAINER Alan Gutierrez, alan@prettyrobots.com

# Update Ubuntu.
RUN apt-get update && apt-get -y upgrade && apt-get -y autoremove

# Install build essentials.
RUN apt-get install -y build-essential

# Additionally needed to build `jq`.
RUN apt-get install -y git automake libtool

# Build the latest `jq`.
RUN mkdir /tmp/src && \
    git clone https://github.com/stedolan/jq.git /tmp/src/jq && \
    cd /tmp/src/jq && \
    git pull origin master && \
    autoreconf -i && \
    ./configure --prefix=/usr/local && \
    make install && \
    rm -rf /tmp/src

# Additionally needed to build `node`.
RUN apt-get install -y curl python

# Build the latest `node`.
RUN mkdir /tmp/src && \
    cd /tmp/src && \
    curl -LO http://nodejs.org/dist/v0.12.3/node-v0.12.3.tar.gz && \
    [ $(sha256sum node-v0.12.3.tar.gz | cut -f1 -d' ') = 'e65d83c6f2c874e28f65c5e192ac0acd2bbb52bfcf9d77e33442d6765a3eb9da' ] && \
    tar zxvf node-v0.12.3.tar.gz && \
    cd node-* && \
    ./configure --prefix=/usr/local && \
    make install && \
    rm -rf /tmp/src

# Editor and shell.
RUN apt-get install -y zsh vim rsync

# Add `alan` user.
RUN /usr/sbin/groupadd --gid 701 alan && \
    /usr/sbin/useradd --gid 701 --uid 701 alan && \
    echo "alan ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER alan
