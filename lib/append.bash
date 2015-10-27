#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport append

    options:

        -t, --tag <string>
            an optional tag for the image so you can create different images
usage

homeport_emit_evaluated "$@" && exit
homeport_labels $1 && shift

trap cleanup EXIT SIGTERM SIGINT

function cleanup() {
    local pids=$(jobs -pr)
    [ -n "$pids" ] && kill $pids
    [ ! -z "$dir" ] && rm -rf "$dir"
}

dir=$(mktemp -d -t homeport_append.XXXXXXX)

mkdir "$dir/src/" && homeport_source_tarball | \
    (cd "$dir/src" && tar xf -)|| abend "cannot create source archive"

count=0
mkdir -p "$dir/src/incoming"
while [ $# -ne 0 ]; do
    package=$1
    shift
    if [[ "$package" != */* ]]; then
        package="$homeport_path/formula/apt-get:$package"
    fi
    formula=${package%:*}
    list=${package#*:}
    echo LIST $list
    relative="incoming/$count/formula/${formula##*/}"
    mkdir -p "$dir/src/incoming/$count/formula"
    let count=count+1
    cp "$formula" "$dir/src/$relative"
    package="$relative"
    if [ ! -z "$list" ]; then
        package+=":$list"
    fi
    echo "$package" >> "$dir/src/incoming/manifest"
done

# todo: copy to /var/lib instead
cat <<EOF > "$dir/Dockerfile"
FROM $homeport_image_name:latest

MAINTAINER Alan Gutierrez, alan@prettyrobots.com

COPY ./src/ /usr/share/homeport/
RUN /usr/share/homeport/container/install
EOF

docker build -t $homeport_image_name:_intermediate "$dir"
docker tag -f $homeport_image_name:_intermediate $homeport_image_name:latest
docker rmi $homeport_image_name:_intermediate
