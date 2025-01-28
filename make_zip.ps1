param (
    [System.Version]$Version = "0.0.0.0",
    [string]$Arch = "x64",
    [string]$CompanyName = "ONLYOFFICE",
    [string]$ProductName = "DocumentBuilder",
    [string]$BuildDir = "build"
)

$ErrorActionPreference = "Stop"

Set-Location $PSScriptRoot

if (-not (Test-Path "$BuildDir")) {
    Write-Error "Path `"$BuildDir`" does not exist"
}
$ZipFile = "zip\$CompanyName-$ProductName-$Version-$Arch.zip"

Write-Host @"
Version     = $Version
Arch        = $Arch
CompanyName = $CompanyName
ProductName = $ProductName
BuildDir    = $BuildDir
ZipFile     = $ZipFile
"@

####

Write-Host "`n[ Create archive ]"

if (Test-Path "$ZipFile") {
    Write-Host "DELETE: $ZipFile"
    Remove-Item -Force -LiteralPath "$ZipFile"
}

Write-Host "CREATE DIR: zip"
New-Item -ItemType Directory -Force -Path "zip" | Out-Null

Write-Host "7z a -y $ZipFile .\$BuildDir\*"
& 7z a -y "$ZipFile" ".\$BuildDir\*"
if (-not $?) { throw "Exited with code $LastExitCode" }
