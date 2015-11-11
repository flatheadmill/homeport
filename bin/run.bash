#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport run
usage

homeport_emit_evaluated "$@" && exit
homeport_get_hops_and_tag "$@"
eval "set -- $homeport_argv"

trap cleanup EXIT SIGTERM SIGINT

function cleanup() {
    local pids=$(jobs -pr)
    [ -n "$pids" ] && kill $pids
}

ssh_options=''
docker_options=''

declare argv
argv=$(getopt --options +e:v:p:A --long label:,privileged,docker,volumes-from:,link: -- "$@") || exit 1
eval "set -- $argv"

docker_rm=1 named=0 daemonize=0

while true; do
    case "$1" in
        --docker)
            if which docker-machine > /dev/null; then
                host_docker="/usr/local/bin/docker"
            else
                host_docker=$(which docker)
            fi
            docker_options+="-v $host_docker:$host_docker:ro "
            docker_options+='-v /var/run/docker.sock:/var/run/docker.sock:rw '
            docker_options+="-e HOMEPORT_DOCKER_IMAGE_NAME=$homeport_image "
            shift
            ;;
        --privileged)
            docker_options+=$(printf %q "$1")' '
            shift
            ;;
        -e | -v | -p | --volumes-from | --link | --label)
            docker_options+=$(printf %q "$1")' '$(printf %q "$2")' '
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

while read -r line; do
    exclude+="${line%%=*}="
done < <(docker run --volumes-from $homeport_home_container --rm $homeport_image bash -c 'printenv')

docker='docker run '
docker+='-P -d '
docker+='--name '$homeport_container' '
docker+='--volumes-from '$homeport_home_container' '
docker+='-h '$homeport_tag' '
docker+=$docker_options
docker+=$homeport_image' '

docker+='/usr/share/homeport/container/sshd '
docker+=$(printf %q $exclude)

if [ $# -ne 0 ]; then
    printf -v sshd_execute ' %q' "$@"
    docker+="$sshd_execute"
fi

eval $docker
