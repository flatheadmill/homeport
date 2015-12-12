#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport start <name>
usage

# TODO Do you add hops to these global commands?
homeport_emit_evaluated "$@" && exit
eval "set -- $homeport_argv"

trap cleanup EXIT SIGTERM SIGINT

function cleanup() {
    local pids=$(jobs -pr)
    [ -n "$pids" ] && kill $pids
}

echo docker ps --filter label=io.homeport "$@"
