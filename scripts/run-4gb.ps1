[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$Model,
    [Parameter(Mandatory=$true)][string]$Trunk,
    [string]$Tok,
    [string]$Prompt,
    [string]$PromptFile,
    [string]$Ids,
    [ValidateRange(0, 4096)][int]$Gen = 1,
    [string]$Out = "k3_4gb_run.json",
    [ValidateRange(1, 64)][int]$Threads = 2,
    [string]$Msys2Root = "C:\msys64"
)

$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$K3 = Join-Path $Root "upstream\bin\k3.exe"

if (-not (Test-Path $K3)) {
    Write-Error "k3.exe not found: $K3`nRun .\scripts\bootstrap-windows.ps1 first."
    exit 2
}
if (-not (Test-Path $Model -PathType Container)) {
    Write-Error "Model directory not found: $Model"
    exit 2
}
if (-not (Test-Path $Trunk -PathType Container)) {
    Write-Error "Trunk directory not found: $Trunk"
    exit 2
}

$PromptCount = 0
if ($PSBoundParameters.ContainsKey('Prompt')) { $PromptCount++ }
if ($PSBoundParameters.ContainsKey('PromptFile')) { $PromptCount++ }
if ($PSBoundParameters.ContainsKey('Ids')) { $PromptCount++ }
if ($PromptCount -ne 1) {
    Write-Error "Provide exactly one of -Prompt, -PromptFile, or -Ids."
    exit 2
}

$ArgsList = @(
    $Model,
    "--trunk", $Trunk,
    "--preset", "ultra",
    "--ultra-low-memory",
    "--gen", "$Gen",
    "--out", $Out
)

if ($PSBoundParameters.ContainsKey('Prompt')) {
    if ([string]::IsNullOrWhiteSpace($Tok)) {
        Write-Error "-Prompt requires -Tok <tokenizer/model directory>."
        exit 2
    }
    $ArgsList += @("--tok", $Tok, "--prompt", $Prompt)
}
elseif ($PSBoundParameters.ContainsKey('PromptFile')) {
    if ([string]::IsNullOrWhiteSpace($Tok)) {
        Write-Error "-PromptFile requires -Tok <tokenizer/model directory>."
        exit 2
    }
    if (-not (Test-Path $PromptFile -PathType Leaf)) {
        Write-Error "Prompt file not found: $PromptFile"
        exit 2
    }
    $ArgsList += @("--tok", $Tok, "--prompt-file", $PromptFile)
}
else {
    $ArgsList += @("--ids", $Ids)
}

# Ensure MinGW runtime DLLs (for example libgomp) are visible when k3.exe is launched
# directly from PowerShell/CMD instead of an MSYS2 terminal.
$MingwBin = Join-Path $Msys2Root "mingw64\bin"
if (Test-Path $MingwBin) {
    $env:Path = "$MingwBin;$env:Path"
}

# Keep OpenMP conservative on a low-RAM host.
$env:OMP_NUM_THREADS = "$Threads"

Write-Host "KimiK3-4G Windows"
Write-Host "Profile : ultra / ultra-low-memory"
Write-Host "Threads : $Threads"
Write-Host "Gen     : $Gen"
Write-Host "Model   : $Model"
Write-Host "Trunk   : $Trunk"
Write-Host ""
Write-Host "Running:"
Write-Host ('"{0}" {1}' -f $K3, (($ArgsList | ForEach-Object { '"' + ($_ -replace '"','\"') + '"' }) -join ' '))
Write-Host ""

& $K3 @ArgsList
exit $LASTEXITCODE
