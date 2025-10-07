using module ../core/core.psm1

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
$kv = $global:__automator_devops.kvinc
#---UI ELEMENTS Shortened------------

$interLogger.invoke("Build", "Running build on nuspec for nuget {inf:kv:target=Powershell Gallery} {inf:kv:buildMethod=NUPSFORGE}", $false, 'info')

#---CONFIG----------------------------
$ModuleConfig   = Get-Content -Path ./build_config.json | ConvertFrom-Json
$ModuleName     = $ModuleConfig.moduleName
$ModuleManifest = Test-ModuleManifest -path "./dist/$ModuleName/$ModuleName.psd1"
$PreRelease     = $ModuleManifest.PrivateData.PSData.Prerelease
[string]$moduleversion   = $ModuleManifest.Version.ToString()
#---CONFIG----------------------------

# Set PreRelease
if (!$prerelease -or $prerelease.Length -eq 0) { $ModuleVersion = $ModuleVersion }
else { $ModuleVersion = "$ModuleVersion-$prerelease" }


# ===========================================
# https://raw.githubusercontent.com/yokoffing/Betterfox/main/user.js
# ===========================================
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

# ===========================================
#             PowerShell Gallery
# ===========================================
# set-location "./dist/$ModuleName"
# New-VerificationFile -RootPath '.\' -OutputPath '.\tools' | Format-Table -auto

# Test-Verification -Path '.\' | Format-Table -auto
# Set-location ../../ # back

# Create Nuget nuspec, Proget, gitlab, PSGallery
New-NuspecPackageFile @NuSpecParams

$interLogger.invoke("Build", "After Build create zip of psgallery upload", $false, 'info')

# Create Zip With .nuspec file for PSGallery
# copy-item -recurse -path "./dist/$ModuleName" -destination "./dist/psgal/$ModuleName"
$module_source_path = [system.io.path]::combine($pwd, "dist", "$ModuleName")
$module_output_path = [system.io.path]::combine($pwd, "dist", "psgal")
$zipFileName = "$ModuleName-$ModuleVersion-psgal.zip"
$interLogger.invoke("Build", "Creating Zip File for PSGallery", $false, 'info')
$interLogger.invoke("Build", "Source: $module_source_path/*", $false, 'info')
$interLogger.invoke("Build", "output: $module_output_path/$($zipFileName)", $false, 'info')

try{
  compress-archive -path "$module_source_path/*" `
                   -destinationpath "$module_output_path/$zipFileName" `
                   -compressionlevel optimal `
                   -update
}catch {
  $interLogger.invoke("Build", "Error creating ZIP of PSGallery Folder: $($_.Exception.Message)", $false, 'error')
  exit 1
}