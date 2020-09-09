# static-toolbox

This repository includes prebuild static binaries and build-recipes for various tools like Nmap and OpenSSH.

The Linux versions are compiled with the musl-cross toolchain and the openssl-pm-snapshot fork of OpenSSL in order to support a wide range of SSL/TLS features (Warning: some of them are insecure!).

Compilation is done automatically with GitHub Actions.

## Tools

| x86 | x86_64 | ARMHF | AARCH64 |
| --- | ------ | ----- | ------- |
|![Nmap x86](https://github.com/ernw/static-toolbox/workflows/Nmap%20x86/badge.svg)|![Nmap x86_64](https://github.com/ernw/static-toolbox/workflows/Nmap%20x86_64/badge.svg)|![Nmap ARMHF](https://github.com/ernw/static-toolbox/workflows/Nmap%20ARMHF/badge.svg)|![Nmap AARCH64](https://github.com/ernw/static-toolbox/workflows/Nmap%20AARCH64/badge.svg)|
|![OpenSSH x86](https://github.com/ernw/static-toolbox/workflows/OpenSSH%20x86/badge.svg)|![OpenSSH x86_64](https://github.com/ernw/static-toolbox/workflows/OpenSSH%20x86_64/badge.svg)|![OpenSSH ARMHF](https://github.com/ernw/static-toolbox/workflows/OpenSSH%20ARMHF/badge.svg)|![OpenSSH AARCH64](https://github.com/ernw/static-toolbox/workflows/OpenSSH%20AARCH64/badge.svg)|
|![socat x86](https://github.com/ernw/static-toolbox/workflows/socat%20x86/badge.svg)|![socat x86_64](https://github.com/ernw/static-toolbox/workflows/socat%20x86_64/badge.svg)|![socat ARMHF](https://github.com/ernw/static-toolbox/workflows/socat%20ARMHF/badge.svg)|![socat AARCH64](https://github.com/ernw/static-toolbox/workflows/socat%20AARCH64/badge.svg)
|![GDB x86](https://github.com/ernw/static-toolbox/workflows/GDB%20x86/badge.svg)|![GDB x86_64](https://github.com/ernw/static-toolbox/workflows/GDB%20x86_64/badge.svg)|![GDB ARMHF](https://github.com/ernw/static-toolbox/workflows/GDB%20ARMHF/badge.svg)|![GDB AARCH64](https://github.com/ernw/static-toolbox/workflows/GDB%20AARCH64/badge.svg)|
|![tcpdump x86](https://github.com/ernw/static-toolbox/workflows/tcpdump%20x86/badge.svg)|![tcpdump x86_64](https://github.com/ernw/static-toolbox/workflows/tcpdump%20x86_64/badge.svg)|![tcpdump ARMHF](https://github.com/ernw/static-toolbox/workflows/tcpdump%20ARMHF/badge.svg)|![tcpdump AARCH64](https://github.com/ernw/static-toolbox/workflows/tcpdump%20AARCH64/badge.svg)|

