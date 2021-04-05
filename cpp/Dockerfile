ARG BASE_IMAGE=openvino/ubuntu18_runtime:2020.3.1
FROM ${BASE_IMAGE}

USER root

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        build-essential \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN ${PYTHON_VER} -m pip install --ignore-installed --no-cache-dir \
        cmake \
        absl-py \
        pybind11

WORKDIR /tmp

## Install MLPerf loadgen (CPP)
RUN git clone \
        --depth 1 \
        --single-branch \
        -b v0.7 \
        https://github.com/mlperf/inference.git /tmp/mlperf_inference && \
    cd /tmp/mlperf_inference && \
    mkdir loadgen/build && cd loadgen/build && \
    cmake .. && cmake --build . && \
    cp libmlperf_loadgen.a .. && \
    rm -r /tmp/mlperf_inference/loadgen/build && \
    cp -r /tmp/mlperf_inference/loadgen /mlperf_loadgen && \
    rm -rf /tmp/mlperf_inference

# Install Boost
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libicu-dev \
        libbz2-dev \
        liblzma-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget -q https://dl.bintray.com/boostorg/release/1.73.0/source/boost_1_73_0.tar.bz2 && \
    tar --bzip2 -xf boost_1_73_0.tar.bz2 && \
    cd boost_1_73_0 && \
    ./bootstrap.sh && \
    ./b2 install && \
    cd /tmp && rm -rf boost*

USER openvino

WORKDIR /mlperf_inference

RUN source ${INTEL_OPENVINO_DIR}/bin/setupvars.sh && \
    mkdir build && cd build && \
    cmake -DLOADGEN_DIR=/mlperf_loadgen \
          -DCMAKE_BUILD_TYPE=Release .. && \
    cmake --build . --config Release


