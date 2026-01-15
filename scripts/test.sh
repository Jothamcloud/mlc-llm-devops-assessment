#!/usr/bin/env bash
set -euo pipefail

source /opt/conda/etc/profile.d/conda.sh
eval "$(conda shell.bash hook)"
conda activate mlc

git config --global --add safe.directory /workspace/mlc-llm

cd /workspace/

echo "Wheels available"
ls -lh mlc-llm/dist

echo "Installing TVM runtime"
python -m pip install --pre -U -f https://mlc.ai/wheels mlc-ai-nightly-cpu

# Install built wheel
pip install mlc-llm/dist/*.whl

# CLI test
mlc_llm chat -h

# Python import test
python - <<EOF
import mlc_llm
print("mlc_llm OK:", mlc_llm.__file__)
EOF

echo "✅ Tests passed"
