# ============================================================================================= 
# ============================ Console Functions  =============================================
# ============================================================================================= 

#================ Data Transport =============================

function EncodeHastable() {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [System.Collections.Hashtable]$Object
    )
    return [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json $Object -Compress)))
}

function DecodeHastable() {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Object
    )
    return [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Object)) | ConvertFrom-Json
}


#================ Write =============================

Function Write-Base {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Object,
        [object]$invocation = $MyInvocation,
        [System.ConsoleColor] $color = "White"
    )
    $str = ""
    $time = (Get-Date).ToString("[HH:mm:ss]")
    if ($debug) {
        $str = "$time $Object at $($invocation.PSCommandPath):$($invocation.ScriptLineNumber)"
    }
    else {
        $str = "$time $Object" 
    }
    write-host $str -ForegroundColor $color

    if (!($null -eq $x_Info_Time)) {   
        $x_Info_Time.Text = $time 
        $x_Info_Message.Text = $Object 
        if ($debug) {
            $x_Info_Postion.Text = "$($invocation.PSCommandPath):$($invocation.ScriptLineNumber)"
        }
    }
}

Function Write-Error {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Object,
        [object]$invocation = $MyInvocation
    )
    Write-Base -Object $Object -invocation $invocation -color Red
}

Function Write-Sucess {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Object,
        [object]$invocation = $MyInvocation
    )
    Write-Base -Object $Object -invocation $invocation -color DarkCyan
}
Function Write-Sucess {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Object,
        [object]$invocation = $MyInvocation
    )
    Write-Base -Object $Object -invocation $invocation -color Green
}
Function Write-Info {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Object,
        [object]$invocation = $MyInvocation
    )
    Write-Base -Object $Object -invocation $invocation -color White
}

Function Write-Cancel {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Object,
        [object]$invocation = $MyInvocation
    )
    Write-Base -Object $Object -invocation $invocation -color Magenta
}

write-error "test"
Function Write-Pretty {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]$Object
    )
    Write-Host $Object.GetType() -ForegroundColor Cyan
    $Object.PSObject.Properties | ForEach-Object {
        $property = $_.Name
        $value = $_.Value
        if ($value.Length -gt 100) {
            $value = $value.Substring(0, 20) + "..."
        }
        Write-Host "    $property :" -ForegroundColor Green -NoNewline
        Write-Host " $value" -ForegroundColor White
    }
}
Function Write-Cleaner {
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string]$InputObject
    )
    process {
        if ($InputObject -ne "" -and $InputObject -notmatch "^[\|/-\\ ]+$" -and $InputObject -notmatch "^\s*-\s*$") {
            if ($InputObject -match "[█▒]") {
                # Rewrite the same line
                Write-Base  -NoNewline "`r  $InputObject"
            }
            else {
                # Write normally
                Write-Base "  $InputObject"
            }
        }
    }
}

#================ Console =============================
Function Console_Setup {
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string]$script_name = $null
    )
    $Host.UI.RawUI.BackgroundColor = "black"  
    if ($null -eq $script_name) {
        $Host.UI.RawUI.WindowTitle = $default_dict.name
    }
    else {
        $Host.UI.RawUI.WindowTitle = "$($default_dict.name) : $script_name"
    }
}

function Console_Header {
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string]$script = $null
    )

    Clear-Host 
    write-host 
    write-host "_______________________________________________________________"
    write-host "_______________________________________________________________"
    write-host "                                                               "
    write-host "               ________   ______   __________                  "
    write-host "              |\_____  \ |\  ___\  |\   ___  \                 "
    write-host "               \|___/  /\ \ \ \__   \ \  \ \  \                "
    write-host "                   /  / /  \ \   _\  \ \  \ \  \               "
    write-host "                  /  /_/__  \ \  \___ \ \  \_\  \              "
    write-host "                 |\_______\  \ \_____\ \ \_______\             "
    write-host "                  \|_______|  \|______| \|_______/             "
    write-host "                                                               "
    write-host "_______________________________________________________________"
    write-host "_______________________________________________________________"
    write-host "                                                               "
    Write-Host $default_dict.name.PadLeft((($default_dict.name.Length + 63) / 2), " ").PadRight(63, " ")
    write-host "                                                               "
    if (!($null -eq $default_dict.version)) {
        Write-Host $default_dict.version.PadLeft((($default_dict.version.Length + 63) / 2), " ").PadRight(63, " ")
        write-host "                                                               "
    }
    write-host "_______________________________________________________________"
    write-host "_______________________________________________________________"
}
