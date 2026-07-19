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

$interLogger.invoke($logname, "Starting GitLab package deployment {kv:module=$ModuleName} {kv:version=$ModuleVersion} {kv:url=$gitlab_uri/$NugetProjectPath}", $false, 'info')

try {
  $interLogger.invoke($logname, "Registering the GitLab NuGet source {kv:url=$gitlab_uri/$NugetProjectPath}", $false, 'info')
  #dotnet nuget add source $gitlab_uri/$NugetProjectPath --name gitlab --username $GitLab_Username --password $ENV:GITLAB_API_KEY
  nuget sources add -name "gitlab_$projectid_$ModuleName`_Packages" -source $gitlab_uri/$NugetProjectPath -username $GitLab_Username -password $env:GITLAB_API_KEY
  $interLogger.invoke($logname, "Registered the GitLab NuGet source {kv:url=$gitlab_uri/$NugetProjectPath}", $false, 'success')
}
catch [system.exception] {
  $interLogger.invoke($logname, "Failed to register the GitLab NuGet source {err:kv:url=$gitlab_uri/$NugetProjectPath}", $false, 'error')
  $interLogger.invoke($logname, $_.Exception.Message, $false, 'error')
  exit 1
}

# check if package already exists
try {
  $interLogger.invoke($logname, "Checking for an existing GitLab package {kv:module=$ModuleName} {kv:version=$ModuleVersion}", $false, 'info')
  $response = Invoke-WebRequest -Uri "https://gitlab.com/api/v4/projects/$projectid/packages/nuget/$ModuleName/$ModuleVersion"
  if ($response.StatusCode -eq 200) {
    $interLogger.invoke($logname, "GitLab package already exists; skipping deployment {kv:module=$ModuleName} {kv:version=$ModuleVersion}", $false, 'info')
    exit 0
  }
  $interLogger.invoke($logname, 'GitLab package does not exist; continuing with deployment', $false, 'info')
}
catch {
  $interLogger.invoke($logname, "Unable to determine whether the GitLab package exists {err:kv:url=$gitlab_uri/$NugetProjectPath}", $false, 'error')
}

try {
  $interLogger.invoke($logname, "Publishing the package to GitLab {kv:module=$modulename} {kv:url=$gitlab_uri/$NugetProjectPath}", $false, 'info')
  #dotnet nuget push ./dist/nuget/$modulename.$SemVerVersion.nupkg --source gitlab 
  nuget push ./dist/nuget/$ModuleName.$ModuleVersion.nupkg -Source "gitlab_$projectid_$ModuleName`_Packages" -ApiKey $env:GITLAB_API_KEY
  
  if ($LASTEXITCODE -ne 0) {
    $interLogger.invoke($logname, "NuGet push failed {err:kv:exitcode=$LASTEXITCODE}", $false, 'error')
    exit 1
  }
  nuget sources remove -Name "gitlab_$projectid_$ModuleName`_Packages"
}
catch [system.exception] {
  $interLogger.invoke($logname, "Failed to publish the package to GitLab {err:kv:module=$modulename} {err:kv:url=$gitlab_uri/$NugetProjectPath}", $false, 'error')
  $interLogger.invoke($logname, $_.Exception.Message, $false, 'error')
  exit 1
}
