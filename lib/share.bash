#!/bin/bash

if [ -z "$DOCKER_HOST" ]; then
    homeport_host=$(docker inspect --format '{{ .NetworkSettings.Gateway }}' "$homeport_image_name")
else
    homeport_host=$(echo "$DOCKER_HOST" | sed 's/^tcp:\/\/\(.*\):.*$/\1/')
fi

export homeport_tag=samba
export homeport_namespace=bigeasy

if [ $(( $(docker images | awk -v user=$USER -v homeport_unix_user=$homeport_unix_user '$1 == "homeport_" user "_" homeport_unix_user "_bigeasy_samba" { print }' | wc -l) )) -eq 0 ]; then
    homeport_exec create
    homeport_exec append samba
fi

password=$(homeport_exec ssh sudo cat /etc/samba/password 2>/dev/null)

if [ -z "$password" ]; then
    homeport_exec ssh sudo /usr/share/homeport/smbd $homeport_unix_user
fi

echo "smb://$homeport_unix_user:$password@$homeport_host"
