#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport flatten
usage

"$homeport_path/lib/export" --archive - | "$homeport_path/lib/import" --archive -
