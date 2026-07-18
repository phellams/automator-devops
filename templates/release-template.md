# 🍹REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER

RELEASE_NOTES

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
REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER-psgal.zip SHA256: `⦿` **`PSGAL_ZIP_HASH`** \
REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.tar.gz SHA256: `⦿` **`GENERIC_TARGZ_HASH`**

## `⦿` Package Repositories

Phellams Modules are distributed to **GitLab Packages**, **Chocolatey Packages**, and **PowerShell Gallery** repositories, and as a `tar.gz` for generic use without a package manager.

### 🟦 **PowerShell Gallery**

```powershell
Find-Module -Name REPONAME_PLACE_HOLDER -MinimumVersion ONLY_VERSION_PLACE_HOLDER PRERELEASE_PSGAL_PLACE_HOLDER |
    Install-Module |
        Import-Module
```

### 🟫 **Chocolatey** `WINDOWS ONLY`

```powershell
# fetch choco package
choco install REPONAME_PLACE_HOLDER --version=VERSION_AND_PRERELEASE_PLACE_HOLDER PRERELEASE_CHOCO_PLACE_HOLDER

# default location of downloaded package
# C:\ProgramData\chocolatey\lib\REPONAME_PLACE_HOLDER
# Import module directly from chocolatey package
Import-Module -Name C:\ProgramData\chocolatey\lib\REPONAME_PLACE_HOLDER

# Copy to user profile location
Copy-Item -Path C:\ProgramData\chocolatey\lib\REPONAME_PLACE_HOLDER -Destination $ENV:HOME\Documents\PowerShell\Modules

Import-Module -Name REPONAME_PLACE_HOLDER
```

### 🟧 **GitLab Packages**

#### **NuGet Direct Source Method**

Add the GITGROUP_PLACE_HOLDER_REPONAME_PLACE_HOLDER GitLab project as a NuGet package source, then install the package.

```powershell
# Add nuget source
nuget sources add -name GITGROUP_PLACE_HOLDER_REPONAME_PLACE_HOLDER -source https://gitlab.com/api/v4/projects/CI_PROJECT_ID/packages/nuget/index.json

# A: Install from gitlab package into current directory
nuget install REPONAME_PLACE_HOLDER PRERELEASE_GITLAB_PLACE_HOLDER -version VERSION_AND_PRERELEASE_PLACE_HOLDER -Source GITGROUP_PLACE_HOLDER_REPONAME_PLACE_HOLDER

# B: Install from gitlab package into user profile
nuget install REPONAME_PLACE_HOLDER PRERELEASE_GITLAB_PLACE_HOLDER -Source GITGROUP_PLACE_HOLDER_REPONAME_PLACE_HOLDER -OutputDirectory $ENV:USERPROFILE/documents/powershell
```

#### **NuGet Direct Download Method**

Install the package from GitLab Packages by downloading directly to a specified directory with `nuget`.

```powershell
nuget install REPONAME_PLACE_HOLDER PRERELEASE_GITLAB_PLACE_HOLDER -version VERSION_AND_PRERELEASE_PLACE_HOLDER -source https://gitlab.com/api/v4/projects/CI_PROJECT_ID/packages/nuget/index.json -OutputDirectory $ENV:USERPROFILE/documents/powershell
```

### Import the Module

Common locations for PowerShell modules:
- **Linux**:
  - `$path = $HOME/.nuget/packages`
- **Windows**:
  - `$path = $ENV:USERPROFILE\.nuget\packages`

🟢 ***Import the module***

```powershell
# Windows
Import-Module -Name $path\REPONAME_PLACE_HOLDER

# Linux
Import-Module -Name $path/REPONAME_PLACE_HOLDER
```

## `⦿` Build Artifacts

For all module output variations, you can simply extract the `.zip` files, or rename `.nupkg` files to `.zip`, then extract them using your preferred compression tool (e.g., **ZIP**, **PeaZip**, **7-Zip**, etc.). After extracting, navigate to the module directory (`cd`) and run `Import-Module`. Alternatively, you can use any of the methods mentioned above or below.

