using module ../core/core.psm1

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
$kv = $global:__automator_devops.kvinc
$package_version = (Get-GitAutoVersion).Version
#---UI ELEMENTS Shortened-------------

#---CONFIG----------------------------
$libraryConfig = (Get-Content -Path ./build_config.json | ConvertFrom-Json).dotnet
$Name = $libraryConfig.Name
#---CONFIG----------------------------

# Check if $libraryConfig.Prerelease exists
# if so append it to $package_version
if ($libraryConfig.Prerelease) {
    $package_version = "$package_version-$($libraryConfig.Prerelease)"
}

# Test if Dist folder exists
if (!(Test-Path -Path "./dist/$Name")) {
    New-Item -Path "./dist/$Name" -ItemType Directory
}


$interLogger.invoke("Build", "Running Build on DotNet {kv:Library=$Name} {kv:Version=$package_version}", $false, 'info')

# Build the library
dotnet build -c Release --no-restore -o "./dist/$Name/lib/$Name/" "./$Name/$Name.csproj"

$interlogger.invoke("Build", "Successfully built DotNet ", $false, 'info')

$interLogger.invoke("Build", "Copying Dist Build Files to {kv:Folder=dist/$Name}", $false, 'info')
# Copy Dist Build Files
foreach ($folder in $libraryConfig.Folders) {
    if (!(Test-Path -Path $folder -ErrorAction SilentlyContinue)){
        $interlogger.invoke("Build", "Folder $folder not found", $false, 'error')
        throw "Folder $folder not found"
        return 1
    }
    Get-ChildItem -Path "./$Name/$folder" -Exclude $libraryConfig.Exclude | ForEach-Object {
        $interLogger.invoke("Build", "Copying $($_.Name) to $folder", $true, 'info')
        Copy-Item -Path "./$Name/$folder/$_" -Destination "./dist/$Name/$folder/$_" -Force
    }
}

$interLogger.invoke("Build", "Successfully copied Folders to {kv:Folder=dist/$Name}", $false, 'info')

$interLogger.invoke("Build", "Copying Dist Build Files to {kv:Folder=dist/$Name}", $false, 'info')
foreach ($file in $libraryConfig.Files) {
    if (!(Test-Path -Path $file -ErrorAction SilentlyContinue)){
        $interlogger.invoke("Build", "File $file not found", $false, 'error')
        throw "File $file not found"
        return 0
    }
    $interLogger.invoke("Build", "Copying $file to ./$Name/$Name/$file", $true, 'info')
    Copy-Item -Path "./$Name/$file" -Destination "./dist/$Name/$file" -Force
}

$interLogger.invoke("Build", "Successfully copied files to {kv:Folder=dist/$Name}", $false, 'info')

# Complete

$interLogger.invoke("Complete", "Successfully completed Build on DotNet {kv:Library=$Name} {kv:Version=$package_version}", $false, 'info')

