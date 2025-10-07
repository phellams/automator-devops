# WINDOWS LOCAL BUILD SCRIPT
#---CONFIG----------------------------
$ModuleConfig         = Get-Content -Path ./build_config.json | ConvertFrom-Json
$ModuleName           = $ModuleConfig.moduleName
$ModuleManifest       = Test-ModuleManifest -path "./dist/$ModuleName/$ModuleName.psd1"
$ModuleVersion        = $ModuleManifest.Version #-replace "/./d+$",""
$PreRelease           = $ModuleManifest.PrivateData.PSData.Prerelease
#---CONFIG----------------------------

# Set PreRelease
if (!$prerelease -or $prerelease.Length -eq 0) { $ModuleVersion = $ModuleVersion }
else { $ModuleVersion = "$ModuleVersion-$prerelease" }


#------------------------------------
if(Get-command choco.exe){
  write-host "Chocolatey is installed, skipping install"
  write-host "Pushing to chocolatey https://community.chocolatey.org/"
  choco push ./dist/choco/$ModuleName.$ModuleVersion.nupkg --source 'https://community.chocolatey.org/' --api-key $ENV:CHOCO_API_KEY
  write-host "Pushed to chocolatey - Complete"
}else{
  write-host "Chocolatey is not installed, please install chocolatey https://community.chocolatey.org/"
  break;
}