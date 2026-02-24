# Automator Devops

Devops template used to build and publish modules to the PowerShell Gallery, choco, gitlab packages and publish release via gitlab, paried with the [phellams-automator](https://hub.docker.com/r/sgkens/automator) docker image and [GitLab WorkFlow Template](https://gitlab.com/phellams/phellams-automator/-/blob/master/.gitlab-ci-template.yml)

## Dependancies for the Devops template

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

## Quick Start

1. Edit the `./automator/devops/templates/build_config-template.json` file for the module you want to build
2. Edit the `./automator/devops/templates/modulename.psd1` file for the module you want to build
3. Run `pwsh ./automator/devops/scripts/local-build.ps1 -Automator -build -phwriter`

## Scripts

Scripts are located in th `./automator/devops/scripts/` directory

  - Test scripts are located in the `./automator/devops/scripts/test/` directory.
  - Build scripts are located in the `./automator/devops/scripts/build/` directory.
  - Release scripts are located in the `./automator/devops/scripts/publish/` directory.
  - Deploy scripts are located in the `./automator/devops/scripts/deploy/` directory.
  - Tools scripts are located in the `./automator/devops/scripts/tools/` directory.

## Local builder

The local build script `./automator/devops/scripts/local-build.ps1` can be used to build the module locally, the script will build module to `./dist/` directory. 

‼️ **Dependancies:**

| Parameter | Description |
|---|---|
| **`-Automator`** | Build using [phellams-automator](https://gitlab.com/phellams/phellams-automator) docker image, if not script will look for powershell locally dependancies must be met see below: **Dependecies Modules(linux/Winx64)**, **Dependecies Binaries(linux/Winx64)** |
| **`-build_dotnet_lib`** | Calls `build-dotnet-library.ps1` which calls `dotnet build` and `donet Pack` commands to release and or pack .nupkg of libs (WIP(works but needs ironing out some bugs)) |
| **`-PhWriter`** | Generates the `phwriter-metadata.ps1` file using [phwriter](https://gitlab.com/phellams/phwriter) module |
| **`-Pester`** | Calls `test-pester-before-build.ps1` witch calls `Invoke-Pester` from [Pester](https://github.com/pester/Pester) module |
| **`-Sa`** | Calls `test-sa-before-build.ps1` witch calls `Invoke-ScriptAnalyzer` from [ScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer) module |
| **`-Build`** | Calls `build-module.ps1` from [psmpacker](https://gitlab.com/phellams/psmpacker) module, copies the module to the `dist` folder and generates the `VERIFICATION.txt` file. |
| **`-Nuget`** | Calls `build-package-generic-nuget.ps1` witch calls `New-NuspecPackageFile` and `New-NupkgPackage` from [nupsforge](https://gitlab.com/phellams/nupsforge) module.
| **`-PsGal`** | Calls `build-package-psgallery.ps1` witch calls `New-NuspecPackageFile` from [nupsforge](https://gitlab.com/phellams/nupsforge) module for psgal consumption |
| **`-ChocoNuSpec`** | Calls `build-nuspec-choco.ps1` witch calls `New-ChocoNuspecfile` from [nupsforge](https://gitlab.com/phellams/nupsforge) module. |
| **`-ChocoPackage`** (DOCKER-ONLY) | Calls `build-package-choco.sh` which can only be run on linux, calls `Choco Pack` and `Choco Push` from `choco\choco:latest` docker image. |
| **`-ChocoPackageWindows`** (WINDOWS-ONLY) | Calls `build-package-choco-windows` witch calls `New-ChocoNuspecfile` and `New-ChocoPackage` from [nupsforge](https://gitlab.com/phellams/nupsforge) module. **Requires Chocolatey** |

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

## **Build Config**

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

## 🟢 Powershell Module Manifest Template



## RoadMap:

- [ ] Complete donet library build for library, AOT and non-AOT, CLI TUI apps
  - [ ] Add `Build-CjProj` from powershell profile to automator devops scripts - Generates `cjproj` files for dotnet library from template AOT Compliant Configuration, with `IsPackable` set to `true` and `IsExe` set to `false`.
  - [ ] Add `Build-CjProjExe` from powershell profile to automator devops scripts - Generates `cjproj` files for dotnet library from template AOT Compliant Configuration, with `IsPackable` set to `true` and `IsExe` set to `true`.
- Set default library type for donet to `library`, create a seperate scripts and seperate template for `exe` and `library` donet projects.


# License

This project is released under the [MIT License](LICENSE)