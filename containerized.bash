function homeport_source_tarball() {
    docker run --rm --entrypoint=/bin/bash homeport/homeport -c '(cd /usr/share/homeport && tar cf - .)'
}

function homeport_emit_evaluated() {
    return 1
}

homeport_evaluated=0
homeport_formula_path=docker:///homeport/homeport/usr/share/homeport
