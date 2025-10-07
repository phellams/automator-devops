
using module ../core/New-ColorConsole.psm1

# ============== NOTES FOR USE ==============
# NOTE: Rename $global:<__automator_devops> to your module name so globals variables can work correctly
# TODO: change $global
# ============== NOTES FOR USE ==============

<# . . . . . . . . . . . . . .
# Global Module Hashtable object
# Containg Functions, utilities and props
 * GLOBAL HASHTABLE MODULE OBJECT
 * --- Enable Logging
 * --- utility object
 * --- kvtinc
 * --- kvinc
 * --- ConvertKvString
 * --- interLogger  
<# . . . . . . . . . . . . . .#>
$global:__automator_devops = @{
    
    # Enable global logging
    # Set via Set-Logging Cmdlets with -Enable or -Disable parameters
    # Default is true
    logging                     = $true
    
    # Internal Logger
    # Properties for UI elements
    utility         = @{
        logName                 = "🤖≈ AUTOMATOR-DEVOPS"
        logname_color           = "darkmagenta"
        logchar                 = "▣"
        logchar_color           = "darkmagenta"
        logchar_format          = "none"
        logchar_sperator        = "≈"
        logchar_sperator_color  = "darkmagenta"
        logchar_sperator_format = "none"
        sublog_spacer           = "$(" "*1)"
        sublog_sperator         = "+ "
        message_color           = "gray"
        message_format          = "none"
        kvinc_bracket_color     = "magenta"
        kvinc_bracket_format    = "none"
        kvinc_key_color         = "cyan"
        kvinc_key_format        = "none"
        kvinc_value_color       = "gray"
        kvinc_value_format      = "none"
        action_color            = "white"
        action_format           = "none"

    }

    <# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
        Hashtable function
        ------------------
        Key Value in color with value type
        Returns a string representation of a key value pair wrapped in 
        ASCII color codes denoting the key and valuetype.
        Example:
        $kvtinc.invoke('key', 'value', 'type')
       . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .#>
    kvtinc  = {
        param([string]$keyName, [string]$KeyValue, [string]$valueType)
        [string]$kvtStringRep = ''
        $kvtStringRep += "$(csole -s '{' -c magenta) "
        $kvtStringRep += "key-($(csole -s $keyName -c cyan)) : "
        $kvtStringRep += "value-(type-($(csole -s $valueType -c yellow))[$(csole -s $KeyValue -c gray)]) "
        $kvtStringRep += "$(csole -s '}' -c magenta)"   
        return $kvtStringRep
    }
    <# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
        Hashtable function
        ------------------
        Key Value in color
        Returns a string representation of a key value pair wrapped in ASCII color codes
        Example:
        $kvinc.invoke('key', 'value', 'inf|wrn|err')
       . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .#>
    kvinc = {

        param([string]$keyName, [string]$KeyValue, [string]$type)
        
        [string]$string = ''
        $string += "$(csole -s '{' -c $global:__automator_devops.utility.kvinc_bracket_color -format $global:__automator_devops.utility.kvinc_bracket_format)"

        switch($type){
            # NOTE: Add in more options
            'inf' { $string += "$(csole -s "INF" -c cyan -bgcolor gray -format bold) ≡" }
            'wrn' { $string += "$(csole -s "WRN" -c black -bgcolor yellow -format bold) ≡" }
            'err' { $string += "$(csole -s "ERR" -c white -bgcolor red -format bold) ≡" }
            default { }
        }

        $string += " $(csole -s $keyName -c $global:__automator_devops.utility.kvinc_key_color -format $global:__automator_devops.utility.kvinc_key_format) "
        $string += "$(csole -s ':' -c $global:__automator_devops.utility.kvinc_bracket_color -format $global:__automator_devops.utility.kvinc_bracket_format)"
        $string += " $(csole -s $KeyValue -c $global:__automator_devops.utility.kvinc_value_color -format $global:__automator_devops.utility.kvinc_value_format) "
        $string += "$(csole -s '}' -c $global:__automator_devops.utility.kvinc_bracket_color -format $global:__automator_devops.utility.kvinc_bracket_format)"

        return $string
    }
    <#
        Hahstable function
        ------------------
        Convert a string with key value pairs into a string with ASCII color codes
        Example:
        $ConvertKvString.invoke('This is a message with kv:Key=Value and {wrn:kv:Key=Value} and {err:kv:Key=Value}')
        Output:
        This is a message with {key-(key) : value-(type-(string)[Value])} and {WRN ≡ key-(key) : value-(type-(string)[Value])} and {ERR ≡ key-(key) : value-(type-(string)[Value])}
    #>
    ConvertKvString = {
        param ([string]$Message)

        $kvinc = $global:__automator_devops.kvinc
        $pattern = '(?<Prefix>\{(?<Level>inf|wrn|err):)?kv:(?<Key>[^=]+)=(?<Value>.*?)\}'
    
        $finalMessage = $Message
    
        # Get all matches first
        $allMatches = [regex]::Matches($finalMessage, $pattern)
    
        # Process matches from right to left to avoid index shifting issues
        for ($i = $allMatches.Count - 1; $i -ge 0; $i--) {
            $match = $allMatches[$i]
            $level = $match.Groups['Level'].Value.Trim()
            $key = $match.Groups['Key'].Value
            $value = $match.Groups['Value'].Value.Trim()

            $replacement = $kvinc.Invoke($key, $value, $level)
            $finalMessage = $finalMessage.Remove($match.Index, $match.Length).Insert($match.Index, $replacement)
        }
    
        return $finalMessage
    }
    <# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
        Hashtable function
        ------------------
        Internal Logger
        Using a combination of colorconsole, [console]::write and kvinc, kvoinc, kvtinc
            - Uses $global:__automator_devops.utility.logName
            - Uses $global:__automator_devops.kvinc
        Examples:
            $global:__automator_devops.interLogger.invoke('Action','Message',$false,'error')
            
            Using ConvertKvString with kv:Key=Value pairs
            $global:__automator_devops.interLogger.invoke('Action','This is a message with kv : Key=Value and {wrn:kv:Key=Value} and {err:kv:Key=Value}',$false,'info')
        -
        #NOTE: The 'sublog' switch is used to indicate if this is a sublog message
        #NOTE: logname is only shown on main log messages
        #NOTE: Action is a short string to indicate the action being performed
        #NOTE: Message is the main message to be logged, can contain kv:Key=Value pairs for color coding
        #NOTE: type is used to color code the message, can be 'error', 'warn', 'info', 'success
        #TODO: Switch the Type and sublog and sublog can be omitted and default to false
      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .#> 
    interLogger = {
        param([string]$Action, [string]$Message, [switch]$sublog, [string]$type)
        
        if($global:__automator_devops.logging -eq $true) {
            # Local Variables
            $logName                 = $global:__automator_devops.utility.logName
            $logname_color           = $global:__automator_devops.utility.logname_color
            $logchar                 = $global:__automator_devops.utility.logchar
            $logchar_color           = $global:__automator_devops.utility.logchar_color
            $logchar_format          = $global:__automator_devops.utility.logchar_format
            $logchar_sperator        = $global:__automator_devops.utility.logchar_sperator
            $logchar_sperator_color  = $global:__automator_devops.utility.logchar_sperator_color
            $logchar_sperator_format = $global:__automator_devops.utility.logchar_sperator_format
            $action_color            = $global:__automator_devops.utility.action_color
            $action_format           = $global:__automator_devops.utility.action_format
            # $message_color         = $global:__automator_devops.utility.message_color
            # $message_format        = $global:__automator_devops.utility.message_format
            $sublog_spacer           = $global:__automator_devops.utility.sublog_spacer
            $sublog_sperator         = $global:__automator_devops.utility.sublog_sperator

            [string]$logger_message = ''
            if (!$sublog) {
                # logchar
                $logger_message += "$(csole -s $logchar -c $logchar_color -format $logchar_format)"
                # logchar_sperator
                $logger_message += "$(csole -s $logchar_sperator -c $logchar_sperator_color -format $logchar_sperator_format)"            
                # logName
                $logger_message += "$(csole -s $logName -c $logname_color -format $logchar_format)"
            }else{
                # sublog_spacer
                $logger_message += $sublog_spacer
                # sublog_sperator
                $logger_message += $sublog_sperator  
            }

            # Action
            $logger_message += " $(csole -s $Action -c $action_color -format $action_format) "
            
            switch ($type) {
                'error' { $Message = csole -s $Message -c red }
                'warn' { $Message = csole -s $Message -c yellow }
                'info' { $Message = csole -s $Message -c gray }
                'success' { $Message = csole -s $Message -c green }
                default { $Message = csole -s $Message -c white }
            }
            
            $logger_message += $global:__automator_devops.ConvertKvString.invoke($Message)
            
            # Console log the Message
            [console]::write("$logger_message `n")
        }
        
    }
}
