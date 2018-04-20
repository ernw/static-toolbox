# GDB

## Build Linux x86

```
sudo docker build -t static-toolbox-gdb-x86 .
sudo docker run -v $(pwd)/output:/output static-toolbox-gdb-x86
```

## Build Linux x86_64

```
sudo docker build -t static-toolbox-gdb-x86-64 .
sudo docker run -v $(pwd)/output:/output static-toolbox-gdb-x86-64
```

## Build Linux armhf

```
sudo docker build -t static-toolbox-gdb-armhf .
sudo docker run -v $(pwd)/output:/output static-toolbox-gdb-armhf
```

## Build Linux aarch64

```
sudo docker build -t static-toolbox-gdb-aarch64 .
sudo docker run -v $(pwd)/output:/output static-toolbox-gdb-aarch64
