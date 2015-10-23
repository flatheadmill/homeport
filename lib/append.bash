#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport append

    options:

        -t, --tag <string>
            an optional tag for the image so you can create different images
usage

trap cleanup EXIT SIGTERM SIGINT

function cleanup() {
    local pids=$(jobs -pr)
    [ -n "$pids" ] && kill $pids
    [ ! -z "$dir" ] && rm -rf "$dir"
}

dir=$(mktemp -d -t homeport_append.XXXXXXX)

mkdir "$dir/src/" && \
    rsync -a "$homeport_path/" "$dir/src/" || abend "cannot create source archive"

mkdir -p "$dir/src/packages/formula"
while [ $# -ne 0 ]; do
    package=$1
    shift
    if [[ "$package" = */* ]]; then
        formula=${package%:*}
        list=${package#*:}
        echo LIST $list
        relative="packages/formula/${formula##*/}"
        cp "$formula" "$dir/src/$relative"
        package="/usr/share/homeport/$relative"
        if [ ! -z "$list" ]; then
            package+=":$list"
        fi
    fi
    echo "$package" >> "$dir/src/packages/manifest"
done

cat <<EOF > "$dir/Dockerfile"
FROM $homeport_image_name:latest

MAINTAINER Alan Gutierrez, alan@prettyrobots.com

COPY ./src/ /usr/share/homeport/
RUN /usr/share/homeport/container/install
EOF

docker build -t $homeport_image_name:intermediate "$dir"
docker tag -f $homeport_image_name:intermediate $homeport_image_name:latest
docker rmi $homeport_image_name:intermediate
