param (
    [string]$Arch = "x64",
    [string]$Version = "1.0.0",
    [string]$Build = "1",
    [string]$Branding,
    [switch]$Sign = $false,
    [string]$CertName = "Ascensio System SIA",
    [string]$TimestampServer = "http://timestamp.digicert.com"
)

Set-Location $PSScriptRoot

$ErrorActionPreference = "Stop"
$BuildDir = "..\build"

# Check base directory
if (-Not (Test-Path -Path "$BuildDir\base")) {
    Write-Host "Path $BuildDir\base not exists" -ForegroundColor Red
    Exit 1
}

# ISCC path
$InnoPath=(Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Inno Setup 6_is1")."Inno Setup: App Path"
$env:Path = "$InnoPath;$env:Path"

# ISCC args
$InnoArgs = "/DBASE_DIR=$BuildDir\base",
            "/DOUTPUT_DIR=$BuildDir\exe",
            "/DVERSION=$Version.$Build"
if ($Branding) {
    $InnoArgs += "/DBRANDING_DIR=$Branding"
}
if ($Sign) {
    $InnoArgs += "/DSIGN"
    $InnoArgs += "/S'byparam=signtool.exe sign /v /n `$q$CertName`$q /t $TimestampServer `$f'"
}

# Build
Write-Host "ISCC $InnoArgs builder.iss" -ForegroundColor Yellow
& ISCC $InnoArgs builder.iss
