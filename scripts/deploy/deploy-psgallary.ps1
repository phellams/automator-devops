using module ../core/core.psm1

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
$kv = $global:__automator_devops.kvinc
#---UI ELEMENTS Shortened------------

#---CONFIG----------------------------
$ModuleConfig   = Get-Content -Path ./build_config.json | ConvertFrom-Json
$modulename     = $ModuleConfig.modulename
$ModuleManifest = Test-ModuleManifest -path "./dist/$moduleName/$moduleName.psd1"
[string]$moduleversion   = $ModuleManifest.Version.ToString()
$prerelease     = $ModuleManifest.PrivateData.PSData.Prerelease
#---CONFIG----------------------------

# Set PreRelease
if (!$prerelease -or $prerelease.Length -eq 0) { $ModuleVersion = $ModuleVersion }
else { $ModuleVersion = "$ModuleVersion-$prerelease" }


# Check if module version exists
$interLogger.invoke("deploy", "Checking if module version {kv:version=$ModuleVersion} exists in PSGallery", $false, 'info')
[string]$psgal_currentnversion = Find-Module -Name $modulename `
                                            -RequiredVersion $ModuleVersion `
                                            -Repository 'psgallery' `
                                            -AllowPrerelease | Select-Object -ExpandProperty Version

if ($psgal_currentnversion -eq $ModuleVersion) {
  $interLogger.invoke("deploy", "Module version {kv:version=$ModuleVersion} already exists in PSGallery, skipping publish", $false, 'info')
  exit 0
} else {
  $interLogger.invoke("deploy", "Module version {kv:version=$ModuleVersion} does not exist in PSGallery", $false, 'info')
}

# Publish to PSGallery if version does not exist
$interLogger.invoke("deploy", "Attempting to publish {kv:module=$modulename} version {kv:version=$ModuleVersion} to PSGallery", $false, 'info')
try {
  publish-Module `
    -path "./dist/$modulename" `
    -Repository 'psgallery' `
    -NuGetApiKey $ENV:PSGAL_API_KEY `
    -projecturi $ModuleManifest.PrivateData.PSData.ProjectUri `
    -licenseuri $ModuleManifest.PrivateData.PSData.LicenseUri `
    -IconUri $ModuleManifest.PrivateData.PSData.IconUri `
    -ReleaseNotes $ModuleManifest.ReleaseNotes `
    -Tags $ModuleManifest.Tags `
    -Verbose

} catch {
  $interLogger.invoke("deploy", "Failed to publish $modulename to PSGallery", $false, 'error')
  $interLogger.invoke("deploy", $_.Exception.Message, $false, 'error')
  exit 1
}

#NOTE: Update this in gitlab
#NOTE: Also update build template script
#NOTE: This is the version that will be used in the build pipeline