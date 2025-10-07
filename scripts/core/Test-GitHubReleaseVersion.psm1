function Test-GitHubReleaseVersion {
    <#
.SYNOPSIS
Checks if a specific release version exists for a GitHub repository.

.DESCRIPTION
This function queries the GitHub API to determine if a release with the exact tag 
matching the specified version is present in the given repository.

.PARAMETER reponame
The owner and repository name, in the format 'owner/repo'.
Example: 'PowerShell/PowerShell'

.PARAMETER version
The exact release tag to check for.
Example: 'v7.4.1'

.EXAMPLE
Test-GitHubReleaseVersion -reponame 'Microsoft/vscode' -version '1.92.0'
# Returns $True if release '1.92.0' exists for 'Microsoft/vscode', $False otherwise.

.EXAMPLE
$IsPresent = Test-GitHubReleaseVersion -reponame 'myuser/myproject' -version 'v1.0.0-beta'
if ($IsPresent) {
    Write-Host "Release v1.0.0-beta is available."
}

.NOTES
Requires internet access to query the GitHub API. 
Authentication (e.g., Personal Access Token) may be needed for private repositories 
or to avoid API rate limits; this example does not include authentication headers.
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$reponame,

        [Parameter(Mandatory = $true)]
        [string]$version
    )

    # --- Construct the API URL ---
    # The API endpoint for a specific release uses the format: 
    # 'repos/{owner}/{repo}/releases/tags/{tag}'
    $url = "https://api.github.com/repos/$reponame/releases/tags/$version"

    Write-Verbose "Checking URL: $url"

    try {
        # --- Query the GitHub API ---
        # The API returns a 200 OK status and the release object if the release exists.
        # It returns a 404 Not Found if the release (tag) does not exist.
        $response = Invoke-RestMethod -Uri $url -Method Get -ErrorAction Stop

        # If Invoke-RestMethod completes without error, the release exists.
        Write-Verbose "Release found: $($response.tag_name)"
        return $true

    }
    catch {
        # --- Handle API Errors ---
        # A 404 error is the expected error when the release is NOT found.
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Verbose "Release $version not found for $reponame."
            return $false
        }
        
        # Handle other errors (e.g., network issues, rate limiting, bad repo name)
        Write-Error "An error occurred while checking the release for $reponame. Status Code: $($_.Exception.Response.StatusCode)."
        # You might choose to return $false or rethrow the error here based on requirements.
        return $false 
    }
}

<#
# --- Example Usage ---
# To use, dot-source the script: '. .\yourscriptname.ps1'
# Then call the function:

# 1. Check for a known existing release
$exists_741 = Test-GitHubReleaseVersion -reponame 'PowerShell/PowerShell' -version 'v7.4.1'
Write-Host "PowerShell v7.4.1 exists: $exists_741"

# 2. Check for a version that likely doesn't exist
$exists_999 = Test-GitHubReleaseVersion -reponame 'PowerShell/PowerShell' -version 'v99.9.9'
Write-Host "PowerShell v99.9.9 exists: $exists_999"
#>