using module ./scripts/core/core.psm1

[cmdletbinding()]

param (
    [switch]$Automator,
    [switch]$build_dotnet_lib,
    [switch]$DotNetBuild,
    [switch]$DotNetPackage,
    [switch]$NativePackage,
    [ValidateSet('linux-x64', 'win-x64', 'osx-arm64')]
    [string[]]$RuntimeIdentifier,
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release',
    [ValidatePattern('^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?$')]
    [string]$Version,
    [switch]$Build,
    [switch]$PsGal,
    [switch]$Nuget,
    [switch]$ChocoNuSpec,
    [switch]$ChocoPackage,
    [switch]$ChocoPackageWindows,
    [switch]$Phwriter,
    [switch]$pester,
    [switch]$cleanup
)
# Import Module config

#---CONFIG----------------------------
$rawConfig = Get-Content -Path ./build_config.json | ConvertFrom-Json
$ModuleConfig = if ($rawConfig.PSModule) { $rawConfig.PSModule } elseif ($rawConfig.PSModeule) { $rawConfig.PSModeule } else { $rawConfig }
$ModuleName = $ModuleConfig.modulename
#---CONFIG----------------------------

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
$logname = "builder"
# $kv = $global:__automator_devops.kvinc
#---UI ELEMENTS Shortened------------

$interLogger.invoke($logname, "Running Build on {kv:module=$ModuleName} ", $false, 'info')

$ModuleBuildRequested = $Build -or $PsGal -or $Nuget -or $ChocoNuSpec -or $ChocoPackage -or $ChocoPackageWindows -or $Phwriter -or $pester
$DotNetBuildRequested = $build_dotnet_lib -or $DotNetBuild -or $DotNetPackage -or $NativePackage

if (!$ModuleBuildRequested -and !$DotNetBuildRequested -and !$cleanup) {

    $interLogger.invoke($logname, "Specify a module or .NET build option", $false, 'error')

    return;
}

if (($PsGal -or $Nuget -or $ChocoNuSpec -or $ChocoPackage -or $ChocoPackageWindows) -and !$Build) {
    throw [System.ArgumentException]::new('PowerShell module packaging options require -Build.')
}

if ($NativePackage -and @($RuntimeIdentifier).Count -eq 0) {
    throw [System.ArgumentException]::new('-NativePackage requires -RuntimeIdentifier.')
}

# Remove dist folder if it exists
if ( test-path ".\dist" ){ remove-item ".\dist" -Recurse -Force -erroraction silentlycontinue }
else { New-Item -Path .\ -Name "dist" -ItemType Directory }

# NOTE: =====================================
# NOTE: LOCAL MACHINE ONLY WITH MODULES LOCATED IN G:\ AND /MNT/G/
# TODO: #1 Once all required modules are release, change to pull from the psgal or from gitlab directly
# TODO: #2 
# local build on windows
# TODO: add included modules from Phellam-Automator for Consisitance once all depenancies are released, as above move to psgal or gitlab once released
if ($isWindows -and !$Automator -and $ModuleBuildRequested) {
    
    $interLogger.invoke($logname, "Importing local modules from 'G:\' {kv:ARC=Windows}", $false, 'info')
    
    import-module -Name G:\devspace\projects\powershell\_repos\commitfusion\; # Get-GitAutoVerion extracted and used as standalone
    import-module -name G:\devspace\projects\powershell\_repos\quicklog\;
    import-module -name G:\devspace\projects\powershell\_repos\shelldock\;
    import-module -name G:\devspace\projects\powershell\_repos\psmpacker\; 
    import-module -Name G:\devspace\projects\powershell\_repos\nupsforge\; 
    import-module -name G:\devspace\projects\powershell\_repos\csverify\; 

}
# linux build
if ($isLinux -and !$Automator -and $ModuleBuildRequested) {

    $interlogger.invoke($logname, "Importing local modules from /mnt/g/devspace/projects/powershell/_repos/ {kv:ARC=Linux}", $false, 'info')

    Import-Module -Name /mnt/g/devspace/projects/powershell/_repos/colorconsole/;
    import-module -Name /mnt/g/devspace/projects/powershell/_repos/commitfusion/;
    import-module -name /mnt/g/devspace/projects/powershell/_repos/quicklog/;
    import-module -name /mnt/g/devspace/projects/powershell/_repos/shelldock/;
    import-module -name /mnt/g/devspace/projects/powershell/_repos/psmpacker/;
    import-module -Name /mnt/g/devspace/projects/powershell/_repos/nupsforge/;
    import-module -name /mnt/g/devspace/projects/powershell/_repos/csverify/;

}

