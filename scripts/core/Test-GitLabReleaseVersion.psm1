function Test-GitLabReleaseVersion {
    <#
.SYNOPSIS
Checks if a specific tag (release version) exists for a GitLab repository.

.DESCRIPTION
This function queries the GitLab API to determine if a tag matching the 
specified version is present in the given repository.

.PARAMETER reponame
The full path of the repository, including group/subgroup(s) and project name.
Example: 'gitlab-org/gitlab-runner'

.PARAMETER version
The exact tag name to check for. This is often prefixed with 'v' (e.g., 'v16.10.0').

.PARAMETER gitlabUrl
The base URL for the GitLab instance. Defaults to the public instance.

.EXAMPLE
# Check a public project on gitlab.com
Test-GitLabReleaseVersion -reponame 'gitlab-org/gitlab-runner' -version 'v16.10.0'
# Returns $True if tag 'v16.10.0' exists, $False otherwise.

.EXAMPLE
# Check a self-hosted or private instance (requires Personal Access Token)
$PrivateToken = 'your_personal_access_token'
$Header = @{ 'Private-Token' = $PrivateToken }
Test-GitLabReleaseVersion -reponame 'mygroup/myproject' -version 'v1.0.0' -gitlabUrl 'https://my.private.gitlab.com' -Headers $Header

.NOTES
For private projects or to avoid rate limits, you must provide 
a Personal Access Token using the -Headers parameter.
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$reponame,

        [Parameter(Mandatory = $true)]
        [string]$version,

        [string]$gitlabUrl = 'https://gitlab.com',

        [hashtable]$Headers
    )

    # --- Encode the repository path for the URL ---
    # GitLab requires the project path to be URL-encoded (e.g., replace '/' with '%2F')
    $encodedRepoName = [uri]::EscapeDataString($reponame)

    # --- Construct the API URL ---
    # The API endpoint for a specific tag is: 
    # '/projects/{encoded_path}/repository/releases/{release_name}'
    $url = "$gitlabUrl/api/v4/projects/$encodedRepoName/repository/releases/$version"

    [console]::writeline("Checking URL: $url")

    try {
        # --- Query the GitLab API ---
        # The API returns a 200 OK status if the tag exists.
        # It returns a 404 Not Found if the tag does not exist.
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers $Headers -ErrorAction Stop

        # If Invoke-RestMethod completes without error, the tag exists.
        [console]::writeline("Release found: $($response.name)")
        return $true

    }
    catch {
        # --- Handle API Errors ---
        # A 404 error is the expected error when the tag is NOT found.
        if ($_.Exception.Response.StatusCode -eq 404) {
            [console]::writeline("Release not found: $version in $reponame")
            return $false
        }
        
        # Handle other critical errors (e.g., 401 Unauthorized, 403 Forbidden/Rate Limit)
        Write-Error "An error occurred while checking the release for $reponame. Status Code: $($_.Exception.Response.StatusCode). Message: $($_.Exception.Message)"
        return $false 
    }
}

<#
## Example Usage

```powershell
# 1. Check for a known existing tag on the public GitLab
$exists_1610 = Test-GitLabReleaseVersion -reponame 'gitlab-org/gitlab-runner' -version 'v16.10.0'
Write-Host "GitLab Runner v16.10.0 exists: $exists_1610"

# 2. Check for a version that likely doesn't exist
$exists_999 = Test-GitLabReleaseVersion -reponame 'gitlab-org/gitlab' -version 'v99.9.9'
Write-Host "GitLab v99.9.9 exists: $exists_999"

#>