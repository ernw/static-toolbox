#!/bin/sh
p=$(dirname "$0")
apk update && apk add bash
"$p"/install_deps_alpine.sh