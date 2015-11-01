#!/bin/bash

homeport module <<-usage
    usage: homeport rsync
usage

homeport_emit_evaluated "$@" && exit
homeport_labels $1 && shift

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

homeport_exec known-hosts "$homeport_tag" > "$dir/known_hosts"
read -r -a ssh_host_port <<< "$(sed 's/^\[\([0-9.]*\)\]:\([0-9]*\).*$/\1 \2/' "$dir/known_hosts")"

arguments=("-e" "ssh -p ${ssh_host_port[1]} -o UserKnownHostsFile=$dir/known_hosts")
while [ $# -ne 0 ]; do
    case "$1" in
        homeport:*)
            value=${1#homeport:}
            value=homeport@"${ssh_host_port[0]}":${value}
            arguments+=("$value")
            shift
            ;;
        *)
            arguments+=("$1")
            shift
            ;;
    esac
done

rsync "${arguments[@]}"
