# REPONAME_PLACE_HOLDER VERSION_AND_PRERELEASE_PLACE_HOLDER

This release provides self-contained Native AOT executables for the configured operating systems and processor architectures.

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

## Native AOT Packages

Each archive contains a self-contained executable and does not require a separately installed .NET runtime.

| Runtime identifier | Archive | SHA-256 |
|---|---|---|
| `linux-x64` | `REPONAME_PLACE_HOLDER-VERSION_AND_PRERELEASE_PLACE_HOLDER-linux-x64.zip` | `NATIVE_LINUX_X64_HASH` |
| `linux-arm64` | `REPONAME_PLACE_HOLDER-VERSION_AND_PRERELEASE_PLACE_HOLDER-linux-arm64.zip` | `NATIVE_LINUX_ARM64_HASH` |
| `win-x64` | `REPONAME_PLACE_HOLDER-VERSION_AND_PRERELEASE_PLACE_HOLDER-win-x64.zip` | `NATIVE_WIN_X64_HASH` |
| `win-arm64` | `REPONAME_PLACE_HOLDER-VERSION_AND_PRERELEASE_PLACE_HOLDER-win-arm64.zip` | `NATIVE_WIN_ARM64_HASH` |
| `osx-x64` | `REPONAME_PLACE_HOLDER-VERSION_AND_PRERELEASE_PLACE_HOLDER-osx-x64.zip` | `NATIVE_OSX_X64_HASH` |
| `osx-arm64` | `REPONAME_PLACE_HOLDER-VERSION_AND_PRERELEASE_PLACE_HOLDER-osx-arm64.zip` | `NATIVE_OSX_ARM64_HASH` |

## Installation

### Linux and macOS

```bash
# Shell: Bash
unzip REPONAME_PLACE_HOLDER-VERSION_AND_PRERELEASE_PLACE_HOLDER-RUNTIME_IDENTIFIER.zip
chmod +x REPONAME_PLACE_HOLDER
./REPONAME_PLACE_HOLDER --version
```

### Windows

```powershell
# Shell: PowerShell 7
Expand-Archive -Path ./REPONAME_PLACE_HOLDER-VERSION_AND_PRERELEASE_PLACE_HOLDER-win-x64.zip -DestinationPath ./REPONAME_PLACE_HOLDER
& ./REPONAME_PLACE_HOLDER/REPONAME_PLACE_HOLDER.exe --version
```

## Integrity Verification

```bash
# Shell: Bash
sha256sum -c REPONAME_PLACE_HOLDER-VERSION_AND_PRERELEASE_PLACE_HOLDER-RUNTIME_IDENTIFIER.zip.sha256
```

```powershell
# Shell: PowerShell 7
Get-FileHash ./REPONAME_PLACE_HOLDER-VERSION_AND_PRERELEASE_PLACE_HOLDER-RUNTIME_IDENTIFIER.zip -Algorithm SHA256
```

## API Reference

| Placeholder | Type | Required | Description |
|---|---|---:|---|
| `REPONAME_PLACE_HOLDER` | String | Yes | Executable and project name. |
| `VERSION_AND_PRERELEASE_PLACE_HOLDER` | SemVer | Yes | Release version, including prerelease label when applicable. |
| `RUNTIME_IDENTIFIER` | .NET RID | Yes | Target operating system and processor architecture. |
| `NATIVE_*_HASH` | SHA-256 | Yes | Lowercase hexadecimal checksum generated from the corresponding archive. |
| `RELEASE_NOTES` | Markdown | Yes | Generated changes for the release. |
