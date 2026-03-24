# Run: powershell -File test/test-new-adr-edge.ps1 (from repo root)
$ErrorActionPreference = "Stop"
$Root = Split-Path $PSScriptRoot -Parent
Set-Location $Root

function Fail($msg) {
    Write-Error "FAIL: $msg"
    exit 1
}

Remove-Item "docs\adr" -Recurse -Force -ErrorAction SilentlyContinue

powershell -NoProfile -ExecutionPolicy Bypass -File ".\new-adr.ps1" 2>$null
if ($LASTEXITCODE -ne 1) { Fail "no args should exit 1" }
if (Test-Path "docs\adr") { Fail "no args should not create docs\adr" }

powershell -NoProfile -ExecutionPolicy Bypass -File ".\new-adr.ps1" "Normal"
if (-not (Test-Path "docs\adr\0001-normal.md")) { Fail "fresh 0001" }

powershell -NoProfile -ExecutionPolicy Bypass -File ".\new-adr.ps1" "!!!"
if (-not (Test-Path "docs\adr\0002-untitled.md")) { Fail "punct-only -> untitled" }

Remove-Item "docs\adr" -Recurse -Force
New-Item -ItemType Directory -Path "docs\adr" -Force | Out-Null
Set-Content "docs\adr\0005-keep.md" "x" -Encoding utf8
powershell -NoProfile -ExecutionPolicy Bypass -File ".\new-adr.ps1" "Six"
if (-not (Test-Path "docs\adr\0006-six.md")) { Fail "increment after 0005" }

Remove-Item "docs\adr" -Recurse -Force
New-Item -ItemType Directory -Path "docs\adr" -Force | Out-Null
Set-Content "docs\adr\0009-a.md" "x" -Encoding utf8
Set-Content "docs\adr\0010-b.md" "x" -Encoding utf8
powershell -NoProfile -ExecutionPolicy Bypass -File ".\new-adr.ps1" "Eleven"
if (-not (Test-Path "docs\adr\0011-eleven.md")) { Fail "order after 0010" }

Remove-Item "docs\adr" -Recurse -Force
New-Item -ItemType Directory -Path "docs\adr" -Force | Out-Null
Set-Content "docs\adr\template.md" "x" -Encoding utf8
powershell -NoProfile -ExecutionPolicy Bypass -File ".\new-adr.ps1" "First real"
if (-not (Test-Path "docs\adr\0001-first-real.md")) { Fail "ignore template.md" }

Remove-Item "docs\adr" -Recurse -Force
New-Item -ItemType Directory -Path "docs\adr" -Force | Out-Null
Set-Content "docs\adr\0005-a.md" "x" -Encoding utf8
Set-Content "docs\adr\0006-six.md" "x" -Encoding utf8
powershell -NoProfile -ExecutionPolicy Bypass -File ".\new-adr.ps1" "Six"
if (-not (Test-Path "docs\adr\0007-six.md")) { Fail "bump when filename collides" }

Remove-Item "docs\adr" -Recurse -Force
New-Item -ItemType Directory -Path "docs\adr" -Force | Out-Null
Set-Content "docs\adr\10000-z.md" "x" -Encoding utf8
powershell -NoProfile -ExecutionPolicy Bypass -File ".\new-adr.ps1" "Next"
if (-not (Test-Path "docs\adr\10001-next.md")) { Fail "ADR past 9999" }

Remove-Item "docs\adr" -Recurse -Force
New-Item -ItemType Directory -Path "docs\adr\.new-adr.lock" -Force | Out-Null
powershell -NoProfile -ExecutionPolicy Bypass -File ".\new-adr.ps1" "Locked" 2>$null
if ($LASTEXITCODE -ne 1) { Fail "lock should block concurrent run" }
Remove-Item "docs\adr" -Recurse -Force

Remove-Item "docs\adr" -Recurse -Force -ErrorAction SilentlyContinue
powershell -NoProfile -ExecutionPolicy Bypass -File ".\new-adr.ps1" "Hello_World Test"
if (-not (Test-Path "docs\adr\0001-hello-world-test.md")) { Fail "ps1 slug" }

Write-Host "OK ps1 edge tests"
Remove-Item "docs\adr" -Recurse -Force -ErrorAction SilentlyContinue
