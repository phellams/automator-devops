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
#$gitlab_mirror_name = "gitlab_mirror"
$github_mirror_name = "github_mirror"
#---CONFIG----------------------------

try {
    # $repo_string = "https://$user`:$ENV:GITLAB_API_KEY@$gitlab.com/$user/$RepoName.git"
    # git remote add $gitlab_mirror_name $repo_string
    # git remote set-url --push $name $repo_string
    # git push $gitlab_mirror_name --all
    # if($LASTEXITCODE -eq 0) {
    #     Write-Host "Gitlab Mirror Added" #! should throw here for ci to fail
    # }else {
    #     throw [system.exception] "Failed to add Gitlab Mirror Exit Code:$LASTEXITCODE, url:$repo_string"
    # }

    # ADD local Mirror - Github
    # -----------------
    $repo_string = "https://$gituser`:$ENV:GITHUB_API_KEY@github.com/$gitgroup/$ModuleName.git"
    git remote add $github_mirror_name $repo_string
    git remote set-url --push $github_mirror_name $repo_string
    $interLogger.invoke("release", "Adding Github Mirror: {kv:url=$repo_string}", $false, 'info')
    git push $github_mirror_name --all
    if($LASTEXITCODE -eq 0) {
        $interLogger.invoke("release", "Successfully added Github Mirror: {kv:url=$repo_string}", $false, 'info')
    }else {
        $interLogger.invoke("release", "Failed to add Github Mirror Exit Code:{kv:code=$LASTEXITCODE}, {kv:url=$repo_string}", $false, 'error')
        exit 1
    }

} catch [system.exception] {
    $interLogger.invoke("release", "Failed to create local mirror: {kv:error=$($_.exception.message)}", $false, 'error')    
}

# Remove local Mirrors
# -----------------
#git remote remove gitlab_mirror
git remote remove github_mirror
