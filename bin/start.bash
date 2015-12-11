#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport start <name>
usage

homeport_emit_evaluated "$@" && exit
homeport_get_hops_and_tag "$@"
eval "set -- $homeport_argv"

trap cleanup EXIT SIGTERM SIGINT

function cleanup() {
    local pids=$(jobs -pr)
    [ -n "$pids" ] && kill $pids
}

docker start "$homeport_container"
