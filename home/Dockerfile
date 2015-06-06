FROM ubuntu

MAINTAINER Alan Gutierrez, alan@prettyrobots.com

RUN apt-get -y update && apt-get -y upgrade && apt-get autoremove -y

RUN apt-get install -y gcc

COPY home/src /app
