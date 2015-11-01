#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport pull <name> <repository:tag>
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

[ -z "repository" ] && abend "repository image name required"

docker pull "$repository_image" && docker tag "$repository_image" "$homeport_image_name"
