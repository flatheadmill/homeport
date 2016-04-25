#!/bin/bash

homeport module <<-usage
    usage: homeport rsync
usage

homeport_emit_evaluated "$@" && exit
homeport_get_hops_and_tag "$@"
eval "set -- $homeport_argv"

dir=$(mktemp -d -t homeport_rsync.XXXXXXX)

function cleanup() {
    local pids=$(jobs -pr)
    [ -n "$pids" ] && kill $pids
    [ ! -z "$dir" ] && rm -rf "$dir"
}

trap cleanup EXIT SIGTERM SIGINT

if [[ "$dir" ==  *' '* ]]; then
    abend "Cannot use a temp directory that contains spaces. TMPDIR=$TMPDIR"
fi

docker cp "$homeport_container":/etc/ssh/ssh_host_rsa_key.pub "$dir"

if [ -z "$DOCKER_HOST" ]; then
    ssh_host=$(docker inspect --format '{{(index (index .NetworkSettings.Ports "22/tcp") 0).HostIp}}' "$homeport_container")
else
    ssh_host=$(echo "$DOCKER_HOST" | sed 's/^tcp:\/\/\(.*\):.*$/\1/')
fi
ssh_port=$(docker port $homeport_container 22 | cut -d: -f2)

echo "[$ssh_host]:$ssh_port $(cut -d' ' -f1,2 < $dir/ssh_host_rsa_key.pub)"
