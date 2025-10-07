using module ../core/core.psm1

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
$kv = $global:__automator_devops.kvinc
#---UI ELEMENTS Shortened------------

$interLogger.invoke("Build", "Running build on nuspec for nuget {inf:kv:buildMethod=NUPSFORGE}", $false, 'info')

#---CONFIG----------------------------
$ModuleConfig   = Get-Content -Path ./build_config.json | ConvertFrom-Json
$ModuleName     = $ModuleConfig.moduleName
$ModuleManifest = Test-ModuleManifest -path "./dist/$ModuleName/$ModuleName.psd1"
[string]$moduleversion   = $ModuleManifest.Version.ToString()
$PreRelease     = $ModuleManifest.PrivateData.PSData.Prerelease
#---CONFIG----------------------------

# Set PreRelease
if (!$prerelease -or $prerelease.Length -eq 0) { $ModuleVersion = $ModuleVersion }
else { $ModuleVersion = "$ModuleVersion-$prerelease" }


# ===========================================
# https://raw.githubusercontent.com/yokoffing/Betterfox/main/user.js
# ===========================================

# Create New Verification CheckSums requires root module directory
# set-location "./dist/$ModuleName"
# New-VerificationFile -RootPath ./ -OutputPath ./tools | Format-Table -auto
# Test-Verification -Path ./ | Format-Table -auto
# Set-location ../../ # back

# Create Nuget nuspec, Proget, gitlab, PSGallery
$NuSpecParams = @{
  path          = "./dist/$ModuleName"
  ModuleName    = $ModuleName
  ModuleVersion = $ModuleManifest.Version #-replace "/./d+$", ""
  Author        = $ModuleManifest.Author
  Description   = $ModuleManifest.Description
  ProjectUrl    = $ModuleManifest.PrivateData.PSData.ProjectUri
  License       = $ModuleConfig.License
  company       = $ModuleManifest.CompanyName
  Tags          = $ModuleManifest.Tags
  dependencies  = $ModuleManifest.ExternalModuleDependencies
  PreRelease    = $PreRelease
}

$module_source_path = [system.io.path]::combine($pwd, "dist", "$ModuleName")
$module_output_path = [system.io.path]::combine($pwd, "dist", "nuget")

New-NuspecPackageFile @NuSpecParams
New-NupkgPackage -Path $module_source_path -OutPath $module_output_path -CI
