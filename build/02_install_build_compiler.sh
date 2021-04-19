#!/bin/bash
if [ $# -ne 1 ];then
    echo "Missing arch"
    exit 1
fi
ARCH="${1,,}"
case $ARCH in
    x86|x86_64|i686|arm|armhf|aarch64)
    ARCH="${ARCH}-linux-musl"
    ;;
    *)
    echo "Invalid arch ${ARCH}"
    exit 1
    ;;
esac
HOST=http://musl.cc
cd /
curl -so ${ARCH}-cross.tgz ${HOST}/${ARCH}-cross.tgz
tar -xf ${ARCH}-cross.tgz 
rm ${ARCH}-cross.tgz