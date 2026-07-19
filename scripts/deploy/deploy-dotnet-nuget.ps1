using module ../core/core.psm1

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
$kv          = $global:__automator_devops.kvinc
$logname     = 'deploy-stage-nuget'
#---UI ELEMENTS Shortened-------------

#---CONFIG----------------------------
$BuildConfig  = Get-Content './build_config.json' -Raw | ConvertFrom-Json
$DotnetConfig = $BuildConfig.Dotnet
$DeployConfig = $BuildConfig.Deployment.NuGet
$PackagePath  = $DotnetConfig.package_output
$PackageId    = $DotnetConfig.package_id
$Source       = $DeployConfig.source
$ApiKey       = [Environment]::GetEnvironmentVariable($DeployConfig.api_key_variable)
#---CONFIG----------------------------

$interLogger.invoke($logname, "Publishing managed package {kv:package=$PackageId}", $false, 'info')
$Package = Get-ChildItem -Path $PackagePath -Filter "$PackageId*.nupkg" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (!$Package -or [string]::IsNullOrWhiteSpace($ApiKey)) {
    $interLogger.invoke($logname, 'NuGet package or configured API key was not found', $false, 'error')
    exit 1
}

try {
    $kv.invoke('Package', $Package.FullName)
    $kv.invoke('Source', $Source)
    dotnet nuget push $Package.FullName --api-key $ApiKey --source $Source --skip-duplicate
    if ($LASTEXITCODE -ne 0) { throw "dotnet nuget push exited with code $LASTEXITCODE" }
    $interLogger.invoke($logname, "Published NuGet package {kv:file=$($Package.Name)}", $false, 'success')
} catch {
    $interLogger.invoke($logname, "NuGet deployment failed: {err:kv:error=$($_.Exception.Message)}", $false, 'error')
    exit 1
}
