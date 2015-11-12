
function homeport_evaluatable() {
    "$homeport_path/homeport.bash" --evaluated "$@"
}

function homeport_exec() {
    # Node that the `+` in the options sets scanning mode to stop at the first
    # non-option parameter, otherwise we'd have to explicilty use `--` before the
    # sub-command.
    declare argv
    argv=$(getopt --options +e --long evaluated -- "$@") || abend "cannot parse arguments"
    eval "set -- $argv"

    while true; do
        case "$1" in
            --evaluated | -e)
                homeport_evaluated=1
                shift
                ;;
            --)
                shift
                break
                ;;
        esac
    done

    local command=$1

    [ -z "$command" ] && abend "TODO: write usage"

    local action="$homeport_path/bin/$command.bash"

    [ ! -e "$action"  ] && abend "invalid action: homeport $command"

    shift

    homeport_image=homeport/${homeport_unix_user}_${homeport_tag}
    homeport_container=homeport-${homeport_unix_user}_${homeport_tag}
    homeport_home_container="homeport_${homeport_unix_user}_home"

    homeport_formula_path="$homeport_path"

    export homeport_path homeport_docker_hub_account homeport_unix_user \
        homeport_tag homeport_image homeport_unix_user \
        homeport_home_container homeport_evaluated homeport_container \
        homeport_formula_path homeport_host_os
    export homeport_command_path="$action" homeport_namespace
    export -f getopt usage abend homeport \
        homeport_exec homeport_emit_evaluated homeport_emit_evaluated_variable \
        homeport_source_tarball homeport_get_tag homeport_get_hops_and_tag \
        homeport_select_image homeport_ssh_config homeport_evaluatable

    "$action" "$@"
}

function homeport_emit_evaluated_variable() {
    local name=$1
    eval 'local value=$(echo $'$name')'
    echo "$name=$(printf %q $value)"
}

function homeport_emit_evaluated() {
    if [ "$homeport_evaluated" -eq 1 ]; then
        # todo: is this all necessary?
        # todo: is this at all necessary?
        homeport_emit_evaluated_variable homeport_unix_user
        homeport_emit_evaluated_variable homeport_namespace
        homeport_emit_evaluated_variable homeport_tag
        homeport_emit_evaluated_variable homeport_image_name
        homeport_emit_evaluated_variable hoemport_home_container
        homeport_emit_evaluated_variable homeport_host_os
        printf -v vargs '%q ' "$@"
        echo ''
        echo 'eval set -- '$vargs
        echo ''
        cat "$homeport_path/lib/common.bash"
        echo ''
        cat "$homeport_path/lib/containerized.bash"
        echo ''
        cat "$homeport_path/lib/getopt.bash"
        echo ''
        cat "$homeport_command_path"
    else
        return 1
    fi
}

function homeport_source_tarball() {
    cd "$homeport_path" && tar cf - .
}
