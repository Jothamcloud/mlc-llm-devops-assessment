$ErrorActionPreference = "Stop"

Write-Host "==> Clone mlc-llm repo if missing"
if (!(Test-Path "mlc-llm")) {
  git clone --recursive https://github.com/mlc-ai/mlc-llm.git
}

Set-Location "mlc-llm"

Write-Host "==> Ensure submodules are present"
git submodule update --init --recursive

Write-Host "==> Create build directory"
if (!(Test-Path "build")) { New-Item -ItemType Directory -Path "build" | Out-Null }
Set-Location "build"

Write-Host "==> Generate config"
$stdinFile = Join-Path $PWD "stdin.txt"

@"
 
n
n
y
n
n
"@ | ForEach-Object { $_.TrimEnd() } | Set-Content -Encoding ASCII $stdinFile

cmd /c "python ..\cmake\gen_cmake_config.py < stdin.txt"

Write-Host "==> Configure CMake with Vulkan SDK paths"
Write-Host "VULKAN_SDK = $env:VULKAN_SDK"

cmake .. `
  "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" `
  "-DVulkan_LIBRARY=$env:VULKAN_SDK\Lib\vulkan-1.lib"

Write-Host "==> Build Release"
cmake --build . --config Release --parallel

Write-Host "==> Fix: ensure mlc_llm.dll is in build root"
if (Test-Path ".\Release\mlc_llm.dll") {
  Copy-Item ".\Release\mlc_llm.dll" ".\mlc_llm.dll" -Force
}

if (!(Test-Path ".\mlc_llm.dll")) {
  Write-Host "❌ ERROR: mlc_llm.dll not found after build"
  Write-Host "Contents of build folder:"
  Get-ChildItem -Recurse | Select-Object FullName
  exit 1
}

Write-Host "==> Install TVM runtime"
python -m pip install --pre -U -f https://mlc.ai/wheels mlc-ai-nightly-cpu

Write-Host "==> Build Python wheel "
Set-Location "..\python"

Write-Host "==> Patch requirements.txt to skip flashinfer on Windows"
if (Test-Path "requirements.txt") {
  (Get-Content "requirements.txt") `
    -replace '^flashinfer-python==0\.4\.0$', 'flashinfer-python==0.4.0; sys_platform == "linux"' |
    Set-Content "requirements.txt"
}

if (Test-Path "dist") { Remove-Item -Recurse -Force "dist" }
New-Item -ItemType Directory -Path "dist" | Out-Null

pip wheel . -w dist

Write-Host "✅ Windows build complete"
Get-ChildItem dist
