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

homeport_home_container="homeport-home-${homeport_guest_user}"

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

exists=$(docker ps --no-trunc -a | awk -v volume=$homeport_home_container '$(NF) == volume { print $(NF) }')

if [ -z "$exists" ]; then
    docker run --name $homeport_home_container -v "/home/homeport" ubuntu bash -c 'exit'
    docker run --rm --volumes-from $homeport_home_container -v "$homeport_path"/container/home:/usr/local/bin/home:ro -it ubuntu \
        bash -c 'mkdir -p /home/homeport/.ssh && echo "$0" >> /home/homeport/.ssh/authorized_keys && chown -R 701:701 /home/homeport && chmod -R go-rwx /home/homeport/.ssh' "$ssh_key"
fi
