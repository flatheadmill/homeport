#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport duplicate <from> <to>

    description:

        Create a new  Homeport image that is a duplicate of an existing image.
usage

homeport_emit_evaluated "$@" && exit
homeport_get_hops_and_tag "$@"
eval "set -- $homeport_argv"

[ -z "$1" ] && abend "New tag name required"

docker tag $homeport_image homeport/image-${1}
