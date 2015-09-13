#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport export --archive <archive>
usage

trap cleanup EXIT SIGTERM SIGINT

function cleanup() {
    local pids=$(jobs -pr)
    [ -n "$pids" ] && kill $pids
    [ ! -z "$dir" ] && rm -rf "$dir"
}

dir=$(mktemp -d -t homeport_export.XXXXXX)

declare argv
argv=$(getopt --options +a: --long archive: -- "$@") || return
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
    docker run --rm $homeport_image_name:latest tar -C /var/lib/homeport -czf - .
}

if [ "$homeport_archive" = "-" ]; then
    homeport_export
else
    homeport_archive=$(
        cd "$(dirname '$homeport_archive')" &>/dev/null && \
            printf "%s/%s" "$PWD" "${homeport_archive##*/}"
    )
    homeport_export > "$homeport_archive"
fi
