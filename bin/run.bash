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
docker_options='-v /usr/local/bin/docker:/usr/local/bin/docker:rw '
docker_options+='-v '$(printf %q "$DOCKER_CERT_PATH:/var/lib/homeport/certs:ro")' '
docker_options+='-e DOCKER_CERT_PATH=/var/lib/homeport/certs '
docker_options+='-e DOCKER_TLS_VERIFY=1 '
docker_options+='-e DOCKER_HOST='$(printf %q "$DOCKER_HOST")' '

declare argv
argv=$(getopt --options +e:v:p:A --long home:,label:,privileged,docker,volumes-from:,link: -- "$@") || exit 1
eval "set -- $argv"

docker_rm=1 named=0 daemonize=0

homeport_home=$HOME

while true; do
    case "$1" in
        --home)
            shift
            homeport_home=$1
            shift
            homeport_dir=$homeport_home
            while [ -L "$homeport_home" ]; do
                expanded=$(homeport_readlink "$homeport_home")
                pushd "${homeport_home%/*}" > /dev/null
                pushd "${expanded%/*}" > /dev/null
                homeport_dir=$(pwd)
                popd > /dev/null
                popd > /dev/null
                homeport_home="$homeport_dir/${homeport_home##*/}"
            done
            homeport_dir=$homeport_home
            while [ "$HOME" != "$homeport_dir"  ]; do
                homeport_dir=${homeport_dir%/*}
                [ -z "$homeport_dir" ] && abend "Home directory must be a child of host home directory."
            done
            ;;
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

homeport_home_volume="$HOME:/var/lib/homeport/home:rw"

if [ "$homeport_host_os" = "OSX" ]; then
    homeport_host_uid=1000
    homeport_host_gid=50
else
    homeport_host_uid=$(id -u)
    homeport_host_gid=$(id -u)
fi

while read -r line; do
    exclude+="${line%%=*}="
done < <(docker run -v "$homeport_home_volume" --rm $homeport_image bash -c 'printenv')

docker='docker run '
docker+='-e HOMEPORT_HOST_HOME='$homeport_home' '
docker+='-P -d --privileged '
docker+='--name '$homeport_container' '
docker+='--label io.homeport=true '
docker+='-v '$homeport_home_volume' '
docker+='-h '$homeport_tag' '
docker+=$docker_options
docker+=$homeport_image' '

docker+='/usr/share/homeport/container/sshd '
docker+=$(printf %q $exclude)" $homeport_host_uid $homeport_host_gid"

if [ $# -ne 0 ]; then
    printf -v sshd_execute ' %q' "$@"
    docker+="$sshd_execute"
fi

eval $docker
