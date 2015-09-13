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

dir=$(mktemp -d -t homeport_create.XXXXXXX)

trap cleanup EXIT SIGTERM SIGINT

function cleanup() {
    local pids=$(jobs -pr)
    [ -n "$pids" ] && kill $pids
    rm -rf "$dir"
}

mkdir "$dir/src/" && \
    rsync -a "$HOMEPORT_PATH/" "$dir/src/" || abend "cannot create source archive"

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

COPY ./src/ /usr/share/homeport/
RUN /usr/share/homeport/container/foundation
EXPOSE 22
EOF

docker build -t $homeport_image_name:foundation "$dir"
docker tag -f $homeport_image_name:foundation  $homeport_image_name:latest
