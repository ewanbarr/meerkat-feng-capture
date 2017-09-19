# Copyright (C) 2016 by Ewan Barr
# Licensed under the Academic Free License version 3.0
# This program comes with ABSOLUTELY NO WARRANTY.
# You are free to modify and redistribute this code as long
# as you do not remove the above attribution and reasonably
# inform receipients that you have modified the original work.

FROM nvidia/cuda:8.0-devel-ubuntu16.04

MAINTAINER Ewan Barr "ebarr@mpifr-bonn.mpg.de"

# Suppress debconf warnings
ENV DEBIAN_FRONTEND noninteractive

# Switch account to root and adding user accounts and password
USER root

# Create space for ssh daemon and update the system
RUN echo 'deb http://us.archive.ubuntu.com/ubuntu trusty main multiverse' >> /etc/apt/sources.list && \
    apt-get -y check && \
    apt-get -y update && \
    apt-get install -y apt-utils apt-transport-https software-properties-common python-software-properties && \
    apt-get -y update --fix-missing && \
    apt-get -y upgrade 

# Install dependencies
RUN apt-get --no-install-recommends -y install \
    build-essential \
    autoconf \
    autotools-dev \
    automake \
    autogen \
    libtool \
    csh \
    gcc \
    gfortran \
    wget \
    git \
    cvs \
    cmake \
    expect \
    libcfitsio-dev \
    libltdl-dev \
    gsl-bin \
    libgsl-dev \
    libgsl2 \
    hwloc \
    libhwloc-dev \
    libboost-all-dev \
    libibverbs-dev \
    librdmacm-dev \ 
    pkg-config

# Define home, psrhome, OSTYPE and create the directory
ENV HOME /home/psr
ENV PSRHOME $HOME/software
ENV OSTYPE linux
RUN mkdir -p $PSRHOME
WORKDIR $PSRHOME

# Install PSRDADA
COPY psrdada_cvs_login $PSRHOME
RUN ls -lrt psrdada_cvs_login && \
    chmod +x psrdada_cvs_login &&\
    sleep 1 &&\
    ./psrdada_cvs_login && \
    cvs -z3 -d:pserver:anonymous@psrdada.cvs.sourceforge.net:/cvsroot/psrdada co -P psrdada
ENV PSRDADA_HOME $PSRHOME/psrdada
WORKDIR $PSRDADA_HOME
RUN mkdir build/ && \
    ./bootstrap && \
    ./configure --prefix=$PSRHOME && \
    make && \
    make install && \
    make clean 
ENV PATH $PATH:$PSRHOME/bin
ENV PSRDADA_BUILD $PSRHOME
ENV PACKAGES $PSRDADA_BUILD

# Install SPEAD2
WORKDIR $PSRHOME
RUN git clone https://github.com/ska-sa/spead2.git && \
    cd spead2 && \
    ./bootstrap.sh && \
    ./configure --prefix=$PSRHOME && \
    make -j && \
    make install && \
    make clean 
ENV PACKAGES $PACKAGES:$PSRHOME

#install PSRDADA_CPP
RUN git clone https://github.com/ewanbarr/psrdada_cpp &&\
    cd psrdada_cpp &&\
    git checkout master &&\
    mkdir build/ &&\
    cd build/ &&\
    cmake -DENABLE_CUDA=true -DCMAKE_INSTALL_PREFIX=$PSRHOME ../ &&\
    make -j 32 &&\
    make install

#install MKRecv
RUN git config --global http.sslverify false &&\
    git clone https://gitlab.mpifr-bonn.mpg.de/mhein/mkrecv.git &&\
    cd mkrecv &&\
    cmake -DCMAKE_INSTALL_PREFIX=$PSRHOME . &&\
    make -j 32 &&\
    make install

WORKDIR $HOME
RUN env | awk '{print "export ",$0}' > $HOME/.profile && \
    echo "source $HOME/.profile" >> $HOME/.bashrc
USER root
