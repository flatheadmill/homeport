#!/bin/bash

set -e

case "$OSTYPE" in
    darwin* )
        homeport_host_os=OSX
        ;;
    linux* )
        homeport_host_os=Linux
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
    if [ "$homeport_host_os" = "OSX" ]; then
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

source "$homeport_path/lib/common.bash"
source "$homeport_path/lib/externalized.bash"
source "$homeport_path/lib/getopt.bash"

homeport_evaluated=0

if [ -e ~/.homeport.conf ]; then
    source ~/.homeport.conf
fi

homeport_exec "$@"
