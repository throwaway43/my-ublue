#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
