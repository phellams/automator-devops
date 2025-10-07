using module cmdlets\Get-KeyFromFile.psm1

$ExportedFunctions = @(
    "Get-KeyFromFile"
) 

Export-ModuleMember -Function $ExportedFunctions