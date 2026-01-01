<# Commit Fusion template file use to create large detailed commits #>

# ==========================
$gituser      = "sgkens"
$footer       = $false
$gitgroup     = "phellams"
# ............................


# ==========================

$change_type  = "feat"; $scope = "core"
$description  = 
  ""

$Notes = "",

# $FeatureNotes =
#   ''


# $FeatureAdditions =
#   ''

# $BugFixes =
#   ''

# $BreakingChanges =
#   ''

$SemVer = 'patch' 
# ............................




$Params = @{
  Type            = $change_type; 
  Scope           = $scope; 
  GitUser         = $gituser; 
  GitGroup        = $gitgroup; 
  Description     = $description
  footer          = $footer 
}

  # ............................................................................

  if ($Notes.count -ne 0) { $Params.Notes = $Notes }
  if ($FeatureAdditions.count -ne 0) { $Params.FeatureAdditions = $FeatureAdditions }
  if ($BugFixes.count -ne 0) { $Params.BugFixes = $BugFixes }
  if ($BreakingChanges.count -ne 0) { $Params.BreakingChanges = $BreakingChanges }
  if ($FeatureNotes.count -ne 0) { $Params.FeatureNotes = $FeatureNotes }
  if ($SemVer -ne '') { $Params.SemVer = $SemVer }
  # ............................................................................


# ACTIONS
# -------
# ConventionalCommit with params sent commit
New-Commit @Params