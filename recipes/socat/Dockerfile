FROM ubuntu:zesty
RUN apt-get update && \
    apt upgrade -yy && \
    apt install -yy \
        automake \
        autoconf \
        yodl \
        build-essential \
        libgmp-dev \
        libmpfr-dev \
        libmpc-dev \
        wget \
        git \
        pkg-config \
        python
RUN mkdir /build
ADD . /build
CMD /build/build.sh