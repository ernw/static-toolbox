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
init_lib $1

build_openssh() {
    fetch "https://github.com/openssh/openssh-portable.git" "${BUILD_DIRECTORY}/openssh-portable" git
    cd "${BUILD_DIRECTORY}/openssh-portable"
    git checkout V_7_9
    git clean -fdx
    autoreconf -i
    CC="gcc ${GCC_OPTS}" \
        CXX="g++ ${GXX_OPTS}" \
        CXXFLAGS="-I${BUILD_DIRECTORY}/openssl -I${BUILD_DIRECTORY}/binutils-gdb/zlib" \
        ./configure \
            --with-ssl-engine \
            --with-ssl-dir="${BUILD_DIRECTORY}/openssl" \
            --with-zlib="${BUILD_DIRECTORY}/binutils-gdb/zlib" \
            --with-ldflags=-static \
            --host="$(get_host_triple)"
    make -j4
    strip ssh sshd
}

main() {
    lib_build_openssl
    lib_build_zlib
    build_openssh
    if [ ! -f "${BUILD_DIRECTORY}/openssh-portable/ssh" -o \
         ! -f "${BUILD_DIRECTORY}/openssh-portable/sshd" ];then
        echo "[-] Building OpenSSH ${CURRENT_ARCH} failed!"
        exit 1
    fi
    OPENSSH_VERSION=$(get_version "${BUILD_DIRECTORY}/openssh-portable/ssh -V 2>&1 | awk '{print \$1}' | sed 's/,//g'")
    cp "${BUILD_DIRECTORY}/openssh-portable/ssh" "${OUTPUT_DIRECTORY}/ssh${OPENSSH_VERSION}"
    cp "${BUILD_DIRECTORY}/openssh-portable/sshd" "${OUTPUT_DIRECTORY}/sshd${OPENSSH_VERSION}"
    echo "[+] Finished building OpenSSH ${CURRENT_ARCH}"

    OPENSSH_VERSION=$(echo $OPENSSH_VERSION | sed 's/-//')
    echo ::set-output name=PACKAGED_NAME::"${OPENSSH_VERSION}"
    echo ::set-output name=PACKAGED_NAME_PATH::"/output/*"
}

main
