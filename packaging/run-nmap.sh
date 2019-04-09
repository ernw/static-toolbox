#!/bin/bash
SOURCE="${BASH_SOURCE[0]}"
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
NMAPDIR="$SCRIPT_DIR/data" "$SCRIPT_DIR/nmap" $@
