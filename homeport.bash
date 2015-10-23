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
homeport_path=$(pwd)
popd > /dev/null

source "$homeport_path/functions.bash"
source "$homeport_path/getopt.bash"

# Node that the `+` in the options sets scanning mode to stop at the first
# non-option parameter, otherwise we'd have to explicilty use `--` before the
# sub-command.
declare argv
argv=$(getopt --options +n:t:u:h: --long evaluated,namespace:,tag:,user:,hub: -- "$@") || return
eval "set -- $argv"

homeport_namespace=about
homeport_tag=default
homeport_unix_user=$USER
homeport_evaluated=0

if [ -e ~/.homeport.conf ]; then
    source ~/.homeport.conf
fi

while true; do
    case "$1" in
        --evaluated | -e)
            homeport_evaluated=1
            shift
            ;;
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

homeport_exec "$@"
