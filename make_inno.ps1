param (
    [string]$Arch = "x64",
    [string]$Version = "1.0.0",
    [string]$Build = "1",
    [string]$Branding,
    [switch]$Sign = $false
)

$ErrorActionPreference = "Stop"

Set-Location $PSScriptRoot

# Check app directory
if ( -Not (Test-Path -Path "build\app") ) {
    Write-Error "Path build\app does not exist"
}

# ISCC path
if ( $env:INNOPATH ) {
    $InnoPath = $env:INNOPATH
}
else
{
    $InnoPath = (Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Inno Setup 6_is1")."Inno Setup: App Path"
}
$env:Path = "$InnoPath;$env:Path"

# ISCC args
$InnoArgs = "/DAPP_DIR=..\build\app",
            "/DOUTPUT_DIR=..\build",
            "/DARCH=$Arch",
            "/DVERSION=$Version.$Build"
if ( $Branding ) {
    $InnoArgs += "/DBRANDING_DIR=$Branding"
}
if ( $Sign ) {
    $CertFile = $env:WINDOWS_CERTIFICATE
    $CertPass = $env:WINDOWS_CERTIFICATE_PASSWORD
    $TimestampServer = "http://timestamp.digicert.com"
    $InnoArgs += "/DSIGN", "/Sbyparam=signtool sign /f `$q$CertFile`$q /p `$q$CertPass`$q /t $TimestampServer `$f"
}

# Build
Write-Host "ISCC $InnoArgs exe\builder.iss" -ForegroundColor Yellow
& ISCC $InnoArgs exe\builder.iss
Exit $LastExitCode
