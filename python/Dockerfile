ARG BASE_IMAGE=tensorflow/tensorflow
FROM ${BASE_IMAGE}

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN python -m pip install --ignore-installed \
        absl-py \
        numpy \
        certifi \
        opencv-python-headless \
        pycocotools \
        pybind11 \
        Cython

ENV LOADER_VER=0.5a0

RUN git clone \
        --recurse-submodules \
        --depth 1 \
        --single-branch \
        -b v0.7 \
        https://github.com/mlperf/inference.git /mlperf_inference && \
    cd /mlperf_inference/loadgen && \
    CFLAGS="-std=c++14 -O3" python setup.py bdist_wheel && \
    python -m pip install \
        dist/mlperf_loadgen-${LOADER_VER}-*.whl && \
    rm dist/mlperf_loadgen-${LOADER_VER}-*.whl

WORKDIR /mlperf_inference
