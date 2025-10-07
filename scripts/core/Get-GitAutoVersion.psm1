using namespace System.Text.RegularExpressions
<#
.SYNOPSIS
Generates and return SemVer Version number and return it as a Pscustomobject

.DESCRIPTION
Generates and return SemVer Version number and return it as a Pscustomobject

.EXAMPLE
Get-GitAutoVersion | Select Version
(Get-GitAutoVersion).Version

.INPUTS
- Type
- Name

.OUTPUTS
[PsCustomObject]

.NOTES
- 

.LINK
#>
Function Get-GitAutoVersion {
    [CmdletBinding()]
    [OutputType([Pscustomobject])]
    param ()
    process {
        [int]$major =  0
        [int]$minor =  1
        [int]$patch =  0

        try {
            # Check for git installation
            if ($null -eq (Get-Command git -ErrorAction SilentlyContinue)) {
                throw "Git is not installed, please install git and try again"
            }
            else {
                $gitCommits = git log --pretty=format:"%s%n%b"

                for($l=$gitcommits.count -1; $l -gt 0; $l--) {
                    if ([regex]::Matches($gitCommits[$l], "Build: major", [RegexOptions]::IgnoreCase)) {
                        $major++
                        $patch = 0
                        $minor = 0
                    }
                    if ([regex]::Matches($gitCommits[$l], "Build: minor", [RegexOptions]::IgnoreCase)) {
                        $minor++
                        $patch = 0
                    }
                    if ([regex]::Matches($gitCommits[$l], "Build: patch", [RegexOptions]::IgnoreCase)) {
                        $patch++
                    }
                }
                return [PSCustomObject]@{ 
                    Version="$major.$minor.$patch";
                    ParsedLines = "$($gitCommits.count.tostring())" 
                }
            }
        }
        catch [System.Exception] {
            Write-Host "An error occurred while creating AutoVersion Number: $($_.Exception.Message)"
            # You can handle the exception here or rethrow it if needed
        }
    }
}

Export-ModuleMember -Function Get-GitAutoVersion
