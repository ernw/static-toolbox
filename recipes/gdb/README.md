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
