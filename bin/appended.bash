#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport export --archive <archive>
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

declare argv
argv=$(getopt --options +a: --long archive: -- "$@") || abend "cannot parse"
eval "set -- $argv"


docker run --rm $homeport_image:latest /bin/bash -c '[ -d /var/lib/homeport ] && (ls /var/lib/homeport/appended/*/invocation | sort -t / -k 4 -n | xargs cat | sed "''s,\(formula/[^/]*\)/install,\1,''")'
