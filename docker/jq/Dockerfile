FROM ubuntu

MAINTAINER Alan Gutierrez, alan@prettyrobots.com

RUN apt-get -y update
RUN apt-get -y upgrade

RUN apt-get -y install libtool flex bison gcc make automake git

RUN mkdir -p /app
COPY jq/app /app
WORKDIR /app
