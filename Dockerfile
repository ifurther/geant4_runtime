# Dockerfile for Geant4 Runtime

ARG g4version="11.1.1"

FROM ubuntu:latest as sdk
LABEL maintener="Koichi Murakami <koichi.murakami@kek.jp>"

ARG g4version
ENV DEBIAN_FRONTEND=nointeractive

RUN apt update && \
    apt install -y tcsh zsh sudo make build-essential vim \
                   libboost-dev libexpat1-dev libxerces-c-dev \
                   libcpputest-dev git cmake wget && \
    rm -rf /var/lib/apt/lists/*
    mkdir -p /opt/geant4/

FROM sdk as build
#
WORKDIR /opt/geant4
RUN wget https://geant4-data.web.cern.ch/releases/geant4-v${g4version}.tar.gz && \
    tar zxvf geant4-v${g4version}.tar.gz

#
WORKDIR /opt/geant4/build
RUN cmake -DCMAKE_INSTALL_PREFIX=/opt/geant4/${g4version} \
          -DGEANT4_INSTALL_DATA=ON \
          -DGEANT4_INSTALL_DATADIR=/opt/geant4/data ../geant4-v${g4version} && \
    make -j`nproc` && \
    make install

# -------------------------------------------------------------------
FROM sdk as release

ARG g4version

RUN mkdir -p /opt/geant4/data

#
WORKDIR /opt/geant4
COPY --from=sdk /opt/geant4/${g4version} .

WORKDIR /opt/geant4/data
COPY --from=sdk /opt/geant4/data .

WORKDIR /
