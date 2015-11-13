#!/bin/bash

docker='/var/lib/homeport/bin/docker'

fixup_volume() {
    local volume=$1 host= rest=
    if [[ "$volume" = *:* ]]; then
        host=${volume%%:*}
        rest=":${volume#*:}"
    else
        host=$volume
    fi
    local host_dir=$host expanded=
    while [ -L "$host" ]; do
        expanded=$(homeport_readlink "$host")
        pushd "${host%/*}" > /dev/null
        pushd "${expanded%/*}" > /dev/null
        host_dir=$(pwd)
        popd > /dev/null
        popd > /dev/null
        homeport_home="$host_dir/${host##*/}"
    done
    host_dir=$host
    while [ "/home/homeport" != "$host_dir"  ]; do
        host_dir=${host_dir%/*}
        [ -z "$host_dir" ] && abend "Volumes be a child of host home directory."
    done
    echo "--volume=$HOMEPORT_HOST_HOME/${host#/home/homeport/}$rest"
}

while [ $# -ne 0 ]; do
    case "$1" in
        --debug | --help | --tls | --tlsverify | --version)
            docker+=' '$(printf %q "$1")
            shift
            if [[ "$1" != -* ]]; then
                docker+=' '$(printf %q "$1")
                shift
            fi
            ;;
        -D | -h | -v)
            docker+=' '$(printf %q "$1")
            shift
            ;;
        --host | -H | --log-level | --tlscacert | --tlscert | --tlsverify)
            docker+=' '$(printf %q "$1")
            shift
            docker+=' '$(printf %q "$1")
            shift
            ;;
        *)
            break
            ;;
    esac
done

if [ $# -ne 0 ]; then
    if [ "$1" = "run" ]; then
        docker+=' '$(printf %q "$1")
        shift
        echo $docker
        while [ $# -ne 0 ]; do
            case "$1" in
                --detach=* | --disble-content-trust=* | --help=* | --interactive=* | \
                --oom-kill-disable=* | --publish-all=* | --privileged=* | --read-only=* | \
                --rm=* | --sig-proxy=* | --tty=*)
                    docker+=' '$(printf %q "$1")
                    shift
                    ;;
                --detach | --disble-content-trust | --help | --interactive | \
                --oom-kill-disable | --publish-all | --privileged | --read-only | \
                --rm | --sig-proxy | --tty)
                    docker+=' '$(printf %q "$1")
                    shift
                    if [[ "$1" != -* ]]; then
                        docker+=' '$(printf %q "$1")
                        shift
                    fi
                    ;;
                -d | -i | -P | -t)
                    docker+=' '$(printf %q "$1")
                    shift
                    ;;
                --attach=* | --add-host=* | --blkio-weight=* | --cpu-shares=* | \
                    --cap-add=* | --cap-drop=* | --cgroup-parent=* | --cidfile=* | \
                    --cpu-period=* | --cpu-quota=* | --cpuset-cpus=* | --cpuset-mems=* | \
                    --device=* | --dns=* | --dns-search=* | --env=* | --entrypoint=* | \
                    --env-file=* | --expose=* | --group-add=* | --hostname=* | \
                    --ipc=* | --label=* | --link=* | --log-driver=* | --log-opt=* | \
                    --lxc-conf=* | --memory=* | --mac-address=* | --memory-swap=* | \
                    --memory-swappiness=* | --name=* | --net=* | --publish=* | \
                    --pid=* | --restart=* | --security-opt=* | --user=* | --ulimit=* | \
                    --uts=* | --volume-driver=* | --volumes-from=* | --workdir=*)
                    docker+=' '$(printf %q "$1")
                    shift
                    ;;
                -a | --attach | --add-host | --blkio-weight | -c | --cpu-shares | \
                    --cap-add | --cap-drop | --cgroup-parent | --cidfile | \
                    --cpu-period | --cpu-quota | --cpuset-cpus | --cpuset-mems | \
                    --device | --dns | --dns-search | -e | --env | --entrypoint | \
                    --env-file | --expose | --group-add | -h | --hostname | \
                    --ipc | -l | --label | --link | --log-driver | --log-opt | \
                    --lxc-conf | -m | --memory | --mac-address | --memory-swap | \
                    --memory-swappiness | --name | --net | -p | --publish | \
                    --pid | --restart | --security-opt | -u | --user | --ulimit | \
                    --uts | --volume-driver | --volumes-from | -w | --workdir)
                    docker+=' '$(printf %q "$1")
                    shift
                    ;;
                --volume=*)
                    path=${1#--volume=}
                    shift
                    docker+=' '$(fixup_volume "$path")
                    ;;
                -v | --volume)
                    shift
                    path=$1
                    shift
                    docker+=' '$(fixup_volume "$path")
                    ;;
                *)
                    docker+=$(printf ' %q' "$@")
                    break
                    ;;
            esac
        done
    else
        docker+=$(printf ' %q' "$@")
    fi
fi

eval $docker
