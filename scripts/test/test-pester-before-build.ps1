
using module ../core/New-ColorConsole.psm1
using module ../core/core.psm1

#---UI ELEMENTS Shortened-------------
$interLogger = $global:__automator_devops.interLogger
#---UI ELEMENTS Shortened-------------

#---CONFIG----------------------------
$ModuleConfig = Get-Content -Path ./build_config.json | ConvertFrom-Json
$ModuleName = $ModuleConfig.moduleName
$pester_test_files =  $ModuleConfig.pester_test_files
#---CONFIG----------------------------

# Pester Configration settings
# Invoke-Pester -CodeCoverage .\libs\*.psm1 -CodeCoverageOutputFile 'Coverage.xml' -CodeCoverageOutputFileFormat JaCoCo -script .\BT0-CI-Test-Pester.ps1 -PassThru

$interLogger.invoke("Pester", "Running Pester on {inf:kv:path=./dist/$modulename} ", $false, 'info')

$pesterConfig = New-PesterConfiguration -hashtable @{
  CodeCoverage = @{ 
    Enabled               = $true
    OutputFormat          = 'JaCoCo'
    OutputPath            = 'coverage.xml'
    OutputEncoding        = 'utf8'
    CoveragePercentTarget = 85
    path                  = $pester_test_files
  }
  Run = @{
    #PassThru = $true
    #scriptblock = {'.\test\Test-Unit-Pester.ps1'}
    Path     = '.\test\test-unit-pester.ps1';
  }
}

Invoke-Pester -Configuration $pesterConfig

# dotnet tool install -g dotnet-reportgenerator-globaltool
#reportgenerator -reports:coverage.xml -targetdir:.\build\temp\coverage_visualizer --title:$Modulename --reporttypes:tmlInline_AzurePipelines ---tag:main