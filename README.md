# Automator Devops

Devops template used to build and publish modules to the PowerShell Gallery, choco, gitlab packages and publish release via gitlab, paried with the [phellams-automator](https://hub.docker.com/r/sgkens/automator) docker image and [GitLab WorkFlow Template](https://gitlab.com/phellams/phellams-automator/-/blob/master/.gitlab-ci-template.yml)

## ⚜️ Dependancies for the Devops template

- **Gitlab** - [https://gitlab.com/](https://gitlab.com/)
- **Gitlab-Runner** - Gitlab Runner configured to run docker and shell scripts 
- **Phellams Automator Docker Image** - [https://hub.docker.com/r/sgkens/phellams-automator](https://hub.docker.com/r/sgkens/phellams-automator)
- **choco docker image** - [https://github.com/chocolatey/choco-docker](https://github.com/chocolatey/choco-docker)
- **build_config.json** - Build config json file for the module in the root of the repo.
  - **Template**: `./automator/devops/templates/build_config-template.json`
- **module_name.psd1** - Module manifest with populated meta data
  - **Template**: `./automator/devops/templates/modulename.psd1`
  - for choco extra meta data see [https://chocolatey.org/docs/metadata](https://chocolatey.org/docs/metadata) and see template file example below
- **phwriter-metadata.ps1** - phwriter metadata file for the module [https://github.com/phellams/phwriter](https://github.com/phellams/phwriter), placed in the root directory of the module
  - PHWriter is used to generate and output formatted help text for the module mimicking the style of linux cli man pages.
- **gitlab-ci.yml** - gitlab workflow config yaml file.
  - **Template**: `./automator/devops/templates/.gitlab-ci.yml`

>❗ Note: before pushing and merging make sure to generate the semver using  `Get-GitAutoVersion` from `./automator/devops/scripts/core/Get-GitAutoVersion.psm1` and update the `modulename.psd1` with the `Major.Minor.Patch` version and the `Prerelease` version as the artifact, tags, and releases are affected by the `version` in the `modulename.psd1`, dist output are automatically updated with the `version` in the `modulename.psd1` but some scripts still pull from root `modulename.psd1`

## ⚙️ Quick Start

## ⚜️ Scripts

Scripts are located in th `./automator/devops/scripts/` directory

  - Test scripts are located in the `./automator/devops/scripts/test/` directory.
  - Build scripts are located in the `./automator/devops/scripts/build/` directory.
  - Release scripts are located in the `./automator/devops/scripts/publish/` directory.
  - Deploy scripts are located in the `./automator/devops/scripts/deploy/` directory.
  - Tools scripts are located in the `./automator/devops/scripts/tools/` directory.

## ⚜️ Local builder

The local build script `./automator/devops/scripts/local-build.ps1` can be used to build the module locally, the script will build module to `./dist/` directory. 

‼️ **Dependancies:**

*Script Parameters:*
  - `-Automator` - initates script `./automator-devops_backup/localbuild.ps1`
    - 🔴 Requires Linux with docker or WLS@2 with docker, runs the scripts in the [phellams-automator](https://hub.docker.com/r/sgkens/automator) docker image
  - `-build` - initates script `./automator/devops/scripts/build/Build-Module.ps1`
    - Uses **PSMPacker** to build module to `./dist/modulename` directory [https://github.com/phellams/psmpacker](https://github.com/phellams/psmpacker)
  - `-psgal` - initates script `./automator/devops/scripts/build/build-package-psgallery.ps1`
    - Uses **NupsForge** to build `nupkg` package to `./dist/psgal` directory [https://github.com/phellams/nupsforge](https://github.com/phellams/nupsforge)
  - `-nupkg` - initates script `./automator/devops/scripts/build/build-package-generic-nuget.ps1`
    - Uses ***NupsForge** to build `nupkg` package to `./dist/nuget` directory
  - `-choconuspec` - initates script `./automator/devops/scripts/build/Build-nuspec-choco.ps1`
    - Creates only the **Choco** `.nuspec` file to `./dist/modulename` directory, choco image in linux must be build with the choco docker image, see [https://github.com/chocolatey/choco](https://github.com/chocolatey/choco) or [https://hub.docker.com/r/chocolatey/chocolatey](https://hub.docker.com/r/chocolatey/chocolatey)
  - `-choconupkgwindows` - initates script `./automator/devops/scripts/wip/build-package-choco-windows.ps1`
    - 🔴 Requires Windows with Choco installed, uses ***NupsForge** to build choco `nupkg`
  - `-phwriter` - initates script `./automator/devops/scripts/build/generate-phwriter-metadata.ps1`
    - Uses ***PHWriter** to generate formatted help text for the module and output to `./libs/help_metadata` directory before build copy

### Examples

🟪 Build module locally

> ❗ The `-Automator` switch will run the scripts in the [phellams-automator](https://hub.docker.com/r/sgkens/automator) docker image, requires docker in linux or docker in wsl in windows
> ❗ if `.\phwriter-metadata.ps1` file is not found script will skip. 

```powershell
pwsh ./automator/devops/scripts/local-build.ps1 -build -phwriter
```

🟪 Build `.nupkg` package locally compatable with **Powershell Gallery**, **GitLab Packages** and **Proget PsGallery**

```powershell
pwsh ./automator/devops/scripts/local-build.ps1 -build -nupkg -phwriter
```

🟪 Build Choco `.nupkg` package locally

```powershell
pwsh ./automator/devops/scripts/local-build.ps1 -build -choconupkgwindows -phwriter
```

🟪 Build Choco `.nupkg`  package locally in linux using the choco docker image.

```powershell
pwsh ./automator/devops/scripts/local-build.ps1 -build -phwriter -choconuspec -ChocoPackage
```

## 🟢 Build Config Json Template

**Example**:

```json
{
    "modulename": "modulename",
    "releasetype": "public",
    "gituser": "user",
    "gitgroup": "group",
    "gitlabid_public": "id",
    "license": "MIT",
    "iconurl": "logo url",
    "phwriter": true,
    "phwriter_source": "url",
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

## 🟢 Pester Unit Test File

Template look for a test file in the root module directory named `test-unit-pester.ps1` in the `./test/` directory.

## 🟢 PHWriter Template file

Template looks for a metadata file in the root module directory named `phwriter-metadata.ps1`.

> ❗ Note: You can use the automated script to generate the file:

 ```powershell
 ./automator-devops/scripts/tools/Generate-PhwriterMetadata.ps1
 ``` 
 or by using: 
 
 ```powershell
 ./automator-devops/local-build.ps1 -build -phwriter
 ```

**Example**:

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

**Example**:

```powershell
@{
    RootModule         = 'modulename.psm1'
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