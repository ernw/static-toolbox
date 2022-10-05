# static-toolbox

This repository includes prebuild static binaries and build-recipes for various tools like Nmap and OpenSSH.

The Linux versions are compiled with the musl-cross toolchain and the openssl-pm-snapshot fork of OpenSSL in order to support a wide range of SSL/TLS features (Warning: some of them are insecure!).

Compilation is done automatically with GitHub Actions. The binaries are uploaded to the [release section](https://github.com/ernw/static-toolbox/releases). The artifacts are also available in the artifacts of each GitHub Action. However, there are some limitations:

* Downloading of build artifacts in GitHub Ations currently requires a GitHub account
* Blobs in build artifacts are zipped by the GitHub frontend by default, even zip files themselves! Build artifact zips may contain other zip files.
* Build artifacts will expire after some time.

Therefore, it is recommended to download the binaries from the release section.

## Building Status

The following table shows the building status for the current toolset. The following architectures are currently supported:

* x86
* x86_64
* ARMHF
* AARCH64

| Tool | Status |
| ---- | ------ |
|[Nmap](https://github.com/takeshixx/static-toolbox/actions?query=workflow%3A%22Nmap%22)|![Nmap](https://github.com/ernw/static-toolbox/workflows/Nmap/badge.svg)|
|[OpenSSH](https://github.com/takeshixx/static-toolbox/actions?query=workflow%3A%22OpenSSH%22)|![OpenSSH](https://github.com/ernw/static-toolbox/workflows/OpenSSH/badge.svg)|
|[socat](https://github.com/takeshixx/static-toolbox/actions?query=workflow%3A%22socat%22)|![socat](https://github.com/ernw/static-toolbox/workflows/socat/badge.svg)|
|[GDB & gdbserver](https://github.com/takeshixx/static-toolbox/actions?query=workflow%3AGDB)|![GDB & gdbserver](https://github.com/ernw/static-toolbox/workflows/GDB%20&%20gdbserver/badge.svg)|
|[tcpdump](https://github.com/takeshixx/static-toolbox/actions?query=workflow%3A%22tcpdump%22)|![tcpdump](https://github.com/ernw/static-toolbox/workflows/tcpdump/badge.svg)|

