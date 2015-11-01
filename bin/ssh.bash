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

dir=$(mktemp -d -t homeport_ssh.XXXXXXX)

function cleanup() {
    local pids=$(jobs -pr)
    [ -n "$pids" ] && kill $pids
    [ ! -z "$dir" ] && rm -rf "$dir"
}

homeport_exec known-hosts "$homeport_tag" > "$dir/known_hosts"
read -r -a ssh_host_port <<< "$(sed 's/^\[\([0-9.]*\)\]:\([0-9]*\).*$/\1 \2/' "$dir/known_hosts")"

ssh -o "UserKnownHostsFile=$dir/known_hosts" -A -l homeport -p "${ssh_host_port[1]}" "${ssh_host_port[0]}" "$@"
