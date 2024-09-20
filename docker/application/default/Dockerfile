#####
# name: build-essential | python | cmake
# group: build
# notes: installs compilers, build tools & configures the default locale
#---
#---
# name: python
# group: build
# depends: build-essential
# notes: installs core `python3` packages and `pip`
#---
#---
# name: cmake:pip
# alias: cmake
# group: build
# depends: [build-essential, python]
# notes: upgrade `cmake` with `pip`
#---
FROM ubuntu:22.04 AS build_essential

###
# build-essential
#
ENV DEBIAN_FRONTEND=noninteractive \
    LANGUAGE=en_US:en \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8
    #TERM=dumb

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        locales \
        locales-all \
        tzdata \
    && locale-gen en_US $LANG \
    && update-locale LC_ALL=$LC_ALL LANG=$LANG \
    && locale \
    \
    && apt-get install -y --no-install-recommends \
        build-essential \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        lsb-release \
        pkg-config \
        gnupg \
        git \
        gdb \
        wget \
        curl \
        nano \
        zip \
        unzip \
        time \
       sshpass \
       ssh-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    \
    && gcc --version \
    && g++ --version

COPY ./build_essential/tarpack /usr/local/bin/

#
###

###
# python
#
ARG PYTHON_VERSION_ARG=3.10

ENV PYTHON_VERSION=${PYTHON_VERSION_ARG} \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=utf-8 \
    PYTHONHASHSEED=random \
    PIP_NO_CACHE_DIR=off \
    PIP_CACHE_PURGE=true \
    PIP_ROOT_USER_ACTION=ignore \
    TWINE_NON_INTERACTIVE=1 \
    DEBIAN_FRONTEND=noninteractive

COPY ./python/install.sh /tmp/install_python.sh
RUN /tmp/install_python.sh

#
###

###
# cmake
#
RUN set -ex \
    && pip3 install --upgrade --force-reinstall --no-cache-dir --verbose cmake \
    \
    && cmake --version \
    && which cmake

#
###

#
#####


#####
# name: cuda
# group: cuda
# config: config.py
# depends: [build-essential]
# test: test.sh
#---
#---
# name: cudnn
# group: cuda
# depends: cuda
# config: config.py
# test: test.sh
#---
FROM build_essential AS cuda

###
# cuda
#
ARG CUDA_URL=https://nvidia.box.com/shared/static/uvqtun1sc0bq76egarc8wwuh6c23e76e.deb \
    CUDA_DEB=cuda-tegra-repo-ubuntu2204-12-2-local \
    CUDA_PACKAGES=cuda-toolkit* \
    CUDA_ARCH_LIST=87 \
    PIP_INDEX_REPO=http://jetson.webredirect.org/jp6/cu122 \
    #PIP_UPLOAD_REPO \
    #PIP_UPLOAD_USER \
    #PIP_UPLOAD_PASS \
    PIP_TRUSTED_HOSTS=jetson.webredirect.org \
    TAR_INDEX_URL=http://jetson.webredirect.org:8000/jp6/cu122 \
    #SCP_UPLOAD_URL \
    #SCP_UPLOAD_USER \
    #SCP_UPLOAD_PASS \
    DISTRO="ubuntu2004"

COPY ./cuda/install.sh /tmp/install_cuda.sh
RUN /tmp/install_cuda.sh

ENV CUDA_HOME="/usr/local/cuda"
ENV NVCC_PATH="$CUDA_HOME/bin/nvcc"

ENV NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=all \
    CUDAARCHS=${CUDA_ARCH_LIST} \
    CUDA_ARCHITECTURES=${CUDA_ARCH_LIST} \
    CUDA_HOME="/usr/local/cuda" \
    CUDNN_LIB_PATH="/usr/lib/aarch64-linux-gnu" \
    CUDNN_LIB_INCLUDE_PATH="/usr/include" \
    CMAKE_CUDA_COMPILER=${NVCC_PATH} \
    CUDA_NVCC_EXECUTABLE=${NVCC_PATH} \
    CUDACXX=${NVCC_PATH} \
    TORCH_NVCC_FLAGS="-Xfatbin -compress-all" \
    CUDA_BIN_PATH="${CUDA_HOME}/bin" \
    CUDA_TOOLKIT_ROOT_DIR="${CUDA_HOME}" \
    PATH="$CUDA_HOME/bin:${PATH}" \
    LD_LIBRARY_PATH="${CUDA_HOME}/compat:${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}" \
    TAR_INDEX_URL=${TAR_INDEX_URL} \
    PIP_INDEX_URL=${PIP_INDEX_REPO} \
    PIP_TRUSTED_HOST=${PIP_TRUSTED_HOSTS} \
    TWINE_REPOSITORY_URL=${PIP_UPLOAD_REPO} \
    TWINE_USERNAME=${PIP_UPLOAD_USER} \
    TWINE_PASSWORD=${PIP_UPLOAD_PASS} \
    SCP_UPLOAD_URL=${SCP_UPLOAD_URL} \
    SCP_UPLOAD_USER=${SCP_UPLOAD_USER} \
    SCP_UPLOAD_PASS=${SCP_UPLOAD_PASS} \
    DEBIAN_FRONTEND=noninteractive

