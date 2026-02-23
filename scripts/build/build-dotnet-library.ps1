using module ../core/core.psm1

#...... UI ELEMENTS Shortened .....................................

$interLogger = $global:__automator_devops.interLogger
$kv = $global:__automator_devops.kvinc
$package_version = (Get-GitAutoVersion).Version

#..................................................................

#... CONFIG ........................................................
 
$libraryConfig = (Get-Content -Path ./build_config.json | ConvertFrom-Json).dotnet
$Name = $libraryConfig.Name
$suffex = $libraryConfig.Suffix
$TargetFramework = $libraryConfig.TargetFramework
#..................................................................

# Set location of .sln folder for dotnet build and pack commands
Set-Location -Path .\$Name

$interLogger.invoke("Build", "Running Build on DotNet {kv:Library=$Name} {kv:Version=$package_version}", $false, 'info')

#debug - Build the library dlls outputs in bin/Release Copy bin to powershell module dist
dotnet build .\$Name\$Name.csproj -c Release
$interlogger.invoke("Build", "Successfully built DotNet ", $false, 'info')

#debug - Copy compiled dlls to root \bin for powershell module to consume
$interLogger.invoke("Build", "Copying built dlls to ./bin for PowerShell module to consume", $false, 'info')
Copy-Item -path .\bin -destination ..\ -recurse

#debug - Build Nuget Package for nuget.org Outputs to nupkgs folder
#debug - If Suffix is provided in build_config.json, append it to the package version for pre-release labeling (e.g., 1.0.0-Library)
#debug -   helpes if we want to publish the library as a separate package from the powershell module but want to keep them in sync
$interLogger.invoke("Build", "Packing DotNet library into NuGet package...", $false, 'info')
if (!$null -ne $suffex -and $suffex.Length -gt 0) {
    dotnet pack .\$Name\$Name.csproj -c Release --output nupkgs -p:PackageVersion="$package_version-$suffex"
}else {
    dotnet pack .\$Name\$Name.csproj -c Release --output nupkgs -p:PackageVersion="$package_version"
}
$interLogger.invoke("Build", "Successfully packed DotNet library into NuGet package", $false, 'info')  

#debug - Copy nuget package to root \dist\dotnet for packaging as build artifact and deployment
$interLogger.invoke("Build", "Copying NuGet package to ../dist/dotnet for build artifact and deployment...", $false, 'info')
Copy-Item -path .\nupkgs -destination ..\dist\dotnet -recurse
$interLogger.invoke("Complete", "Successfully completed Build on DotNet {kv:Library=$Name} {kv:Version=$package_version}", $false, 'info')

#debug - output of built packages and dlls for verification before deployment
[Console]::writeline("==== Build Package Info : TargetFramework=$TargetFramework ====")
Get-ChildItem -Recurse '../dist/dotnet' -Filter "*.nupkg" | ForEach-Object {
    $kv.invoke("Package", $_.Name)
}
Get-ChildItem -Recurse '../bin' -Filter "*.dll" | ForEach-Object {
    $kv.invoke("DLL", $_.Name)
}
[Console]::writeline("============================")

