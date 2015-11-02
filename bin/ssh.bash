#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport append

    options:

        -t, --tag <string>
            an optional tag for the image so you can create different images
usage

homeport_emit_evaluated "$@" && exit

trap cleanup EXIT SIGTERM SIGINT

dir=$(mktemp -d -t homeport_ssh.XXXXXXX)

function cleanup() {
    local pids=$(jobs -pr)
    [ -n "$pids" ] && kill $pids
    [ ! -z "$dir" ] && rm -rf "$dir"
}

hops=()
while [ $# -ne 0 ]; do
    if [[ "$1" = *@* ]]; then
        hops+=("$1")
        shift
    else
        break
    fi
done

homeport_labels $1 && shift

fetch=
if [ ${#hops[@]} -eq 0 ]; then
    touch "$dir/config"
else
    separator=
    for hop in "${hops[@]}"; do
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

homeport_known_hosts=$(homeport_exec --evaluated known-hosts $homeport_tag | $fetch bash 2> /dev/null)

IFS=: read -ra destination <<< "$(echo "$homeport_known_hosts" | sed 's/\[\([0-9.]*\)\]:\([0-9]*\).*/\1:\2/')"
echo "$homeport_known_hosts" > "$dir/known_hosts"
echo "Host ${destination[0]}" >> "$dir/config"
echo "Port ${destination[1]}" >> "$dir/config"
echo "UserKnownHostsFile $dir/known_hosts" >> "$dir/config"
echo "$proxy_command" >> "$dir/config"

ssh -F "$dir/config" -l homeport "${destination[0]}" "$@"
