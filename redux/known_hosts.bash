#!/bin/bash

set -e

function is_homeport_container () {
    return 0
}

homeport_container=$1

ssh_host=$(docker inspect --format '{{(index (index .NetworkSettings.Ports "22/tcp") 0).HostIp}}' "$homeport_container")

if [ "$ssh_host" = "0.0.0.0" ]; then
    ssh_host=127.0.0.1
fi

ssh_port=$(docker port $homeport_container 22 | cut -d: -f2)
ssh_key=$({ docker cp homeport-jupyter:/etc/ssh/ssh_host_rsa_key.pub - | tar -Oxvf - ssh_host_rsa_key.pub | cut -d' ' -f1,2; } 2>/dev/null)

sed -i.bak -e '/^\['$ssh_host']:'$ssh_port'/d' ~/.ssh/homeport/known_hosts

echo "[$ssh_host]:$ssh_port $ssh_key" >> ~/.ssh/homeport/known_hosts
