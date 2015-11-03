#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport import --archive <archive>
usage

homeport_emit_evaluated "$@" && exit
homeport_get_hops_and_tag "$@"
set -- $homeport_argv

trap cleanup EXIT SIGTERM SIGINT

function cleanup() {
    local pids=$(jobs -pr)
    [ -n "$pids" ] && kill $pids
    [ ! -z "$dir" ] && rm -rf "$dir"
}

dir=$(mktemp -d -t homeport_export.XXXXXX)

argv=$(getopt --options +a: --long archive: -- "$@") || abend "cannot parse arguments"
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

#mkdir "$dir/src/" "$dir/export/" && \
#    rsync -a "$HOMEPORT_PATH/" "$dir/src/" || abend "cannot create source archive"

mkdir "$dir/src/" "$dir/export/"
tar -C "$dir/export/" -xvzf "$homeport_archive"

arguments=()

while read -r package; do
    arguments+=("$dir/export/$package")
done < "$dir/export/manifest"

echo "${arguments[@]}"

exisitng_image=$(docker images | awk -v image=$homeport_image '
    $1 == image && $2 == "latest" { print }
' | wc -l | xargs echo)

[ "$exisitng_image" -eq 0 ] && "$homeport_path/lib/create.bash" "$homeport_tag"

docker tag -f $homeport_image:latest $homeport_image:recovery
{ "$homeport_path/lib/clear.bash" "$homeport_tag" && \
    "$homeport_path/lib/append.bash" "$homeport_tag" "${arguments[@]}"; } && \
    docker rmi $homeport_image:recovery || \
    docker tag -f $homeport_image:recovery $homeport_image:latest
