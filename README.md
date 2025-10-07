# Automator Devops

Devops template used to build and publish modules to the PowerShell Gallery, choco, gitlab packages and publish release via gitlab, paried with the [phellams-automator](https://hub.docker.com/r/sgkens/automator) docker image.

## 🥊 Dependancies for the Devops template

- **Gitlab** - [https://gitlab.com/](https://gitlab.com/)
- **Gitlab-Runner** - Gitlab Runner configured to run docker and shell scripts 
- **Phellams Automator Docker Image** - [https://hub.docker.com/r/sgkens/phellams-automator](https://hub.docker.com/r/sgkens/phellams-automator)
- **build_config.json** - Build config json file for the module in the root of the repo.
  - **Template**: `./automator/devops/templates/build_config-template.json`
- **module_name.psd1** - Module manifest with populated meta data
  - **Template**: `./automator/devops/templates/modulename.psd1`
  - for choco extra meta data see [https://chocolatey.org/docs/metadata](https://chocolatey.org/docs/metadata) and see template file example below
- **phwriter-metadata.ps1** - phwriter metadata file for the module [https://github.com/phellams/phwriter](https://github.com/phellams/phwriter), placed in the root directory of the module
  - PHWriter is used to generate and output formatted help text for the module mimicking the style of linux cli man pages.
- **gitlab-ci.yml** - gitlab workflow config yaml file.
  - **Template**: `./automator/devops/templates/.gitlab-ci.yml`

>❗ Note: before pushing and merging make sure to generate the semver using  `Get-GitAutoVersion` from `./automator/devops/scripts/core/Get-GitAutoVersion.psm1` and update the `modulename.psd1` with the `Major.Minor.Patch` version and the `Prerelease` version as the artifact, tags, and releases are affected by the `version` in the `modulename.psd1`

## Scripts

Scripts are located in th `./automator/devops/scripts/` directory

  - Test scripts are located in the `./automator/devops/scripts/test/` directory.
  - Build scripts are located in the `./automator/devops/scripts/build/` directory.
  - Release scripts are located in the `./automator/devops/scripts/publish/` directory.
  - Deploy scripts are located in the `./automator/devops/scripts/deploy/` directory.

## Local build

The local build script `./automator/devops/scripts/local-build.ps1` can be used to build the module locally, the script will build module to `./dist/` directory. 

🥊 Dependancies:

Script Parameters:

  - `-build` - initates script `./automator/devops/scripts/build/Build-Module.ps1`
  - `-psgal` - initates script `./automator/devops/scripts/build/build-package-psgallery.ps1`
  - `-choco` - initates script `./automator/devops/scripts/build/build-package-choco.ps1`
  - `-Nupkg` - initates script `./automator/devops/scripts/build/build-package-generic-nuget.ps1`
  - `-ChocoNuSpec` - initates script `./automator/devops/scripts/build/Build-nuspec-choco.ps1`
  - `-ChocoNupkgWindows` - initates script `./automator/devops/scripts/wip/build-package-choco-windows.ps1`

```powershell
# Example running in wsl2
```

## 🟢 Build Config Json Template

🥽 **Example**:

```json
{
    "modulename": "modulename",
    "releasetype": "public",
    "gituser": "user",
    "gitgroup": "group",
    "gitlabid_public": "id",
    "license": "MIT",
    "iconurl": "logo url",
    "modulefiles": [
        "modulename.psm1",
        "modulename.psd1",
        "LICENSE",
        "icon.png",
        "readme.md",
        "readme.txt"
    ],
    "modulefolders": [
        "cmdlets",
        "libs",
        "tools"
    ],
    "moduleexclude": [
        "commit-helper.ps1"
    ]
}
```

## 🟢 PHWriter Template file

> ❗ Note: the file name must be `phwriter-metadata.ps1`

> ❗ Note: You can use the automated script to generate the file `./automator/devops/scripts/core/Generate-PhwriterMetadata.ps1`

🥽 **Example**:

```powershell
# phwriter-metadata.ps1
$phwriter_metadata_array = @(
    @{
        Name        = $modulename;
        version     = $moduleversion
        Padding     = 1
        Indent      = 1
        #CustomLogo  = $CustomLogo
        CommandInfo = @{
            cmdlet      = "Get-FolderSizeFast";
            synopsis    = "Get-FolderSizeFast [-Path <String>] [-Recurse] [-Detailed] [-Format <String>] [-Help]";
            description = "This cmdlet calculates the size of a folder quickly by leveraging .NET methods. It supports recursion, progress display, and can output results in various formats including JSON and XML.";
        }
        ParamTable  = @(
            @{
                Name        = "Path"
                Param       = "p|Path"
                Type        = "string"
                required    = $true
                Description = "Specifies the path of the folder to calculate its size. Wildcards are supported."
                Inline      = $false # Description on a new line
            },
            @{
                Name        = "Recurse"
                Param       = "r|Recurse"
                Type        = "switch"
                required    = $false
                Description = "Indicates that the operation should process subdirectories recursively."
                Inline      = $false
            },
            @{
                Name        = "Detailed"
                Param       = "d|Detailed"
                Type        = "switch"
                required    = $false
                Description = "Outputs detailed information about each file and folder processed."
                Inline      = $false
            },
            @{
                Name        = "format"
                Param       = "f|Format"
                Type        = "string"
                required    = $false
                Description = "Specifies the output format. Supported formats are 'json' and 'xml'."
                Inline      = $false
            }
        )
        Examples    = @(
            "Get-FolderSizeFast -Path 'C:\MyFolder' -Detailed",
            "Get-FolderSizeFast -Path 'C:\MyFolder\*' -Recurse -ShowProgress",
            "Get-FolderSizeFast -Path 'C:\MyFolder' -Recurse -format json",
            "Get-FolderSizeFast -Path 'C:\MyFolder' -format xml"
        )
    }
)
```

## 🟢 Powershell Module Manifest Template

```powershell
@{
    RootModule         = 'zypline.psm1'
    ModuleVersion      = '0.1.0'
    GUID               = 'ccc9be26-17aa-4a86-8d5b-14d6d15def37'
    Author             = 'Garvey k. Snow'
    CompanyName        = 'Phellams'
    Copyright          = '(c) 2025 Garvey k. Snow. All rights reserved.'
    Description        = 'A PowerShell module for advanced file and folder searching with configuration management.'
    FunctionsToExport  = @()
    CmdletsToExport    = @()
    VariablesToExport  = @()
    AliasesToExport    = @()
    PrivateData        = @{
        PSData = @{
            Tags                     = @('Help', 'Formatting', 'CLI', 'PowerShell', 'Documentation')
            ReleaseNotes             = @{
                # '1.2.1' = 'Initial release with New-PHWriter cmdlet for custom help formatting and enhanced layout.'
            }
            RequireLicenseAcceptance = $false
            LicenseUri               = 'https://choosealicense.com/licenses/mit'
            ProjectUri               = 'https://gitlab.com/phellams/zypline.git'
            IconUri                  = 'https://raw.githubusercontent.com/phellams/phellams-general-resources/main/logos/zypline/dist/png/zypline-logo-128x128.png'
            # CHOCOLATE ---------------------
            LicenseUrl               = 'https://choosealicense.com/licenses/mit'
            ProjectUrl               = 'https://github.com/phellams/zypline'
            IconUrl                  = 'https://raw.githubusercontent.com/phellams/phellams-general-resources/main/logos/zypline/zypline-logo-128x128.png'
            Docsurl                  = 'https://pages.gitlab.io/sgkens/ptoml'
            MailingListUrl           = 'https://github.com/phellams/zypline/issues'
            projectSourceUrl         = 'https://github.com/phellams/zypline'
            bugTrackerUrl            = 'https://github.com/phellams/zypline/issues'
            Summary                  = 'A PowerShell module for advanced file and folder searching with configuration management.'
            # CHOCOLATE ---------------------
            Prerelease               = 'prerelease'

        }        
    }
    RequiredModules    = @()
    RequiredAssemblies = @()
    FormatsToProcess   = @()
    TypesToProcess     = @()
    NestedModules      = @()
    ScriptsToProcess   = @()
}
```


# License

This project is released under the [MIT License](LICENSE)