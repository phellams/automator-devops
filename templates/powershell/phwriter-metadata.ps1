# ==============================================================================
# File: phwriter-metadata.ps1
# ==============================================================================
$source = "https://gitlab.com/phellams/fluidbar/-/blob/main/README.md"
$phwriter_metadata_array = @(
    @{
        commandinfo = @{
            cmdlet      = "New-FluidBar"
            synopsis    = "New-FluidBar [[-Brackets] <String[]>] [-Fill] <Int32> [-Width <Int32>]"
            description = "Generates static string representations of progress intervals with precise structural and color formatting."
            source      = $source
        }
        paramtable  = @(
            @{
                name        = "Brackets"
                param       = "Brackets"
                type        = "string[]"
                required    = $false
                description = "Cap strings for the left and right boundaries."
                inline      = $false
            },
            @{
                name        = "Fill"
                param       = "Fill"
                type        = "int"
                required    = $true
                description = "The completion percentage (0-100) driving internal character counts."
                inline      = $false
            },
            @{
                name        = "Width"
                param       = "Width"
                type        = "int"
                required    = $false
                description = "The absolute total character length of the generated string output."
                inline      = $false
            }
        )
        examples    = @(
            "New-FluidBar -Fill 50 -Width 20",
            "New-FluidBar -Fill 80 -Width 40 -ColorMode Gradient -GradientStart @(255,0,0) -GradientEnd @(0,255,0)"
        )
    },
    @{
        commandinfo = @{
            cmdlet      = "Invoke-FluidBarAnimation"
            synopsis    = "Invoke-FluidBarAnimation [-BarParameters] <Hashtable> [-DelayMilliseconds <Int32>]"
            description = "Console wrapper that sequences New-FluidBar generation across a 0 to 100 iteration loop with cursor safety."
            source      = $source
        }
        paramtable  = @(
            @{
                name        = "BarParameters"
                param       = "BarParameters"
                type        = "hashtable"
                required    = $true
                description = "A splatted hashtable containing arguments for New-FluidBar."
                inline      = $false
            },
            @{
                name        = "DelayMilliseconds"
                param       = "DelayMilliseconds"
                type        = "int"
                required    = $false
                description = "The execution pause duration between iterative rendering frames."
                inline      = $false
            }
        )
        examples    = @(
            "Invoke-FluidBarAnimation -BarParameters @{ Width = 30; ColorMode = 'Gradient' }"
        )
    },
    @{
        commandinfo = @{
            cmdlet      = "New-VerticalBar"
            synopsis    = "New-VerticalBar [-Data] <OrderedDictionary> [-Height <Int32>] [-Style <String>]"
            description = "Renders a multi-column TUI chart natively handling variable arrays via hashtable/ordered dictionary data inputs."
            source      = $source
        }
        paramtable  = @(
            @{
                name        = "Data"
                param       = "Data"
                type        = "OrderedDictionary"
                required    = $true
                description = "Key-Value pairs driving column headers and percentage heights."
                inline      = $false
            },
            @{
                name        = "Height"
                param       = "Height"
                type        = "int"
                required    = $false
                description = "Total terminal lines utilized for the Y-axis."
                inline      = $false
            }
        )
        examples    = @(
            "New-VerticalBar -Data ([ordered]@{ 'CPU' = 45; 'RAM' = 70 }) -Height 8"
        )
    },
    @{
        commandinfo = @{
            cmdlet      = "New-3DBar"
            synopsis    = "New-3DBar [-Title] <String> [-Fill] <Int32> [-Width <Int32>]"
            description = "Renders an extruded pipe style graphic mapped across 3 vertical lines, complete with structural caps."
            source      = $source
        }
        paramtable  = @(
            @{
                name        = "Title"
                param       = "Title"
                type        = "string"
                required    = $true
                description = "Injected structurally above the rendered pipe."
                inline      = $false
            },
            @{
                name        = "Fill"
                param       = "Fill"
                type        = "int"
                required    = $true
                description = "Determines the visual pipe volume."
                inline      = $false
            }
        )
        examples    = @(
            "New-3DBar -Title 'CPU Status' -Fill 60"
        )
    },
    @{
        commandinfo = @{
            cmdlet      = "New-DashboardBar"
            synopsis    = "New-DashboardBar [-Data] <PSCustomObject> [-Width <Int32>]"
            description = "Aggregates custom objects to automate multi-line dashboard reporting formats, complete with offset subtext lines."
            source      = $source
        }
        paramtable  = @(
            @{
                name        = "Data"
                param       = "Data"
                type        = "PSCustomObject"
                required    = $true
                description = "Must contain properties structured with .Percentage and .Subtext elements."
                inline      = $false
            }
        )
        examples    = @(
            "New-DashboardBar -Data [PSCustomObject]@{ Disk = @{ Percentage = 80; Subtext = @('200GB Free') } }"
        )
    },
    @{
        commandinfo = @{
            cmdlet      = "New-TrailingLog"
            synopsis    = "New-TrailingLog [-LogData] <Object> [-MaxLines <Int32>]"
            description = "Processes collection objects (like Queue) into sequential arrays for trailing output with gradient fading."
            source      = $source
        }
        paramtable  = @(
            @{
                name        = "LogData"
                param       = "LogData"
                type        = "object"
                required    = $true
                description = "The raw collection of data representing the execution log."
                inline      = $false
            }
        )
        examples    = @(
            "New-TrailingLog -LogData $history -MaxLines 5"
        )
    },
    @{
        commandinfo = @{
            cmdlet      = "New-Separator"
            synopsis    = "New-Separator [[-Char] <Char>] [-Repeat <Int32>]"
            description = "Provides a robust, structurally calculated horizontal rule for separating output between modules or log streams."
            source      = $source
        }
        paramtable  = @(
            @{
                name        = "Char"
                param       = "Char"
                type        = "char"
                required    = $false
                description = "The character to be repeated to construct the separator."
                inline      = $false
            },
            @{
                name        = "Repeat"
                param       = "Repeat"
                type        = "int"
                required    = $false
                description = "Specifies the absolute character width of the generated separator."
                inline      = $false
            }
        )
        examples    = @(
            "New-Separator -Char '=' -Repeat 40"
        )
    }
)
