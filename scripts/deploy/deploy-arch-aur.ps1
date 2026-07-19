using module ../core/core.psm1

[CmdletBinding()]
param([string]$Version = $env:CI_COMMIT_TAG.TrimStart('v'))

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
$kv          = $global:__automator_devops.kvinc
$logname     = 'deploy-stage-arch-aur'
#---UI ELEMENTS Shortened-------------

#---CONFIG----------------------------
$Config      = (Get-Content './build_config.json' -Raw | ConvertFrom-Json).Deployment.Arch
$PrivateKey  = [Environment]::GetEnvironmentVariable($Config.ssh_key_variable)
$PackageName = $Config.package_name
$ReleaseUrl  = $Config.release_url -replace 'VERSION', $Version
$Artifact    = $Config.artifact -replace 'VERSION', $Version
$ArtifactPath = [System.IO.Path]::Combine('./dist/dotnet/release', $Artifact)
#---CONFIG----------------------------

if ([string]::IsNullOrWhiteSpace($Version) -or [string]::IsNullOrWhiteSpace($PrivateKey)) {
    $interLogger.invoke($logname, 'Arch deployment requires a release version and the configured AUR SSH key', $false, 'error')
    exit 1
}

if (!(Test-Path -Path $ArtifactPath -PathType Leaf)) {
    $interLogger.invoke($logname, "Arch release artifact was not found at {err:kv:path=$ArtifactPath}", $false, 'error')
    exit 1
}

$Hash = (Get-FileHash -Path $ArtifactPath -Algorithm SHA256).Hash.ToLower()
$WorkPath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "aur-$PackageName-$([guid]::NewGuid())")
$KeyPath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "aur-key-$([guid]::NewGuid())")

$interLogger.invoke($logname, "Updating Arch User Repository package {kv:package=$PackageName}", $false, 'info')
$kv.invoke('Version', $Version)
$kv.invoke('Source', $ReleaseUrl)
$kv.invoke('SHA256', $Hash)

try {
    Set-Content -Path $KeyPath -Value $PrivateKey -Encoding utf8
    chmod 600 $KeyPath
    $env:GIT_SSH_COMMAND = "ssh -i '$KeyPath' -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"

    git -c init.defaultBranch=master clone "ssh://aur@aur.archlinux.org/$PackageName.git" $WorkPath
    if ($LASTEXITCODE -ne 0) { throw 'Unable to clone the AUR package repository.' }

    $PkgBuild = @"
# Maintainer: $($Config.maintainer)
pkgname=$PackageName
pkgver=$Version
pkgrel=1
pkgdesc='$($Config.description)'
arch=('x86_64')
url='$($Config.homepage)'
license=('$($Config.license)')
provides=('$($Config.provides)')
conflicts=('$($Config.provides)')
source=("$Artifact::$ReleaseUrl")
sha256sums=('$Hash')

package() {
  install -Dm755 "`$srcdir/$($Config.executable)" "`$pkgdir/usr/bin/$($Config.executable)"
  install -Dm644 "`$srcdir/LICENSE" "`$pkgdir/usr/share/licenses/`$pkgname/LICENSE"
}
"@

    Set-Content -Path ([System.IO.Path]::Combine($WorkPath, 'PKGBUILD')) -Value $PkgBuild -Encoding utf8
    Push-Location $WorkPath
    try {
        makepkg --printsrcinfo | Set-Content -Path '.SRCINFO' -Encoding utf8
        if ($LASTEXITCODE -ne 0) { throw 'makepkg failed to generate .SRCINFO.' }
        if (Get-Command namcap -ErrorAction SilentlyContinue) { namcap PKGBUILD }
        git add PKGBUILD .SRCINFO
        git -c "user.name=$($Config.git_name)" -c "user.email=$($Config.git_email)" commit -m "chore: update $PackageName to $Version"
        git push origin HEAD:master
        if ($LASTEXITCODE -ne 0) { throw 'Unable to push the AUR package update.' }
    } finally {
        Pop-Location
    }

    $interLogger.invoke($logname, "Updated AUR package {kv:version=$Version}", $false, 'success')
} catch {
    $interLogger.invoke($logname, "Arch deployment failed: {err:kv:error=$($_.Exception.Message)}", $false, 'error')
    exit 1
} finally {
    Remove-Item Env:GIT_SSH_COMMAND -ErrorAction SilentlyContinue
    if (Test-Path $KeyPath) { Remove-Item $KeyPath -Force }
    if (Test-Path $WorkPath) { Remove-Item $WorkPath -Recurse -Force }
}
