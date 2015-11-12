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

function homeport_get_hops_and_tag() {
    hompeort_hops=()
    while [ $# -ne 0 ]; do
        if [[ "$1" = *@* ]]; then
            homeport_hops+=("$1")
            shift
        else
            break
        fi
    done
    homeport_get_tag "$@"
}

function homeport_get_tag() {
    [ -z "$1" ] && abend "Tag name required"
    homeport_tag=$1
    shift
    if [[ "$homeport_tag" = *@* ]]; then
        homeport_unix_user=${homeport_tag%@*}
        homeport_tag=${homeport_tag#*@}
    else
        homeport_unix_user=$USER
    fi
    homeport_image="homeport/image-${homeport_tag}"
    homeport_home_container="homeport-home-${homeport_unix_user}"
    homeport_container="homeport-${homeport_tag}"
    if [ $# -eq 0 ]; then
        homeport_argv=''
    else
        printf -v homeport_argv ' %q' "$@"
    fi
}

function homeport_select_image() {
    [ -z "$1" ] && abend "Tag name required"
    homeport_tag=$1
    homeport_image="homeport/image-${homeport_tag}"
    homeport_container="homeport-${homeport_tag}"
}

function homeport_ssh_config() {
    dir=$1
    fetch=
    if [ ${#homeport_hops[@]} -eq 0 ]; then
        touch "$dir/config"
    else
        separator=
        for hop in "${homeport_hops[@]}"; do
            fetch+=$separator
            separator=' '
            ssh_host=${hop#*@}
            ssh_port=${ssh_host#*:}
            if [ "$ssh_port" = "$ssh_host" ]; then
                ssh_port=22
            fi
            ssh_host=${ssh_host%:*}
            ssh_user=${hop%@*}
            fetch+="ssh -A -p $ssh_port -l $ssh_user $ssh_host"
        done
        proxy_command="ProxyCommand $fetch -W %h:%p 2> /dev/null" >> "$dir/config"
    fi

    homeport_known_hosts=$(homeport_evaluatable known-hosts $homeport_tag | $fetch bash 2> /dev/null)

    IFS=: read -ra destination <<< "$(echo "$homeport_known_hosts" | sed 's/\[\([0-9.]*\)\]:\([0-9]*\).*/\1:\2/')"
    echo "$homeport_known_hosts" > "$dir/known_hosts"
    echo "Host ${destination[0]}" >> "$dir/config"
    echo "Port ${destination[1]}" >> "$dir/config"
    echo "UserKnownHostsFile $dir/known_hosts" >> "$dir/config"
    echo "$proxy_command" >> "$dir/config"
}
