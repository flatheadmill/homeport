#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport push <name> <repository:tag>
usage

homeport_emit_evaluated "$@" && exit
homeport_select_image $1 && shift

trap cleanup EXIT SIGTERM SIGINT

function cleanup() {
    local pids=$(jobs -pr)
    [ -n "$pids" ] && kill $pids
    [ ! -z "$dir" ] && rm -rf "$dir"
}

dir=$(mktemp -d -t homeport_append.XXXXXXX)

repository_image=$1

[ -z "$repository_image" ] && abend "repository image name required"

docker tag "$homeport_image_name" "$repository_image" && docker push "$repository_image"
docker rmi "$repository_image"
