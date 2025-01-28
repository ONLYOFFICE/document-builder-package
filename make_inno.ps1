param (
    [System.Version]$Version = "0.0.0.0",
    [string]$Arch = "x64",
    [string]$CompanyName = "ONLYOFFICE",
    [string]$ProductName = "DocumentBuilder",
    [string]$BuildDir = "build",
    [string]$Branding,
    [switch]$Sign
)

$ErrorActionPreference = "Stop"

Set-Location $PSScriptRoot

if ( -Not (Test-Path -Path "$BuildDir") ) {
    Write-Error "Path `"$BuildDir`" does not exist"
}

Write-Host @"
Version       $Version
Arch          $Arch
CompanyName   $CompanyName
ProductName   $ProductName
BuildDir      $BuildDir
Branding      $Branding
Sign          $Sign
"@

####

Write-Host "`n[ Get Inno Setup path ]"

if ($env:INNOPATH) {
    $InnoPath = $env:INNOPATH
}
else {
    $RegPath = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Inno Setup 6_is1"
    $InnoPath = (Get-ItemProperty $RegPath)."Inno Setup: App Path"
}
$InnoPath
$env:Path = "$InnoPath;$env:Path"

####

Write-Host "`n[ Build Inno Setup project ]"

$InnoArgs = "/DARCH=$Arch",
            "/DVERSION=$Version"
if ($Branding) {
    $InnoArgs += "/DBRANDING_DIR=$Branding"
}
if ($Sign) {
    $CertName = $(if ($env:WINDOWS_CERTIFICATE_NAME) { `
        $env:WINDOWS_CERTIFICATE_NAME } else { "Ascensio System SIA" })
    $TimestampServer = "http://timestamp.digicert.com"
    $InnoArgs += "/DSIGN"
    $InnoArgs += "/Sbyparam=signtool sign /a /v /n `$q$CertName`$q /t $TimestampServer `$f"
}

Write-Host "ISCC $InnoArgs exe\builder.iss"
& ISCC $InnoArgs exe\builder.iss
if (-not $?) { throw "Exited with code $LastExitCode" }
