#!/bin/bash

# Change to default working directory
cd /home/jovyan/work/

# git requires e-mail and password for cloning and committing,
# even when authenticating via HTTPS
git config --global user.email anon@anon.noo
git config --global user.name anon
