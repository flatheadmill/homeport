FROM ubuntu

MAINTAINER Alan Gutierrez, alan@prettyrobots.com

RUN apt-get update && apt-get -y upgrade && apt-get -y autoremove

COPY . /usr/share/homeport/

RUN find /usr/share/homeport

ENTRYPOINT ["/bin/bash", "/usr/share/homeport/homeport.bash"]
