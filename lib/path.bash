#!/bin/bash

set -e

homeport module <<-usage
    usage: homeport path

    description:

        Print the location of the Homeport directory. Useful if you you're
        trying to locate the default Homeport formulas.
usage

echo $homeport_path
