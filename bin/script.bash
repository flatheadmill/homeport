#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport script <path>

    description:

        Create a script that will run a containerzed homeport.
usage

homeport_emit_evaluated "$@" && exit

script=$1

[ ! -z "$script" ] || abend "path to script is required"

mkdir -p "${script%/*}"

cat << 'EOF' > "$script"
#!/bin/bash

bash -c "$(docker run --rm homeport/homeport "$@")"
EOF

chmod +x "$script"
