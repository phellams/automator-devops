using module ../core/core.psm1

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
$kv = $global:__automator_devops.kvinc
#---UI ELEMENTS Shortened------------

#---CONFIG----------------------------
$ModuleConfig   = (Get-Content -Path ./build_config.json | ConvertFrom-Json).PSModule
$modulename     = $ModuleConfig.modulename
$ModuleManifest = Test-ModuleManifest -path "./dist/$moduleName/$moduleName.psd1"
[string]$moduleversion   = $ModuleManifest.Version.ToString()
$prerelease     = $ModuleManifest.PrivateData.PSData.Prerelease
$logname = "deploy-stage-psgallery"
#---CONFIG----------------------------

# Set PreRelease
if (!$prerelease -or $prerelease.Length -eq 0) { $ModuleVersion = $ModuleVersion }
else { $ModuleVersion = "$ModuleVersion-$prerelease" }


# Check if module version exists
$interLogger.invoke($logname, "Checking PowerShell Gallery for the module version {kv:module=$modulename} {kv:version=$ModuleVersion}", $false, 'info')
[string]$psgal_currentnversion = Find-Module -Name $modulename `
                                             -RequiredVersion $ModuleVersion `
                                             -Repository 'psgallery' `
                                             -ErrorAction SilentlyContinue `
                                             -AllowPrerelease | Select-Object -ExpandProperty Version

if ($psgal_currentnversion -eq $ModuleVersion) {
  $interLogger.invoke($logname, "PowerShell Gallery version already exists; skipping publication {kv:module=$modulename} {kv:version=$ModuleVersion}", $false, 'info')
  exit 0
} else {
  $interLogger.invoke($logname, 'PowerShell Gallery version does not exist; continuing with publication', $false, 'info')
}

# Publish to PSGallery if version does not exist
$interLogger.invoke($logname, "Publishing the module to PowerShell Gallery {kv:module=$modulename} {kv:version=$ModuleVersion}", $false, 'info')
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

  $interLogger.invoke($logname, "Published the module to PowerShell Gallery {kv:module=$modulename} {kv:version=$ModuleVersion}", $false, 'success')

} catch {
  $interLogger.invoke($logname, "PowerShell Gallery publication failed {err:kv:module=$modulename} {err:kv:error=$($_.Exception.Message)}", $false, 'error')
  exit 1
}

#NOTE: Update this in gitlab
#NOTE: Also update build template script
#NOTE: This is the version that will be used in the build pipeline
