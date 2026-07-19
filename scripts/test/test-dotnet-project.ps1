using module ../core/core.psm1

[CmdletBinding()]
param(
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release'
)

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
$kv          = $global:__automator_devops.kvinc
$logname     = 'test-stage-dotnet'
#---UI ELEMENTS Shortened-------------

#---CONFIG----------------------------
$BuildConfig   = Get-Content -Path './build_config.json' -Raw | ConvertFrom-Json
$DotnetConfig  = $BuildConfig.Dotnet
$ProjectName   = $DotnetConfig.name
$Solution      = $DotnetConfig.solution
$TestScript    = $DotnetConfig.test_script
#---CONFIG----------------------------

if ($null -eq $DotnetConfig) {
    $interLogger.invoke($logname, "Missing {err:kv:config=Dotnet} scope in build_config.json", $false, 'error')
    exit 1
}

$interLogger.invoke($logname, "Running .NET tests for {kv:project=$ProjectName} {kv:configuration=$Configuration}", $false, 'info')
$kv.invoke('Solution', "$Solution")
$kv.invoke('Test Script', "$TestScript")

try {
    if (![string]::IsNullOrWhiteSpace($TestScript)) {
        if (!(Test-Path -Path $TestScript -PathType Leaf)) {
            $interLogger.invoke($logname, "Configured test script was not found at {err:kv:path=$TestScript}", $false, 'error')
            exit 1
        }

        $interLogger.invoke($logname, "Executing configured test script {kv:path=$TestScript}", $false, 'info')
        & $TestScript
    } else {
        if (!(Test-Path -Path $Solution -PathType Leaf)) {
            $interLogger.invoke($logname, "Configured solution was not found at {err:kv:path=$Solution}", $false, 'error')
            exit 1
        }

        $interLogger.invoke($logname, "Executing dotnet test on {kv:solution=$Solution}", $false, 'info')
        dotnet test $Solution --configuration $Configuration
    }

    if ($LASTEXITCODE -ne 0) {
        $interLogger.invoke($logname, ".NET tests failed with {err:kv:exitcode=$LASTEXITCODE}", $false, 'error')
        exit 1
    }

    $interLogger.invoke($logname, "Completed .NET tests for {kv:project=$ProjectName}", $false, 'success')
} catch {
    $interLogger.invoke($logname, ".NET test execution failed: {err:kv:error=$($_.Exception.Message)}", $false, 'error')
    exit 1
}
