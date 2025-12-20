using module Remove-Emojis.psm1

<#
    .SYNOPSIS 
    Get Release Notes from git log based on branch, head and commit message body, cmdlet supports a release notes based on commit message,
    commit message body, commit message notes, commit message feature additions, commit message feature updates, commit message breaking changes.
    
    Also supports a commit link prefix for each commit message category with the commit link prefix being set to github, gitlab, gitea, or custom.

    .DESCRIPTION
    Get Release Notes from git log based on branch, head and commit message body, cmdlet supports a release notes based on commit message,
    commit message body, commit message notes, commit message feature additions, commit message feature updates, commit message breaking changes.

    .PARAMETER Notes
    Set to true to include commit message that are contained in 'Notes:'.

    .PARAMETER FeaturesNotes
    Set to true to include commit message that are contained in 'Features Notes:'.

    .PARAMETER BreakingChanges
    Set to true to include commit message that are contained in 'Breaking Changes:'.

    .PARAMETER FeatureAdditions
    Set to true to include commit message that are contained in 'Feature Additions:'.

    .PARAMETER FeatureUpdates
    Set to true to include commit message that are contained in 'Feature Updates:'.

    .PARAMETER CommitLink
    Set to true to include commit links in the release notes.

    .PARAMETER CommitLinkPrefix
    Set to github, gitlab, gitea, or custom to include commit links in the release notes.

    .PARAMETER CustomPrefix
    Set to a custom prefix for the commit link.

    .PARAMETER NameSpace
    Set to true to include the namespace in the commit link.

    .PARAMETER AsObject
    Set to true to return the release notes as an object.

    .EXAMPLE
    Get-ReleaseNotes

    .EXAMPLE
    Get-ReleaseNotes -Notes -FeaturesNotes -BreakingChanges -FeatureAdditions

    .EXAMPLE

    Get-ReleaseNotes -Notes -FeaturesNotes -BreakingChanges -FeatureAdditions -CommitLink -CommitLinkPrefix github

    .EXAMPLE

    Get-ReleaseNotes -Notes -FeaturesNotes -BreakingChanges -FeatureAdditions -CommitLink -CommitLinkPrefix gitlab

    .EXAMPLE

    Get-ReleaseNotes -Notes -FeaturesNotes -BreakingChanges -FeatureAdditions -CommitLink -CommitLinkPrefix gitea

    .EXAMPLE

    Get-ReleaseNotes -Notes -FeaturesNotes -BreakingChanges -FeatureAdditions -CommitLink -CommitLinkPrefix custom -CustomPrefix example.com

    .EXAMPLE

    Get-ReleaseNotes -Notes -FeaturesNotes -BreakingChanges -FeatureAdditions -AsObject -Debug
