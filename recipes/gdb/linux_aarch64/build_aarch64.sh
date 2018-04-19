#!/bin/bash
#set -e
set -o pipefail
set -x
NMAP_COMMIT=

fetch(){
    if [ ! -d "/build/musl" ];then
        #git clone https://github.com/GregorR/musl-cross.git /build/musl
        git clone https://github.com/takeshixx/musl-cross.git /build/musl
    fi
    if [ ! -d "/build/binutils-gdb" ];then
        git clone https://github.com/bminor/binutils-gdb.git /build/binutils-gdb
    fi
    cd /build/binutils-gdb
    git checkout binutils-2_30
    cd -
}

build_musl_aarch64() {
    cd /build/musl
    git clean -fdx
    echo "ARCH=arm64" >> config.sh
    echo "GCC_BUILTIN_PREREQS=yes" >> config.sh
    echo "TRIPLE=aarch64-linux-musleabi" >> config.sh
    ./build.sh
    echo "[+] Finished building musl-cross aarch64"
}

build_gdb_aarch64() {
    cd /build/binutils-gdb
    git clean -fdx
    make clean || true

    cd /build/binutils-gdb/bfd
    CC='/opt/cross/aarch64-linux-musleabi/bin/aarch64-linux-musleabi-gcc -static -fPIC' \
        CXX='/opt/cross/aarch64-linux-musleabi/bin/aarch64-linux-musleabi-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/aarch64-linux-musleabi/bin/aarch64-linux-musleabi-ld \
        ./configure \
            --host=x86_64-linux-gnu \
            --target=aarch64-none-linux-gnueabi
    make -j4
    
    cd /build/binutils-gdb/readline
    CC='/opt/cross/aarch64-linux-musleabi/bin/aarch64-linux-musleabi-gcc -static -fPIC' \
        CXX='/opt/cross/aarch64-linux-musleabi/bin/aarch64-linux-musleabi-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/aarch64-linux-musleabi/bin/aarch64-linux-musleabi-ld \
        ./configure \
            --host=x86_64-linux-gnu \
            --target=aarch64-none-linux-gnueabi \
            --disable-shared \
            --enable-static
    make -j4
    
    cd /build/binutils-gdb/opcodes
    CC='/opt/cross/aarch64-linux-musleabi/bin/aarch64-linux-musleabi-gcc -static -fPIC' \
        CXX='/opt/cross/aarch64-linux-musleabi/bin/aarch64-linux-musleabi-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/aarch64-linux-musleabi/bin/aarch64-linux-musleabi-ld \
        ./configure \
            --host=x86_64-linux-gnu \
            --target=aarch64-none-linux-gnueabi \
            --disable-shared \
            --enable-static
    make -j4
    
    cd /build/binutils-gdb/libiberty
    CC='/opt/cross/aarch64-linux-musleabi/bin/aarch64-linux-musleabi-gcc -static -fPIC' \
        CXX='/opt/cross/aarch64-linux-musleabi/bin/aarch64-linux-musleabi-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/aarch64-linux-musleabi/bin/aarch64-linux-musleabi-ld \
        ./configure \
            --host=x86_64-linux-gnu \
            --target=aarch64-none-linux-gnueabi \
            --disable-shared \
            --enable-static
    make -j4
    
    cd /build/binutils-gdb/libdecnumber
    CC='/opt/cross/aarch64-linux-musleabi/bin/aarch64-linux-musleabi-gcc -static -fPIC' \
        CXX='/opt/cross/aarch64-linux-musleabi/bin/aarch64-linux-musleabi-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/aarch64-linux-musleabi/bin/aarch64-linux-musleabi-ld \
        ./configure \
            --host=x86_64-linux-gnu \
            --target=aarch64-none-linux-gnueabi \
            --disable-shared \
            --enable-static
    make -j4
    
    cd /build/binutils-gdb/zlib
    CC='/opt/cross/aarch64-linux-musleabi/bin/aarch64-linux-musleabi-gcc -static -fPIC' \
        CXX='/opt/cross/aarch64-linux-musleabi/bin/aarch64-linux-musleabi-g++ -static -static-libstdc++ -fPIC' \
        cmake -DBUILD_SHARED_LIBS=OFF -DCMAKE_LINKER=/opt/cross/aarch64-linux-musleabi/bin/aarch64-linux-musleabi-ld .
    make zlibstatic

    cd /build/binutils-gdb/gdb
    CC='/opt/cross/aarch64-linux-musleabi/bin/aarch64-linux-musleabi-gcc -static -fPIC' \
        CXX='/opt/cross/aarch64-linux-musleabi/bin/aarch64-linux-musleabi-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/aarch64-linux-musleabi/bin/aarch64-linux-musleabi-ld \
        LDFLAGS='-static' \
        ./configure \
            --enable-static=yes \
            --host=x86_64-linux-gnu \
            --target=aarch64-none-linux-gnueabi \
            --disable-interprocess-agent
    make -j4
    
    cd /build/binutils-gdb/gdb/gdbserver/
    CC='/opt/cross/aarch64-linux-musleabi/bin/aarch64-linux-musleabi-gcc -static -fPIC' \
        CXX='/opt/cross/aarch64-linux-musleabi/bin/aarch64-linux-musleabi-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/aarch64-linux-musleabi/bin/aarch64-linux-musleabi-ld \
        LDFLAGS='-static' \
        ./configure \
            --enable-static=yes \
            --host=x86_64-linux-gnu \
            --target=aarch64-none-linux-gnueabi \
            --disable-interprocess-agent
    make -j4
    
    /opt/cross/aarch64-linux-musleabi/bin/aarch64-linux-musleabi-strip /build/binutils-gdb/gdb/gdb /build/binutils-gdb/gdb/gdbserver/gdbserver
}

build_aarch64(){
    OUT_DIR=/output/`uname | tr 'A-Z' 'a-z'`/aarch64
    mkdir -p $OUT_DIR
    build_musl_aarch64
    build_gdb_aarch64
    GDB_VERSION=
    GDBSERVER_VERSION=
    if which qemu-aarch64 >/dev/null;then
        GDB_VERSION="-$(qemu-aarch64 /build/binutils-gdb/gdb/gdb --version |head -n1 |awk '{print $4}')"
        GDBSERVER_VERSION="-$(qemu-aarch64 /build/binutils-gdb/gdb/gdbserver/gdbserver --version |head -n1 |awk '{print $4}')"
    fi
    cp /build/binutils-gdb/gdb/gdb "${OUT_DIR}/gdb-aarch64${GDB_VERSION}"
    cp /build/binutils-gdb/gdb/gdbserver/gdbserver "${OUT_DIR}/gdbserver-aarch64${GDBSERVER_VERSION}"
    echo "[+] Finished building aarch64"
}

main() {
    if [ ! -d "/output" ];then
        echo "[-] /output does not exist, creating it"
        mkdir /output
    fi
    fetch
    build_aarch64
}

main
