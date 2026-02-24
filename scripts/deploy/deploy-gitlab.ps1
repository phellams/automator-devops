using module ../core/core.psm1

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
$kv = $global:__automator_devops.kvinc
#---UI ELEMENTS Shortened------------

#---CONFIG----------------------------
$ModuleConfig               = (Get-Content -Path ./build_config.json | ConvertFrom-Json).PSModule
$ModuleName                 = $ModuleConfig.moduleName
$ModuleManifest             = Test-ModuleManifest -path "./dist/$ModuleName/$ModuleName.psd1"
$gitlab_username            = $ModuleConfig.gituser
$gitlab_uri                 = "https://gitlab.com" # https://$($ENV:GITLAB_HOST)"
$projectid                  = $ModuleConfig.gitlabID_public
[string]$moduleversion      = $ModuleManifest.Version.ToString()
$prerelease                 = $ModuleManifest.PrivateData.PSData.Prerelease
$NugetProjectPath           = "api/v4/projects/$projectid/packages/nuget/index.json" # push to poject level not group for public access without auth
$logname                    = "deploy-stage-gitlab-package"
#---CONFIG----------------------------

# Set PreRelease
if (!$prerelease -or $prerelease.Length -eq 0) { $ModuleVersion = $ModuleVersion }
else { $ModuleVersion = "$ModuleVersion-$prerelease" }

$interLogger.invoke($logname, "GitLab package push to {kv:url=$gitlab_uri/$NugetProjectPath} for {kv:module=$ModuleName} version {kv:version=$ModuleVersion}", $false, 'info')

try {
  $interLogger.invoke($logname, "Registering Gitlab: $gitlab_uri/$NugetProjectPath", $false, 'info')
  #dotnet nuget add source $gitlab_uri/$NugetProjectPath --name gitlab --username $GitLab_Username --password $ENV:GITLAB_API_KEY
  nuget sources add -name "gitlab_$projectid_$ModuleName`_Packages" -source $gitlab_uri/$NugetProjectPath -username $GitLab_Username -password $env:GITLAB_API_KEY
  $interLogger.invoke($logname, "Successfully registered Gitlab: $gitlab_uri/$NugetProjectPath", $false, 'info')
}
catch [system.exception] {
  $interLogger.invoke($logname, "Failed to register Gitlab: $gitlab_uri/$NugetProjectPath", $false, 'error')
  $interLogger.invoke($logname, $_.Exception.Message, $false, 'error')
  exit 1
}

# check if package already exists
try {
  $interLogger.invoke($logname, "Checking if package exists: $gitlab_uri/$NugetProjectPath", $false, 'info')
  $response = Invoke-WebRequest -Uri "https://gitlab.com/api/v4/projects/$projectid/packages/nuget/$ModuleName/$ModuleVersion"
  if ($response.StatusCode -eq 200) {
    $interLogger.invoke($logname, "Package already exists: $gitlab_uri/$NugetProjectPath", $false, 'info')
    exit 0
  }
  $interLogger.invoke($logname, "Package does not exist, proceeding to push: $gitlab_uri/$NugetProjectPath", $false, 'info')
}
catch {
  $interLogger.invoke($logname, "Failed to check if package exists: $gitlab_uri/$NugetProjectPath", $false, 'error')
}

try {
  $interLogger.invoke($logname, "Pushing $modulename to Gitlab: $gitlab_uri/$NugetProjectPath", $false, 'info')
  #dotnet nuget push ./dist/nuget/$modulename.$SemVerVersion.nupkg --source gitlab 
  nuget push ./dist/nuget/$ModuleName.$ModuleVersion.nupkg -Source "gitlab_$projectid_$ModuleName`_Packages" -ApiKey $env:GITLAB_API_KEY
  
  if ($LASTEXITCODE -ne 0) {
    $interLogger.invoke($logname, "nuget push failed with exit code $LASTEXITCODE", $false, 'error')
    exit 1
  }
  nuget sources remove -Name "gitlab_$projectid_$ModuleName`_Packages"
}
catch [system.exception] {
  $interLogger.invoke($logname, "Failed to push $modulename to Gitlab: $gitlab_uri/$NugetProjectPath", $false, 'error')
  $interLogger.invoke($logname, $_.Exception.Message, $false, 'error')
  exit 1
}