param (
    [System.Version]$Version = "0.0.0.0",
    [string]$Arch = "x64",
    [string]$CompanyName = "ONLYOFFICE",
    [string]$ProductName = "DocumentBuilder",
    [string]$SourceDir,
    [string]$BuildDir = "build",
    [switch]$Sign
)
$ErrorActionPreference = "Stop"

Set-Location $PSScriptRoot

if (-not $SourceDir) {
    $BuildPrefix = switch ($Arch) {
        "x64" { "win_64" }
        "x86" { "win_32" }
    }
    $SourceDir = "$PSScriptRoot\..\build_tools\out\" `
        + "$BuildPrefix\$CompanyName\$ProductName" | Resolve-Path
}
if (-not (Test-Path "$SourceDir")) {
    Write-Error "Path `"$SourceDir`" does not exist"
}

Write-Host @"
Version       $Version
Arch          $Arch
CompanyName   $CompanyName
ProductName   $ProductName
SourceDir     $SourceDir
BuildDir      $BuildDir
Sign          $Sign
"@

####

Write-Host "`n[ Prepare build directory ]"

if (Test-Path "$BuildDir") {
    Write-Host "REMOVE DIR: $BuildDir"
    Remove-Item -Force -Recurse -LiteralPath "$BuildDir"
}

Write-Host "CREATE DIR: $BuildDir"
New-Item -ItemType Directory -Force -Path "$BuildDir" | Out-Null

Write-Host "COPY: $SourceDir\* > $BuildDir\"
Copy-Item -Force -Recurse `
    -Path "$SourceDir\*" `
    -Destination "$BuildDir\"

####

Write-Host "`n[ Sign files ]"

if ($Sign) {
    Set-Location "$BuildDir"

    $CertName = $(if ($env:WINDOWS_CERTIFICATE_NAME) { `
        $env:WINDOWS_CERTIFICATE_NAME } else { "Ascensio System SIA" })
    $TimestampServer = "http://timestamp.digicert.com"
    $SignFiles = Get-ChildItem *.exe, *.dll | Resolve-Path -Relative
    $SignFiles

    Write-Host "signtool sign /a /n $CertName /t $TimestampServer /v ..."
    & signtool sign /a /n $CertName /t $TimestampServer /v $SignFiles
    if (-not $?) { throw "Exited with code $LastExitCode" }

    Write-Host "signtool verify /q /pa /all ..."
    & signtool verify /q /pa /all $SignFiles | Out-Null
    if (-not $?) { throw "Exited with code $LastExitCode" }

    Set-Location $PSScriptRoot
}
