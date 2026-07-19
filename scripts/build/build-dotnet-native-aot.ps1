using module ../core/core.psm1

[CmdletBinding()]
param(
    [ValidateSet('Package', 'NativeAot')]
    [string]$Mode = 'Package',

    [string]$RuntimeIdentifier,

    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release',

    [string]$Version
)

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
$kv          = $global:__automator_devops.kvinc
$logname     = 'build-stage-dotnet'
#---UI ELEMENTS Shortened-------------

#---CONFIG----------------------------
$BuildConfig      = Get-Content -Path './build_config.json' -Raw | ConvertFrom-Json
$DotnetConfig     = $BuildConfig.Dotnet
$ProjectName      = $DotnetConfig.name
$BuildScript      = $DotnetConfig.build_script
$ConfiguredRids   = @($DotnetConfig.native_rids)
$PackageOutput    = $DotnetConfig.package_output
$NativeOutput     = $DotnetConfig.native_output
#---CONFIG----------------------------

if ($null -eq $DotnetConfig) {
    $interLogger.invoke($logname, "Missing {err:kv:config=Dotnet} scope in build_config.json", $false, 'error')
    exit 1
}

if (!(Test-Path -Path $BuildScript -PathType Leaf)) {
    $interLogger.invoke($logname, "Configured build script was not found at {err:kv:path=$BuildScript}", $false, 'error')
    exit 1
}

if ([string]::IsNullOrWhiteSpace($Version) -and ![string]::IsNullOrWhiteSpace($env:CI_COMMIT_TAG)) {
    $Version = $env:CI_COMMIT_TAG.TrimStart('v')
}

if ($Mode -eq 'NativeAot') {
    if ([string]::IsNullOrWhiteSpace($RuntimeIdentifier)) {
        $interLogger.invoke($logname, 'RuntimeIdentifier is required for NativeAot mode', $false, 'error')
        exit 1
    }

    if ($ConfiguredRids.Count -gt 0 -and $RuntimeIdentifier -notin $ConfiguredRids) {
        $interLogger.invoke($logname, "Runtime identifier is not configured {err:kv:rid=$RuntimeIdentifier}", $false, 'error')
        exit 1
    }
}

$interLogger.invoke($logname, "Running .NET build for {kv:project=$ProjectName} {kv:mode=$Mode}", $false, 'info')
$kv.invoke('Configuration', "$Configuration")
$kv.invoke('Version', "$(if ($Version) { $Version } else { 'project-default' })")
$kv.invoke('Runtime Identifier', "$(if ($RuntimeIdentifier) { $RuntimeIdentifier } else { 'none' })")
$kv.invoke('Build Script', "$BuildScript")

$BuildParameters = @{
    Configuration = $Configuration
}

if (![string]::IsNullOrWhiteSpace($Version)) {
    $BuildParameters.Version = $Version
}

if ($Mode -eq 'NativeAot') {
    $BuildParameters.RuntimeIdentifier = $RuntimeIdentifier
    $BuildParameters.SkipPack = $true
}

try {
    & $BuildScript @BuildParameters

    if ($LASTEXITCODE -ne 0) {
        $interLogger.invoke($logname, ".NET build failed with {err:kv:exitcode=$LASTEXITCODE}", $false, 'error')
        exit 1
    }

    $OutputPath = if ($Mode -eq 'NativeAot') { "$NativeOutput/$RuntimeIdentifier" } else { $PackageOutput }
    $interLogger.invoke($logname, "Completed .NET build {kv:output=$OutputPath}", $false, 'success')
} catch {
    $interLogger.invoke($logname, ".NET build failed: {err:kv:error=$($_.Exception.Message)}", $false, 'error')
    exit 1
}
