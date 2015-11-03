#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport append

    options:

        -t, --tag <string>
            an optional tag for the image so you can create different images
usage

homeport_emit_evaluated "$@" && exit
homeport_get_hops_and_tag "$@"
set -- $homeport_vargs

trap cleanup EXIT SIGTERM SIGINT

dir=$(mktemp -d -t homeport_ssh.XXXXXXX)

function cleanup() {
    local pids=$(jobs -pr)
    [ -n "$pids" ] && kill $pids
    [ ! -z "$dir" ] && rm -rf "$dir"
}

homeport_ssh_config "$dir"

ssh -F "$dir/config" -l homeport "${destination[0]}" "$@"
