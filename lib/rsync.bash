#!/bin/bash
#rsync -av -e 'ssh -p 32768' ~/Sync/PrettyRobots/DetroitShapeFiles/ alan@192.168.99.100:~/DetroitShapeFiles/
 
homeport module <<-usage
    usage: homeport append

    options:

        -t, --tag <string>
            an optional tag for the image so you can create different images
usage

arguments=('-av' '-e' 'ssh -p '$(docker port $homeport_image_name 22 | cut -d: -f2))

if [ -z "$DOCKER_HOST" ]; then
    ip=$(docker inspect --format '{{ .NetworkSettings.Gateway }}' "$homeport_image_name")
else
    ip=$(echo "$DOCKER_HOST" | sed 's/^tcp:\/\/\(.*\):.*$/\1/')
fi

arguments+=("$2")


while [ $# -ne 0 ]; do
    case "$1" in
        homeport:*)
            value=${1#homeport:}
            value=${homeport_unix_user}@${ip}:${value}
            arguments+=("$value")
            shift
            ;;
        *)
            shift
            ;;
    esac
done

echo ${arguments[@]}
