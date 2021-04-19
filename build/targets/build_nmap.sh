#!/bin/bash
if [ -z "$GITHUB_WORKSPACE" ];then
    echo "GITHUB_WORKSPACE environemnt variable not set!"
    exit 1
fi
if [ "$#" -ne 1 ];then
    echo "Usage: ${0} [x86|x86_64|armhf|aarch64]"
    echo "Example: ${0} x86_64"
    exit 1
fi
set -e
set -o pipefail
set -x
source $GITHUB_WORKSPACE/build/lib.sh
init_lib $1

build_nmap() {
    fetch "https://github.com/nmap/nmap.git" "${BUILD_DIRECTORY}/nmap" git
    cd "${BUILD_DIRECTORY}/nmap"
    git clean -fdx || true
    # make sure we only build the static libraries
    sed -i '/build-zlib: $(ZLIBDIR)\/Makefile/!b;n;c\\t@echo Compiling zlib; cd $(ZLIBDIR) && $(MAKE) static;' "${BUILD_DIRECTORY}/nmap/Makefile.in"
    CC='gcc -static -fPIC' \
        CXX='g++ -static -static-libstdc++ -fPIC' \
        LD=ld \
        LDFLAGS="-L/build/openssl" \
        ./configure \
            --host="$(get_host_triple)" \
            --without-ndiff \
            --without-zenmap \
            --without-nmap-update \
            --without-libssh2 \
            --with-pcap=linux \
            --with-openssl="${BUILD_DIRECTORY}/openssl"
    sed -i -e "s/shared\: /shared\: #/" "${BUILD_DIRECTORY}/nmap/libpcap/Makefile"
    make
    strip nmap ncat/ncat nping/nping
}

main() {
    lib_build_openssl
    build_nmap
    if [ ! -f "${BUILD_DIRECTORY}/nmap/nmap" -o \
         ! -f "${BUILD_DIRECTORY}/nmap/ncat/ncat" -o \
         ! -f "${BUILD_DIRECTORY}/nmap/nping/nping" ];then
        echo "[-] Building Nmap ${CURRENT_ARCH} failed!"
        exit 1
    fi
    VERSION_CMD=$(get_version "${BUILD_DIRECTORY}/nmap/nmap --version")
    NMAP_VERSION=$(echo "$VERSION_CMD" | grep "Nmap version" | awk '{print $3}')
    if [ -n "$NMAP_VERSION" ];then
        NMAP_VERSION="-${NMAP_VERSION}"
    fi
    cp "${BUILD_DIRECTORY}/nmap/nmap" "${OUTPUT_DIRECTORY}/nmap${NMAP_VERSION}"
    cp "${BUILD_DIRECTORY}/nmap/ncat/ncat" "${OUTPUT_DIRECTORY}/ncat${NMAP_VERSION}"
    cp "${BUILD_DIRECTORY}/nmap/nping/nping" "${OUTPUT_DIRECTORY}/nping${NMAP_VERSION}"
    echo "[+] Finished building Nmap ${CURRENT_ARCH}"
    NMAP_COMMIT=$(cd "${BUILD_DIRECTORY}/nmap/" && git rev-parse --short HEAD)
    NMAP_DIR="${OUTPUT_DIRECTORY}/nmap-data${NMAP_VERSION}-${NMAP_COMMIT}"
    if [ ! -d "$NMAP_DIR" ];then
        echo "[-] ${NMAP_DIR} does not exist, creating it"
        mkdir -p "${NMAP_DIR}"
    fi
    if [ -n "$(ls $NMAP_DIR)" ];then
        echo "[+] Data directory is not empty"
        exit
    fi
    cd "${BUILD_DIRECTORY}/nmap"
    make install
    cp -r /usr/local/share/nmap/* $NMAP_DIR
    echo "[+] Copied data to Nmap data dir"
}

main
