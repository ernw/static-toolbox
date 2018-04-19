# static-toolbox

This repository includes prebuild static binaries and build-recipes for various tools like Nmap.

The Linux versions are compiled with the [musl-cross](https://github.com/takeshixx/musl-cross) toolchain and the [openssl-pm-snapshot](https://github.com/drwetter/openssl-pm-snapshot) fork of OpenSSL in order to support a wide range of SSL/TLS features (Warning: some of them are insecure!).

## Nmap

Precompiled versions of Nmap are available for the following operating systems/architectures:

* [Linux x86](bin/linux/x86) (nmap, ncat, nping)
* [Linux x86_64](bin/linux/x86_64) (nmap, ncat, nping)
* [Linux armhf](bin/linux/armhf) (nmap, ncat, nping)
* [Linux aarch64](bin/linux/aarch64) (nmap, ncat, nping)
* [Windows x86](bin/windows/x86) (nmap)

### Packaged Archives

For Nmap it is recommended to use one of the [packaged](packaged/) archives. These include the nmap, ncat and nping binaries and also the Nmap data directory that contains service probes and NSE scripts.

## Socat

Precompiled versions of socat are available for the following operating systems/architectures:

* [Linux x86](bin/linux/x86)
* [Linux x86_64](bin/linux/x86_64)

## GDB

Precompiled versions of `gdb` and `gdbserver` are available for the following operating systems/architecturs:

* [Linux x86](bin/linux/x86)
* [Linux x86_64](bin/linux/x86_64)
* [Linux armhf](bin/linux/armhf)
* [Linux aarch64](bin/linux/aarch64)

# Building with Vagrant

The recipes are supposed to be built in Docker containers. In case Docker is not available, it is recommended to use Vagrant to built everything in a VM, e.g. Nmap for Linux x86:

```
vagrant up
vagrant ssh
cd /vagrant/recipes/nmap/linux_x86
sudo docker build -t static-toolbox-nmap-x86 .
sudo docker run -v $(pwd)/output:/output static-toolbox-nmap-x86
```

This is also the recommended way to run the build scripts without Docker without creating directories like `/build` and `/output` on your host system.
