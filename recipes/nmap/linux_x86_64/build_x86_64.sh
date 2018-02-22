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

build_musl() {
    cd /build/musl
    git clean -fdx
    ./build.sh
    echo "[+] Finished building musl-cross x86_64"
}

build_openssl() {
    cd /build/openssl
    git clean -fdx
    make clean
    CC='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-gcc -static' ./Configure no-shared linux-x86_64
    make -j4
    echo "[+] Finished building OpenSSL x86_64"
}

build_nmap() {
    cd /build/nmap
    git clean -fdx
    make clean
    cd /build/nmap/libz
    CC='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-gcc -static -fPIC' \
        CXX='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-g++ -static -static-libstdc++ -fPIC' \
        cmake -DBUILD_SHARED_LIBS=OFF -DCMAKE_LINKER=/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-ld .
    make zlibstatic
    cd /build/nmap
    CC='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-gcc -static -fPIC' \
        CXX='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-g++ -static -static-libstdc++ -fPIC' \
        CXXFLAGS="-I/build/nmap/libz" \
        LD=/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-ld \
        LDFLAGS="-L/build/openssl -L/build/nmap/libz" \
        ./configure \
            --without-ndiff \
            --without-zenmap \
            --without-nmap-update \
            --without-libssh2 \
            --with-pcap=linux \
            --with-libz=/build/nmap/libz \
            --with-openssl=/build/openssl

    sed -i -e 's/shared\: /shared\: #/' libpcap/Makefile
    sed -i 's|LIBS = |& libz/libz.a |' Makefile
    make -j4
    /opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-strip nmap ncat/ncat nping/nping
}

build_x86_64(){
    OUT_DIR_x86_64=/output/`uname | tr 'A-Z' 'a-z'`/x86_64
    mkdir -p $OUT_DIR_x86_64
    build_musl
    build_openssl
    build_nmap
    if [ ! -f "/build/nmap/nmap" -o ! -f "/build/nmap/ncat/ncat" -o ! -f "/build/nmap/nping/nping" ];then
        echo "[-] Building Nmap x86_64 failed!"
        exit 1
    fi
    NMAP_VERSION=$(/build/nmap/nmap --version |grep "Nmap version" | awk '{print $3}')
    NCAT_VERSION=$(/build/nmap/ncat/ncat --version 2>&1 |grep "Ncat: Version" | awk '{print $3}')
    NPING_VERSION=$(/build/nmap/nping/nping --version |grep "Nping version" | awk '{print $3}')
    cp /build/nmap/nmap "${OUT_DIR_x86_64}/nmap-${NMAP_VERSION}-${NMAP_COMMIT}"
    cp /build/nmap/ncat/ncat "${OUT_DIR_x86_64}/ncat-${NCAT_VERSION}-${NMAP_COMMIT}"
    cp /build/nmap/nping/nping "${OUT_DIR_x86_64}/nping-${NPING_VERSION}-${NMAP_COMMIT}"
    echo "[+] Finished building x86_64"
}

main() {
    if [ ! -d "/output" ];then
        echo "[-] /output does not exist, creating it"
        mkdir /output
    fi
    fetch
    build_x86_64
    NMAP_DIR=/output/nmap-data-${NPING_VERSION}-${NMAP_COMMIT}
    if [ ! -d "$NMAP_DIR" ];then
        echo "[-] ${NMAP_DIR} does not exist, creating it"
        mkdir -p "${NMAP_DIR}"
    fi
    if [ -n "$(ls $NMAP_DIR)" ];then
        echo "[+] Data directory is not empty"
        exit
    fi
    cd /build/nmap
    make install
    cp -r /usr/local/share/nmap/* $NMAP_DIR
    echo "[+] Copied data to data dir"
}

main
