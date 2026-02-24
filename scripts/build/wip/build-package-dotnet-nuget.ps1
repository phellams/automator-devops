using module ../core/core.psm1

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
$kv = $global:__automator_devops.kvinc
#---UI ELEMENTS Shortened------------

$interLogger.invoke("Build", "Running build on nuspec for nuget {inf:kv:buildMethod=NUPSFORGE}", $false, 'info')

#---CONFIG----------------------------
$LibraryConfig           = (Get-Content -Path ./build_config.json | ConvertFrom-Json).Donet
$Name                    = $LibraryConfig.Name
[string]$Version         = (Get-GitAutoVersion).Version
$PreRelease              = $LibraryConfig.Prerelease
#---CONFIG----------------------------

# Set PreRelease
if (!$prerelease -or $prerelease.Length -eq 0) { $Version = $Version }
else { $Version = "$Version-$prerelease" }


# ===========================================
# https://raw.githubusercontent.com/yokoffing/Betterfox/main/user.js
# ===========================================

# Create New Verification CheckSums requires root module directory
# set-location "./dist/$Name"
# New-VerificationFile -RootPath ./ -OutputPath ./tools | Format-Table -auto
# Test-Verification -Path ./ | Format-Table -auto
# Set-location ../../ # back

# Create Nuget nuspec, Proget, gitlab, PSGallery
$NuSpecParams = @{
  path          = "./dist/$Name"
  Name          = $Name
  Version       = $Version
  Author        = $LibraryConfig.authors
  Description   = $LibraryConfig.Description
  ProjectUrl    = $LibraryConfig.ProjectUrl
  License       = $LibraryConfig.License
  company       = $LibraryConfig.CompanyName
  Tags          = $LibraryConfig.Tags
  dependencies  = $LibraryConfig.ExternalModuleDependencies
  PreRelease    = $LibraryConfig.Prerelease
}

$module_source_path = [system.io.path]::combine($pwd, "dist", "$Name")
$module_output_path = [system.io.path]::combine($pwd, "dist", "nuget")

New-NuspecPackageFile @NuSpecParams
New-NupkgPackage -Path $module_source_path -OutPath $module_output_path -CI
