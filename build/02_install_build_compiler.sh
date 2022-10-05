#!/bin/bash

function die(){
    echo "$1"
    exit 1
}

if [ $# -ne 1 ];then
    echo "Missing arch"
    exit 1
fi
ARCH="${1}"
case $ARCH in
    x86_64|i686|aarch64)
        ARCH="${ARCH}-linux-musl"
        ;;
    x86)
        ARCH="i686-linux-musl"
        ;;
    arm)
        ARCH="arm-linux-musleabihf"
        ;;
    *)
        echo "Invalid arch ${ARCH}"
        exit 1
        ;;
esac
HOST=http://musl.cc
echo "Fetching ${HOST}/${ARCH}-cross.tgz"
cd /
curl -so ${ARCH}-cross.tgz ${HOST}/${ARCH}-cross.tgz || die "Failed to download build compiler package"
tar -xf ${ARCH}-cross.tgz || die "Failed to extract build compiler package"
rm ${ARCH}-cross.tgz || die "Failed to remove build compiler package"