#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport update

    description:

        Update Homeport by pulling from GitHub.
usage

(cd $HOMEPORT_PATH && git pull)
