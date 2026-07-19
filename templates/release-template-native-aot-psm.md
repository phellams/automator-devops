# REPONAME_PLACE_HOLDER VERSION_AND_PRERELEASE_PLACE_HOLDER

This release provides a PowerShell module, a managed .NET package, and self-contained Native AOT executables from one source version.

RELEASE_NOTES

## Build Information

| Field | Value |
|---|---|
| Project | `REPONAME_PLACE_HOLDER` |
| Project ID | `CI_PROJECT_ID` |
| Pipeline ID | `CI_PIPELINE_ID` |
| Pipeline URL | `CI_PIPELINE_URL` |
| Build date | `BUILD_DATE` |
| Commit | `COMMIT_SHA` |
| Version | `VERSION_AND_PRERELEASE_PLACE_HOLDER` |

## PowerShell Module

| Package | SHA-256 |
|---|---|
| `REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER.nupkg` | `NUGET_NUPKG_HASH` |
| `REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER-psgal.zip` | `PSGAL_ZIP_HASH` |
| `REPONAME_PLACE_HOLDER.VERSION_AND_PRERELEASE_PLACE_HOLDER-choco.nupkg` | `CHOCO_NUPKG_HASH` |

```powershell
# Shell: PowerShell 7
Install-Module -Name REPONAME_PLACE_HOLDER -RequiredVersion ONLY_VERSION_PLACE_HOLDER PRERELEASE_PSGAL_PLACE_HOLDER
Import-Module REPONAME_PLACE_HOLDER
```

## Managed .NET Package

| Package | SHA-256 |
|---|---|
| `DOTNET_PACKAGE_ID.VERSION_AND_PRERELEASE_PLACE_HOLDER.nupkg` | `DOTNET_NUPKG_HASH` |

```bash
# Shell: Bash or PowerShell
dotnet add package DOTNET_PACKAGE_ID --version VERSION_AND_PRERELEASE_PLACE_HOLDER
```

## Native AOT Packages

The Native AOT archives are self-contained and do not require a separately installed .NET runtime.

| Runtime identifier | Archive | SHA-256 |
|---|---|---|
| `linux-x64` | `NATIVE_ARTIFACT_NAME-VERSION_AND_PRERELEASE_PLACE_HOLDER-linux-x64.zip` | `NATIVE_LINUX_X64_HASH` |
| `linux-arm64` | `NATIVE_ARTIFACT_NAME-VERSION_AND_PRERELEASE_PLACE_HOLDER-linux-arm64.zip` | `NATIVE_LINUX_ARM64_HASH` |
| `win-x64` | `NATIVE_ARTIFACT_NAME-VERSION_AND_PRERELEASE_PLACE_HOLDER-win-x64.zip` | `NATIVE_WIN_X64_HASH` |
| `win-arm64` | `NATIVE_ARTIFACT_NAME-VERSION_AND_PRERELEASE_PLACE_HOLDER-win-arm64.zip` | `NATIVE_WIN_ARM64_HASH` |
| `osx-x64` | `NATIVE_ARTIFACT_NAME-VERSION_AND_PRERELEASE_PLACE_HOLDER-osx-x64.zip` | `NATIVE_OSX_X64_HASH` |
| `osx-arm64` | `NATIVE_ARTIFACT_NAME-VERSION_AND_PRERELEASE_PLACE_HOLDER-osx-arm64.zip` | `NATIVE_OSX_ARM64_HASH` |

```bash
# Shell: Bash
unzip NATIVE_ARTIFACT_NAME-VERSION_AND_PRERELEASE_PLACE_HOLDER-RUNTIME_IDENTIFIER.zip
chmod +x NATIVE_ARTIFACT_NAME
./NATIVE_ARTIFACT_NAME --version
```

## API Reference

| Placeholder | Type | Required | Description |
|---|---|---:|---|
| `REPONAME_PLACE_HOLDER` | String | Yes | PowerShell module and repository name. |
| `DOTNET_PACKAGE_ID` | String | Yes | Managed NuGet package identifier. |
| `NATIVE_ARTIFACT_NAME` | String | Yes | Native executable and archive prefix. |
| `VERSION_AND_PRERELEASE_PLACE_HOLDER` | SemVer | Yes | Shared release version. |
| `ONLY_VERSION_PLACE_HOLDER` | Version | Yes | Stable numeric module version without prerelease metadata. |
| `PRERELEASE_PSGAL_PLACE_HOLDER` | String | No | PowerShell Gallery prerelease argument. |
| `*_HASH` | SHA-256 | Yes | Checksum for the named package or archive. |
| `RELEASE_NOTES` | Markdown | Yes | Generated changes for the release. |
