using module ../core/core.psm1

[CmdletBinding()]
param([string]$Version = $env:CI_COMMIT_TAG.TrimStart('v'))

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
$kv          = $global:__automator_devops.kvinc
$logname     = 'deploy-stage-homebrew'
#---UI ELEMENTS Shortened-------------

#---CONFIG----------------------------
$Config       = (Get-Content './build_config.json' -Raw | ConvertFrom-Json).Deployment.Homebrew
$Token        = [Environment]::GetEnvironmentVariable($Config.token_variable)
$Repository   = $Config.repository
$FormulaName  = $Config.formula
$ReleaseUrl   = $Config.release_url -replace 'VERSION', $Version
$ReleasePath  = "./dist/dotnet/release/$($Config.artifact -replace 'VERSION', $Version)"
#---CONFIG----------------------------

if (!(Test-Path $ReleasePath) -or [string]::IsNullOrWhiteSpace($Token)) {
    $interLogger.invoke($logname, 'Homebrew artifact or repository token was not found', $false, 'error')
    exit 1
}

$Hash = (Get-FileHash $ReleasePath -Algorithm SHA256).Hash.ToLower()
$TapPath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "homebrew-$([guid]::NewGuid())")
$interLogger.invoke($logname, "Updating Homebrew tap {kv:repository=$Repository}", $false, 'info')

try {
    git clone "https://oauth2:$Token@github.com/$Repository.git" $TapPath
    if ($LASTEXITCODE -ne 0) { throw 'Unable to clone Homebrew tap.' }
    $FormulaPath = [System.IO.Path]::Combine($TapPath, 'Formula', "$FormulaName.rb")
    New-Item ([System.IO.Path]::GetDirectoryName($FormulaPath)) -ItemType Directory -Force | Out-Null
    $Formula = @"
class $FormulaName < Formula
  desc "$($Config.description)"
  homepage "$($Config.homepage)"
  url "$ReleaseUrl"
  version "$Version"
  sha256 "$Hash"
  def install
    bin.install "$($Config.executable)"
  end
  test do
    system "#{bin}/$($Config.executable)", "--version"
  end
end
"@
    Set-Content $FormulaPath $Formula -Encoding utf8
    git -C $TapPath add "Formula/$FormulaName.rb"
    git -C $TapPath -c user.name=automator-devops -c user.email=ci@phellams.dev commit -m "chore: update $FormulaName to $Version"
    git -C $TapPath push origin HEAD:main
    if ($LASTEXITCODE -ne 0) { throw 'Unable to push Homebrew formula.' }
    $interLogger.invoke($logname, "Updated Homebrew formula {kv:version=$Version}", $false, 'success')
} catch {
    $interLogger.invoke($logname, "Homebrew deployment failed: {err:kv:error=$($_.Exception.Message)}", $false, 'error')
    exit 1
} finally {
    if (Test-Path $TapPath) { Remove-Item $TapPath -Recurse -Force }
}
