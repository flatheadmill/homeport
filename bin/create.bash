#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport create

    description:

        Creates a configuration that stores the user name in a data container
        for use with all Homeport Create a configuration file in a volume named
        "/etc/data container named "homeport_configuration" for use with
        homeport.
usage

homeport_emit_evaluated "$@" && exit
homeport_labels $1 && shift

dir=$(mktemp -d -t homeport_create.XXXXXXX)

trap cleanup EXIT SIGTERM SIGINT

function cleanup() {
    local pids=$(jobs -pr)
    [ -n "$pids" ] && kill $pids
    rm -rf "$dir"
}

mkdir "$dir/src/" && homeport_source_tarball | \
    (cd "$dir/src" && tar xf -)|| abend "cannot create source archive"

mkdir -p "$HOME/.homeport"

echo $homeport_image_name
cat <<EOF > "$dir/src/configuration"
homeport_unix_user=$homeport_unix_user
homeport_docker_hub_account=$homeport_docker_hub_account
homeport_image_name=$homeport_image_name
EOF

cat <<EOF > "$dir/Dockerfile"
FROM ubuntu

MAINTAINER Alan Gutierrez, alan@prettyrobots.com

RUN apt-get update && apt-get -y upgrade && apt-get -y autoremove && apt-get -y install openssh-server

COPY ./src/ /usr/share/homeport/
RUN /usr/share/homeport/container/foundation
EXPOSE 22
EOF

docker build -t $homeport_image_name "$dir"
