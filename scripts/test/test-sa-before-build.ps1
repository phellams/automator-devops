using module ../core/New-ColorConsole.psm1
using module ../core/core.psm1

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
#---UI ELEMENTS Shortened-------------

#---CONFIG----------------------------
$ModuleConfig = Get-Content -Path ./build_config.json | ConvertFrom-Json
$modulename = $ModuleConfig.moduleName
#---CONFIG----------------------------

$interLogger.invoke("ScriptAnalyzer", "Running Analyzer on {inf:kv:path=./dist/$modulename}", $false, 'info')

Invoke-ScriptAnalyzer -Path ./dist/$modulename `
                      -Recurse `
                      -severity warning `
                      -excluderule PSUseBOMForUnicodeEncodedFile || exit 1

# , PSAvoidUsingWriteHost 