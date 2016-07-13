#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport append <name> <packages>

    description:

        Update a Homeport image by appending packages and formulae.

        The \`append\` command is used to add new packages to a Homeport image.
        The packages are specified by package name and installed using
        \`apt-get\`.
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

dir=$(mktemp -d -t homeport_append.XXXXXXX)

mkdir -p "$dir/src"
{ (homeport_source_tarball || echo '\0') | \
    (cd "$dir/src" && tar xf -); } || abend "cannot create source archive"

mkdir -p "$dir/src/append"

formula=$1
shift

[ -z "$formula" ] && abend "formula is required."

if [[ "$formula" = formula/* ]]; then
    formula="$homeport_formula_path"/"$formula"
fi

if [[ "$formula" = "docker:///"* ]]; then
    docker_formula_stripped=${formula#docker:///}
    formula_name=${docker_formula_stripped##*/}
    docker_formula_path=/"${docker_formula_stripped#*/*/}"
    docker_formula_image=${docker_formula_stripped%$docker_formula_path}
    mkdir -p "$dir/formula/$formula_name"
    docker run --rm --entrypoint=/bin/bash "$docker_formula_image" \
        -c 'cd $0 && tar cf - .' "$docker_formula_path"  | \
            (cd "$dir/formula/$formula_name" && tar xf -)
    formula="$dir/formula/$formula_name"
fi

mkdir -p "$dir/src/append/formula"
formula_name=${formula##*/}
relative="append/formula/$formula_name"
rsync -a "$formula/" "$dir/src/$relative/"
invocation=$(printf %q "formula/$formula_name/install")
while [ $# -ne 0 ]; do
    invocation+=$(printf ' %q' "$1")
    shift
done
echo "$invocation" >> "$dir/src/append/invocation"

# todo: copy to /var/lib instead
cat <<EOF > "$dir/Dockerfile"
FROM $homeport_image:latest

MAINTAINER Alan Gutierrez, alan@prettyrobots.com

COPY ./src/ /usr/share/homeport/
RUN /usr/share/homeport/container/install /usr/share/homeport/append
EOF

docker build --no-cache -t $homeport_image:_intermediate "$dir"
docker tag $homeport_image:_intermediate $homeport_image:latest
docker rmi $homeport_image:_intermediate
