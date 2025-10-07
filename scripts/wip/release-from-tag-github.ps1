#---CONFIG----------------------------
$ModuleConfig   = Get-Content -Path ./build_config.json | ConvertFrom-Json
$ModuleName = $ModuleConfig.moduleName
$gituser = $ModuleConfig.gituser
#---CONFIG----------------------------

$artifactsUrl = "https://$ENV:GITLAB_HOST/$gituser/$reponame/-/jobs/$($ENV:CI_JOB_ID)/artifacts/raw/dist"
$semver_version = "v$((Get-GitAutoVersion).version)" # requires Module Commit Fusion

# Parse release body
$releasenotes = Get-Content -Path '.\build\release-template\releasenotes.md' -Raw
$packages     = Get-Content -Path '.\build\release-template\packages.md' -Raw 
$nupkgFiles   = Get-Content -Path '.\build\release-template\nupkgs.md' -Raw
$nupkgFiles   = $nupkgFiles -replace $reponame, $modulename `
                            -replace $chocoRawLink, "$artifactsUrl\choco\$reponame.$version.nupkg"
$packages     = $packages -replace $reponame, $modulename `
                          -replace $chocoRawLink, "$artifactsUrl\choco\$reponame.$version.nupkg"
$releasenotes = $releasenotes -replace $reponame, $modulename

$ReleaseBody = $releasenotes + $packages + $nupkgFiles

# $nupkgFiles = Get-ChildItem -Path './build' -Filter '*.nupkg'
# $zip = Get-ChildItem -Path './build' -Filter '*.zip'

# foreach ($file in $nupkgFiles) {
#     $description += "`n- [$($file.Name)]($artifactsUrl/$($file.Name))"
# }

# $ReleaseNotes = ""
# $Packages = ""
# $nupkgFiles = ""
$headers = New-Object 'System.Collections.Generic.Dictionary[[String],[String]]'
$headers.Add("PRIVATE-TOKEN", "$($ENV:GITLAB_API_KEY)")
$headers.Add("Content-Type", "application/json")
Invoke-RestMethod -Uri "https://$ENV:GITLAB_HOST/api/v4/projects/$($ENV:CI_PROJECT_ID)/releases" -Method 'POST' -Headers $headers -Body @{
  "name"        = "🍹Release($semver_version)"
  "tag_name"    = "$semver_version"
  "description" = $ReleaseBody
}
