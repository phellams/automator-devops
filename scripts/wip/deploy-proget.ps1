<# ---CONFIG--------------------------- #>
$ModuleConfig = Get-Content -Path .\devops\build_config.json | ConvertFrom-Json
$ModuleName           = $ModuleConfig.moduleName
$PROGET_CHOCOINSTANCE  = "https://$($ENV:PROGET_HOST)/nuget/chocolatey/" 
$PROGET_NUGETINSTACE  = "https://$($ENV:PROGET_HOST)/nuget/nuget/v3/index.json"
$PROGET_PSGALINSTANCE = "https://$($ENV:PROGET_HOST)/nuget/powershell/" 
<# ---CONFIG--------------------------- #>

# Set PreRelease
if (!$prerelease -or $prerelease.Length -eq 0) { $ModuleVersion = $ModuleVersion }
else { $ModuleVersion = "$ModuleVersion-$prerelease" }

#------------------------------------
# Output FileNames
$ModuleManifest       = Test-ModuleManifest -path ".\dist\$ModuleName\$ModuleName`.psd1"
$zipFileName          = "$($ModuleName).zip"
$SemVerVersion        = $ModuleManifest.Version -replace "\.\d+$",""
if($ModuleManifest.PrivateData.PSData.Prerelease){
  $SemVerVersion = "$SemVerVersion-$($ModuleManifest.PrivateData.PSData.Prerelease)"
}
$nupkgFileName        = "$ModuleName.$SemVerVersion.nupkg"

# Force Tls12
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if($ModuleManifest){

  # Push to ProGet Chocolatey
  [console]::write("Checking if Chocolatey is installed, skipping install `n")
  if(Get-command choco){
    [console]::write("Pushing to chocolatey: .\dist\choco\$nupkgFileName `n")
    choco push ".\dist\choco\$nupkgFileName" --source $PROGET_CHOCOINSTANCE --apikey $ENV:PROGET_API_KEY
    [console]::write("Pushed to chocolatey $nupkgFileName - Complete `n")
  }
  else{
    write-host "Chocolatey is not installed, installing Chocolatey"
    break;
  }

  # Push to ProGet Nuget
  [console]::write("Checking if Nuget is installed, skipping install `n")
  if(Get-command nuget.exe){
    [console]::write("Pushing to Nuget: .\dist\nuget\$nupkgFileName `n")
    nuget push ".\dist\nuget\$nupkgFileName" -source $PROGET_NUGETINSTACE -apikey $env:PROGET_API_KEY
    [console]::write("Pushed to Nuget $nupkgFileName - Complete `n")
  }
  else{
    throw "Nuget is not installed, installing Nuget"
  }
  

  # puish to proget pscore repo 'powershell gallery'
  # Publish-Module -Path ".\dist\$zipFileName" -Repository pscore -NuGetApiKey $apikey
  # Example of trusting the certificate (not recommended for production)
  # [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
  # Register-PSRepository -name 'pscore_Local_instance' `
  #                       -SourceLocation "https://proget.lab.davilion.online/nuget/pscore/" `
  #                       -PublishLocation (New-Object -TypeName Uri -ArgumentList "https://proget.lab.davilion.online/nuget/pscore/", 'package/').AbsoluteUri `
  #                       -InstallationPolicy "Trusted"
  

  # Push to ProGet PSGallery
  Register-PSRepositoryFix -Name "powershell" `
                           -SourceLocation $ProGet_PSGalInstance `
                           -InstallationPolicy Trusted `
                           -confirm
  write-host "Pushing to Powershell-Nuget-Proget: .\dist\psgal\$zipFileName"
  publish-Module `
    -path ".\dist\$ModuleName" `
    -Repository "powershell" `
    -NuGetApiKey $ENV:PROGET_API_KEY `
    -projecturi $ModuleManifest.PrivateData.PSData.ProjectUrl `
    -licenseuri $ModuleManifest.PrivateData.PSData.LicenseUrl `
    -IconUri $ModuleManifest.PrivateData.PSData.IconUrl `
    -ReleaseNotes $ModuleManifest.ReleaseNotes `
    -Tags $ModuleManifest.Tags `
    -Verbose
 }
unregister-PSRepository -name "powershell"



