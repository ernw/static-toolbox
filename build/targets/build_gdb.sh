#!/bin/bash
set -e
set -o pipefail
set -x
if [ "$#" -ne 1 ];then
    echo "Usage: ${0} [x86|x86_64|armhf|aarch64]"
    echo "Example: ${0} x86_64"
    exit 1
fi
source $GITHUB_WORKSPACE/build/lib.sh
init_lib $1

build_gdb() {
    fetch "$GIT_BINUTILS_GDB" "${BUILD_DIRECTORY}/binutils-gdb" git
    cd "${BUILD_DIRECTORY}/binutils-gdb/" || { echo "Cannot cd to ${BUILD_DIRECTORY}/binutils-gdb/"; exit 1; }
    git checkout binutils-2_35-branch
    #git clean -fdx

    cd "${BUILD_DIRECTORY}/binutils-gdb/bfd"
    CC="gcc ${GCC_OPTS}" \
        CXX="g++ ${GXX_OPTS}" \
        ./configure \
            --host="$(get_host_triple)" \
            --disable-shared \
            --enable-static
    make -j4
    
    cd "${BUILD_DIRECTORY}/binutils-gdb/readline"
    CC="gcc ${GCC_OPTS}" \
        CXX="g++ ${GXX_OPTS}" \
        ./configure \
            --host="$(get_host_triple)" \
            --disable-shared \
            --enable-static
    make -j4
    
    cd "${BUILD_DIRECTORY}/binutils-gdb/opcodes"
    CC="gcc ${GCC_OPTS}" \
        CXX="g++ ${GXX_OPTS}" \
        ./configure \
            --host="$(get_host_triple)" \
            --disable-shared \
            --enable-static
    make -j4
    
    cd "${BUILD_DIRECTORY}/binutils-gdb/libiberty"
    CC="gcc ${GCC_OPTS}" \
        CXX="g++ ${GXX_OPTS}" \
        ./configure \
            --host="$(get_host_triple)" \
            --disable-shared \
            --enable-static
    make -j4
    
    cd "${BUILD_DIRECTORY}/binutils-gdb/libdecnumber"
    CC="gcc ${GCC_OPTS}" \
        CXX="g++ ${GXX_OPTS}" \
        ./configure \
            --host="$(get_host_triple)" \
            --disable-shared \
            --enable-static
    make -j4
    
    cd "${BUILD_DIRECTORY}/binutils-gdb/zlib"
    CC="gcc ${GCC_OPTS}" \
        CXX="g++ ${GXX_OPTS}" \
        /bin/bash ./configure \
            --host="$(get_host_triple)" \
            --enable-static
    make -j4

    cd "${BUILD_DIRECTORY}/binutils-gdb/gdb"
    CC="gcc ${GCC_OPTS}" \
        CXX="g++ ${GXX_OPTS}" \
        ./configure \
            --enable-static=yes \
            --host="$(get_host_triple)" \
            --disable-interprocess-agent
    make -j4
    
    cd "${BUILD_DIRECTORY}/binutils-gdb/gdb/gdbserver"
    CC="gcc ${GCC_OPTS}" \
        CXX="g++ ${GXX_OPTS}" \
        ./configure \
            --enable-static=yes \
            --host="$(get_host_triple)" \
            --disable-interprocess-agent
    make -j4
    
    strip "${BUILD_DIRECTORY}/binutils-gdb/gdb/gdb" "${BUILD_DIRECTORY}/binutils-gdb/gdb/gdbserver/gdbserver"
}

main() {
    build_gdb
    if [ ! -f "${BUILD_DIRECTORY}/binutils-gdb/gdb/gdb" -o \
         ! -f "${BUILD_DIRECTORY}/binutils-gdb/gdb/gdbserver/gdbserver" ];then
        echo "[-] Building GDB ${CURRENT_ARCH} failed!"
        exit 1
    fi
    GDB_VERSION=$(get_version "${BUILD_DIRECTORY}/binutils-gdb/gdb/gdb --version |head -n1 |awk '{print \$4}'")
    GDBSERVER_VERSION=$(get_version "${BUILD_DIRECTORY}/binutils-gdb/gdb/gdbserver/gdbserver --version |head -n1 |awk '{print \$4}'")
    cp "${BUILD_DIRECTORY}/binutils-gdb/gdb/gdb" "${OUTPUT_DIRECTORY}/gdb${GDB_VERSION}"
    cp "${BUILD_DIRECTORY}/binutils-gdb/gdb/gdbserver/gdbserver" "${OUTPUT_DIRECTORY}/gdbserver${GDBSERVER_VERSION}"
    echo "[+] Finished building GDB ${CURRENT_ARCH}"

    echo ::set-output name=PACKAGED_NAME::"gdb${GDB_VERSION}"
    echo ::set-output name=PACKAGED_NAME_PATH::"/output/*"
}

main
