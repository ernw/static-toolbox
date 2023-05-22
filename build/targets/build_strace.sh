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

VERSION="v6.3"

build_strace() {
    fetch "https://github.com/strace/strace" "${BUILD_DIRECTORY}/strace" git
    cd "${BUILD_DIRECTORY}/strace"
    git clean -fdx
    git checkout "$VERSION"
    ./bootstrap
    CMD="CFLAGS=\"${GCC_OPTS}\" "
    CMD+="CXXFLAGS=\"${GXX_OPTS}\" "
    CMD+="LDFLAGS=\"-static -pthread\" "
    if [ "$CURRENT_ARCH" != "x86_64" ];then
        CMD+="CC_FOR_BUILD=\"/x86_64-linux-musl-cross/bin/x86_64-linux-musl-gcc\" "
        CMD+="CPP_FOR_BUILD=\"/x86_64-linux-musl-cross/bin/x86_64-linux-musl-g++ -E\" "
        CMD+="CXX_FOR_BUILD=\"/x86_64-linux-musl-cross/bin/x86_64-linux-musl-g++\" "
    fi
    CMD+="./configure --disable-mpers --host=$(get_host_triple)"
    eval "$CMD"
    make CFLAGS="-w" -j4
    strip "${BUILD_DIRECTORY}/strace/src/strace"
}

main() {
    build_strace
    local version
    version=$(get_version "${BUILD_DIRECTORY}/strace/src/strace -V 2>&1 | head -n1 | awk '{print \$4}'")
    version_number=$(echo "$version" | cut -d"-" -f2)
    cp "${BUILD_DIRECTORY}/strace/src/strace" "${OUTPUT_DIRECTORY}/strace${version}"
    echo "[+] Finished building strace ${CURRENT_ARCH}"

    echo "PACKAGED_NAME=strace${version}" >> $GITHUB_OUTPUT
    echo "PACKAGED_NAME_PATH=${OUTPUT_DIRECTORY}/*" >> $GITHUB_OUTPUT
    echo "PACKAGED_VERSION=${version_number}" >> $GITHUB_OUTPUT
}

main
