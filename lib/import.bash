#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport import --archive <archive>
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

mkdir "$dir/src/" "$dir/export/" && \
    rsync -a "$HOMEPORT_PATH/" "$dir/src/" || abend "cannot create source archive"

tar -C "$dir/export/" -xzf "$homeport_archive"

declare -a arguments

while read -r package; do
    if [[ $package = */* ]]; then
        formula=${package%:*}
        list=${package#*:}
        argument="$dir/export/$formula"
        if [ ! -z "$list" ]; then
            argument+=":$list"
        fi
        echo "PACKAGE ARGUMENT $package $argument"
        arguments+=($argument)
    else
        arguments+=($package)
    fi
done < "$dir/export/manifest"

exisitng_image=$(docker images | awk -v image=$homeport_image_name '
    $1 == image && $2 == "latest" { print }
' | wc -l | xargs echo)

[ "$exisitng_image" -eq 0 ] && "$homeport_path/lib/create"

docker tag -f $homeport_image_name:latest $homeport_image_name:recovery
{ "$homeport_path/lib/clear" && \
    "$HOMEPORT_PATH/lib/append" "${arguments[@]}"; } && \
    docker rmi $homeport_image_name:recovery || \
    docker tag -f $homeport_image_name:recovery $homeport_image_name:latest
