#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport start <name>
usage

# TODO Do you add hops to these global commands?
homeport_emit_evaluated "$@" && exit

trap cleanup EXIT SIGTERM SIGINT

function cleanup() {
    local pids=$(jobs -pr)
    [ -n "$pids" ] && kill $pids
}

docker images --filter label=io.homeport "$@"
