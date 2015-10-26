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

function homeport_labels() {
    [ -z "$1" ] && abend "Tag name required"
    homeport_tag=$1
    if [[ "$homeport_tag" = *@* ]]; then
        homeport_unix_user=${homeport_tag%@*}
        homeport_tag=${homeport_tag#*@}
    else
        homeport_unix_user=$USER
    fi
    homeport_image_name="homeport/image-${homeport_tag}"
    homeport_home_volume="homeport-home-${homeport_unix_user}"
    homeport_container_name="homeport-${homeport_tag}"
}

function homeport_exec() {
    local command=$1

    [ -z "$command" ] && abend "TODO: write usage"

    local action="$homeport_path/lib/$command.bash"

    [ ! -e "$action"  ] && abend "invalid action: homeport $command"

    shift

    homeport_image_name=homeport/${homeport_unix_user}_${homeport_tag}
    homeport_container_name=homeport-${homeport_unix_user}_${homeport_tag}
    homeport_home_volume="homeport_${homeport_unix_user}_home"

    export homeport_path homeport_docker_hub_account homeport_unix_user homeport_tag homeport_image_name homeport_unix_user homeport_home_volume homeport_evaluated homeport_container_name
    export homeport_command_path="$action" homeport_namespace
    export -f usage abend getopt homeport homeport_exec homeport_emit_evaluated homeport_emit_evaluated_variable homeport_source_tarball homeport_labels

    "$action" "$@"
}
