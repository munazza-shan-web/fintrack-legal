$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
$releaseFolder = Join-Path $repoRoot 'output\play-store-release-1.3.4'
if (-not (Test-Path -LiteralPath (Join-Path $repoRoot 'android\key.properties'))) {
    throw 'Configure your upload keystore first: run tools/setup_upload_key.ps1 or fill android/key.properties from the example.'
}
if ($env:SAVING_GOALS_PREPARE_UNSIGNED_RELEASE -eq 'true' -or $env:ORG_GRADLE_PROJECT_prepareUnsignedRelease -eq 'true') {
    throw 'Unsigned preparation mode is enabled. Clear its environment variables before building the signed release.'
}
Push-Location $repoRoot
try {
    & flutter build appbundle --release
    if ($LASTEXITCODE -ne 0) { throw 'Signed app bundle build failed.' }
    & flutter build apk --release
    if ($LASTEXITCODE -ne 0) { throw 'Signed APK build failed.' }
    $javaBin = 'C:\Program Files\Android\Android Studio\jbr\bin'
    $androidSdk = Join-Path $env:LOCALAPPDATA 'Android\sdk'
    $signer = Join-Path $androidSdk 'build-tools\36.0.0\apksigner.bat'
    $env:JAVA_HOME = Split-Path $javaBin -Parent
    & (Join-Path $javaBin 'jarsigner.exe') -verify 'build\app\outputs\bundle\release\app-release.aab'
    if ($LASTEXITCODE -ne 0) { throw 'App bundle signature verification failed.' }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $bundleZip = [System.IO.Compression.ZipFile]::OpenRead((Join-Path $repoRoot 'build\app\outputs\bundle\release\app-release.aab'))
    try {
        if (-not ($bundleZip.Entries | Where-Object FullName -Match '^META-INF/[^/]+\.(RSA|DSA|EC)$')) {
            throw 'App bundle is unsigned; no signing certificate entry was found.'
        }
    } finally { $bundleZip.Dispose() }
    & $signer verify --print-certs 'build\app\outputs\flutter-apk\app-release.apk'
    if ($LASTEXITCODE -ne 0) { throw 'APK signature verification failed.' }
    New-Item -ItemType Directory -Path $releaseFolder -Force | Out-Null
    Copy-Item -LiteralPath 'build\app\outputs\bundle\release\app-release.aab' -Destination (Join-Path $releaseFolder 'saving-goals-1.3.4-build8-play-store.aab')
    Copy-Item -LiteralPath 'build\app\outputs\flutter-apk\app-release.apk' -Destination (Join-Path $releaseFolder 'saving-goals-1.3.4-build8-release.apk')
    Get-ChildItem -LiteralPath $releaseFolder -File | Where-Object { $_.Extension -in '.aab','.apk' -and $_.Name -notlike '*UNSIGNED*' } | Get-FileHash -Algorithm SHA256 | ForEach-Object { "$($_.Hash)  $([System.IO.Path]::GetFileName($_.Path))" } | Set-Content -LiteralPath (Join-Path $releaseFolder 'SHA256SUMS.txt') -Encoding ascii
    Write-Output "Verified signed release artifacts saved to $releaseFolder"
} finally {
    Pop-Location
}
