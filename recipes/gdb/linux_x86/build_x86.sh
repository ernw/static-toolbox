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

build_musl_x86() {
    cd /build/musl
    git clean -fdx
    echo "ARCH=i486" >> config.sh
    echo "GCC_BUILTIN_PREREQS=yes" >> config.sh
    ./build.sh
    echo "[+] Finished building musl-cross x86"
}

build_gdb_x86() {
    cd /build/binutils-gdb
    git clean -fdx
    make clean || true

    cd /build/binutils-gdb/bfd
    CC='/opt/cross/i486-linux-musl/bin/i486-linux-musl-gcc -static -fPIC' \
        CXX='/opt/cross/i486-linux-musl/bin/i486-linux-musl-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/i486-linux-musl/bin/i486-linux-musl-ld \
        LDFLAGS="" \
        ./configure
    make -j4
    
    cd /build/binutils-gdb/readline
    CC='/opt/cross/i486-linux-musl/bin/i486-linux-musl-gcc -static -fPIC' \
        CXX='/opt/cross/i486-linux-musl/bin/i486-linux-musl-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/i486-linux-musl/bin/i486-linux-musl-ld \
        ./configure \
            --target=i686-linux-gnu \
            --disable-shared \
            --enable-static
    make -j4
    
    cd /build/binutils-gdb/opcodes
    CC='/opt/cross/i486-linux-musl/bin/i486-linux-musl-gcc -static -fPIC' \
        CXX='/opt/cross/i486-linux-musl/bin/i486-linux-musl-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/i486-linux-musl/bin/i486-linux-musl-ld \
        ./configure \
            --target=i686-linux-gnu \
            --disable-shared \
            --enable-static
    make -j4
    
    cd /build/binutils-gdb/libiberty
    CC='/opt/cross/i486-linux-musl/bin/i486-linux-musl-gcc -static -fPIC' \
        CXX='/opt/cross/i486-linux-musl/bin/i486-linux-musl-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/i486-linux-musl/bin/i486-linux-musl-ld \
        ./configure \
            --target=i686-linux-gnu \
            --disable-shared \
            --enable-static
    make -j4
    
    cd /build/binutils-gdb/libdecnumber
    CC='/opt/cross/i486-linux-musl/bin/i486-linux-musl-gcc -static -fPIC' \
        CXX='/opt/cross/i486-linux-musl/bin/i486-linux-musl-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/i486-linux-musl/bin/i486-linux-musl-ld \
        ./configure \
            --target=i686-linux-gnu \
            --disable-shared \
            --enable-static
    make -j4
    
    cd /build/binutils-gdb/zlib
    CC='/opt/cross/i486-linux-musl/bin/i486-linux-musl-gcc -static -fPIC' \
        CXX='/opt/cross/i486-linux-musl/bin/i486-linux-musl-g++ -static -static-libstdc++ -fPIC' \
        cmake -DBUILD_SHARED_LIBS=OFF -DCMAKE_LINKER=/opt/cross/i486-linux-musl/bin/i486-linux-musl-ld .
    make zlibstatic

    cd /build/binutils-gdb/gdb
    CC='/opt/cross/i486-linux-musl/bin/i486-linux-musl-gcc -m32 -static -fPIC' \
        CXX='/opt/cross/i486-linux-musl/bin/i486-linux-musl-g++ -m32 -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/i486-linux-musl/bin/i486-linux-musl-ld \
        ./configure \
            --enable-static=yes \
            --host=x86_64-linux-gnu \
            --target=i686-linux-gnu \
            --disable-interprocess-agent
    make -j4
    
    cd /build/binutils-gdb/gdb/gdbserver/
    CC='/opt/cross/i486-linux-musl/bin/i486-linux-musl-gcc -m32 -static -fPIC' \
        CXX='/opt/cross/i486-linux-musl/bin/i486-linux-musl-g++ -m32 -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/i486-linux-musl/bin/i486-linux-musl-ld \
        ./configure \
            --enable-static=yes \
            --host=x86_64-linux-gnu \
            --target=i686-linux-gnu \
            --disable-interprocess-agent
    make -j4
    
    /opt/cross/i486-linux-musl/bin/i486-linux-musl-strip /build/binutils-gdb/gdb/gdb /build/binutils-gdb/gdb/gdbserver/gdbserver
}

build_x86(){
    OUT_DIR_x86=/output/`uname | tr 'A-Z' 'a-z'`/x86
    mkdir -p $OUT_DIR_x86
    build_musl_x86
    build_gdb_x86
    GDB_VERSION=$(/build/binutils-gdb/gdb/gdb --version |head -n1 |awk '{print $4}')
    GDBSERVER_VERSION=$(/build/binutils-gdb/gdb/gdbserver/gdbserver --version |head -n1 |awk '{print $4}')
    cp /build/binutils-gdb/gdb/gdb "${OUT_DIR_x86}/gdb-${GDB_VERSION}-${GDB_COMMIT}"
    cp /build/binutils-gdb/gdb/gdbserver/gdbserver "${OUT_DIR_x86}/gdbserver-${GDBSERVER_VERSION}-${GDB_COMMIT}"
    echo "[+] Finished building x86"
}

main() {
    if [ ! -d "/output" ];then
        echo "[-] /output does not exist, creating it"
        mkdir /output
    fi
    fetch
    build_x86
}

main
