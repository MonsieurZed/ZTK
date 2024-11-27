

# =============================================================================================     
# ================================   Script_ Function  =========================================  
# =============================================================================================  

function Script_Debloat {
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "Invoke-RestMethod https://win11debloat.raphi.re/ | Invoke-Expression" -Verb RunAs
}

Function Script_Titus {
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "irm https://christitus.com/win | iex" -Verb RunAs
}

function Script_Upgrade_All_Package {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        $command_winget = {
            $Host.UI.RawUI.BackgroundColor = [System.ConsoleColor]::Black
            winget upgrade --all
            Pause
            exit
        }
        Start-Process powershell -ArgumentList "-NoExit", "-Command", $command_winget -Verb RunAs
    }
        
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        $command_choco = {
            $Host.UI.RawUI.BackgroundColor = [System.ConsoleColor]::Black 
            choco upgrade all -y
            Pause
            exit
        }
        Start-Process powershell -ArgumentList "-NoExit", "-Command", $command_choco -Verb RunAs
    }  
}

function Script_Add_Shortcut {
    $startMenuPath = [System.IO.Path]::Combine($env:APPDATA, "Microsoft\Windows\Start Menu\Programs", "$default_dict.name.lnk")
    $desktopPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "$default_dict.name.lnk")

    $powershellPath = (Get-Command "powershell.exe").Source
    $arguments = "-NoProfile -Command Start-Process powershell -ArgumentList '-NoProfile -Command $default_dict.command' -Verb RunAs"
    #-WindowStyle Hidden 

    $wShell = New-Object -ComObject WScript.Shell
    
    $stm_shortcut = $wShell.CreateShortcut($startMenuPath)
    $stm_shortcut.TargetPath = $powershellPath
    $stm_shortcut.Arguments = $arguments
    $stm_shortcut.WorkingDirectory = [System.IO.Path]::GetDirectoryName($powershellPath)
    $stm_shortcut.IconLocation = $iconPath
    $stm_shortcut.Save()
 
    $desk_shortcut = $wShell.CreateShortcut($desktopPath)
    $desk_shortcut.TargetPath = $powershellPath
    $desk_shortcut.Arguments = $arguments
    $desk_shortcut.WorkingDirectory = [System.IO.Path]::GetDirectoryName($powershellPath)
    $desk_shortcut.IconLocation = $iconPath
    $desk_shortcut.Save()
}

function Script_Add_Exclusion_Folder {
    $exclusionFolderPath = "C:\Exclusions" 
    if (!(Test-Path -Path $exclusionFolderPath)) {
        New-Item -Path $exclusionFolderPath -ItemType Directory | Out-Null
        Write-Ok "Folder created: $exclusionFolderPath" 
    }
    else {
        Write-Info "The folder already exists: $exclusionFolderPath" 
    }
    Add-MpPreference -ExclusionPath $exclusionFolderPath
    $exclusions = Get-MpPreference | Select-Object -ExpandProperty ExclusionPath
    if ($exclusionFolderPath -in $exclusions) {
        Write-Ok "Folder added to Windows Defender exclusion list." 
        if ($exclusionFolderPath) {
            Invoke-Item -Path $exclusionFolderPath
        }
        else {
            Write-Error "Exclusion path is not defined."
        }
    }
    else {
        Write-Error "Failed to add the folder to the exclusion list." 
    }   
}


function Script_Clean_App {
    $startMenuPath = [System.IO.Path]::Combine($env:APPDATA, "Microsoft\Windows\Start Menu\Programs", "$default_dict.name.lnk")
    $desktopPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "$default_dict.name.lnk")

    Write-Info "Cleaning the mess" 

    $wshell = New-Object -ComObject Wscript.Shell
    switch ($wshell.Popup("Voulez vous vraiment quitter", 0, $default_dict.name, 4 + 32)) {
        6 { 
            Remove-Item -Path $startMenuPath, $desktopPath -Force
            Remove-Item -Path $default_dict.temp_folder -Recurse -Force
            Stop-Process -Id $PID
        }
        7 { 
            Write-Cancel "Cancelled"
            return
        } 
        default { return } 
    }
}

