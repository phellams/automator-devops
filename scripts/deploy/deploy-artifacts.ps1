using module ../core/core.psm1

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
$kv = $global:__automator_devops.kvinc
#---UI ELEMENTS Shortened------------

#---CONFIG----------------------------
$ModuleConfig            = (Get-Content -Path ./build_config.json | ConvertFrom-Json).PSModule
$ModuleName              = $ModuleConfig.moduleName
$ModuleManifest          = Test-ModuleManifest -path "./dist/$ModuleName/$ModuleName.psd1"
[string]$moduleversion   = $ModuleManifest.Version.ToString()
$PreRelease              = $ModuleManifest.PrivateData.PSData.Prerelease
$logname                 = "deploy-stage-artifacts"
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

$interLogger.invoke($logname, "Starting GitLab artifact upload {kv:module=$ModuleName} {kv:version=$moduleversion} {kv:url=$baseUrl}", $false, 'info')

$interLogger.invoke($logname, 'Resolved GitLab CI environment', $false, 'info')
$kv.invoke("CI_API_V4_URL", "$env:CI_API_V4_URL")
$kv.invoke("CI_PROJECT_ID", "$env:CI_PROJECT_ID")
$kv.invoke("CI_COMMIT_TAG", "$env:CI_COMMIT_SHA")
$kv.invoke("CI_JOB_TOKEN", "$($null -ne $env:CI_JOB_TOKEN)")
$interLogger.invoke($logname, 'Resolved module artifact metadata', $false, 'info')
$kv.invoke("MODULE NAME", "$ModuleName")
$kv.invoke("MODULE VERSION", "$moduleversion")
$kv.invoke("BASE URL", "$baseUrl")

$file_hashes = @()

# Upload NuGet package
$interLogger.invoke($logname, "Locating the NuGet artifact {kv:pattern=$ModuleName*$moduleversion*.nupkg}", $false, 'info')
$nugetFile = Get-ChildItem -Recurse './dist/nuget' -Filter "$ModuleName*.nupkg" | 
    Where-Object { $_.Name -like "$ModuleName*$moduleversion*.nupkg" } | 
    Select-Object -First 1

if ($nugetFile) {
    $nugetFile | Select-Object Name, FullName
    $interLogger.invoke($logname, "Uploading the NuGet artifact {kv:file=$($nugetFile.FullName)}", $false, 'info')
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/$($nugetFile.Name)" -Method Put -InFile $nugetFile.FullName -Headers $headers
        $interLogger.invoke($logname, "Uploaded the NuGet artifact {kv:file=$($nugetFile.Name)} {kv:status=$($response.StatusCode)}", $false, 'success')
    }
    catch {
        $interLogger.invoke($logname, "NuGet artifact upload failed {err:kv:error=$($_.Exception.Message)}", $false, 'error')
        exit 1
    }
} else {
    $interLogger.invoke($logname, 'No NuGet artifact was found for upload', $false, 'error')
    # List what files are actually there for debugging
    $allNugetFiles = Get-ChildItem -Recurse './dist/nuget' -Filter "*.nupkg" -ErrorAction SilentlyContinue
    if ($allNugetFiles) {
        $interLogger.invoke($logname, 'Available NuGet artifacts', $false, 'info')
        $allNugetFiles | ForEach-Object { $interLogger.invoke('artifact', "{kv:file=$($_.Name)}", $true, 'info') }
    } else {
        $interLogger.invoke($logname, "No .nupkg files found in ./dist/nuget/", $false, 'error')
    }
    exit 1
}

# Upload Chocolatey package
$interLogger.invoke($logname, "Locating the Chocolatey artifact {kv:pattern=$ModuleName*$moduleversion*choco*.nupkg}", $false, 'info')
$chocoFile = Get-ChildItem -Recurse './dist/choco' -Filter "$ModuleName*.nupkg" | 
    Where-Object { $_.Name -like "$ModuleName*$moduleversion*choco*.nupkg" } | 
    Select-Object -First 1

if ($chocoFile) {
    $chocoFile | Select-Object Name, FullName
    $interLogger.invoke($logname, "Uploading the Chocolatey artifact {kv:file=$($chocoFile.FullName)}", $false, 'info')
    try {
        Invoke-RestMethod -Uri "$baseUrl/$($chocoFile.Name)" -Method Put -InFile $chocoFile.FullName -Headers $headers
        $interLogger.invoke($logname, "Uploaded the Chocolatey artifact {kv:file=$($chocoFile.Name)}", $false, 'success')
    }
    catch {
        $interLogger.invoke($logname, "Chocolatey artifact upload failed {err:kv:error=$($_.Exception.Message)}", $false, 'error')
        exit 1
    }
} else {
    $interLogger.invoke($logname, 'No Chocolatey artifact was found for upload', $false, 'error')
    # List what files are actually there for debugging
    $allChocoFiles = Get-ChildItem -Recurse './dist/choco' -Filter "*.nupkg" -ErrorAction SilentlyContinue
    if ($allChocoFiles) {
        $interLogger.invoke($logname, 'Available Chocolatey artifacts', $false, 'info')
        $allChocoFiles | ForEach-Object { $interLogger.invoke('artifact', "{kv:file=$($_.Name)}", $true, 'info') }
    } else {
        $interLogger.invoke($logname, "No .nupkg files found in ./dist/choco/", $false, 'error')
    }
    exit 1
}

