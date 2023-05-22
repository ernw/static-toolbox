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

build_autogen(){
    fetch "http://ftp.gnu.org/gnu/autogen/rel5.16.2/autogen-5.16.2.tar.gz" "${BUILD_DIRECTORY}/autogen" http
    cd "${BUILD_DIRECTORY}/autogen"
    automake
    CFLAGS="${GCC_OPTS}" \
        CXXFLAGS="${GXX_OPTS}" \
        CPPFLAGS="-static" \
        LDFLAGS="-static" \
        ./configure \
            --host="$(get_host_triple)"
    make -j4
    make install
}

build_tcpreplay() {
    fetch "https://github.com/appneta/tcpreplay.git" "${BUILD_DIRECTORY}/tcpdump" git
    cd "${BUILD_DIRECTORY}/tcpreplay"
    git clean -fdx
    git checkout v4.3.3
    export LIBPCAP_PATH="${BUILD_DIRECTORY}/libpcap"
    ./autogen.sh
    CFLAGS="${GCC_OPTS} -I${LIBPCAP_PATH} -L${LIBPCAP_PATH}" \
        CXXFLAGS="${GXX_OPTS}" \
        CPPFLAGS="-static" \
        LDFLAGS="-static" \
        ./configure \
            --host="$(get_host_triple)"
    make -j4
    strip tcpreplay
}

main() {
    lib_build_libpcap
    build_autogen
    build_tcpreplay
    local version
    version=$(get_version "${BUILD_DIRECTORY}/tcpreplay/tcpreplay --version 2>&1 | head -n1 | awk '{print \$3}'")
    cp "${BUILD_DIRECTORY}/tcpreplay/tcpreplay" "${OUTPUT_DIRECTORY}/tcpreplay"
    echo "[+] Finished building tcpreplay ${CURRENT_ARCH}"

    echo "PACKAGED_NAME=tcpreplay${version}"
    echo "PACKAGED_NAME_PATH=${OUTPUT_DIRECTORY}/*"
}

main
