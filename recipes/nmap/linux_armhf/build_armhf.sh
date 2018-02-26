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
    if [ ! -d "/build/openssl" ];then
        git clone https://github.com/drwetter/openssl-pm-snapshot.git /build/openssl
    fi
    if [ ! -d "/build/nmap" ];then
        git clone https://github.com/nmap/nmap.git /build/nmap
    fi
    NMAP_COMMIT=$(cd /build/nmap/ && git rev-parse --short HEAD)
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

build_openssl_armhf() {
    cd /build/openssl
    git clean -fdx
    make clean
    CC='/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-gcc -static' ./Configure no-shared linux-generic32
    make -j4
    echo "[+] Finished building OpenSSL armhf"
}

build_nmap_armhf() {
    cd /build/nmap
    git clean -fdx
    make clean
    cd /build/nmap/libz
    CC='/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-gcc -static -fPIC' \
        CXX='/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-g++ -static -static-libstdc++ -fPIC' \
        cmake -DBUILD_SHARED_LIBS=OFF -DCMAKE_LINKER=/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-ld .
    make zlibstatic
    cd /build/nmap
    CC='/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-gcc -static -fPIC' \
        CXX='/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-g++ -static -static-libstdc++ -fPIC' \
        CXXFLAGS="-I/build/nmap/libz" \
        LD=/opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-ld \
        LDFLAGS="-L/build/openssl -L/build/nmap/libz" \
        ./configure \
            --host=arm-none-linux-gnueabi \
            --without-ndiff \
            --without-zenmap \
            --without-nmap-update \
            --without-libssh2 \
            --with-pcap=linux \
            --with-libz=/build/nmap/libz \
            --with-openssl=/build/openssl \
            --with-liblua=included
    sed -i -e 's/shared\: /shared\: #/' libpcap/Makefile
    sed -i 's|LIBS = |& libz/libz.a |' Makefile
    make -j4
    if [ ! -f "/build/nmap/nmap" -o ! -f "/build/nmap/ncat/ncat" -o ! -f "/build/nmap/nping/nping" ];then
        echo "[-] Building Nmap armhf failed!"
        exit 1
    fi
    if [ -f "/build/nmap/nmap" -a -f "/build/nmap/ncat/ncat" -a -f "/build/nmap/nping/nping" ];then
        /opt/cross/arm-linux-musleabihf/bin/arm-linux-musleabihf-strip nmap ncat/ncat nping/nping
    fi
}

build_armhf(){
    OUT_DIR_ARMHF=/output/`uname | tr 'A-Z' 'a-z'`/armhf
    mkdir -p $OUT_DIR_ARMHF
    build_musl_armhf
    build_openssl_armhf
    build_nmap_armhf
    if [ ! -f "/build/nmap/nmap" -o ! -f "/build/nmap/ncat/ncat" -o ! -f "/build/nmap/nping/nping" ];then
        echo "[-] Building Nmap armhf failed!"
        exit 1
    fi
    cp /build/nmap/nmap "${OUT_DIR_ARMHF}/nmap-${NMAP_COMMIT}"
    cp /build/nmap/ncat/ncat "${OUT_DIR_ARMHF}/ncat-${NMAP_COMMIT}"
    cp /build/nmap/nping/nping "${OUT_DIR_ARMHF}/nping-${NMAP_COMMIT}"
    echo "[+] Finished building Nmap armhf"
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
