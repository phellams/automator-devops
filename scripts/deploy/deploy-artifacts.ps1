using module ../core/core.psm1

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
$kv = $global:__automator_devops.kvinc
#---UI ELEMENTS Shortened------------

#---CONFIG----------------------------
$ModuleConfig            = Get-Content -Path ./build_config.json | ConvertFrom-Json
$ModuleName              = $ModuleConfig.moduleName
$ModuleManifest          = Test-ModuleManifest -path "./dist/$ModuleName/$ModuleName.psd1"
[string]$moduleversion   = $ModuleManifest.Version.ToString()
$PreRelease              = $ModuleManifest.PrivateData.PSData.Prerelease
#---CONFIG----------------------------

if (!$prerelease -or $prerelease.Length -eq 0) { 
    $moduleversion = $moduleversion 
} else { 
    $moduleversion = "$moduleversion-$prerelease"
}

# Rename Choco package file for build artifact as output name is the same 
# for psgal, nuget and choco
Rename-Item -Path "./dist/choco/$ModuleName.$moduleversion.nupkg" `
            -NewName "$ModuleName.$moduleversion-choco.nupkg"

$headers = @{ "JOB-TOKEN" = $env:CI_JOB_TOKEN }

# Check if we should use CI_COMMIT_SHA instead of CI_COMMIT_TAG
$CommitTag = if ($env:CI_COMMIT_TAG) { $env:CI_COMMIT_TAG } else { $env:CI_COMMIT_SHA }

# Base URL
# .../packages/generic/:package_name/:package_version/:file_name
# Note this filed when i first did it with $env:CI_COMMIT_TAG and the tag had a 'v' in it like v1.0.0
# FIX: try with "$modulename/$moduleversion/$ModuleName-$moduleversion.nupkg" name
$baseUrl = "$env:CI_API_V4_URL/projects/$env:CI_PROJECT_ID/packages/generic/$modulename/$moduleversion"

$interLogger.invoke("deploy", "Uploading artifacts to {kv:url=$baseUrl}", $false, 'info')

[console]::writeline("==== ENVIRONMENT VARIABLES DEBUG ====")
$kv.invoke("CI_API_V4_URL", "$env:CI_API_V4_URL")
$kv.invoke("CI_PROJECT_ID", "$env:CI_PROJECT_ID")
$kv.invoke("CI_COMMIT_TAG", "$env:CI_COMMIT_SHA")
$kv.invoke("CI_JOB_TOKEN", "$($null -ne $env:CI_JOB_TOKEN)")
[console]::writeline("====================================")

[console]::writeline("===== MODULE INFO ==================")
$kv.invoke("MODULE NAME", "$ModuleName")
$kv.invoke("MODULE VERSION", "$moduleversion")
$kv.invoke("BASE URL", "$baseUrl")
[console]::writeline("====================================")

$file_hashes = @()

# Upload NuGet package
$interLogger.invoke("deploy", "Finding NuGet package: $ModuleName-$moduleversion.nupkg to upload...", $false, 'info')
$nugetFile = Get-ChildItem -Recurse './dist/nuget' -Filter "$ModuleName*.nupkg" | 
    Where-Object { $_.Name -like "$ModuleName*$moduleversion*.nupkg" } | 
    Select-Object -First 1

if ($nugetFile) {
    $nugetFile | Select-Object Name, FullName
    $interLogger.invoke("deploy", "Uploading NuGet package: $($nugetFile.FullName)", $false, 'info')    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/$($nugetFile.Name)" -Method Put -InFile $nugetFile.FullName -Headers $headers
        $interLogger.invoke("deploy", "{kv:StatusCode=$response.StatusCode} On file upload {kv:File=$($nugetFile.Name)}", $false, 'info')
    }
    catch {
        $interLogger.invoke("deploy", "Upload failed: $($_.Exception.Message)", $false, 'error')
        exit 1
    }
} else {
    $interLogger.invoke("deploy", "No NuGet package found to upload.", $false, 'info')
    # List what files are actually there for debugging
    $allNugetFiles = Get-ChildItem -Recurse './dist/nuget' -Filter "*.nupkg" -ErrorAction SilentlyContinue
    if ($allNugetFiles) {
        $interLogger.invoke("deploy", "Available NuGet files:", $false, 'info')
        $allNugetFiles | ForEach-Object { [console]::writeline("  $($_.Name)") }
    } else {
        $interLogger.invoke("deploy", "No .nupkg files found in ./dist/nuget/", $false, 'error')
    }
    exit 1
}

# Upload Chocolatey package
$interLogger.invoke("deploy", "Finding Chocolatey package: $ModuleName-$moduleversion-choco.nupkg to upload...", $false, 'info')
$chocoFile = Get-ChildItem -Recurse './dist/choco' -Filter "$ModuleName*.nupkg" | 
    Where-Object { $_.Name -like "$ModuleName*$moduleversion*choco*.nupkg" } | 
    Select-Object -First 1

if ($chocoFile) {
    $chocoFile | Select-Object Name, FullName
    $interLogger.invoke("deploy", "Uploading Chocolatey package: $($chocoFile.FullName)", $false, 'info')
    try {
        Invoke-RestMethod -Uri "$baseUrl/$($chocoFile.Name)" -Method Put -InFile $chocoFile.FullName -Headers $headers
        $interLogger.invoke("deploy", "Uploaded: $($chocoFile.Name)", $false, 'info')
    }
    catch {
        $interLogger.invoke("deploy", "Upload failed: $($_.Exception.Message)", $false, 'error')
        exit 1
    }
} else {
    $interLogger.invoke("deploy", "No Chocolatey package found to upload.", $false, 'info')
    # List what files are actually there for debugging
    $allChocoFiles = Get-ChildItem -Recurse './dist/choco' -Filter "*.nupkg" -ErrorAction SilentlyContinue
    if ($allChocoFiles) {
        $interLogger.invoke("deploy", "Available Chocolatey files:", $false, 'info')
        $allChocoFiles | ForEach-Object { [console]::writeline("  $($_.Name)") }
    } else {
        $interLogger.invoke("deploy", "No .nupkg files found in ./dist/choco/", $false, 'error')
    }
    exit 1
}

# Upload ZIP file
$interLogger.invoke("deploy", "Finding ZIP file: $ModuleName-$moduleversion-psgal.zip to upload...", $false, 'info')
$zipFile = Get-ChildItem -Recurse './dist/psgal' -Filter "$ModuleName*.zip" | 
    Where-Object { $_.Name -like "$ModuleName*$moduleversion*psgal*.zip" } | 
    Select-Object -First 1

if ($zipFile) {
    $zipFile | Select-Object Name, FullName
    $interLogger.invoke("deploy", "Uploading ZIP file: $($zipFile.FullName)", $false, 'info')
    try {
        Invoke-RestMethod -Uri "$baseUrl/$($zipFile.Name)" -Method Put -InFile $zipFile.FullName -Headers $headers
        $interLogger.invoke("deploy", "Uploaded: $($zipFile.Name)", $false, 'info')
    }
    catch {
        $interLogger.invoke("deploy", "ZIP upload failed: $($_.Exception.Message)", $false, 'error')
        exit 1
    }
} else {
    $interLogger.invoke("deploy", "No ZIP file found to upload.", $false, 'info')
    # List what files are actually there for debugging
    $allZipFiles = Get-ChildItem -Recurse './dist/psgal' -Filter "*.zip" -ErrorAction SilentlyContinue
    if ($allZipFiles) {
        $interLogger.invoke("deploy", "Available ZIP files:", $false, 'info')
        $allZipFiles | ForEach-Object { [console]::writeline("  $($_.Name)") }
    } else {
        $interLogger.invoke("deploy", "No .zip files found in ./dist/psgal/", $false, 'error')
    }
    exit 1
}