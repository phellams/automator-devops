function Get-RemoteFileHash {
    param(
        [string]$Url,
        [string]$Algorithm = "SHA256"
    )
    
    $request = [System.Net.WebRequest]::Create($Url)
    $response = $request.GetResponse()
    $stream = $response.GetResponseStream()
    
    try {
        $hashAlgorithm = [System.Security.Cryptography.HashAlgorithm]::Create($Algorithm)
        $hashBytes = $hashAlgorithm.ComputeHash($stream)
        $hash = [System.BitConverter]::ToString($hashBytes) -replace '-', ''
        return $hash
    }
    finally {
        $stream.Close()
        $response.Close()
    }
}

# Usage:
# Get-RemoteFileHash -Url "https://example.com/file.zip" -Algorithm SHA256