#
###

###
# cudnn
#
ARG CUDNN_URL=https://nvidia.box.com/shared/static/ht4li6b0j365ta7b76a6gw29rk5xh8cy.deb
ARG CUDNN_DEB=cudnn-local-tegra-repo-ubuntu2204-8.9.4.25
ARG CUDNN_PACKAGES=libcudnn*-dev libcudnn*-samples

RUN echo "Downloading ${CUDNN_DEB}" && \
    mkdir /tmp/cudnn && cd /tmp/cudnn && \
    wget --quiet --show-progress --progress=bar:force:noscroll ${CUDNN_URL} && \
    dpkg -i *.deb && \
    cp /var/cudnn-local-tegra-repo-*/cudnn-local-tegra-*-keyring.gpg /usr/share/keyrings/ && \
    apt-get update && \
    apt-cache search cudnn && \
    apt-get install -y --no-install-recommends ${CUDNN_PACKAGES} && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    dpkg --list | grep cudnn && \
    dpkg -P ${CUDNN_DEB} && \
    rm -rf /tmp/cudnn

#RUN cd /usr/src/cudnn_samples_v*/conv_sample/ && \
#    make -j$(nproc)

#
###

#
#####

#####
#---
# name: numpy
# group: core
# depends: [build-essential, python]
# test: test.py
#---
#---
# name: onnx
# group: ml
# config: config.py
# depends: [cmake, python, numpy]
# test: test.py
# notes: the `protobuf_apt` is added as a dependency on JetPack 4 (newer versions of onnx build it in-tree)
#---
#---
# name: pytorch:pip
# alias: torch
# group: pytorch
# config: config.py
# depends: [cuda, cudnn, numpy, onnx]
# test: test.py
# docs: |
#  Containers for PyTorch with CUDA support.
#  Note that the [`l4t-pytorch`](/packages/l4t/l4t-pytorch) containers also include PyTorch, `torchvision`, and `torchaudio`.
#---
#---
# name: tensorrt
# group: cuda
# depends: [cuda, cudnn, python]
# config: config.py
# test: test.sh
#---
#---
# name: torchvision
# group: pytorch
# config: config.py
# depends: [pytorch, cmake]
# test: test.py
#---
#---
# name: opencv
# group: core
# config: config.py
# depends: [cuda, cudnn, python, numpy]
# test: test.py
# notes: install or build OpenCV (with CUDA) from Jetson pip server
#---
#---
# name: onnxruntime
# group: ml
# config: config.py
# depends: [cuda, cudnn, tensorrt, cmake, python, numpy, onnx]
# test: test.py
# notes: the `onnxruntime-gpu` wheel that's built is saved in the container under `/opt`
#---
#---
# patchmatch
#
#---
FROM cuda as pytorch

###
# numpy
#

# https://github.com/numpy/numpy/issues/18131#issuecomment-755438271
ENV OPENBLAS_CORETYPE=ARMV8

# we used to install the apt version of numpy first so that it was marked as installed,
# however when moving to building for any PYTHON_VERSION, these may not be available.
#RUN set -ex \
#    && apt-get update \
#    && apt-get install -y --no-install-recommends \
#        python3-numpy \
#    && rm -rf /var/lib/apt/lists/* \
#    && apt-get clean \
#    && pip3 show numpy && python3 -c 'import numpy; print(numpy.__version__)'

RUN pip3 install --upgrade --force-reinstall --no-cache-dir --verbose 'numpy<2' && \
    pip3 show numpy && python3 -c 'import numpy; print(numpy.__version__)'


#
###

###
# onnx
#
ARG ONNX_VERSION=main

RUN pip3 install --no-cache-dir --verbose onnx || \
    pip3 install --no-cache-dir --verbose git+https://github.com/onnx/onnx@${ONNX_VERSION} && \
    pip3 show onnx && \
    python3 -c 'import onnx; print(onnx.__version__)'

#
###

###
# pytorch
#
# set the CUDA architectures that PyTorch extensions get built for
# set the torch hub model cache directory to mounted /data volume
ARG TORCH_CUDA_ARCH_ARGS=8.7 \
    TORCH_VERSION=2.2 \
    PYTORCH_BUILD_VERSION=2.2.0 \
    FORCE_BUILD=off

