param(
    [string]$KeystorePath = (Join-Path $env:USERPROFILE '.android-keystores\saving-goals-upload.jks'),
    [string]$Alias = 'upload',
    [switch]$GeneratePassword
)
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
$propertiesPath = Join-Path $repoRoot 'android\key.properties'
$keytool = 'C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe'
if (-not (Test-Path -LiteralPath $keytool)) { $keytool = (Get-Command keytool -ErrorAction Stop).Source }
if ((Test-Path -LiteralPath $KeystorePath) -or (Test-Path -LiteralPath $propertiesPath)) {
    throw 'A keystore or android/key.properties already exists. Use the existing signing identity; this helper never overwrites it.'
}
if ($GeneratePassword) {
    $bytes = New-Object byte[] 32
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try { $rng.GetBytes($bytes) } finally { $rng.Dispose() }
    $password = [Convert]::ToBase64String($bytes)
} else {
    $secret = Read-Host 'Choose a private upload-keystore password (at least 12 characters)' -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret)
    try { $password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
    if ($password.Length -lt 12) { throw 'Choose a password of at least 12 characters.' }
}
if ($password.Contains("`n") -or $password.Contains("`r")) { throw 'Password must be one line.' }
New-Item -ItemType Directory -Path (Split-Path $KeystorePath -Parent) -Force | Out-Null
$previousPassword = $env:SAVING_GOALS_KEY_PASSWORD
try {
    $env:SAVING_GOALS_KEY_PASSWORD = $password
    & $keytool -genkeypair -keystore $KeystorePath -storetype JKS -keyalg RSA -keysize 4096 -validity 10000 -alias $Alias -dname 'CN=Saving Goals Upload' -storepass:env SAVING_GOALS_KEY_PASSWORD -keypass:env SAVING_GOALS_KEY_PASSWORD -noprompt
    if ($LASTEXITCODE -ne 0) { throw 'Upload key generation failed.' }
    $publicCertificate = [System.IO.Path]::ChangeExtension($KeystorePath, '.pem')
    & $keytool -exportcert -rfc -keystore $KeystorePath -alias $Alias -storepass:env SAVING_GOALS_KEY_PASSWORD -file $publicCertificate
    if ($LASTEXITCODE -ne 0) { throw 'Public certificate export failed.' }
    function Escape-Property([string]$value) {
        $result = New-Object System.Text.StringBuilder
        foreach ($character in $value.ToCharArray()) {
            $code = [int][char]$character
            if ($code -gt 126 -or $code -lt 32) { [void]$result.Append(('\u{0:x4}' -f $code)) }
            elseif ('\:=#! '.Contains([string]$character)) { [void]$result.Append('\'); [void]$result.Append($character) }
            else { [void]$result.Append($character) }
        }
        return $result.ToString()
    }
    $content = "storeFile=$(Escape-Property ([System.IO.Path]::GetFullPath($KeystorePath).Replace('\','/')))`nstorePassword=$(Escape-Property $password)`nkeyAlias=$(Escape-Property $Alias)`nkeyPassword=$(Escape-Property $password)`n"
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($propertiesPath, $content, $utf8)
    [System.IO.File]::WriteAllText((Join-Path (Split-Path $KeystorePath -Parent) 'saving-goals-key.properties'), $content, $utf8)
    Write-Output "Created private upload keystore: $KeystorePath"
    Write-Output 'Password saved in ignored android/key.properties and alongside the private keystore; it was not printed.'
    Write-Output "Public upload certificate: $publicCertificate"
} finally {
    $env:SAVING_GOALS_KEY_PASSWORD = $previousPassword
    $password = $null
}
