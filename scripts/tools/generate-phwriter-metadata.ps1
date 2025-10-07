using module ..\core\core.psm1
# PHWriter Metadata Generator

#---CONFIG----------------------------
$ModuleConfig           = Get-Content -Path ./build_config.json | ConvertFrom-Json
$modulename             = $ModuleConfig.modulename
$ModuleManifest         = Test-ModuleManifest -path "./$moduleName.psd1"
[string]$moduleversion  = $ModuleManifest.Version.ToString()
$prerelease             = $ModuleManifest.PrivateData.PSData.Prerelease
$source                 = $ModuleConfig.phwriter_source
#---CONFIG----------------------------

# Set PreRelease
if (!$prerelease -or $prerelease.Length -eq 0) { $ModuleVersion = $ModuleVersion }
else { $ModuleVersion = "$ModuleVersion-$prerelease" }

# ==== GLOBAL VARIABLES ====
$interlogger = $global:__automator_devops.interLogger
# ==== GLOBAL VARIABLES ====

$interlogger.invoke("Tools", "Generating PHWriter help meta data for {kv:module=$modulename}", $false, 'info')

# ps1 script to generate phwriter metadata for cmdlets
# exports will be stored in json, phwriter cant load help data from json Using
# output file will be store per cmdlet to limit the size of the import time.

# Each object represents a cmdlet's help metadata which is then looped below and exported
# as cmdlet_<cmdletname>.json in the ./libs/help_data/ folder

#Note: load hashtable data from ps1 file
. './phwriter-metadata.ps1'

# Creat help_data folder if it doest exists
New-Item -Path .\libs\help_metadata -ItemType Directory


foreach ($helpdata in $phwriter_metadata_array) {
    $cmdlet_name = $helpdata.CommandInfo.cmdlet
    # Add Module Name
    $helpdata.name = $modulename
    # Add version to each cmdlet propery
    $helpdata.version = $moduleversion
    # Add Padding to each cmdlet propery
    $helpdata.padding = 3
    # Add indenting to each cmdlet propery
    $helpdata.indent = 2
    # Add source to each cmdlet propery
    $helpdata.CommandInfo.source = $source

    $json_output_path = ".\libs\help_metadata\$($cmdlet_name.tolower())_phwriter_metadata.json"
    $helpdata  | ConvertTo-Json -Depth 5 | Out-File -FilePath $json_output_path -Force -Encoding UTF8
    $interlogger.invoke("generate", "help metadata for {kv:cmdlet=$cmdlet_name} at {kv:path=$json_output_path}", $false, 'info')
}
