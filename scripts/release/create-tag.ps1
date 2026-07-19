using module ../core/core.psm1

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
$kv = $global:__automator_devops.kvinc
#---UI ELEMENTS Shortened------------

#---CONFIG----------------------------
$ModuleConfig   = (Get-Content -Path ./build_config.json | ConvertFrom-Json).PSModule
$ModuleName     = $ModuleConfig.moduleName
$gituser        = $ModuleConfig.gituser
$gitgroup       = $ModuleConfig.gitgroup
$ModuleManifest = Test-ModuleManifest -path "./dist/$ModuleName/$ModuleName.psd1"
$PreRelease     = $ModuleManifest.PrivateData.PSData.Prerelease
$ModuleVersion  = $ModuleManifest.Version.ToString()
$gitlab_host    = "gitlab.com" # $ENV:GITLAB_HOST
$logname        = "release-stage"
#---CONFIG----------------------------

if (!$prerelease -or $prerelease.Length -eq 0) { $ModuleVersion = $ModuleVersion }
else { $ModuleVersion = "$ModuleVersion-$prerelease" }

# push Tag
git config --global user.name $gitUser
git config --global user.email "$($ENV:GITLAB_EMAIL)"

$interLogger.invoke($logname, "Creating git tag {kv:version=$ModuleVersion} for {kv:module=$ModuleName}", $false, 'info')
git tag "$ModuleVersion"

$git_remote_url = "https://oauth2:$($ENV:GITLAB_API_KEY)@$gitlab_host/$gitgroup/$ModuleName.git"

$interLogger.invoke($logname, "Pushing Git tag {kv:version=$ModuleVersion} {kv:url=https://$gitlab_host/$gitgroup/$ModuleName.git}", $false, 'info')
git push --tags $git_remote_url HEAD:main

if($LASTEXITCODE -ne 0) {
    $interLogger.invoke($logname, "Failed to push the Git tag {err:kv:version=$ModuleVersion} {err:kv:url=https://$gitlab_host/$gitgroup/$ModuleName.git}", $false, 'error')
    exit 1
} else {
    $interLogger.invoke($logname, "Pushed the Git tag {kv:version=$ModuleVersion} {kv:url=https://$gitlab_host/$gitgroup/$ModuleName.git}", $false, 'success')
}