# docker phellams/automator
if ($Automator) {

    $docker_image = "docker.io/sgkens/phellams-automator:$($ENV:AUTOMATOR_VERSION)"

    $interLogger.invoke($logname, "Running Phellams-Automator on {kv:DockerImage=$docker_image}", $false, 'info')

    [string]$scripts_to_run = ""
    $build_Module                = "./automator-devops/scripts/build/build-module.ps1;"
    $build_dotnet_library       = "./automator-devops/scripts/build/build-dotnet-library.ps1;"
    $build_dotnet_managed       = "./scripts/build/Build-PHWriterDotNet.ps1 -Configuration $Configuration -SkipPack$(if ($Version) { " -Version '$Version'" });"
    $build_dotnet_package       = "./automator-devops/scripts/build/build-dotnet-native-aot.ps1 -Mode Package -Configuration $Configuration$(if ($Version) { " -Version '$Version'" });"
    $build_package_generic_nuget = "./automator-devops/scripts/build/build-package-generic-nuget.ps1;"
    $build_choco_nuspec          = "./automator-devops/scripts/build/build-nuspec-choco.ps1;"
    $build_package_psgallery     = "./automator-devops/scripts/build/build-package-psgallery.ps1;"
    $build_package_choco         = "./automator-devops/scripts/build/build-package-choco.sh"
    $tools_phwriter_metadata     = "./automator-devops/scripts/tools/generate-phwriter-metadata.ps1;"
    $pester_test_script          = "./automator-devops/scripts/test/test-pester-before-build.ps1;"
    $SafeDirectory               = "git config --global --add safe.directory /$ModuleName"

    if ($pester) { $scripts_to_run += $pester_test_script } # psmodule
    if ($build) { $scripts_to_run += $build_Module } # psmodule
    if ($build_dotnet_lib) { $scripts_to_run += $build_dotnet_library } # .net
    if ($DotNetBuild) { $scripts_to_run += $build_dotnet_managed } # managed .NET outputs
    if ($DotNetPackage) { $scripts_to_run += $build_dotnet_package } # Phwriter.Core NuGet package
    if ($NativePackage) {
        foreach ($rid in $RuntimeIdentifier) {
            $nativeVersion = if ($Version) { " -Version '$Version'" } else { '' }
            $scripts_to_run += "./automator-devops/scripts/build/build-dotnet-native-aot.ps1 -Mode NativeAot -RuntimeIdentifier '$rid' -Configuration $Configuration$nativeVersion;"
            $scripts_to_run += "./automator-devops/scripts/release/stage-native-aot-artifacts.ps1 -RuntimeIdentifier '$rid'$nativeVersion;"
        }
    }
    if ($psgal) { $scripts_to_run += $build_package_psgallery } # psmodule
    if ($nuget) { $scripts_to_run += $build_package_generic_nuget } # psmodule, dotnet
    if ($Phwriter) { $scripts_to_run += $tools_phwriter_metadata } # psmodule
    if ($ChocoNuSpec) { $scripts_to_run += $build_choco_nuspec  } # psmodule
    if ($ChocoPackage) { 
        if(!$ChocoNuSpec -or !$build){
            throw [System.Exception]::new("ChocoMonoPackage requires ChocoNuSpec and Build")
        }
        docker run --rm -v .:/$ModuleName $docker_image pwsh -c "cd /$modulename; $SafeDirectory; $scripts_to_run"
        $docker_image = "docker.io/chocolatey/choco:latest"
        $interLogger.invoke($logname, "Switching to Choco on {kv:DockerImage=$docker_image}", $false, 'info')
        docker run --rm -v .:/$ModuleName $docker_image bash -c "cd /$modulename; $build_package_choco"
    }else{
        docker run --rm -v .:/$ModuleName $docker_image pwsh -c "cd /$modulename; $SafeDirectory; $scripts_to_run"
    }
}

# =================================
# BUILD SCRIPTS
# =================================
if ($build_dotnet_lib -and !$Automator) { ./automator-devops/scripts/build/build-dotnet-library.ps1 }
if ($DotNetBuild -and !$Automator) {
    $DotNetBuildParameters = @{ Configuration = $Configuration; SkipPack = $true }
    if ($Version) { $DotNetBuildParameters.Version = $Version }
    ./scripts/build/Build-PHWriterDotNet.ps1 @DotNetBuildParameters
}
if ($DotNetPackage -and !$Automator) {
    $DotNetPackageParameters = @{ Mode = 'Package'; Configuration = $Configuration }
    if ($Version) { $DotNetPackageParameters.Version = $Version }
    ./automator-devops/scripts/build/build-dotnet-native-aot.ps1 @DotNetPackageParameters
}
if ($NativePackage -and !$Automator) {
    foreach ($rid in $RuntimeIdentifier) {
        $NativeBuildParameters = @{ Mode = 'NativeAot'; RuntimeIdentifier = $rid; Configuration = $Configuration }
        $NativeStageParameters = @{ RuntimeIdentifier = $rid }
        if ($Version) {
            $NativeBuildParameters.Version = $Version
            $NativeStageParameters.Version = $Version
        }
        ./automator-devops/scripts/build/build-dotnet-native-aot.ps1 @NativeBuildParameters
        ./automator-devops/scripts/release/stage-native-aot-artifacts.ps1 @NativeStageParameters
    }
}
if ($pester -and !$automator) { ./automator-devops/scripts/test/test-pester-before-build.ps1 }
if ($Sa -and !$automator) { ./automator-devops/scripts/test/test-sa-before-build.ps1 }
if ($build -and !$Automator) { ./automator-devops/scripts/build/build-module.ps1 }
if ($psgal -and !$Automator) { ./automator-devops/scripts/build/build-package-psgallery.ps1 }
if ($Nuget -and !$Automator) { ./automator-devops/scripts/build/build-package-generic-nuget.ps1 }
if ($ChocoNuSpec -and !$Automator) { ./automator-devops/scripts/build/Build-nuspec-choco.ps1 }
if ($ChocoPackageWindows -and !$Automator) { ./automator-devops/scripts/build/win-only/build-package-choco-windows.ps1 }
if ($cleanup) { ./automator-devops/run-cleanup.ps1 }
#TODO: add switch for clean up so it can be run sperately if needed
#TODO: move run-cleanup to scripts dir

# TEST DEPLOY
#./devops/scripts/deploy/deploy-gitlab.ps1
#./devops/scripts/deploy/deploy-psgallary.ps1
#./devops/scripts/deploy-extended-chocolatey.ps1
#./devops/scripts/create-tag.ps1
