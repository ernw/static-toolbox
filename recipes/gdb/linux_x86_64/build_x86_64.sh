#!/bin/bash
set -e
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
    GDB_COMMIT=$(cd /build/binutils-gdb/ && git rev-parse --short HEAD)
}

build_musl_x86_64() {
    cd /build/musl
    git clean -fdx
    ./build.sh
    echo "[+] Finished building musl-cross x86_64"
}

build_gdb_x86_64() {
    cd /build/binutils-gdb
    git clean -fdx
    make clean || true

    cd /build/binutils-gdb/bfd
    CC='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-gcc -static -fPIC' \
        CXX='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-ld \
        LDFLAGS="" \
        ./configure
    make -j4
    
    cd /build/binutils-gdb/readline
    CC='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-gcc -static -fPIC' \
        CXX='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-ld \
        ./configure \
            --target=x86_64-linux-gnu \
            --disable-shared \
            --enable-static
    make -j4
    
    cd /build/binutils-gdb/opcodes
    CC='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-gcc -static -fPIC' \
        CXX='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-ld \
        ./configure \
            --target=x86_64-linux-gnu \
            --disable-shared \
            --enable-static
    make -j4
    
    cd /build/binutils-gdb/libiberty
    CC='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-gcc -static -fPIC' \
        CXX='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-ld \
        ./configure \
            --target=x86_64-linux-gnu \
            --disable-shared \
            --enable-static
    make -j4
    
    cd /build/binutils-gdb/libdecnumber
    CC='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-gcc -static -fPIC' \
        CXX='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-ld \
        ./configure \
            --target=x86_64-linux-gnu \
            --disable-shared \
            --enable-static
    make -j4
    
    cd /build/binutils-gdb/zlib
    CC='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-gcc -static -fPIC' \
        CXX='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-g++ -static -static-libstdc++ -fPIC' \
        cmake -DBUILD_SHARED_LIBS=OFF -DCMAKE_LINKER=/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-ld 
    make zlibstatic

    cd /build/binutils-gdb/gdb
    CC='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-gcc -static -fPIC' \
        CXX='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-ld \
        LDFLAGS='-static' \
        ./configure \
            --enable-static=yes \
            --host=x86_64-linux-gnu \
            --target=x86_64-linux-gnu \
            --disable-interprocess-agent
    make -j4
    
    cd /build/binutils-gdb/gdb/gdbserver/
    CC='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-gcc -static -fPIC' \
        CXX='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-ld \
        LDFLAGS='-static' \
        ./configure \
            --enable-static=yes \
            --disable-interprocess-agent
    make -j4
    
    /opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-strip /build/binutils-gdb/gdb/gdb /build/binutils-gdb/gdb/gdbserver/gdbserver
}

build_x86_64(){
    OUT_DIR_x86_64=/output/`uname | tr 'A-Z' 'a-z'`/x86_64
    mkdir -p $OUT_DIR_x86_64
    build_musl_x86_64
    build_gdb_x86_64
    GDB_VERSION=$(/build/binutils-gdb/gdb/gdb --version |head -n1 |awk '{print $4}')
    GDBSERVER_VERSION=$(/build/binutils-gdb/gdb/gdbserver/gdbserver --version |head -n1 |awk '{print $4}')
    cp /build/binutils-gdb/gdb/gdb "${OUT_DIR_x86_64}/gdb-${GDB_VERSION}-${GDB_COMMIT}"
    cp /build/binutils-gdb/gdb/gdbserver/gdbserver "${OUT_DIR_x86_64}/gdbserver-${GDBSERVER_VERSION}-${GDB_COMMIT}"
    echo "[+] Finished building x86_64"
}

main() {
    if [ ! -d "/output" ];then
        echo "[-] /output does not exist, creating it"
        mkdir /output
    fi
    fetch
    build_x86_64
}

main