ENV TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_ARGS} \
    TORCH_HOME=/data/models/torch

COPY ./pytorch/install.sh ./pytorch/build.sh /tmp/pytorch/

# attempt to install from pip, and fall back to building it
RUN /tmp/pytorch/install.sh || /tmp/pytorch/build.sh

#
###

###
# tensorrt

ARG TENSORRT_URL=https://nvidia.box.com/shared/static/hmwr57hm88bxqrycvlyma34c3k4c53t9.deb \
    TENSORRT_DEB=nv-tensorrt-local-repo-l4t-8.6.2-cuda-12.2 \
    TENSORRT_PACKAGES=tensorrt tensorrt-libs python3-libnvinfer-dev

RUN set -ex && \
    echo "Downloading ${TENSORRT_DEB}" && \
    mkdir -p /tmp/tensorrt && \
    cd /tmp/tensorrt && \
    wget --quiet --show-progress --progress=bar:force:noscroll ${TENSORRT_URL} && \
    dpkg -i *.deb && \
    cp /var/nv-tensorrt-local-repo-*/nv-tensorrt-local-*-keyring.gpg /usr/share/keyrings/ && \
    apt-get update && \
    apt-cache search tensorrt && \
    apt-get install -y --no-install-recommends ${TENSORRT_PACKAGES} && \
    \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    dpkg --list | grep tensorrt && \
    dpkg -P ${TENSORRT_DEB} && \
    rm -rf /tmp/tensorrt

#
###

###
# torchvision
ARG TORCHVISION_VERSION=0.17.2 \
    FORCE_BUILD=off

COPY ./torchvision /opt/torchvision/

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libjpeg-dev \
        libpng-dev \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN /opt/torchvision/install.sh || /opt/torchvision/build.sh

#
###

###
# opencv
#
ARG OPENCV_VERSION=4.9.0 \
    OPENCV_PYTHON=4.x \
    CUDA_ARCH_BIN=8.9 \
    FORCE_BUILD=off

COPY ./opencv /opt/opencv

RUN /opt/opencv/install.sh

#
###

###
# onnxruntime
#
ARG ONNXRUNTIME_VERSION=1.17.0 \
    ONNXRUNTIME_BRANCH=v1.17.0 \
    ONNXRUNTIME_FLAGS=--allow_running_as_root \
    FORCE_BUILD=off

COPY ./onnxruntime /opt/onnxruntime

RUN /opt/onnxruntime/install.sh || /opt/onnxruntime/build.sh

#
###

###
# patchmatch
RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        libopencv-dev \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && pip install pypatchmatch \
    && python3 -m patchmatch.patch_match

#
###

###
# cargo
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

#
###

#
#####


###
# build invoke
#
FROM scratch AS invokeai
FROM pytorch as invoke-builder

# nvm / npm / pnpm
ENV NVM_DIR=/usr/local/nvm

ARG INVOKEAI_GIT_TARGET
ARG INVOKEAI_GIT_TAG

RUN \
    mkdir $NVM_DIR \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install 18 \
    && nvm use 18 \
    && corepack enable \
    && corepack prepare pnpm@8.15.6

RUN git clone ${INVOKEAI_GIT_TARGET} -b ${INVOKEAI_GIT_TAG} /opt/invokeai_source

# TODO - PIP TORCH OVERWRITE BUG
# - need to patch pyproject.toml to prevent over writing torch dependencies

COPY --from=invokeai patch/pyproject.toml /opt/invokeai_source/pyproject.toml
COPY --from=invokeai patch/package.json /opt/invokeai_source/invokeai/frontend/web/package.json

RUN \
    cd /opt/invokeai_source/invokeai/frontend/web \
    && . $NVM_DIR/nvm.sh \
    && pnpm install \
    && pnpm fix \
    && pnpm build

RUN \
    cd /opt/invokeai_source \
    && pip wheel -w dist --no-deps .

#
###

###
# runtime
#
FROM pytorch as runtime
ARG INVOKEAI_GIT_TAG

COPY --from=invoke-builder /opt/invokeai_source/dist/InvokeAI-*-py3-none-any.whl /opt/invokeai_source/

RUN pip install /opt/invokeai_source/InvokeAI-*-py3-none-any.whl

COPY --from=invokeai runtime/invokeai.yaml /opt/invokeai_data/invokeai.yaml
COPY --from=invokeai runtime/entrypoint.sh /opt/entrypoint.sh

CMD ["/opt/entrypoint.sh"]

#
###