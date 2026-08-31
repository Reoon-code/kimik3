[CmdletBinding()]
param(
    [int]$Jobs = 2,
    [string]$Msys2Root = "C:\msys64"
)

$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Bash = Join-Path $Msys2Root "usr\bin\bash.exe"

if (-not (Test-Path $Bash)) {
    Write-Error "MSYS2 bash not found: $Bash"
    exit 2
}

$env:KIMIK3_ROOT_WIN = $Root
$env:KIMIK3_JOBS = "$Jobs"
$env:MSYSTEM = "MINGW64"
$env:CHERE_INVOKING = "1"
& $Bash -lc 'cd "$(cygpath -u "$KIMIK3_ROOT_WIN")" && ./scripts/verify.sh'
exit $LASTEXITCODE
