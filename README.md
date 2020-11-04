# static-toolbox

This repository includes prebuild static binaries and build-recipes for various tools like Nmap and OpenSSH.

The Linux versions are compiled with the musl-cross toolchain and the openssl-pm-snapshot fork of OpenSSL in order to support a wide range of SSL/TLS features (Warning: some of them are insecure!).

Compilation is done automatically with GitHub Actions.

## Current Limitations

* Downloading of build artifacts in GitHub Ations currently requires a GitHub account
* Blobs in build artifacts are zipped by the GitHub frontend by default, even zip files themselves! Build artifact zips may contain other zip files.

## Tools

|[Nmap](https://github.com/ernw/static-toolbox/actions?query=workflow%3A%22Nmap%22)||
|[OpenSSH](https://github.com/ernw/static-toolbox/actions?query=workflow%3A%22OpenSSH%22)||
|[socat](https://github.com/ernw/static-toolbox/actions?query=workflow%3A%22socat%22)||
|[GDB](https://github.com/ernw/static-toolbox/actions?query=workflow%3AGDB)||
|[tcpdump](https://github.com/ernw/static-toolbox/actions?query=workflow%3A%22tcpdump%22)||