Or you can use the individual build artifacts to install the module with your target package manager, i.e.:

- **Chocolatey** (`choco.exe`)
- **GitLab Packages** (`nuget.exe`)
- **PowerShell Gallery** (`Install-Package`)

### ⏬ Nupkg Manual Download and Installation

*Download the build package from the build artifact archive using PowerShell's `Invoke-WebRequest`.*
> You can also use `curl` or `wget` to download the package.

```powershell
# psgal artifact download
Invoke-WebRequest -Uri "https://gitlab.com/GITGROUP_PLACE_HOLDER/REPONAME_PLACE_HOLDER/-/jobs/CI_JOB_ID/artifacts/raw/dist/psgal/REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER-psgal.zip"

# choco artifact download
Invoke-WebRequest -Uri "https://gitlab.com/GITGROUP_PLACE_HOLDER/REPONAME_PLACE_HOLDER/-/jobs/CI_JOB_ID/artifacts/raw/dist/choco/REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER-choco.nupkg"

# nuget artifact download
Invoke-WebRequest -Uri "https://gitlab.com/GITGROUP_PLACE_HOLDER/REPONAME_PLACE_HOLDER/-/jobs/CI_JOB_ID/artifacts/raw/dist/nuget/REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.nupkg"
```

#### 🔸 Using `Install-Package`

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
# Common profile locations:
# - /usr/local/share/powershell/Modules/
# - $HOME/.local/share/powershell/Modules/
Install-Package -Name REPONAME_PLACE_HOLDER `
                -RequiredVersion VERSION_AND_PRERELEASE_PLACE_HOLDER `
                -Source "/path/to/download/REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.nupkg" `
                -Destination "/usr/local/share/powershell/Modules/REPONAME_PLACE_HOLDER" `
                -Force
```
*Install the downloaded package from the build artifact using the `Install-Package` cmdlet.*

### 🔸 Using `nuget.exe`

🚪 `REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.nupkg`

```powershell
Invoke-WebRequest -Uri "https://gitlab.com/GITGROUP_PLACE_HOLDER/REPONAME_PLACE_HOLDER/-/jobs/CI_JOB_ID/artifacts/raw/dist/nuget/REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.nupkg" -OutFile "\path\to\download\REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.nupkg"

# default windows install location
# - %APPDATA%\NuGet\NuGet
nuget install REPONAME_PLACE_HOLDER -Version VERSION_AND_PRERELEASE_PLACE_HOLDER

Copy-Item -Path $ENV:APPDATA\NuGet\NuGet\REPONAME_PLACE_HOLDER -Destination $ENV:USERPROFILE\Documents\PowerShell\Modules

Import-Module -Name REPONAME_PLACE_HOLDER
```

### 🔸 Using `zip` / `7zip` / `pzip` with nupkg

*Install the downloaded package from the build artifact by extracting it to your desired location.*

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

*Install the downloaded package from the build artifact using `choco.exe`.*

🚪 `REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER-choco.nupkg`

```powershell
# Install from chocolatey nupkg file
# Elevated privileges required - install from local source
choco install REPONAME_PLACE_HOLDER --version="VERSION_AND_PRERELEASE_PLACE_HOLDER" --source="/download/path/to/REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.nupkg" PRERELEASE_CHOCO_PLACE_HOLDER

# import the module
Import-Module "C:\ProgramData\chocolatey\lib\REPONAME_PLACE_HOLDER"

# or

Copy-Item -Path "C:\ProgramData\chocolatey\lib\REPONAME_PLACE_HOLDER" -Destination $ENV:USERPROFILE\Documents\PowerShell\Modules\REPONAME_PLACE_HOLDER

# import the module
Import-Module REPONAME_PLACE_HOLDER
```

### 🔸 Using `tar.gz`

*Download and install the generic module package from the build artifacts by extracting it to your desired location.*

🚪 `REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.tar.gz`

```bash
tar -xzvf REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.tar.gz -C /path/to/destination
```