#!/bin/bash

set -e

case "$OSTYPE" in
    darwin* )
        HOMEPORT_OS=OSX
        ;;
    linux* )
        HOMEPORT_OS=Linux
        ;;
    * )
        abend "Homeport will only run on OS X or Linux."
        ;;
esac

if [ "$1" == "module" ]; then
    echo $0
    echo "Please do not execute these programs directly. Use homeport."
    exit 1
fi

# At the top of every module. This will gather a usage message to share with the
# user if we abend.
function homeport() {
    [ "$1" == "module" ] || fail "invalid argument to homeport"
    local message; local spaces;
    IFS="\000" read -r -d'\000' message && true
    spaces=$(
        echo "$message" | sed -e '/^$/d' -e 's/^\( *\).*/\1/' | \
            sed -e '1h;H;g;s/[^\n]/#/g;s/\(#*\)\n\1/\n/;G;/^\n/s/\n.*\n\(.*\)\n.*/\1/;s/.*\n//;h;$!d'
    )
    USAGE="$(echo "$message" | sed -e "s/^$spaces//")"
}

function homeport_readlink() {
    file=$1
    if [ "$HOMEPORT_OS" = "OSX" ]; then
        if [ -L "$file" ]; then
            readlink $1
        else
            echo "$file"
        fi
    else
        readlink -f $1
    fi
}

function homeport_absolutize() {
    expanded=$(cd ${1/*} && homeport_readlink $1)
    readlink $1 1>&2
    echo x $expanded 1>&2
    base=${expanded##*/}
    dir=$(cd ${expanded%/*} && pwd -P)
    echo "$dir/$base"
}

function usage() {
    local code=$1
    echo "$USAGE"
    exit $code
}

function abend() {
    local message=$1
    echo "error: $message"
    usage 1
}

function __homeport_configuration() {
    homeport_tag=$1
    homeport_shell=$(docker images | awk -v user=$USER -v tag=$homeport_tag '
        $1 == "homeport_shell-"tag && $2 == user {print $1":"$2}
    ')

    if [  -z "$homeport_shell" ]; then
        printf '%s %q\n' abend 'no shell. please create shell with `homeport create`'
    else
        echo "homeport_shell=$homeport_shell"
        docker run --rm $homeport_shell cat /etc/homeport/configuration
    fi
}

function homeport_exec() {
    local command=$1

    [ -z "$command" ] && abend "TODO: write usage"

    local action="$HOMEPORT_PATH/lib/$command.bash"

    [ ! -e "$action"  ] && abend "invalid action: homeport $command"

    shift

    export homeport_namespace="$homeport_docker_hub_account"
    export HOMEPORT_PATH homeport_docker_hub_account homeport_unix_user homeport_tag homeport_image_name homeport_unix_user homeport_home_volume
    export -f usage abend getopt homeport

    "$action" "$@"
}

homeport_file=$0

while [ -L "$homeport_file" ]; do
    expanded=$(homeport_readlink "$homeport_file")
    pushd "${homeport_file%/*}" > /dev/null
    pushd "${expanded%/*}" > /dev/null
    homeport_path=$(pwd)
    popd > /dev/null
    popd > /dev/null
    homeport_file="$homeport_path/${homeport_file##*/}"
done

pushd "${homeport_file%/*}" > /dev/null
HOMEPORT_PATH=$(pwd)
popd > /dev/null

source "$HOMEPORT_PATH/getopt.bash"

# Node that the `+` in the options sets scanning mode to stop at the first
# non-option parameter, otherwise we'd have to explicilty use `--` before the
# sub-command.
declare argv
argv=$(getopt --options +n:t:u:h: --long namespace:,tag:,user:,hub: -- "$@") || return
eval "set -- $argv"

homeport_namespace=about
homeport_tag=default
homeport_unix_user=$USER

if [ -e ~/.homeport.conf ]; then
    source ~/.homeport.conf
fi

while true; do
    case "$1" in
        --namespace | -n)
            shift
            homeport_namespace=$1
            shift
            ;;
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

if [ ! -z "$homeport_docker_hub_account" ]; then
    homeport_image_name="${homeport_docker_hub_account}/"
fi
homeport_image_name+=homeport_${USER}_${homeport_unix_user}_${homeport_namespace}_${homeport_tag}

homeport_home_volume="homeport_${USER}_${homeport_unix_user}_home"

homeport_exec "$@"
