#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport flatten
usage

"$HOMEPORT_PATH/lib/export" --archive - | "$HOMEPORT_PATH/lib/import" --archive -
