# ============================================================================================= 
# ============================ Console Functions  =============================================
# ============================================================================================= 

#================ Data Transport =============================

function EncodeHastable() {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [System.Collections.Hashtable]$object,
        [bool] $dbg = $false
    )
    if ($dbg) {
        $jsoned = ConvertTo-Json $object -Compress
        write-host $jsoned
        $b64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($jsoned))
        write-host $b64
        return $b64
    }
    else { 
        return [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json $object -Compress))) 
    }
}

function DecodeHastable() {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$object
    )
    return [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($object)) | ConvertFrom-Json
}

#================ Write =============================
Function Write-Base {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$message,
        [object]$invocation = $MyInvocation,
        [System.ConsoleColor] $color = "White"
    )
    $darkColor = ""
    if ($color -in $("Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", "Gray")) {
        $darkColor = "Dark$color"
    }
    elseif ($color -eq "White" ) {
        $darkColor = "DarkGray"
    }
    else {
        $darkColor = $color
    }
    $time = (Get-Date).ToString("[HH:mm:ss]")

    if ($message.Length -gt 150) {
        $message = $message.Substring(0, $maxLength) + "..."
    }

    if ($Global:debug) {
        write-host "$time " -ForegroundColor $darkColor -NoNewline
        write-host "$message " -ForegroundColor $color -NoNewline
        write-host "at $($invocation.PSCommandPath):$($invocation.ScriptLineNumber)" -ForegroundColor $darkColor
    }
    else {
        write-host $message -ForegroundColor $color
    }
   

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
        [string]$message,
        [object]$invocation = $MyInvocation
    )
    Write-Base -message $message -invocation $invocation -color Red
}

Function Write-Sucess {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$message,
        [object]$invocation = $MyInvocation
    )
    Write-Base -message $message -invocation $invocation -color DarkCyan
}
Function Write-Sucess {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$message,
        [object]$invocation = $MyInvocation
    )
    Write-Base -message $message -invocation $invocation -color Green
}
Function Write-Info {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$message,
        [object]$invocation = $MyInvocation
    )
    Write-Base -message $message -invocation $invocation -color White
}

Function Write-Cancel {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$message,
        [object]$invocation = $MyInvocation
    )
    Write-Base -message $message -invocation $invocation -color Magenta
}

Function Write-Event {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$message,
        [object]$invocation = $MyInvocation
    )
    Write-Base -message $message -invocation $invocation -color Blue
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
    Write-Host $Global:branch.name.PadLeft((($Global:branch.name.Length + 63) / 2), " ").PadRight(63, " ")
    write-host "                                                               "
    if (!($null -eq $default_dict.version)) {
        Write-Host $default_dict.version.PadLeft((($default_dict.version.Length + 63) / 2), " ").PadRight(63, " ")
        write-host "                                                               "
    }
    write-host "_______________________________________________________________"
    write-host "_______________________________________________________________"
}


#================ Manager =============================

function Load_Resource_Dictionary {
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]    
        [string]$xamlFilePath
    )

    [void][System.Reflection.Assembly]::LoadWithPartialName("presentationframework")

    if ($xamlFilePath -match 'http') {
        $xamlContent = Invoke-WebRequest -Uri $xamlFilePath -UseBasicParsing | Select-Object -ExpandProperty Content
    }
    else {
        $xamlContent = Get-Content $xamlFilePath -Raw
    }

    [xml]$xamlXml = $xamlContent
    $reader = New-Object System.Xml.XmlNodeReader $xamlXml
    return [Windows.Markup.XamlReader]::Load($reader)
}
