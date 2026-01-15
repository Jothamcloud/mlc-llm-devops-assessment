FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CONDA_DIR=/opt/conda
ENV PATH=${CONDA_DIR}/bin:$PATH

# system deps
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    libvulkan-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# install miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
      -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p ${CONDA_DIR} && \
    rm /tmp/miniconda.sh

# configure conda
RUN conda config --set plugins.auto_accept_tos true && \
    conda config --add channels conda-forge

# create mlc env
RUN conda create -y -n mlc \
    python=3.13 \
    "cmake>=3.24" \
    rust \
    git \
    git-lfs \
    ccache \
    libstdcxx-ng \
    spirv-headers \
    spirv-tools \
    vulkan-tools

#bash shell so conda works
SHELL ["/bin/bash", "-c"]

WORKDIR /workspace

#DEV ENTRYPOINT
ENTRYPOINT ["/bin/bash"]
