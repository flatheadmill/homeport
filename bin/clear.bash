#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport clear <options>
usage

homeport_emit_evaluated "$@" && exit
homeport_labels $1 && shift

docker tag -f $homeport_image:latest $homeport_image:_outgoing
docker tag -f $homeport_image:_foundation $homeport_image:latest
docker rmi $homeport_image:_outgoing
