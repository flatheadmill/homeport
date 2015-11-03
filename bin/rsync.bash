#!/bin/bash

homeport module <<-usage
    usage: homeport rsync
usage

homeport_emit_evaluated "$@" && exit
homeport_get_hops_and_tag "$@" && shift
set -- $homeport_argv

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

homeport_ssh_config "$dir"

arguments=("-e" "ssh -F $dir/config")
while [ $# -ne 0 ]; do
    case "$1" in
        homeport:*)
            value=${1#homeport:}
            value=homeport@"${destination[0]}":${value}
            arguments+=("$value")
            shift
            ;;
        *)
            arguments+=("$1")
            shift
            ;;
    esac
done

cat "$dir/known_hosts"
cat "$dir/config"

rsync "${arguments[@]}"
