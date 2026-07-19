using module ../core/core.psm1

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$RuntimeIdentifier,

    [string]$Version
)

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
$kv          = $global:__automator_devops.kvinc
$logname     = 'release-stage-native-aot'
#---UI ELEMENTS Shortened-------------

#---CONFIG----------------------------
$BuildConfig      = Get-Content -Path './build_config.json' -Raw | ConvertFrom-Json
$DotnetConfig     = $BuildConfig.Dotnet
$ProjectName      = $DotnetConfig.name
$ArtifactName     = $DotnetConfig.artifact_name
$NativeOutput     = $DotnetConfig.native_output
$ReleaseOutput    = $DotnetConfig.release_output
$ConfiguredRids   = @($DotnetConfig.native_rids)
#---CONFIG----------------------------

if ($null -eq $DotnetConfig) {
    $interLogger.invoke($logname, "Missing {err:kv:config=Dotnet} scope in build_config.json", $false, 'error')
    exit 1
}

if ($RuntimeIdentifier -notin $ConfiguredRids) {
    $interLogger.invoke($logname, "Runtime identifier is not configured {err:kv:rid=$RuntimeIdentifier}", $false, 'error')
    exit 1
}

if ([string]::IsNullOrWhiteSpace($Version)) {
    if (![string]::IsNullOrWhiteSpace($env:CI_COMMIT_TAG)) {
        $Version = $env:CI_COMMIT_TAG.TrimStart('v')
    } elseif (![string]::IsNullOrWhiteSpace($env:CI_PIPELINE_IID)) {
        $Version = "0.0.0-ci.$($env:CI_PIPELINE_IID)"
    } else {
        $Version = '0.0.0-local'
    }
}

if ([string]::IsNullOrWhiteSpace($ArtifactName)) {
    $ArtifactName = $ProjectName
}

$SourcePath   = [System.IO.Path]::Combine($NativeOutput, $RuntimeIdentifier)
$ArchiveName  = "$ArtifactName-$Version-$RuntimeIdentifier"
$StagingPath  = [System.IO.Path]::Combine($ReleaseOutput, $ArchiveName)
$ArchivePath  = [System.IO.Path]::Combine($ReleaseOutput, "$ArchiveName.zip")
$ChecksumPath = "$ArchivePath.sha256"

if (!(Test-Path -Path $SourcePath -PathType Container)) {
    $interLogger.invoke($logname, "Native AOT output was not found at {err:kv:path=$SourcePath}", $false, 'error')
    exit 1
}

$interLogger.invoke($logname, "Staging Native AOT release for {kv:project=$ProjectName} {kv:rid=$RuntimeIdentifier}", $false, 'info')
$kv.invoke('Source', "$SourcePath")
$kv.invoke('Archive', "$ArchivePath")
$kv.invoke('Version', "$Version")

try {
    if (!(Test-Path -Path $ReleaseOutput -PathType Container)) {
        New-Item -Path $ReleaseOutput -ItemType Directory -Force | Out-Null
    }

    if (Test-Path -Path $StagingPath) {
        Remove-Item -Path $StagingPath -Recurse -Force
    }

    if (Test-Path -Path $ArchivePath) {
        Remove-Item -Path $ArchivePath -Force
    }

    $interLogger.invoke($logname, "Copying Native AOT files to {kv:path=$StagingPath}", $false, 'info')
    Copy-Item -Path $SourcePath -Destination $StagingPath -Recurse -Force
    if (Test-Path -Path './LICENSE' -PathType Leaf) {
        Copy-Item -Path './LICENSE' -Destination ([System.IO.Path]::Combine($StagingPath, 'LICENSE')) -Force
    }

    $interLogger.invoke($logname, "Creating release archive {kv:file=$ArchiveName.zip}", $false, 'info')
    Compress-Archive -Path "$StagingPath/*" -DestinationPath $ArchivePath -CompressionLevel Optimal -Force

    $Checksum = (Get-FileHash -Path $ArchivePath -Algorithm SHA256).Hash.ToLower()
    "$Checksum  $ArchiveName.zip" | Set-Content -Path $ChecksumPath -Encoding utf8

    $kv.invoke('SHA256', "$Checksum")
    $interLogger.invoke($logname, "Staged Native AOT release {kv:archive=$ArchivePath}", $false, 'success')
} catch {
    $interLogger.invoke($logname, "Native AOT artifact staging failed: {err:kv:error=$($_.Exception.Message)}", $false, 'error')
    exit 1
}
