#!/bin/bash
set -e
set -x
set -o pipefail

fetch(){
    #git clone https://github.com/GregorR/musl-cross.git /build/musl
    git clone https://github.com/takeshixx/musl-cross.git /build/musl
    git clone https://github.com/drwetter/openssl-pm-snapshot.git /build/openssl
    git clone https://git.savannah.gnu.org/git/readline.git /build/readline
    git clone https://github.com/mirror/ncurses.git /build/ncurses
    git clone http://repo.or.cz/socat.git /build/socat
}

build_musl() {
    cd /build/musl
    git clean -fdx
    ./build.sh
    echo "[+] Finished building musl-cross x86_64"
}

build_musl_x86() {
    cd /build/musl
    git clean -fdx
    echo "ARCH=i486" >> config.sh
    echo "GCC_BUILTIN_PREREQS=yes" >> config.sh
    ./build.sh
    echo "[+] Finished building musl-cross x86"
}

build_openssl() {
    cd /build/openssl
    git clean -fdx
    CC='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-gcc -static' ./Configure no-shared linux-x86_64
    make
    echo "[+] Finished building OpenSSL x86_64"
}

build_openssl_x86() {
    cd /build/openssl
    git clean -fdx
    CC='/opt/cross/i486-linux-musl/bin/i486-linux-musl-gcc -static' ./Configure no-shared -m32 linux-generic32
    make
    echo "[+] Finished building OpenSSL x86"
}

build_ncurses() {
    cd /build/ncurses
    CC='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-gcc -static' CFLAGS='-fPIC' ./configure \
        --disable-shared \
        --enable-static
    echo "[+] Finished building ncurses x86_64"
}

build_ncurses_x86() {
    cd /build/ncurses
    CC='/opt/cross/i486-linux-musl/bin/i486-linux-musl-gcc -static' CFLAGS='-fPIC' ./configure \
        --disable-shared \
        --enable-static
    echo "[+] Finished building ncurses x86"
}

build_readline() {
    cd /build/readline
    git clean -fdx
    CC='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-gcc -static' CFLAGS='-fPIC' ./configure \
        --disable-shared \
        --enable-static
    make -j4
    echo "[+] Finished building readline x86_64"
}

build_readline_x86() {
    cd /build/readline
    git clean -fdx
    CC='/opt/cross/i486-linux-musl/bin/i486-linux-musl-gcc -static' CFLAGS='-fPIC' ./configure \
        --disable-shared \
        --enable-static
    make -j4
    echo "[+] Finished building readline x86"
}

build_socat() {
    cd /build/socat
    git clean -fdx
    autoconf
    CC='/opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-gcc -static' \
        CFLAGS='-fPIC' \
        CPPFLAGS='-I/build -I/build/openssl/include -DNETDB_INTERNAL=-1' \
        LDFLAGS="-L/build/readline -L/build/ncurses/lib -L/build/openssl" \
        ./configure
    make -j4
    /opt/cross/x86_64-linux-musl/bin/x86_64-linux-musl-strip socat
}

build_socat_x86() {
    cd /build/socat
    git clean -fdx
    autoconf
    CC='/opt/cross/i486-linux-musl/bin/i486-linux-musl-gcc -static' \
        CFLAGS='-fPIC' \
        CPPFLAGS='-I/build -I/build/openssl/include -DNETDB_INTERNAL=-1' \
        LDFLAGS="-L/build/readline -L/build/ncurses/lib -L/build/openssl" \
        ./configure
    make -j4
    /opt/cross/i486-linux-musl/bin/i486-linux-musl-strip socat
}

main() {
    if [ ! -d /output ];then
        echo "[-] /output does not exist"
        exit
    fi
    fetch

    build_musl
    build_openssl
    build_ncurses
    build_readline
    build_socat

    OUT_DIR=/output/`uname | tr 'A-Z' 'a-z'`/x86_64
    mkdir -p $OUT_DIR
    cp /build/socat/socat $OUT_DIR/
    echo "[+] Finished building socat x86_64"

    build_musl_x86
    build_openssl_x86
    build_ncurses_x86
    build_readline_x86
    build_socat_x86

    OUT_DIR=/output/`uname | tr 'A-Z' 'a-z'`/x86
    mkdir -p $OUT_DIR
    cp /build/socat/socat $OUT_DIR/
    echo "[+] Finished building socat x86"
}

main
