# ============================================================================================= 
# ============================ Console Functions  =============================================
# ============================================================================================= 

#================ Data Transport =============================

function EncodeHastable() {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [System.Collections.Hashtable]$object
    )
    return [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json $object -Compress)))
}

function DecodeHastable() {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$object
    )
    return [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($object)) | ConvertFrom-Json
}

function GetHastable() {
    param (
        [string]$object
    )
    retunr
}

#================ Write =============================
Function Write-Base {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$object,
        [object]$invocation = $MyInvocation,
        [System.ConsoleColor] $color = "White"
    )
    $str = ""
    $time = (Get-Date).ToString("[HH:mm:ss]")
    if ($Global:debug) {
        $str = "$time $object at $($invocation.PSCommandPath):$($invocation.ScriptLineNumber)"
    }
    else {
        $str = "$object" 
    }
    write-host $str -ForegroundColor $color

    if (!($null -eq $x_Info_Time)) {   
        $x_Info_Time.Text = $time 
        $x_Info_Message.Text = $object 
        if ($Global:debug) {
            $x_Info_Postion.Text = "$($invocation.PSCommandPath):$($invocation.ScriptLineNumber)"
        }
    }
}

Function Write-Error {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$object,
        [object]$invocation = $MyInvocation
    )
    Write-Base -Object $object -invocation $invocation -color Red
}

Function Write-Sucess {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$object,
        [object]$invocation = $MyInvocation
    )
    Write-Base -Object $object -invocation $invocation -color DarkCyan
}
Function Write-Sucess {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$object,
        [object]$invocation = $MyInvocation
    )
    Write-Base -Object $object -invocation $invocation -color Green
}
Function Write-Info {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$object,
        [object]$invocation = $MyInvocation
    )
    Write-Base -Object $object -invocation $invocation -color White
}

Function Write-Cancel {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$object,
        [object]$invocation = $MyInvocation
    )
    Write-Base -Object $object -invocation $invocation -color Magenta
}

Function Write-Pretty {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCustomObject]$object
    )
    Write-Host $object.GetType() -ForegroundColor Cyan
    $object.PSObject.Properties | ForEach-Object {
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
        [string]$script_name = ""
    )
    $Host.UI.RawUI.BackgroundColor = "black"  
    if ($script_name.Length -eq 0) {
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
