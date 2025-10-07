# 🍹REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER


### **░░░░▌ Build Information ▐░░░░**

||||
|-|-|-|
|🏷️ | Project Name |`⬡` **REPONAME_PLACE_HOLDER**|
|🆔 | Project ID |`⬡` **CI_PROJECT_ID** |
|📐 | Pipeline ID |`⬡` **CI_PIPELINE_ID** |
|🅱️ | Pipeline URL |`⬡` **CI_PIPELINE_URL** |
|🗓️ | Build Date |`⬡` **BUILD_DATE** |
|🔑 | Commit SHA |`⬡` **COMMIT_SHA** |


### **░░░░▌ SHA256 Checksums ▐░░░░**

REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.nupkg SHA256: `⦿` **`NUGET_NUPKG_HASH`** \
REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER-choco.nupkg SHA256: `⦿` **`CHOCO_NUPKG_HASH`** \
REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER-psgal.zip SHA256: `⦿` **`PSGAL_ZIP_HASH`**

## `⦿` Package Repositories 

Phellams Modules are distributed to **GitLab Packages**, **Chocolatey Packages**, and **Powershell Gallery** repositories.

### 🟦 **Powershell Gallery**

```powershell 
Find-Module -Name REPONAME_PLACE_HOLDER -MinimumVersion ONLY_VERSION_PLACE_HOLDER PRERELEASE_PSGAL_PLACE_HOLDER | 
    Install-module | 
        Import-Module
```
### 🟫 **Chocolatey** `WINDOWS ONLY`

```powershell
# fetch choco package
choco install REPONAME_PLACE_HOLDER --version=VERSION_AND_PRERELEASE_PLACE_HOLDER PRERELEASE_CHOCO_PLACE_HOLDER

# default location of downloaded package
# C:\ProgramData\chocolatey\lib\REPONAME_PLACE_HOLDER
# Import module directly from chocolatey package
import-module -name C:\ProgramData\chocolatey\lib\REPONAME_PLACE_HOLDER

# Copy to user profile location
Copy-Item -Path C:\ProgramData\chocolatey\lib\REPONAME_PLACE_HOLDER -Destination $ENV:HOME\Documents\PowerShell\Modules

Import-Module -Name REPONAME_PLACE_HOLDER
```

### 🟧 **Gitlab Packages**

#### **Nuget direct Sources Method**

Use the nuget sources to add the GROUPNAME_PLACEHOLDER_REPONAME_PLACE_HOLDER as a package source and install the package.

```powershell
# Add nuget source
nuget sources add -name GITGROUP_PLACE_HOLDER_REPONAME_PLACE_HOLDER -source https://gitlab.com/api/v4/projects/CI_PROJECT_ID/packages/nuget/index.json

# A: Install from gitlab package into current directory
nuget install REPONAME_PLACE_HOLDER PRERELEASE_GITLAB_PLACE_HOLDER -version VERSION_AND_PRERELEASE_PLACE_HOLDER -Source GITGROUP_PLACE_HOLDER_REPONAME_PLACE_HOLDER

# B: Install from gitlab package into user profile
nuget install REPONAME_PLACE_HOLDER PRERELEASE_GITLAB_PLACE_HOLDER -Source gitlab-fastfsc PRERELEASE_GITLAB_PLACE_HOLDER -OutputDirectory $ENV:USERPROFILE/documents/powershell
```

#### **Nuget direct download method**

Install the package from gitlab packages by using the `nuget` download and install direct to specified directory.

```powershell
nuget install REPONAME_PLACE_HOLDER PRERELEASE_GITLAB_PLACE_HOLDER -version VERSION_AND_PRERELEASE_PLACE_HOLDER -source https://gitlab.com/api/v4/projects/CI_PROJECT_ID/packages/nuget/index.json -OutputDirectory $ENV:USERPROFILE/documents/powershell
```

### Import the module

Common locations for PowerShell modules:
 -  **linux**:
    - `$path = $ENV:USERPROFILE/.nuget/packages`
    - `$path = $home/.nuget/packages`
 - **Windows**
    - `$path = $ENV:USERPROFILE\.nuget\packages`

🟢 ***Import the module***

```powershell
# Windows
import-module -name $path\REPONAME_PLACE_HOLDER

# Linux
import-module -name $path/REPONAME_PLACE_HOLDER
```


## `⦿` Build Artifactes

For all module output variations, you can simply extract the `.zip` files, or rename `.nupkg` files to `.zip`, then extract them using your preferred compression tool (e.g., **ZIP**, **PeaZip**, **7-Zip**, etc.). After extracting, navigate to the module directory (`cd`) and run Import-Module. Alternatively, you can use any of the methods mentioned above or below.

Or you can use the individual build artifacts to install the module, using the target package manager ie:  

