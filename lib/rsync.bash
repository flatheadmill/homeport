rsync -av -e 'ssh -p 32768' ~/Sync/PrettyRobots/DetroitShapeFiles/ alan@192.168.99.100:~/DetroitShapeFiles/

"$@"

declare -a arguments

arguments=('-e' 'ssh -p '${port})

while [ $# -ne 0 ]; do
    case "$1" in
        homeport:*)
            value=${1#homeport:}
            value=${user}@${ip}:${value}
            arguments+=("$value")
            shift
            ;;
        *)
            arguments+=("$1")
            shift
            ;;
    esac
done

echo ${arguments}
