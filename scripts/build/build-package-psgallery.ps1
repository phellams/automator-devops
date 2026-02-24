using module ../core/core.psm1

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
$kv = $global:__automator_devops.kvinc
$logname = $Global:__automator_devops.logname
#---UI ELEMENTS Shortened------------

$interLogger.invoke($logname, "Running build on nuspec for nuget {inf:kv:target=Powershell Gallery} {inf:kv:buildMethod=NUPSFORGE}", $false, 'info')

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

$interLogger.invoke($logname, "After Build create zip of psgallery upload", $false, 'info')

# Create Zip With .nuspec file for PSGallery
# copy-item -recurse -path "./dist/$ModuleName" -destination "./dist/psgal/$ModuleName"
$module_source_path = [system.io.path]::combine($pwd, "dist", "$ModuleName")
$module_output_path = [system.io.path]::combine($pwd, "dist", "psgal")
$zipFileName = "$ModuleName-$ModuleVersion-psgal.zip"
$interLogger.invoke($logname, "Creating Zip File for PSGallery", $false, 'info')
$interLogger.invoke($logname, "Source: $module_source_path/*", $false, 'info')
$interLogger.invoke($logname, "output: $module_output_path/$($zipFileName)", $false, 'info')

try{
  compress-archive -path "$module_source_path/*" `
                   -destinationpath "$module_output_path/$zipFileName" `
                   -compressionlevel optimal `
                   -update
}catch {
  $interLogger.invoke($logname, "Error creating ZIP of PSGallery Folder: $($_.Exception.Message)", $false, 'error')
  exit 1
}

$interLogger.invoke($logname, "Created Zip File for PSGallery", $false, 'info')
# check if requirement tools/VERIFICATION.txt exists
if (!(Test-Path -path "./dist/choco/tools/VERIFICATION.txt")) {
  throw [System.Exception]::new("ChocoMonoPackage requires tools/VERIFICATION.txt")
  exit 1 # fail pipeline if verification file is not found as this is required for package verification and security
}