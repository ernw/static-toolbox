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

build_tcpdump() {
    fetch "https://github.com/the-tcpdump-group/tcpdump.git" "${BUILD_DIRECTORY}/tcpdump" git
    cd "${BUILD_DIRECTORY}/tcpdump"
    git clean -fdx
    git checkout tcpdump-4.9.3
    export LIBPCAP_PATH="${BUILD_DIRECTORY}/libpcap"
    CFLAGS="${GCC_OPTS} -I${LIBPCAP_PATH} -L${LIBPCAP_PATH}" \
        CXXFLAGS="${GXX_OPTS}" \
        CPPFLAGS="-static" \
        LDFLAGS="-static" \
        ./configure \
            --host="$(get_host_triple)"
    make -j4
    strip tcpdump
}

main() {
    lib_build_libpcap
    build_tcpdump
    local version
    version=$(get_version "${BUILD_DIRECTORY}/tcpdump/tcpdump --version 2>&1 | head -n1 | awk '{print \$3}'")
    cp "${BUILD_DIRECTORY}/tcpdump/tcpdump" "${OUTPUT_DIRECTORY}/tcpdump"
    echo "[+] Finished building tcpdump ${CURRENT_ARCH}"

    echo ::set-output name=PACKAGED_NAME::"tcpdump${version}"
    echo ::set-output name=PACKAGED_NAME_PATH::"${OUTPUT_DIRECTORY}/*"
}

main
