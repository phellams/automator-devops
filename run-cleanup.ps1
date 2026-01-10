# Remove all build temp files, .dlls, .nupkg, .nuspec from rootfolder
# usefull if building locally

$interLogger.invoke("Cleanup", "Starting cleanup of build artifacts", $false, 'info')

# clear up here