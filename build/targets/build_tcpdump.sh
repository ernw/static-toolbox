#!/bin/bash
if [ -z "$GITHUB_WORKSPACE" ];then
    echo "GITHUB_WORKSPACE environemnt variable not set!"
    exit 1
fi
if [ "$#" -ne 1 ];then
    echo "Usage: ${0} [x86|x86_64|armhf|aarch64]"
    echo "Example: ${0} x86_64"
    exit 1
fi
set -e
set -o pipefail
set -x
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
    version_number=$(echo "$version" | cut -d"-" -f2)
    cp "${BUILD_DIRECTORY}/tcpdump/tcpdump" "${OUTPUT_DIRECTORY}/tcpdump${version}"
    echo "[+] Finished building tcpdump ${CURRENT_ARCH}"

    echo "PACKAGED_NAME=tcpdump${version}" >> $GITHUB_OUTPUT
    echo "PACKAGED_NAME_PATH=${OUTPUT_DIRECTORY}/*" >> $GITHUB_OUTPUT
    echo "PACKAGED_VERSION=${version_number}" >> $GITHUB_OUTPUT
}

main
