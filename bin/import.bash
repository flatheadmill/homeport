#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport import --archive <archive>
usage

homeport_emit_evaluated "$@" && exit
homeport_get_hops_and_tag "$@"
eval "set -- $homeport_argv"

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

mkdir -p "$dir/src/import"
{ (homeport_source_tarball || echo '\0') | \
    (cd "$dir/src" && tar xf -); } || abend "cannot create source archive"
tar -C "$dir/src/import/" -xvzf "$homeport_archive"

cat <<EOF > "$dir/Dockerfile"
FROM $homeport_image:latest

MAINTAINER Alan Gutierrez, alan@prettyrobots.com

COPY ./src/ /usr/share/homeport/
RUN /usr/share/homeport/container/import
EOF

docker build -t $homeport_image:_intermediate "$dir"
docker tag -f $homeport_image:_intermediate $homeport_image:latest
docker rmi $homeport_image:_intermediate
