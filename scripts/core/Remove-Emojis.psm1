function Remove-Emojis {
    [CmdletBinding()]
    [OutputType([string])]
    [Alias("rmmjs")]
    param (
        [string]$inputString
    )

    # Regular expression pattern to match emoji characters
    $emojiPattern = '[\uD83C-\uDBFF\uDC00-\uDFFF\u2600-\u26FF\u2700-\u27BF\u2B50\u231A-\u23F3\u2B06\u2194\u25AA\u25FE\u25B6\u23F8\u23F9\u23F3\u26A0\u26C8\u2694\u2696\u2702\u2728\u2734\u2744\u2747\u2753\u2755\u2795\u2796\u2797\u2B06\u21A9\u2B05]+'

    # Replace emojis with an empty string
    $cleanedString = $inputString -replace $emojiPattern, ''

    return $cleanedString.TrimStart()
}

$cmdletconfig = @{
    function = "Remove-Emojis"
    alias = "rmmjs"
}

Export-ModuleMember @cmdletconfig