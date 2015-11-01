#!/bin/bash

homeport module <<-usage
    usage: homeport ip
usage

if [ -z "$DOCKER_HOST" ]; then
    docker inspect --format '{{ .NetworkSettings.Gateway }}' "$homeport_image"
else
    echo "$DOCKER_HOST" | sed 's/^tcp:\/\/\(.*\):.*$/\1/'
fi
