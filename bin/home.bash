#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport home
usage

homeport_emit_evaluated "$@" && exit

homeport_guest_user=$1
if [ -z "$homeport_guest_user" ]; then
    homeport_guest_user=$USER
fi

homeport_home_volume="homeport-home-${homeport_guest_user}"

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

exists=$(docker ps --no-trunc -a | awk -v volume=$homeport_home_volume '$(NF) == volume { print $(NF) }')

if [ -z "$exists" ]; then
    docker run --name $homeport_home_volume -v "/home/homeport" homeport/blank
    docker run --rm --volumes-from $homeport_home_volume -v "$homeport_path"/container/home:/usr/local/bin/home:ro -it ubuntu /usr/local/bin/home "$ssh_key"
fi
