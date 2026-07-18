using module ../core/core.psm1

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
$kv = $global:__automator_devops.kvinc
$logname = $Global:__automator_devops.logname
#---UI ELEMENTS Shortened------------

$interLogger.invoke($logname, "Running generic build for tar.gz {inf:kv:target=generic} {inf:kv:buildMethod=NONE->TAR}", $false, 'info')

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
$interLogger.invoke($logname, "Creating tar.gz ile for simple download/extract/use", $false, 'info')
$interLogger.invoke($logname, "Source: $module_source_path/*", $false, 'info')
$interLogger.invoke($logname, "output: $module_output_path_generic/$ModuleName-$ModuleVersion.tar.gz", $false, 'info')
try{ 
  # for completness .tar.gz generic nuget .nupkg
  & bash -c tar -cvzf "$module_source_path" -C "$module_output_path_generic/$ModuleName-$ModuleVersion.tar.gz"
  $interLogger.invoke($logname, "Created tar.gz successfully", $false, 'info')  
}catch {
  $interLogger.invoke($logname, "Error creating .tar: $($_.Exception.Message)", $false, 'error')
  exit 1
}
