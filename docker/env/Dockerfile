FROM bigeasy/gcc

MAINTAINER Alan Gutierrez, alan@prettyrobots.com

RUN /usr/sbin/groupadd --gid 701 alan && \
    /usr/sbin/useradd --gid 701 --uid 701 alan

RUN apt-get install -y git zsh vim rsync

RUN apt-get install -y nfs-kernel-server

COPY docker/build/usr/local /usr/local

RUN echo "alan ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER alan
