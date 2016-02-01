#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport version

    description:

        Print the current version of Homeport.
usage

homeport_emit_evaluated && exit

echo "1.0.6"
