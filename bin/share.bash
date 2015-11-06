#!/bin/bash

homeport_share_type=$1
if [ -z "$homeport_share_type" ]; then
    homeport_share_type=apple
fi

if [ -z "$DOCKER_HOST" ]; then
    homeport_host=$(docker inspect --format '{{ .NetworkSettings.Gateway }}' "$homeport_image")
else
    homeport_host=$(echo "$DOCKER_HOST" | sed 's/^tcp:\/\/\(.*\):.*$/\1/')
fi

function dawdle() {
    ssh_exit_status=255 retry=5 nap=0
    while [ $retry -ne 0 -a $ssh_exit_status -eq 255 ]; do
        sleep $nap
        nap=1
        homeport_exec ssh netatalk echo 1 2> /dev/null > /dev/null
        ssh_exit_status=$?
        let retry=retry-1
    done
}

case "$homeport_share_type" in
    apple)
        IFS=$'\t' read -r container_id image_status <<< "$(docker ps -a --filter 'label=io.homeport.share=apple' --format '{{.ID}}\t{{.Status}}')"
        if [ -z "$container_id" ]; then
            homeport_exec run netatalk -p 548:548 -p 5353:5353/udp --label io.homeport.share=apple /usr/local/bin/netatalk $homeport_host > /dev/null
            dawdle
        elif [[ "$image_status" = Exited* ]]; then
            docker start $container_id > /dev/null
            dawdle
        fi
        homeport_exec ssh netatalk cat /usr/local/etc/netatalk
        shift
        ;;
esac
