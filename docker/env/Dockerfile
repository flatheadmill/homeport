FROM ubuntu

MAINTAINER Alan Gutierrez, alan@prettyrobots.com

RUN apt-get update && apt-get -y upgrade && apt-get -y autoremove
RUN apt-get install -y build-essential

RUN /usr/sbin/groupadd --gid 701 alan && \
    /usr/sbin/useradd --gid 701 --uid 701 alan

RUN apt-get install -y git zsh vim rsync

USER alan
