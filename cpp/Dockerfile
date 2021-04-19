ARG BASE_IMAGE=provarepro/openvino:2019_R3.1_c-python-3.6

FROM openvino/ubuntu18_dev:2019_R3.1 as builder

WORKDIR /tmp

RUN curl -O https://zenodo.org/record/3401714/files/ssd_mobilenet_v1_quant_ft_no_zero_point_frozen_inference_graph.pb && \
    curl -O https://zenodo.org/record/3252084/files/mobilenet_v1_ssd_8bit_finetuned.tar.gz && \
    tar xf mobilenet_v1_ssd_8bit_finetuned.tar.gz && \
    rm mobilenet_v1_ssd_8bit_finetuned.tar.gz && \
    cp mobilenet_v1_ssd_finetuned/pipeline.config . && \
    rm -rf mobilenet_v1_ssd_finetuned && \
    python3 /opt/intel/openvino/deployment_tools/model_optimizer/mo.py \
        --input_model /tmp/ssd_mobilenet_v1_quant_ft_no_zero_point_frozen_inference_graph.pb \
        --input_shape [1,300,300,3] \
        --reverse_input_channels \
        --tensorflow_use_custom_operations_config /opt/intel/openvino/deployment_tools/model_optimizer/extensions/front/tf/ssd_v2_support.json \
        --tensorflow_object_detection_api_pipeline_config /tmp/pipeline.config && \
    ls /tmp

FROM ${BASE_IMAGE}

USER root

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /

# Install Boost
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libicu-dev \
        libbz2-dev \
        liblzma-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV BOOST_VERSION="1.71.0" \
    _BOOST_VERSION="1_71_0"

RUN wget -q https://dl.bintray.com/boostorg/release/${BOOST_VERSION}/source/boost_${_BOOST_VERSION}.tar.gz && \
    tar xf boost_${_BOOST_VERSION}.tar.gz && \
    cd boost_${_BOOST_VERSION} && \
    ./bootstrap.sh && \
    ./b2 install && \
    cd /tmp && rm -rf boost*

RUN python${PYTHON_VERSION} -m pip install --ignore-installed --no-cache-dir \
        absl-py \
        pybind11 && \
    git clone \
        --recurse-submodules \
        --single-branch \
        -b r0.5 \
        https://github.com/mlcommons/inference.git /mlperf_inference && \
    cd /mlperf_inference && \
    git config --global user.email "antonio.maffia@gmail.com" && \
    git config --global user.name "fenz" && \
    git pull --no-commit --force origin pull/502/head && \
    git pull --no-commit origin pull/482/head && \
    git commit -m "merge PRs" && \
    mkdir loadgen/build && cd loadgen/build && \
    cmake .. && cmake --build . && \
    cp libmlperf_loadgen.a .. && \
    rm -r /mlperf_inference/loadgen/build && \
    cp -r /mlperf_inference/loadgen /mlperf_loadgen && \
    rm -rf /mlperf_inference

ENV InferenceEngine_DIR=/openvino/inference-engine/build

RUN git clone \
        --depth 1 \
        https://github.com/mlcommons/inference_results_v0.5.git && \
    mv inference_results_v0.5/closed/Intel/code/ssd-small/openvino-linux /mlperf_inference && \
    rm -rf inference_results_v0.5 && \
    cd /mlperf_inference && \
    mkdir build && cd build && \
    cmake \
        -DLOADGEN_DIR=/mlperf_loadgen \
        -DBOOST_SYSTEM_LIB=/usr/local/lib/libboost_system.so \
        -DCMAKE_BUILD_TYPE=Release \
        .. && \
    cmake --build . --config Release

COPY --from=builder \
         /tmp/ssd_mobilenet_v1_quant_ft_no_zero_point_frozen_inference_graph.xml \
         /mlperf_inference/model/ssd_mobilenet.xml

COPY --from=builder \
         /tmp/ssd_mobilenet_v1_quant_ft_no_zero_point_frozen_inference_graph.bin \
         /mlperf_inference/model/ssd_mobilenet.bin

WORKDIR /mlperf_inference

USER openvino