# Upload powershell gallary zip file
$interLogger.invoke($logname, "Locating the PowerShell Gallery archive {kv:pattern=$ModuleName*$moduleversion*psgal*.zip}", $false, 'info')
$zipFile = Get-ChildItem -Recurse './dist/psgal' -Filter "$ModuleName*.zip" | 
    Where-Object { $_.Name -like "$ModuleName*$moduleversion*psgal*.zip" } | 
    Select-Object -First 1

if ($zipFile) {
    $zipFile | Select-Object Name, FullName
    $interLogger.invoke($logname, "Uploading the PowerShell Gallery archive {kv:file=$($zipFile.FullName)}", $false, 'info')
    try {
        Invoke-RestMethod -Uri "$baseUrl/$($zipFile.Name)" -Method Put -InFile $zipFile.FullName -Headers $headers
        $interLogger.invoke($logname, "Uploaded the PowerShell Gallery archive {kv:file=$($zipFile.Name)}", $false, 'success')
    }
    catch {
        $interLogger.invoke($logname, "PowerShell Gallery archive upload failed {err:kv:error=$($_.Exception.Message)}", $false, 'error')
        exit 1
    }
} else {
    $interLogger.invoke($logname, 'No PowerShell Gallery archive was found for upload', $false, 'error')
    # List what files are actually there for debugging
    $allZipFiles = Get-ChildItem -Recurse './dist/psgal' -Filter "*.zip" -ErrorAction SilentlyContinue
    if ($allZipFiles) {
        $interLogger.invoke($logname, 'Available PowerShell Gallery archives', $false, 'info')
        $allZipFiles | ForEach-Object { $interLogger.invoke('artifact', "{kv:file=$($_.Name)}", $true, 'info') }
    } else {
        $interLogger.invoke($logname, "No .zip files found in ./dist/psgal/", $false, 'error')
    }
    exit 1
}

# Upload tar.gz file
$interLogger.invoke($logname, "Locating the generic tar.gz artifact {kv:pattern=$ModuleName*$moduleversion*.tar.gz}", $false, 'info')
$targzFile = Get-ChildItem -Recurse './dist/generic' -Filter "$ModuleName*.tar.gz" | 
    Where-Object { $_.Name -like "$ModuleName*$moduleversion*.tar.gz" } | 
    Select-Object -First 1

if ($targzFile) {
    $targzFile | Select-Object Name, FullName
    $interLogger.invoke($logname, "Uploading the generic tar.gz artifact {kv:file=$($targzFile.FullName)}", $false, 'info')
    try {
        Invoke-RestMethod -Uri "$baseUrl/$($targzFile.Name)" -Method Put -InFile $targzFile.FullName -Headers $headers
        $interLogger.invoke($logname, "Uploaded the generic tar.gz artifact {kv:file=$($targzFile.Name)}", $false, 'success')
    }
    catch {
        $interLogger.invoke($logname, "Generic tar.gz artifact upload failed {err:kv:error=$($_.Exception.Message)}", $false, 'error')
        exit 1
    }
} else {
    $interLogger.invoke($logname, 'No generic tar.gz artifact was found for upload', $false, 'error')
    # List what files are actually there for debugging
    $alltargzFiles = Get-ChildItem -Recurse './dist/generic' -Filter "*.tar.gz" -ErrorAction SilentlyContinue
    if ($alltargzFiles) {
        $interLogger.invoke($logname, 'Available generic tar.gz artifacts', $false, 'info')
        $alltargzFiles | ForEach-Object { $interLogger.invoke('artifact', "{kv:file=$($_.Name)}", $true, 'info') }
    } else {
        $interLogger.invoke($logname, "No .tar.gz files found in ./dist/generic/", $false, 'error')
    }
    exit 1
}

# Upload NUGET .net Package
if((test-path -path "./dist/dotnet")) {
    # upload dotnet package
    $interLogger.invoke($logname, "Locating the managed .NET artifact {kv:pattern=$ModuleName.$moduleversion.nupkg}", $false, 'info')
    $dotnetFile = Get-ChildItem -Recurse './dist/dotnet' -Filter "$ModuleName*.nupkg" | 
        Where-Object { $_.Name -like "$ModuleName.$moduleversion.nupkg" } | 
        Select-Object -First 1

    if ($dotnetFile) {
        $dotnetFile | Select-Object Name, FullName
        $interLogger.invoke($logname, "Uploading the managed .NET artifact {kv:file=$($dotnetFile.FullName)}", $false, 'info')
        try {
            Invoke-RestMethod -Uri "$baseUrl/$($dotnetFile.Name)" -Method Put -InFile $dotnetFile.FullName -Headers $headers
            $interLogger.invoke($logname, "Uploaded the managed .NET artifact {kv:file=$($dotnetFile.Name)}", $false, 'success')
        }
        catch {
            $interLogger.invoke($logname, "Managed .NET artifact upload failed {err:kv:error=$($_.Exception.Message)}", $false, 'error')
            exit 1
        }
    } else {
        $interLogger.invoke($logname, 'No managed .NET artifact was found for upload', $false, 'error')
        # List what files are actually there for debugging
        $allDotnetFiles = Get-ChildItem -Recurse './dist/dotnet' -Filter "*.nupkg" -ErrorAction SilentlyContinue
        if ($allDotnetFiles) {
            $interLogger.invoke($logname, 'Available managed .NET artifacts', $false, 'info')
            $allDotnetFiles | ForEach-Object { $interLogger.invoke('artifact', "{kv:file=$($_.Name)}", $true, 'info') }
        } else {
            $interLogger.invoke($logname, "No .nupkg files found in ./dist/dotnet/", $false, 'error')
        }
        exit 1
    }
}
