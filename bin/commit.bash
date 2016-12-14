#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport commit <name>

    description:

        Replace homeport image with contents of running container.
usage

homeport_emit_evaluated "$@" && exit
homeport_get_hops_and_tag "$@"
eval "set -- $homeport_argv"

docker commit $homeport_container $homeport_image
