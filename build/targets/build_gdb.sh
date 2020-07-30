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
    git clean -fdx
    git checkout gdb-8.3.1-release

    CMD="CFLAGS=\"${GCC_OPTS}\" "
    CMD+="CXXFLAGS=\"${GXX_OPTS}\" "
    CMD+="LDFLAGS=\"-static -pthread\" "
    if [ "$CURRENT_ARCH" != "x86" ] && "$CURRENT_ARCH" != "x86_64" ];then
        CMD+="CC_FOR_BUILD=\"/x86_64-linux-musl-cross/bin/x86_64-linux-musl-gcc\" "
        CMD+="CPP_FOR_BUILD=\"/x86_64-linux-musl-cross/bin/x86_64-linux-musl-g++\" "
    fi
    CMD+="./configure --target=$(get_host_triple) --host=x86_64-unknown-linux-musl "
    CMD+="--disable-shared --enable-static"

    GDB_CMD="${CMD} --disable-interprocess-agent"

    cd "${BUILD_DIRECTORY}/binutils-gdb/bfd"
    eval "$CMD"
    make -j4
    
    cd "${BUILD_DIRECTORY}/binutils-gdb/readline"
    eval "$CMD"
    make -j4
    
    cd "${BUILD_DIRECTORY}/binutils-gdb/opcodes"
    eval "$CMD"
    make -j4
    
    cd "${BUILD_DIRECTORY}/binutils-gdb/libiberty"
    eval "$CMD"
    make -j4
    
    cd "${BUILD_DIRECTORY}/binutils-gdb/libdecnumber"
    eval "$CMD"
    make -j4
    
    cd "${BUILD_DIRECTORY}/binutils-gdb/zlib"
    eval "$CMD"
    make -j4

    cd "${BUILD_DIRECTORY}/binutils-gdb/gdb"
    eval "$GDB_CMD"
    make -j4
    
    cd "${BUILD_DIRECTORY}/binutils-gdb/gdb/gdbserver"
    eval "$GDB_CMD"
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
