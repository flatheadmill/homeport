#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport append

    options:

        -t, --tag <string>
            an optional tag for the image so you can create different images
usage

trap cleanup EXIT SIGTERM SIGINT

dir=$(mktemp -d -t homeport_ssh.XXXXXXX)

function cleanup() {
    local pids=$(jobs -pr)
    [ -n "$pids" ] && kill $pids
    [ ! -z "$dir" ] && rm -rf "$dir"
}

declare argv
argv=$(getopt --options +v:p:Ad --long docker,volumes-from:,link:,name: -- "$@") || exit 1
eval "set -- $argv"

ssh_port=$(docker port $homeport_image_name 22 | cut -d: -f2)
if [ -z "$DOCKER_HOST" ]; then
    ssh_host=$(docker inspect --format '{{ .NetworkSettings.Gateway }}' "$homeport_image_name")
else
    ssh_host=$(echo "$DOCKER_HOST" | sed 's/^tcp:\/\/\(.*\):.*$/\1/')
fi
ssh -l $homeport_unix_user -p "$ssh_port" "$ssh_host"
exit

homeport_tag=default
homeport_unix_user=$USER

docker_rm=1 named=0 daemonize=0

while true; do
    case "$1" in
        --docker)
            docker_options+="-v $host_docker:$host_docker:ro "
            docker_options+='-v /var/run/docker.sock:/var/run/docker.sock:rw '
            docker_options+="-e HOMEPORT_DOCKER_IMAGE_NAME=$homeport_image_name "
            shift
            ;;
        -d)
            daemonize=1
            docker_options+="$1"' '
            shift
            ;;
        -v | -p | --volumes-from | --link | --name)
            case "$1" in
                --name)
                    named=1
                    ;;
            esac
            docker_options+="$1"' '"$2"' '
            shift
            shift
            ;;
        -A)
            ssh_options+="$1"' '
            docker_options+='-v $(readlink -f $SSH_AUTH_SOCK):/home/'$homeport_unix_user/.ssh-agent' '
            docker_options+='-e SSH_AUTH_SOCK=/home/'$homeport_unix_user'/.ssh-agent '
            shift
            ;;
        --)
            shift
            break
            ;;
    esac
done
