#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport clear <options>
usage

docker tag -f $homeport_image_name:latest $homeport_image_name:_outgoing
docker tag -f $homeport_image_name:_foundation $homeport_image_name:latest
docker rmi $homeport_image_name:_outgoing
