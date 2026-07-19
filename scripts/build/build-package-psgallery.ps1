using module ../core/core.psm1

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
$kv = $global:__automator_devops.kvinc
$logname = $Global:__automator_devops.logname
#---UI ELEMENTS Shortened------------

$interLogger.invoke($logname, 'Starting PowerShell Gallery package build {inf:kv:method=NupsForge}', $false, 'info')

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

$interLogger.invoke($logname, 'Creating the PowerShell Gallery release archive', $false, 'info')

# Create Zip With .nuspec file for PSGallery
# copy-item -recurse -path "./dist/$ModuleName" -destination "./dist/psgal/$ModuleName"
$module_source_path = [system.io.path]::combine($pwd, "dist", "$ModuleName")
$module_output_path_psgal = [system.io.path]::combine($pwd, "dist", "psgal")
$interLogger.invoke($logname, "Archive paths {kv:source=$module_source_path/*} {kv:output=$module_output_path_psgal/$ModuleName-$ModuleVersion-psgal.zip}", $false, 'info')

try{
  compress-archive -path "$module_source_path/*" `
                   -destinationpath "$module_output_path_psgal/$ModuleName-$ModuleVersion-psgal.zip" `
                   -compressionlevel optimal `
                   -update
}catch {
  $interLogger.invoke($logname, "Failed to create the PowerShell Gallery archive {err:kv:error=$($_.Exception.Message)}", $false, 'error')
  exit 1
}

$interLogger.invoke($logname, 'Created the PowerShell Gallery release archive', $false, 'success')
# check if requirement tools/VERIFICATION.txt exists
if (!(Test-Path -path "./dist/$modulename/tools/VERIFICATION.txt")) {
  $interLogger.invoke($logname, 'Package verification file was not found {err:kv:path=tools/VERIFICATION.txt}', $false, 'error')
  throw [System.Exception]::new("ChocoMonoPackage requires tools/VERIFICATION.txt")
  exit 1 # fail pipeline if verification file is not found as this is required for package verification and security
}
