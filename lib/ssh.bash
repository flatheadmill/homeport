#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport append

    options:

        -t, --tag <string>
            an optional tag for the image so you can create different images
usage

trap cleanup EXIT SIGTERM SIGINT

dir=$(mktemp -d -t homeport_ssh.XXXXXXX)

function cleanup() {
    local pids=$(jobs -pr)
    [ -n "$pids" ] && kill $pids
    [ ! -z "$dir" ] && rm -rf "$dir"
}

declare argv
argv=$(getopt --options +v:p:Ad --long docker,volumes-from:,link:,name: -- "$@") || exit 1
eval "set -- $argv"

ssh_port=$(docker port $homeport_image_name 22 | cut -d: -f2)
if [ -z "$DOCKER_HOST" ]; then
    ssh_host=$(docker inspect --format '{{ .NetworkSettings.Gateway }}' "$homeport_image_name")
else
    ssh_host=$(echo "$DOCKER_HOST" | sed 's/^tcp:\/\/\(.*\):.*$/\1/')
fi
ssh -A -l $homeport_unix_user -p "$ssh_port" "$ssh_host"
