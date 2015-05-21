FROM ubuntu

MAINTAINER Alan Gutierrez, alan@prettyrobots.com

# Update Ubuntu.
RUN apt-get update && apt-get -y upgrade && apt-get -y autoremove

# Install build essentials.
RUN apt-get install -y curl

RUN curl -s https://syncthing.net/release-key.txt | apt-key add -

RUN sh -c 'echo deb http://apt.syncthing.net/ syncthing release > /etc/apt/sources.list.d/syncthing-release.list'

RUN apt-get update && apt-get -y install syncthing && apt-get -y autoremove
