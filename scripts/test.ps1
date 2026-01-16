ErrorActionPreference = "Stop"

Write-Host "==> Install TVM runtime"
python -m pip install --pre -U -f https://mlc.ai/wheels mlc-ai-nightly-cpu

Write-Host "==> Find downloaded mlc_llm wheel"
$wheel = Get-ChildItem -Path "mlc-llm\python\dist" -Filter "mlc_llm-*.whl" | Select-Object -First 1

if (!$wheel) {
  Write-Host "❌ ERROR: mlc_llm wheel not found in mlc-llm\python\dist"
  Get-ChildItem "mlc-llm\python\dist"
  exit 1
}

Write-Host "==> Install built wheel: $($wheel.FullName)"
python -m pip install "$($wheel.FullName)"

Write-Host "==> CLI test"
mlc_llm chat -h

Write-Host "==> Python import test"
python -c "import mlc_llm; print('mlc_llm OK:', mlc_llm.__file__)"

Write-Host "✅ Tests passed"