#>
function Get-ReleaseNotes {
    [CmdletBinding()]
    [Alias("grn")]
    param (
        [Parameter(Mandatory = $false)]
        [switch]$Notes,
        [Parameter(Mandatory = $false)]
        [switch]$FeatureNotes,
        [Parameter(Mandatory = $false)]
        [switch]$BreakingChanges,
        [Parameter(Mandatory = $false)]
        [switch]$FeatureAdditions,
        [Parameter(Mandatory = $false)]
        [switch]$FeatureUpdates,
        [Parameter(Mandatory = $false)]
        [switch]$CommitLink,
        [Parameter(Mandatory = $false)]
        [validateset("github", "gitlab", "gitea", "custom")]
        [string]$CommitLinkPrefix,
        [Parameter(Mandatory = $false)]
        [string]$CustomPrefix,
        [Parameter(Mandatory = $false)]
        [string]$NameSpace,
        [Parameter(Mandatory = $false)]
        [switch]$AsObject,
        [Parameter(Mandatory = $false)]
        [switch]$OnlyMessageHead,
        [Parameter(Mandatory = $false)]
        [switch]$AheadOnly,
        [Parameter(Mandatory = $false)]
        [string]$MainBranch
    )
    begin {

        [hashtable]$categories = @{}
        $categories['Notes:'] = @{ entry = @(); strippedLine = ''; commitid = '' }
        $categories['Feature Additions:'] = @{ entry = @(); strippedLine = ''; commitid = '' }
        $categories['Feature Notes:'] = @{ entry = @(); strippedLine = ''; commitid = '' }
        $categories['Feature Updates:'] = @{ entry = @(); strippedLine = ''; commitid = '' }
        $categories['Breaking Changes:'] = @{ entry = @(); strippedLine = ''; commitid = '' }

        # Function to generate commit link: Internal function
        function generate_commit_link([string]$commitid) {
            if ($CommitLinkPrefix -eq "github") { $CommitLinkPrefix = "github.com" }
            elseif ($CommitLinkPrefix -eq "gitlab") { $CommitLinkPrefix = "gitlab.com" }
            elseif ($CommitLinkPrefix -eq "custom") { $CommitLinkPrefix = $CustomPrefix }
            else { $CommitLinkPrefix = "github.com" }
            $repoName = (Get-ItemProperty -Path ".\").Name
            $commitid_small = $commitid.Substring(0, 15)
            $commitLinkUrl = "https://$($CommitLinkPrefix)/$($namespace)/$($RepoName)/-/commit/$($current_commit)"
            $link = "[$commitid_small]($commitLinkUrl)"
            return $link
        }

        if(!$MainBranch){
            $MainBranch = "main"
        }

    }
    process {
        # Get the current branch name
        $currentBranch = git rev-parse --abbrev-ref HEAD

        # Fetch the git log for the current branch, including the full commit body
        # if OnlyMessage is true, fetch only the commit messages not the full commit body and
        # return as an array and exit
        if ($OnlyMessageHead) {
            $commitArray = @()
            $gitlab = $null
            if($AheadOnly){
                $gitLog = git log origin/$MainBranch.. --pretty=format:"%s"
            }else{
                $gitLog = git log $currentBranch --pretty=format:"%s"
            }
            foreach ($line in $gitLog) {
                $line = $line.Trim()
                # control mardown new dot points with correct spacing
                $commitArray += " - $line"
            }
            return $commitArray
        }
        else {
            if ($AheadOnly) {
                $gitLog = git log origin/$MainBranch.. --pretty=format:"%H%n%B" 
            }
            else {
                $gitLog = git log $currentBranch --pretty=format:"%H%n%B" 
            }

            # if branch is not main or master, get git log from brain main/master
            if ($currentBranch -ne "main" -or $currentBranch -ne "master") {
                $gitLogMM = git log origin/main --pretty=format:"%H"
                $lastCommitFromMain = ($gitLogMM -split "`n")
            }
            # Debugging: Print the fetched git log to verify its content
            Write-debug "Git Log Contents:`n$gitLog`n"

            # Split the log into lines and process each line
            [string]$currentCategory = $null
            [string]$currentEntry = $null
            [string]$current_commit = $null
            [string]$commitLinkUrl = $null
            $gitLog -split "`n"| ForEach-Object {
                
                $line = $_.Trim()

                # check if commit is in main/master and ignore
                if ($lastCommitFromMain -Contains $line) { return }

                # Ignore empty lines
                if ([string]::IsNullOrWhiteSpace($line)) { return }

                # Check if the line contains a commit hash and set it as the current commit
                if ($line -match "\b[0-9a-f]{40}\b") {
                    $current_commit = $line
                    Write-Debug "----[ setting commit tag to: $current_commit"
                    return
                }

                # Check if the line matches one of the predefined categories
                $strippedLine = Remove-Emojis -inputString $line
                
                # Sort categories by length in descending order to match most specific first
                $sortedCategories = $categories.Keys | Sort-Object -Property Length -Descending
                
                $matchedCategory = $sortedCategories | Where-Object { $strippedLine -eq $_ } | Select-Object -First 1
                
                if ($matchedCategory) {
                    Write-Debug "valid category detected on line: $strippedLine"
                    $currentCategory = $matchedCategory
                    $categories[$currentCategory]['strippedLine'] = $strippedLine
                    $categories[$currentCategory]['commitid'] = $current_commit
                    $currentEntry = $null
                    return
                }

                # If the line belongs to the current category and starts with " - ", start a new entry
                if ($currentCategory -and $line -match "^- .*") {
                    Write-debug "adding new entry to $currentCategory`: $line"
                    $currentEntry = $line.Trim()
                    if ($CommitLink) { $commitLinkUrl = generate_commit_link($current_commit) }
                    $categories[$currentCategory]['entry'] += "$currentEntry $commitLinkUrl" 
                    return
                }

                # If the line does not start with " - " but follows an existing entry, append it
                # commit fusion usies psparagraph to indent the text in commit messages
                if (
                    $currentEntry -and $currentCategory['strippedLine'] -and 
                    $line -notmatch "^- " -and 
                    $line -notmatch "^.*Merge*.*branch*.*into.*" -and 
                    $line -notmatch "^.*Merge*.*tag*.*into.*" -and
                    $line -notmatch "^.*Merge*.*commit*.*into.*" -and
                    $line -notmatch "^.*Merge*.*request.*" -and
                    $line -notmatch "^.*# " -and
                    $line -notmatch "[\uD83C-\uDBFF\uDC00-\uDFFF\u2600-\u26FF\u2700-\u27BF\u2B50\u231A-\u23F3\u2B06\u2194\u25AA\u25FE\u25B6\u23F8\u23F9\u23F3\u26A0\u26C8\u2694\u2696\u2702\u2728\u2734\u2744\u2747\u2753\u2755\u2795\u2796\u2797\u2B06\u21A9\u2B05]+") {
                    # Append the additional line to the last entry
                    $categories[$currentCategory]['entry'][-1] += " " + $line.TrimStart()
                    Write-debug "possible Second paragraph found and appending to $($currentCategory['strippedLine'])`: $line"
                    return
                }

            }

            # Debugging: Print the hashtable content after processing
            #Write-Output "Processed Release Notes Hashtable:"
            # $categories.GetEnumerator() | ForEach-Object { 
            #     Write-Output "$($_.Key):"
            #     $_.Value | ForEach-Object { Write-Output "  $_" }
            # }

            # Generate the markdown string
            [string]$markdown = ""
            foreach ($category in $categories.GetEnumerator()) {
                Write-Debug "Processing category: $($category.Key)"
                if ($Notes -eq $true -and $category.Key -eq "Notes:" -and $category.value['entry'].Count -gt 0) {
                    $markdown += "## $($category.Key)`n`n"
                    foreach ($entry in $category.value['entry']) {
                        $markdown += " $entry`n"
                    }
                }
                if ($FeatureNotes -eq $true -and $category.Key -eq "Feature Notes:" -and $category.value['entry'].Count -gt 0) {
                    $markdown += "## $($category.Key)`n`n"
                    foreach ($entry in $category.value['entry']) {
                        $markdown += " $entry`n"
                    }
                }
                if ($FeatureAdditions -eq $true -and $category.Key -eq "Feature Additions:" -and $category.value['entry'].Count -gt 0) {
                    $markdown += "## $($category.Key)`n`n"
                    foreach ($entry in $category.value['entry']) {
                        $markdown += " $entry`n"
                    }
                }
                if ($FeatureUpdates -eq $true -and $category.Key -eq "Feature Updates:" -and $category.value['entry'].Count -gt 0) {
                    $markdown += "## $($category.Key)`n`n"
                    foreach ($entry in $category.value['entry']) {
                        $markdown += " $entry`n"
                    }
                }
                if ($BreakingChanges -eq $true -and $category.Key -eq "Breaking Changes:" -and $category.value['entry'].Count -gt 0) {
                    $markdown += "## $($category.Key)`n`n"
                    foreach ($entry in $category.value['entry']) {
                        $markdown += " $entry`n"
                    }
                }
                $markdown += "`n"
            }
        }
        # return object or markdown not use if OnlyMessageHead is true
        if ($AsObject) {
            return $categories
        }else {
            return $markdown
        }
    }
}

$cmdletconfig = @{
    function = 'Get-ReleaseNotes'
    alias    = 'grn' 
}

Export-ModuleMember @cmdletconfig