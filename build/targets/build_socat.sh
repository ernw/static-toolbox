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

build_socat() {
    fetch "http://repo.or.cz/socat.git" "${BUILD_DIRECTORY}/socat" git
    cd "${BUILD_DIRECTORY}/socat"
    git clean -fdx
    autoconf
    CFLAGS="${GCC_OPTS}" \
        CXXFLAGS="${GXX_OPTS}" \
        CPPFLAGS="-I${BUILD_DIRECTORY} -I${BUILD_DIRECTORY}/openssl/include -DNETDB_INTERNAL=-1" \
        LDFLAGS="-L${BUILD_DIRECTORY}/readline -L${BUILD_DIRECTORY}/ncurses/lib -L${BUILD_DIRECTORY}/openssl" \
        ./configure \
            --host="$(get_host_triple)"
    make -j4
    strip socat
}

main() {
    #sudo apt install yodl
    lib_build_openssl
    lib_build_ncurses
    lib_build_readline
    build_socat
    local version
    version=$(get_version "${BUILD_DIRECTORY}/socat/socat -V | grep 'socat version' | awk '{print \$3}'")
    cp "${BUILD_DIRECTORY}/socat/socat" "${OUTPUT_DIRECTORY}/socat${version}"
    echo "[+] Finished building socat ${CURRENT_ARCH}"

    echo ::set-output name=PACKAGED_NAME::"socat${version}"
    echo ::set-output name=PACKAGED_NAME_PATH::"${OUTPUT_DIRECTORY}/*"
}

main
