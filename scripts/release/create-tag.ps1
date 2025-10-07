using module ../core/core.psm1

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
$kv = $global:__automator_devops.kvinc
#---UI ELEMENTS Shortened------------

#---CONFIG----------------------------
$ModuleConfig   = Get-Content -Path ./build_config.json | ConvertFrom-Json
$ModuleName     = $ModuleConfig.moduleName
$gituser        = $ModuleConfig.gituser
$gitgroup       = $ModuleConfig.gitgroup
$ModuleManifest = Test-ModuleManifest -path "./dist/$ModuleName/$ModuleName.psd1"
$PreRelease     = $ModuleManifest.PrivateData.PSData.Prerelease
$ModuleVersion  = $ModuleManifest.Version.ToString()
$gitlab_host    = "gitlab.com" # $ENV:GITLAB_HOST
#---CONFIG----------------------------

if (!$prerelease -or $prerelease.Length -eq 0) { $ModuleVersion = $ModuleVersion }
else { $ModuleVersion = "$ModuleVersion-$prerelease" }

# push Tag
git config --global user.name $gitUser
git config --global user.email "$($ENV:GITLAB_EMAIL)"

$interLogger.invoke("release", "Creating git tag {kv:version=$ModuleVersion} for {kv:module=$ModuleName}", $false, 'info')
git tag "$ModuleVersion"

$git_remote_url = "https://oauth2:$($ENV:GITLAB_API_KEY)@$gitlab_host/$gitgroup/$ModuleName.git"

$interLogger.invoke("release", "Pushing git tag {kv:version=$ModuleVersion} to {kv:url=$git_remote_url}", $false, 'info')
git push --tags $git_remote_url HEAD:main

if($LASTEXITCODE -ne 0) {
    $interLogger.invoke("release", "Failed to push git tag {kv:version=$ModuleVersion} to {kv:url=$git_remote_url}", $false, 'error')
    exit 1
} else {
    $interLogger.invoke("release", "Successfully pushed git tag {kv:version=$ModuleVersion} to {kv:url=$git_remote_url}", $false, 'info')
}