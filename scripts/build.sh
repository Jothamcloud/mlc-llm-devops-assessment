#!/usr/bin/env bash
set -euo pipefail

# Conda activation
source /opt/conda/etc/profile.d/conda.sh
eval "$(conda shell.bash hook)"
conda activate mlc


cd /workspace/mlc-llm

# Fix git ownership issue for mounted volumes
git config --global --add safe.directory /workspace/mlc-llm

# Ensure submodules are present
git submodule update --init --recursive

# Native build
mkdir -p build
cd build

# Non-interactive config: Vulkan ON, everything else OFF
python ../cmake/gen_cmake_config.py <<EOF

n
n
y
n
n
EOF

cmake .. -DCMAKE_POLICY_VERSION_MINIMUM=3.5
make -j"$(nproc)"

# Sanity check native artifacts
ls -l libmlc_llm.so
ls -l tvm/libtvm_runtime.so

cd ..

# TVM Python runtime
python -m pip install --pre -U -f https://mlc.ai/wheels mlc-ai-nightly-cpu

# Build Python wheel
cd python
rm -rf dist
mkdir -p dist

pip wheel . -w dist

echo "✅ Build + package complete"
ls -lh dist