- **chocolatey(`Choco.exe`)**
- **Gitlab Packages(`Nuget.exe`)**
- **powershell gallery(`Install-Package`)**
- **gitlab packages(`Nuget.exe`)**

### ⏬ Nupkg's Manual Download and Installation

*Download the build package from the build artifact archive using powershell `Invoke-WebRequest`*
> You can also use `curl` or `wget` to download the packaage.

```powershell
# psgal artifact download
Invoke-WebRequest -url "https://gitlab.com/GITGROUP_PLACE_HOLDER/REPONAME_PLACE_HOLDER/-/jobs/CI_JOB_ID/artifacts/raw/dist/psgal/REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER-psgal.zip"

# choco artifact download
Invoke-WebRequest -url "https://gitlab.com/GITGROUP_PLACE_HOLDER/REPONAME_PLACE_HOLDER/-/jobs/CI_JOB_ID/artifacts/raw/dist/choco/REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER-choco.nupkg"

# nuget artifact download
Invoke-WebRequest -url "https://gitlab.com/GITGROUP_PLACE_HOLDER/REPONAME_PLACE_HOLDER/-/jobs/CI_JOB_ID/artifacts/raw/dist/nuget/REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.nupkg"
```

#### 🔸 Using `Install-Package` cmdlet

```powershell
# WINDOWS
Install-Package -Name REPONAME_PLACE_HOLDER `
                -RequiredVersion VERSION_AND_PRERELEASE_PLACE_HOLDER `
                -Source "\path\to\download\REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.nupkg" `
                -Destination "$ENV:USERPROFILE\Documents\PowerShell\Modules\REPONAME_PLACE_HOLDER" `
                -Force

# Import module into powershell session
Import-Module -Name REPONAME_PLACE_HOLDER

# LINUX
# Comming profile locations:
# - /usr/local/share/powershell/Modules/
# - $HOME/.local/share/powershell/Modules/
Install-Package -Name REPONAME_PLACE_HOLDER `
                -RequiredVersion VERSION_AND_PRERELEASE_PLACE_HOLDER `
                -Source "\path\to\download\REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.nupkg" `
                -Destination "/usr/local/share/powershell/Modules/REPONAME_PLACE_HOLDER" `
                -Force
``` 
*Install the downloaded package from the build artifact by using the `Install-Package` cmdlet*

### 🔸 Using `nuget.exe` 

🚪 `REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.nupkg`

```powershell
Invoke-WebRequest -url "https://gitlab.com/GITGROUP_PLACE_HOLDER/REPONAME_PLACE_HOLDER/-/jobs/CI_JOB_ID/artifacts/raw/dist/nuget/REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.nupkg" -OutFile "\path\to\download\REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.nupkg"

# default windows install location
# - %APPDATA%\NuGet\NuGet
nuget install REPONAME_PLACE_HOLDER -Version VERSION_AND_PRERELEASE_PLACE_HOLDER

Copy-Item -Path $ENV:APPDATA\NuGet\NuGet\REPONAME_PLACE_HOLDER -Destination $ENV:USERPROFILE\Documents\PowerShell\Modules

Import-Module -Name REPONAME_PLACE_HOLDER
```


### 🔸 Using `zip`|`7zp`|`pzip` exe

*Install the downloaded package from the build artifact by extracting it to your desired location*

🚪 `REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER-psgal.zip`

```powershell
# Zip
Expand-Archive -Path ".\REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.nupkg" `
               -DestinationPath "$ENV:USERPROFILE\Documents\PowerShell\Modules\REPONAME_PLACE_HOLDER"

# 7zip
7z.exe e ".\REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.nupkg" -o$ENV:USERPROFILE\Documents\PowerShell\Modules\REPONAME_PLACE_HOLDER

# Import the module
Import-Module REPONAME_PLACE_HOLDER
```

### 🔸 Using Choco

*Install the downloaded package from the build artifact by using choco.exe*

🚪 `REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER-choco.nupkg`

```powershell
# Install from chocolatey nupkg file
# Elevated privileges required - install froms local source
# -
choco install REPONAME_PLACE_HOLDER --version="VERSION_AND_PRERELEASE_PLACE_HOLDER" --source="/download/path/to/REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.nupkg" PRERELEASE_CHOCO_PLACE_HOLDER

# import the module
Import-Module "C:\ProgramData\chocolatey\lib\REPONAME_PLACE_HOLDER"

# or

Copy-Item -Path "C:\ProgramData\chocolatey\lib\REPONAME_PLACE_HOLDER" -Destination $ENV:USERPROFILE\Documents\PowerShell\Modules\REPONAME_PLACE_HOLDER

# import the module
Import-Module REPONAME_PLACE_HOLDER
```