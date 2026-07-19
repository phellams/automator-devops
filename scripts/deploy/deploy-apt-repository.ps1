using module ../core/core.psm1

[CmdletBinding()]
param([string]$Version = $env:CI_COMMIT_TAG.TrimStart('v'))

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
$kv          = $global:__automator_devops.kvinc
$logname     = 'deploy-stage-apt'
#---UI ELEMENTS Shortened-------------

#---CONFIG----------------------------
$Config       = (Get-Content './build_config.json' -Raw | ConvertFrom-Json).Deployment.Apt
$SshKey       = [Environment]::GetEnvironmentVariable($Config.ssh_key_variable)
$PackageFiles = Get-ChildItem './dist/dotnet/deb' -Filter "*$Version*.deb" -ErrorAction SilentlyContinue
#---CONFIG----------------------------

if (!$PackageFiles -or [string]::IsNullOrWhiteSpace($SshKey)) {
    $interLogger.invoke($logname, 'APT packages or the configured SSH key were not found', $false, 'error')
    exit 1
}

$KeyPath = Join-Path ([System.IO.Path]::GetTempPath()) "apt-key-$([guid]::NewGuid())"
try {
    Set-Content $KeyPath $SshKey -Encoding utf8
    if (!$IsWindows) { chmod 600 $KeyPath }
    foreach ($Package in $PackageFiles) {
        $interLogger.invoke($logname, "Uploading Debian package {kv:file=$($Package.Name)}", $false, 'info')
        scp -i $KeyPath $Package.FullName "$($Config.user)@$($Config.host):$($Config.incoming)/$($Package.Name)"
        if ($LASTEXITCODE -ne 0) { throw "scp exited with code $LASTEXITCODE" }
        ssh -i $KeyPath "$($Config.user)@$($Config.host)" "reprepro -b '$($Config.repository_path)' includedeb '$($Config.distribution)' '$($Config.incoming)/$($Package.Name)'"
        if ($LASTEXITCODE -ne 0) { throw "reprepro exited with code $LASTEXITCODE" }
    }
    $interLogger.invoke($logname, "Published APT packages {kv:version=$Version}", $false, 'success')
} catch {
    $interLogger.invoke($logname, "APT deployment failed: {err:kv:error=$($_.Exception.Message)}", $false, 'error')
    exit 1
} finally {
    if (Test-Path $KeyPath) { Remove-Item $KeyPath -Force }
}
