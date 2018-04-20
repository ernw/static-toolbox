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

build_musl_armhf() {
    cd /build/musl
    git clean -fdx
    echo "ARCH=arm" >> config.sh
    echo "GCC_BUILTIN_PREREQS=yes" >> config.sh
    echo "TRIPLE=arm-linux-musleabihf" >> config.sh
    echo "GCC_BOOTSTRAP_CONFFLAGS='--with-arch=armv7-a --with-float=hard --with-fpu=vfpv3-d16'" >> config.sh
    echo "GCC_CONFFLAGS='--with-arch=armv7-a --with-float=hard --with-fpu=vfpv3-d16'" >> config.sh
    ./build.sh
    echo "[+] Finished building musl-cross armhf"
}

build_gdb_armhf() {
    cd /build/binutils-gdb
    git clean -fdx
    make clean || true

    cd /build/binutils-gdb/bfd
    CC='/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-gcc -static -fPIC' \
        CXX='/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-ld \
        ./configure \
            --host=x86_64-linux-gnu \
            --target=arm-none-linux-gnueabi
    make -j4
    
    cd /build/binutils-gdb/readline
    CC='/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-gcc -static -fPIC' \
        CXX='/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-ld \
        ./configure \
            --host=x86_64-linux-gnu \
            --target=arm-none-linux-gnueabi \
            --disable-shared \
            --enable-static
    make -j4
    
    cd /build/binutils-gdb/opcodes
    CC='/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-gcc -static -fPIC' \
        CXX='/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-ld \
        ./configure \
            --host=x86_64-linux-gnu \
            --target=arm-none-linux-gnueabi \
            --disable-shared \
            --enable-static
    make -j4
    
    cd /build/binutils-gdb/libiberty
    CC='/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-gcc -static -fPIC' \
        CXX='/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-ld \
        ./configure \
            --host=x86_64-linux-gnu \
            --target=arm-none-linux-gnueabi \
            --disable-shared \
            --enable-static
    make -j4
    
    cd /build/binutils-gdb/libdecnumber
    CC='/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-gcc -static -fPIC' \
        CXX='/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-ld \
        ./configure \
            --host=x86_64-linux-gnu \
            --target=arm-none-linux-gnueabi \
            --disable-shared \
            --enable-static
    make -j4
    
    cd /build/binutils-gdb/zlib
    CC='/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-gcc -static -fPIC' \
        CXX='/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-g++ -static -static-libstdc++ -fPIC' \
        cmake -DBUILD_SHARED_LIBS=OFF -DCMAKE_LINKER=/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-ld .
    make zlibstatic

    cd /build/binutils-gdb/gdb
    CC='/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-gcc -static -fPIC' \
        CXX='/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-ld \
        LDFLAGS='-static' \
        ./configure \
            --enable-static=yes \
            --host=x86_64-linux-gnu \
            --target=arm-none-linux-gnueabi \
            --disable-interprocess-agent
    make -j4
    
    cd /build/binutils-gdb/gdb/gdbserver/
    CC='/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-gcc -static -fPIC' \
        CXX='/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-g++ -static -static-libstdc++ -fPIC' \
        LD=/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-ld \
        LDFLAGS='-static' \
        ./configure \
            --host=x86_64-linux-gnu \
            --target=arm-none-linux-gnueabi \
            --enable-static=yes \
            --disable-interprocess-agent
    make -j4
    
    /opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-strip /build/binutils-gdb/gdb/gdb /build/binutils-gdb/gdb/gdbserver/gdbserver
}

build_armhf(){
    OUT_DIR=/output/`uname | tr 'A-Z' 'a-z'`/armhf
    mkdir -p $OUT_DIR
    build_musl_armhf
    build_gdb_armhf
    GDB_VERSION=
    GDBSERVER_VERSION=
    if which qemu-arm >/dev/null;then
        GDB_VERSION="-$(qemu-arm /build/binutils-gdb/gdb/gdb --version |head -n1 |awk '{print $4}')"
        GDBSERVER_VERSION="-$(qemu-arm /build/binutils-gdb/gdb/gdbserver/gdbserver --version |head -n1 |awk '{print $4}')"
    fi
    cp /build/binutils-gdb/gdb/gdb "${OUT_DIR}/gdb-armhf${GDB_VERSION}"
    cp /build/binutils-gdb/gdb/gdbserver/gdbserver "${OUT_DIR}/gdbserver-armhf${GDBSERVER_VERSION}"
    echo "[+] Finished building armhf"
}

main() {
    if [ ! -d "/output" ];then
        echo "[-] /output does not exist, creating it"
        mkdir /output
    fi
    fetch
    build_armhf
}

main
