using module ../core/core.psm1

[CmdletBinding()]
param([string]$Version = $env:CI_COMMIT_TAG.TrimStart('v'))

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
$kv          = $global:__automator_devops.kvinc
$logname     = 'deploy-stage-winget'
#---UI ELEMENTS Shortened-------------

#---CONFIG----------------------------
$Config     = (Get-Content './build_config.json' -Raw | ConvertFrom-Json).Deployment.WinGet
$Token      = [Environment]::GetEnvironmentVariable($Config.token_variable)
$PackageUrl = $Config.release_url -replace 'VERSION', $Version
#---CONFIG----------------------------

if (!$IsWindows -or [string]::IsNullOrWhiteSpace($Token)) {
    $interLogger.invoke($logname, 'WinGet deployment requires Windows and the configured GitHub token', $false, 'error')
    exit 1
}

try {
    $Tool = Join-Path $env:TEMP 'wingetcreate.exe'
    Invoke-WebRequest 'https://aka.ms/wingetcreate/latest' -OutFile $Tool
    $interLogger.invoke($logname, "Submitting WinGet manifest {kv:package=$($Config.package_id)} {kv:version=$Version}", $false, 'info')
    & $Tool update $Config.package_id -u $PackageUrl -v $Version -t $Token --submit
    if ($LASTEXITCODE -ne 0) { throw "wingetcreate exited with code $LASTEXITCODE" }
    $interLogger.invoke($logname, "Submitted WinGet manifest {kv:version=$Version}", $false, 'success')
} catch {
    $interLogger.invoke($logname, "WinGet deployment failed: {err:kv:error=$($_.Exception.Message)}", $false, 'error')
    exit 1
}
