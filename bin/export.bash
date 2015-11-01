#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport export --archive <archive>
usage

homeport_emit_evaluated "$@" && exit
homeport_labels $1 && shift

trap cleanup EXIT SIGTERM SIGINT

function cleanup() {
    local pids=$(jobs -pr)
    [ -n "$pids" ] && kill $pids
    [ ! -z "$dir" ] && rm -rf "$dir"
}

dir=$(mktemp -d -t homeport_export.XXXXXX)

declare argv
argv=$(getopt --options +a: --long archive: -- "$@") || abend "cannot parse"
eval "set -- $argv"

while true; do
    case "$1" in
        --archive | -a)
            shift
            homeport_archive=$1
            shift
            ;;
        --)
            shift
            break
            ;;
    esac
done

[ -z "$homeport_archive" ] && usage "--archive is required"

function homeport_export() {
    docker run --rm $homeport_image:latest tar -C /var/lib/homeport -czf - .
}

if [ "$homeport_archive" = "-" ]; then
    homeport_export
else
    homeport_export > "$homeport_archive"
fi
