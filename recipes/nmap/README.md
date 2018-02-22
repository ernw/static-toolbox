# Nmap

## Build x86

```
sudo docker build -t static-toolbox-nmap-x86 .
sudo docker run -v $(pwd)/output:/output static-toolbox-nmap-x86
```

## Build x86_64

```
sudo docker build -t static-toolbox-nmap-x86-64 .
sudo docker run -v $(pwd)/output:/output static-toolbox-nmap-x86-64
```

## Using the Nmap data directory

In order to use features like script scanning, we also need the Nmap data files that are typically installed into `/usr/share/nmap`. They are available in the `data/nmap` directory. Just copy this directory to the target system, e.g. into `/tmp/nmap-data` and run Nmap like this:

```
NMAPDIR=/tmp/nmap-data ./nmap
```
