#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport home
usage

declare argv
argv=$(getopt -o t:u:h: --long tag:,user:,hub: -- "$@") || return
eval "set -- $argv"

homeport_tag=default
homeport_unix_user=$USER

while true; do
    case "$1" in
        --user | -u)
            shift
            homeport_unix_user=$1
            shift
            ;;
        --hub | -h)
            shift
            homeport_docker_hub_account=$1
            shift
            ;;
        --tag | -t)
            shift
            homeport_tag=$1
            shift
            ;;
        --)
            shift
            break
            ;;
    esac
done

if [ -z "$ssh_key_file" ]; then
    ssh_key_file=$(ssh-add -L | head -n 1 | awk 'NR = 1 { print $3 }')
fi

if [ -z "$ssh_key_file" ]; then
    abend "cannot find an ssh key to use."
fi

ssh_key=$(ssh-add -L | awk -v sought="$ssh_key_file" '
    function basename(file) {
        sub(".*/", "", file)
        return file
    }
    sought ~ /\// ? $3 == sought : $3 == basename(sought)  { print }
' | head -n 1)

homeport_home=$(docker ps --no-trunc -a | awk -v host=$USER -v container=$homeport_unix_user '$(NF) == "homeport_home_"host"_"container { print $(NF) }')

if [ -z "$homeport_home" ]; then
    homeport_home="homeport_home_${USER}_${homeport_unix_user}"
    docker run --name "homeport_home_${USER}_${homeport_unix_user}" -v "/home/$homeport_unix_user" bigeasy/blank
    docker run --rm --volumes-from $homeport_home_volume -v "$HOMEPORT_PATH"/container/home:/usr/local/bin/home:ro -it ubuntu /usr/local/bin/home "$homeport_unix_user" "$ssh_key"
fi
