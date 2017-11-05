#!/usr/bin/env bash

# Install the Stackdriver monitoring agent
curl -sSL https://repo.stackdriver.com/stack-install.sh | sudo bash -s -- --write-gcm
