function Get-KeyFromFile() {
    [cmdletbinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$path,
        [Parameter(Mandatory = $true)]
        [string]$key
    )
    $KeyFile = Get-Content -Path $path | ConvertFrom-Json
    return $KeyFile.where({ $_.key -eq $key }).value
}

Export-ModuleMember -Function Get-KeyFromFile