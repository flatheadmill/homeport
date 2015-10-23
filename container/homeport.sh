#!/bin/bash

bash -c "$(docker run -e USER=$USER --rm homeport/homeport --evaluated "$@")"
