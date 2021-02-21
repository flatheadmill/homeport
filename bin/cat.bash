#!/bin/bash

homeport module <<-usage
    usage: homeport cat
usage

#homeport_emit_evaluated "$@" && exit
#homeport_get_hops_and_tag "$@"
#eval "set -- $homeport_argv"

cat "$homeport_path/$1"
