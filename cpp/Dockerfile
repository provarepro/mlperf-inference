ARG BASE_IMAGE=provarepro/openvino:2021.1pre_c-python-3.6
FROM ${BASE_IMAGE}

USER root

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

WORKDIR /

RUN git clone https://github.com/gflags/gflags.git && \
    mkdir gflags/build && cd gflags/build && \
    cmake .. && make

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libicu-dev \
        libbz2-dev \
        liblzma-dev && \
    rm -rf /var/lib/apt/lists/*

ENV BOOST_VERSION="1.72.0" \
    _BOOST_VERSION="1_72_0"

RUN wget -q https://dl.bintray.com/boostorg/release/${BOOST_VERSION}/source/boost_${_BOOST_VERSION}.tar.gz && \
    tar xf boost_${_BOOST_VERSION}.tar.gz && \
    cd boost_${_BOOST_VERSION} && \
    ./bootstrap.sh --with-libraries=filesystem && \
    ./b2 --with-filesystem

RUN python${PYTHON_VERSION} -m pip install \
    pybind11 absl-py && \
    git clone \
        --depth 1 \
        --single-branch \
        -b v0.7 \
        https://github.com/mlperf/inference.git /mlperf_inference && \
    cd /mlperf_inference && \
    mkdir loadgen/build && cd loadgen/build && \
    cmake .. && cmake --build . && \
    cp libmlperf_loadgen.a .. && \
    rm -r /mlperf_inference/loadgen/build && \
    cp -r /mlperf_inference/loadgen /mlperf_loadgen && \
    rm -rf /mlperf_inference

ENV gflags_DIR=/gflags/build \
    InferenceEngine_DIR=/openvino/build

RUN git clone https://github.com/mlperf/inference_results_v0.7.git && \
    mv inference_results_v0.7/closed/Intel/code/resnet/resnet-ov /mlperf_inference && \
    rm -rf inference_results_v0.7 && \
    cd /mlperf_inference && \
    mkdir build && cd build && \
    cmake \
        -DLOADGEN_DIR=/mlperf_loadgen \
        -DBOOST_INCLUDE_DIRS=/boost_1_72_0 \
        -DBOOST_FILESYSTEM_LIB=/boost_1_72_0/stage/lib/libboost_filesystem.so \
        -DCMAKE_BUILD_TYPE=Release \
        .. && \
    cmake --build . --config Release
