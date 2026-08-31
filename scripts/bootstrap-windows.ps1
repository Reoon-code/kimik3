[CmdletBinding()]
param(
    [int]$Jobs = 2,
    [string]$Msys2Root = "C:\msys64"
)

$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Bash = Join-Path $Msys2Root "usr\bin\bash.exe"

if (-not (Test-Path $Bash)) {
    Write-Error @"
MSYS2 bash was not found at: $Bash
Install MSYS2 from https://www.msys2.org/ and keep the default C:\msys64 path,
or run this script with -Msys2Root <path>.
Then open MSYS2 MINGW64 once and install:
  pacman -Syu
  pacman -S --needed git make mingw-w64-x86_64-gcc python
"@
    exit 2
}

$env:KIMIK3_ROOT_WIN = $Root
$env:KIMIK3_JOBS = "$Jobs"
$env:MSYSTEM = "MINGW64"
$env:CHERE_INVOKING = "1"

Write-Host "KimiK3-4G Windows bootstrap"
Write-Host "Root : $Root"
Write-Host "MSYS2: $Msys2Root"
Write-Host "Jobs : $Jobs"
Write-Host ""

& $Bash -lc 'cd "$(cygpath -u "$KIMIK3_ROOT_WIN")" && ./scripts/bootstrap.sh'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$Exe = Join-Path $Root "upstream\bin\k3.exe"
if (Test-Path $Exe) {
    Write-Host ""
    Write-Host "PASS: built $Exe"
} else {
    Write-Warning "Build finished but k3.exe was not found at $Exe. Check the MSYS2 build output."
}
