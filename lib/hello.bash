#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport hello

    description:

        Print a greeting to standard out.
usage

homeport_emit_evaluated && exit

echo "hello, world"
