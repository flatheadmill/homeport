#!/bin/bash

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

# TODO: Not used.
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

function homeport_emit_evaluated_variable() {
    local name=$1
    eval 'local value=$(echo $'$name')'
    echo "$name=$(printf %q $value)"
}

function homeport_emit_evaluated() {
    return 1
    if [ "$homeport_evaluated" -eq 1 ]; then
        homeport_emit_evaluated_variable homeport_unix_user
        homeport_emit_evaluated_variable homeport_namespace
        homeport_emit_evaluated_variable homeport_tag
        homeport_emit_evaluated_variable homeport_evaluated
        homeport_emit_evaluated_variable homeport_image_name
        homeport_emit_evaluated_variable homeport_home_volume
        while [ $# -ne 0 ]; do
            echo 1
        done
        echo ''
        cat "$homeport_command_path"
    fi
}

function homeport_exec() {
    local command=$1

    [ -z "$command" ] && abend "TODO: write usage"

    local action="$HOMEPORT_PATH/lib/$command.bash"

    [ ! -e "$action"  ] && abend "invalid action: homeport $command"

    shift

    # todo: you're never using this and you're always building, should this be the namespace?
    if [ ! -z "$homeport_docker_hub_account" ]; then
        homeport_image_name="${homeport_docker_hub_account}/"
    else
        homeport_image_name=
    fi
    homeport_image_name+=homeport_${USER}_${homeport_unix_user}_${homeport_namespace}_${homeport_tag}
    homeport_home_volume="homeport_${USER}_${homeport_unix_user}_home"

    export HOMEPORT_PATH homeport_docker_hub_account homeport_unix_user homeport_tag homeport_image_name homeport_unix_user homeport_home_volume homeport_evaluated
    export homeport_command_path="$action" homeport_namespace
    export -f usage abend getopt homeport homeport_exec homeport_emit_evaluated homeport_emit_evaluated_variable

    "$action" "$@"
}
