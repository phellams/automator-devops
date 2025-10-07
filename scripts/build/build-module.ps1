using module ../core/Get-GitAutoVersion.psm1
using module ../core/core.psm1

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
$kv          = $global:__automator_devops.kvinc
#---UI ELEMENTS Shortened-------------

#---CONFIG----------------------------
$ModuleConfig            = Get-Content -Path ./build_config.json | ConvertFrom-Json
[string]$ModuleName      = $ModuleConfig.moduleName
[string[]]$ModuleFiles   = $ModuleConfig.ModuleFiles
[string[]]$ModuleFolders = $ModuleConfig.ModuleFolders
[string[]]$ModuleExclude = $ModuleConfig.ModuleExclude
$source                  = $ModuleConfig.phwriter_source
$phwriter                = $ModuleConfig.phwriter
#---CONFIG----------------------------

$AutoVersion = (Get-GitAutoVersion).Version

$interLogger.invoke("Build", "Running Build on {kv:module=$ModuleName} ", $false, 'info')
$interLogger.invoke("Build", "Creating dist folders", $false, 'info')

if((Test-Path -Path './phwriter-metadata.ps1') -and $phwriter) {                                                                         
    $interlogger.invoke("Build", "Generating PHWriter help meta data for {kv:module=$modulename}", $false, 'info')

    # ps1 script to generate phwriter metadata for cmdlets
    # exports will be stored in json, phwriter cant load help data from json Using
    # output file will be store per cmdlet to limit the size of the import time.

    # Each object represents a cmdlet's help metadata which is then looped below and exported
    # as cmdlet_<cmdletname>.json in the ./libs/help_data/ folder

    # Create help_data folder if it doest exists
    if ((test-path ./libs/help_data) -and $phwriter) {
        New-Item -Path ./libs/help_metadata -ItemType Directory
    }

    # Load hashtable data from .ps1 meta file
    . './phwriter-metadata.ps1'

    foreach ($helpdata in $phwriter_metadata_array) {
        $cmdlet_name = $helpdata.CommandInfo.cmdlet
        # Add Module Name
        $helpdata.name = $modulename
        # Add version to each cmdlet propery
        $helpdata.version = $moduleversion
        # Add Padding to each cmdlet propery
        $helpdata.padding = 1
        # Add indenting to each cmdlet propery
        $helpdata.indent = 1
        # Add source to each cmdlet propery
        $helpdata.CommandInfo.source = $source
        
        $json_output_path = [System.IO.Path]::Join('./', 'libs', 'help_metadata', "$($cmdlet_name.tolower())_phwriter_metadata.json")

        #$json_output_path = "./libs/help_metadata/$($cmdlet_name.tolower())_phwriter_metadata.json"
        $helpdata  | ConvertTo-Json -Depth 5 | Out-File -FilePath $json_output_path -Force -Encoding UTF8
        $interlogger.invoke("generated", "help metadata for {kv:cmdlet=$cmdlet_name} at {kv:path=$json_output_path}", $true, 'info')
    }

} else {
    $interLogger.invoke("Build", "PHWriter metadata file not found at {kv:path=./phwriter-metadata.ps1}", $false, 'warning')
}

# Create dist folder
if (!(Test-Path -Path ./dist)){                                                                         
    New-Item -Path './dist' -ItemType Directory 
}

# for build output
if (!(Test-Path -path "./dist/nuget")) { mkdir "./dist/nuget" }
if (!(Test-Path -path "./dist/choco")) { mkdir "./dist/choco" }
if (!(Test-Path -path "./dist/psgal")) { mkdir "./dist/psgal" }

# for csverify
if (!(Test-Path -Path "./dist/$moduleName/tools")) { 
    New-Item -Path "./dist/$moduleName/tools" -ItemType Directory 
}

$interLogger.invoke("Build", "Copying files to dist {inf:kv:BuildSource=PSMPacker}", $false, 'info')

# Copy module files to dist for packaging
Build-Module -SourcePath ./ `
             -DestinationPath './dist' `
             -Name $ModuleName `
             -IncrementVersion None `
             -FilesToCopy $ModuleFiles `
             -FoldersToCopy $ModuleFolders `
             -ExcludedFiles $ModuleExclude `
             -Manifest `
             -Version $AutoVersion
            #  -Dependencies @(@{type="module";name="quicklog";version="1.2.3"})



# Create ENV as Choco image does not support powershell execution
# Set the choco package name as a ENV and use choco push
# Name will be pulled by the gitlab ci script and use to rename the choco package after choco pack
if((Test-ModuleManifest -path "./dist/$ModuleName/$ModuleName.psd1")) {
    $interLogger.invoke("Build", "Module manifest found at ./dist/$ModuleName/$ModuleName.psd1", $false, 'info') 
} else {
    $interLogger.invoke("Build", "Module manifest not found at ./dist/$ModuleName/$ModuleName.psd1", $false, 'error')
    exit 1

}
$ModuleManifest          = Test-ModuleManifest -path "./dist/$ModuleName/$ModuleName.psd1"
[string]$prerelease      = $ModuleManifest.PrivateData.PSData.Prerelease
[string]$moduleversion   = $ModuleManifest.Version.ToString()

if (!$prerelease -or $prerelease.Length -eq 0) { $moduleversion = $moduleversion }
else { $moduleversion = "$moduleversion-$prerelease" }

$interLogger.invoke("Build", "Module version is {kv:version=$moduleversion}", $false, 'info')
$interLogger.invoke("Build", "Generating build env {kv:path=./build.env}", $false, 'info')

New-Item -Type File -Path "build.env" -Force -Value $null

$BuildEnvContent = @(
    "CHOCO_NUPKG_PACKAGE_NAME=$ModuleName.$moduleversion.nupkg",
    "PSGAL_NUPKG_PACKAGE_NAME=$ModuleName.$moduleversion-psgal.nupkg",
    "GITLAB_NUPKG_PACKAGE_NAME=$ModuleName.$moduleversion.nupkg",
    "BUILD_PACKAGE_VERSION=$moduleversion",
    "BUILD_PACKAGE_NAME=$ModuleName"
)

# Echo out build env
$kv.invoke("CHOCO_NUPKG_PACKAGE_NAME", "$ModuleName.$moduleversion-choco.nupkg")
$kv.invoke("PSGAL_NUPKG_PACKAGE_NAME", "$ModuleName.$moduleversion-psgal.nupkg")
$kv.invoke("GITLAB_NUPKG_PACKAGE_NAME", "$ModuleName.$moduleversion.nupkg")
$kv.invoke("BUILD_PACKAGE_VERSION", "$moduleversion")
$kv.invoke("BUILD_PACKAGE_NAME", "$ModuleName")

Set-Content -Path "build.env" -Value $BuildEnvContent -Force -Encoding UTF8

# NOTE: This is a note