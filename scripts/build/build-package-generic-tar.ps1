using module ../core/core.psm1

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
$kv = $global:__automator_devops.kvinc
$logname = $Global:__automator_devops.logname
#---UI ELEMENTS Shortened------------

$interLogger.invoke($logname, 'Starting generic tar.gz package build {inf:kv:target=generic} {inf:kv:method=tar}', $false, 'info')

#---CONFIG----------------------------
$ModuleConfig            = (Get-Content -Path ./build_config.json | ConvertFrom-Json).PSModule
$ModuleName              = $ModuleConfig.moduleName
$ModuleManifest          = Test-ModuleManifest -path "./dist/$ModuleName/$ModuleName.psd1"
$PreRelease              = $ModuleManifest.PrivateData.PSData.Prerelease
[string]$moduleversion   = $ModuleManifest.Version.ToString()
$logname                 = "build-stage"
#---CONFIG----------------------------

# Set PreRelease
if (!$prerelease -or $prerelease.Length -eq 0) { $ModuleVersion = $ModuleVersion }
else { $ModuleVersion = "$ModuleVersion-$prerelease" }


$module_source_path = [system.io.path]::combine($pwd, "dist", "$ModuleName")
$module_output_path_generic = [system.io.path]::combine($pwd, "dist", "generic")
$interLogger.invoke($logname, 'Creating the generic tar.gz package', $false, 'info')
$interLogger.invoke($logname, "Package paths {kv:source=$module_source_path/*} {kv:output=$module_output_path_generic/$ModuleName-$ModuleVersion.tar.gz}", $false, 'info')
try{ 
  # for completness .tar.gz generic nuget .nupkg
  & bash -c tar -cvzf "$module_source_path" -C "$module_output_path_generic/$ModuleName-$ModuleVersion.tar.gz"
  $interLogger.invoke($logname, 'Created the generic tar.gz package', $false, 'success')
}catch {
  $interLogger.invoke($logname, "Failed to create the generic tar.gz package {err:kv:error=$($_.Exception.Message)}", $false, 'error')
  exit 1
}
