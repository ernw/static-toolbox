#!/bin/bash
set -e
set -x
set -o pipefail
if [ "$#" -ne 1 ];then
    echo "Usage: ${0} [x86|x86_64|armhf|aarch64]"
    echo "Example: ${0} x86_64"
    exit 1
fi
source $GITHUB_WORKSPACE/build/lib.sh
init_lib "$1"

build_strace() {
    fetch "https://github.com/strace/strace" "${BUILD_DIRECTORY}/strace" git
    cd "${BUILD_DIRECTORY}/strace"
    git clean -fdx
    git checkout v5.7
    ./bootstrap
    CMD="CFLAGS=\"${GCC_OPTS}\" "
    CMD+="CXXFLAGS=\"${GXX_OPTS}\" "
    CMD+="LDFLAGS=\"-static -pthread\" "
    if [ "$CURRENT_ARCH" != "x86" ] && [ "$CURRENT_ARCH" != "x86_64" ];then
        CMD+="CC_FOR_BUILD=\"/i686-linux-musl-cross/bin/i686-linux-musl-gcc\" "
        CMD+="CPP_FOR_BUILD=\"/i686-linux-musl-cross/bin/i686-linux-musl-g++\" "
    fi
    CMD+="./configure --host=i486-linux-musl --target=$(get_host_triple)"
    eval "$CMD"
    make CFLAGS="-w" -j4
    strip strace
}

main() {
    build_strace
    local version
    version=$(get_version "${BUILD_DIRECTORY}/strace/strace --version 2>&1 | head -n1 | awk '{print \$4}'")
    cp "${BUILD_DIRECTORY}/strace/strace" "${OUTPUT_DIRECTORY}/strace"
    echo "[+] Finished building strace ${CURRENT_ARCH}"

    echo "PACKAGED_NAME=strace${version}" >> $GITHUB_OUTPUT
    echo "PACKAGED_NAME_PATH=${OUTPUT_DIRECTORY}/*" >> $GITHUB_OUTPUT
}

main
