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
init_lib "$1"

build_conntrack() {
    libmnl=1.0.5
    libnfnetlink=1.0.2
    libnetfilter_conntrack=1.0.9
    libnetfilter_cttimeout=1.0.1
    libnetfilter_queue=1.0.5
    libnetfilter_cthelper=1.0.1
    conntrack=1.4.7

    wget https://www.netfilter.org/projects/libmnl/files/libmnl-${libmnl}.tar.bz2
    wget https://www.netfilter.org/projects/libnfnetlink/files/libnfnetlink-${libnfnetlink}.tar.bz2
    wget https://www.netfilter.org/projects/libnetfilter_conntrack/files/libnetfilter_conntrack-${libnetfilter_conntrack}.tar.bz2
    wget https://www.netfilter.org/projects/libnetfilter_cttimeout/files/libnetfilter_cttimeout-${libnetfilter_cttimeout}.tar.bz2
    wget https://www.netfilter.org/projects/libnetfilter_queue/files/libnetfilter_queue-${libnetfilter_queue}.tar.bz2
    wget https://www.netfilter.org/projects/libnetfilter_cthelper/files/libnetfilter_cthelper-${libnetfilter_cthelper}.tar.bz2
    wget https://www.netfilter.org/projects/conntrack-tools/files/conntrack-tools-${conntrack}.tar.bz2

   	tar xvf libmnl-${libmnl}.tar.bz2
	cd libmnl-${libmnl} && ./configure --enable-static && make -j $(nproc)
	make install
	cd ..

	tar xvf libnfnetlink-${libnfnetlink}.tar.bz2
	cd libnfnetlink-${libnfnetlink} && ./configure --enable-static && make -j $(nproc)
	make install
	cd ..

	tar xvf libnetfilter_conntrack-${libnetfilter_conntrack}.tar.bz2
	cd libnetfilter_conntrack-${libnetfilter_conntrack} && ./configure --enable-static && make -j $(nproc)
	make install
	cd ..

	tar xvf libnetfilter_cttimeout-${libnetfilter_cttimeout}.tar.bz2
	cd libnetfilter_cttimeout-${libnetfilter_cttimeout} && ./configure --enable-static && make -j $(nproc)
	make install
	cd ..

	tar xvf libnetfilter_queue-${libnetfilter_queue}.tar.bz2
	cd libnetfilter_queue-${libnetfilter_queue} && ./configure --enable-static && make -j $(nproc)
	make install
	cd ..

	tar xvf libnetfilter_cthelper-${libnetfilter_cthelper}.tar.bz2
	cd libnetfilter_cthelper-${libnetfilter_cthelper} && ./configure --enable-static && make -j $(nproc)
	make install
	cd ..

	tar xvf conntrack-tools-${conntrack}.tar.bz2
	cd conntrack-tools-${conntrack}
	./configure && make -j $(nproc)
}

main() {
    build_conntrack
    local version
    version=1.4
    version_number=17

    cp "${BUILD_DIRECTORY}/conntrack-tools-1.4.7/src/conntrack" "${OUTPUT_DIRECTORY}/conntrack${version}"
    echo "[+] Finished building conntrack ${CURRENT_ARCH}"

    echo ::set-output name=PACKAGED_NAME::"conntrack${version}"
    echo ::set-output name=PACKAGED_NAME_PATH::"${OUTPUT_DIRECTORY}/*"
    echo ::set-output name=PACKAGED_VERSION::"${version_number}"
}

main
