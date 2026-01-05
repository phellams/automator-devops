using module ./scripts/core/core.psm1
[cmdletbinding()]
param (
    [switch]$Automator,
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
$ModuleConfig = Get-Content -Path ./build_config.json | ConvertFrom-Json
$ModuleName = $ModuleConfig.moduleName
$moduleVersion = $ModuleConfig.moduleVersion
#---CONFIG----------------------------

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
$kv = $global:__automator_devops.kvinc
#---UI ELEMENTS Shortened------------

$interLogger.invoke("Local-Build", "Running Build on {kv:module=$ModuleName} ", $false, 'info')

if (!$build) {
    $interLogger.invoke("Local-Build", "Build is required all other build options", $false, 'error')
    return
}

# Remove dist folder if it exists
if ( test-path ".\dist" ){ remove-item ".\dist" -Recurse -Force -erroraction silentlycontinue }
else { New-Item -Path .\ -Name "dist" -ItemType Directory }

# NOTE: =====================================
# NOTE: LOCAL MACHINE ONLY WITH MODULES LOCATED IN G:\ AND /MNT/G/
# TODO: #1 Once all required modules are release, change to pull from the psgal or from gitlab directly
# TODO: #2 
# local build on windows
if ($isWindows -and !$Automator) {
    $interLogger.invoke("Local-Build", "Importing local modules from 'G:\' {kv:ARC=Windows}", $false, 'info')
    import-module -Name G:\devspace\projects\powershell\_repos\commitfusion\; # Get-GitAutoVerion extracted and used as standalone
    import-module -name G:\devspace\projects\powershell\_repos\quicklog\;
    import-module -name G:\devspace\projects\powershell\_repos\shelldock\;
    import-module -name G:\devspace\projects\powershell\_repos\psmpacker\; 
    import-module -Name G:\devspace\projects\powershell\_repos\nupsforge\; 
    import-module -name G:\devspace\projects\powershell\_repos\csverify\;   
}
# linux build
if ($isLinux -and !$Automator) {
    $interlogger.invoke("Local-Build", "Importing local modules from /mnt/g/devspace/projects/powershell/_repos/ {kv:ARC=Linux}", $false, 'info')
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

    $docker_image = "docker.io/sgkens/phellams-automator:2.6.1"

    $interLogger.invoke("Local-Build", "Running Phellams-Automator on {kv:DockerImage=$docker_image}", $false, 'info')

    [string]$scripts_to_run = ""
    $build_Module                = "./automator-devops/scripts/build/build-module.ps1;"
    $build_package_generic_nuget = "./automator-devops/scripts/build/build-package-generic-nuget.ps1;"
    $build_choco_nuspec          = "./automator-devops/scripts/build/build-nuspec-choco.ps1;"
    $build_package_psgallery     = "./automator-devops/scripts/build/build-package-psgallery.ps1;"
    $build_package_choco         = "./automator-devops/scripts/build/build-package-choco.sh"
    $tools_phwriter_metadata     = "./automator-devops/scripts/tools/generate-phwriter-metadata.ps1;"
    $pester_test_script          = "./automator-devops/scripts/test/test-pester-before-build.ps1;"
    $SafeDirectory               = "git config --global --add safe.directory /$ModuleName"

    if($pester){ $scripts_to_run += $pester_test_script }
    if($build){ $scripts_to_run += $build_Module }
    if($psgal){ $scripts_to_run += $build_package_psgallery }
    if($nuget){ $scripts_to_run += $build_package_generic_nuget }
    if($Phwriter) { $scripts_to_run += $tools_phwriter_metadata }
    if($ChocoNuSpec) { $scripts_to_run += $build_choco_nuspec  }
    if ($ChocoPackage) { 
        if(!$ChocoNuSpec -or !$build){
            throw [System.Exception]::new("ChocoMonoPackage requires ChocoNuSpec and Build")
        }
        docker run --rm -v .:/$ModuleName $docker_image pwsh -c "cd /$modulename; $SafeDirectory; $scripts_to_run"
        $docker_image = "docker.io/chocolatey/choco:latest"
        $interLogger.invoke("Local-Build", "Switching to Choco on {kv:DockerImage=$docker_image}", $false, 'info')
        docker run --rm -v .:/$ModuleName $docker_image bash -c "cd /$modulename; $build_package_choco"
    }else{
        docker run --rm -v .:/$ModuleName $docker_image pwsh -c "cd /$modulename; $SafeDirectory; $scripts_to_run"
    }
}

# =================================
# BUILD SCRIPTS
# =================================
if ($pester -and !$automator) { ./automator-devops/scripts/test/test-pester-before-build.ps1 }
if ($Sa -and !$automator) { ./automator-devops/scripts/test/test-sa-before-build.ps1 }
if ($build -and !$Automator) { ./automator-devops/scripts/build/build-module.ps1 }
if ($psgal -and !$Automator) { ./automator-devops/scripts/build/build-package-psgallery.ps1 }
if ($Nuget -and !$Automator) { ./automator-devops/scripts/build/build-package-generic-nuget.ps1 }
if ($ChocoNuSpec -and !$Automator) { ./automator-devops/scripts/build/Build-nuspec-choco.ps1 }
if ($ChocoPackageWindows -and !$Automator) { ./automator-devops/scripts/wip/build-package-choco-windows.ps1 }
if ($cleanup) { ./automator-devops/run-cleanup.ps1 }
#TODO: add switch for clean up so it can be run sperately if needed
#TODO: move run-cleanup to scripts dir

# TEST DEPLOY
#./devops/scripts/deploy/deploy-gitlab.ps1
#./devops/scripts/deploy/deploy-psgallary.ps1
#./devops/scripts/deploy-extended-chocolatey.ps1
#./devops/scripts/create-tag.ps1