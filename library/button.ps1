

# =============================================================================================     
# ================================   Button_ Function  =========================================  
# =============================================================================================  

function Button_Debloat {
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "Invoke-RestMethod https://win11debloat.raphi.re/ | Invoke-Expression" -Verb RunAs
}

Function Button_Titus {
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "irm https://christitus.com/win | iex" -Verb RunAs
}

function Button_Upgrade_All_Package {
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

function Button_Add_Shortcut {
    $startMenuPath = [System.IO.Path]::Combine($env:APPDATA, "Microsoft\Windows\Start Menu\Programs", "$zed_dictionnary.name.lnk")
    $desktopPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "$zed_dictionnary.name.lnk")

    $powershellPath = (Get-Command "powershell.exe").Source
    $arguments = "-NoProfile -Command Start-Process powershell -ArgumentList '-NoProfile -Command $zed_dictionnary.command' -Verb RunAs"
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

function Button_Add_ExclusionFolder {
    $exclusionFolderPath = "C:\Exclusions" 
    if (!(Test-Path -Path $exclusionFolderPath)) {
        New-Item -Path $exclusionFolderPath -ItemType Directory | Out-Null
        Write-Ok "Folder created: $exclusionFolderPath" 
    }
    else {
        Write-Event "The folder already exists: $exclusionFolderPath" 
    }
    Add-MpPreference -ExclusionPath $exclusionFolderPath
    $exclusions = Get-MpPreference | Select-Object -ExpandProperty ExclusionPath
    if ($exclusionFolderPath -in $exclusions) {
        Write-Ok "Folder added to Windows Defender exclusion list." 
        if ($exclusionFolderPath) {
            Invoke-Item -Path $exclusionFolderPath
        }
        else {
            Write-Error "[$($MyInvocation.ScriptLineNumber)] Exclusion path is not defined."
        }
    }
    else {
        Write-Error "[$($MyInvocation.ScriptLineNumber)] Failed to add the folder to the exclusion list." 
    }   
}


function Button_CleanApp {
    $startMenuPath = [System.IO.Path]::Combine($env:APPDATA, "Microsoft\Windows\Start Menu\Programs", "$zed_dictionnary.name.lnk")
    $desktopPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "$zed_dictionnary.name.lnk")

    Write-Event "Cleaning the mess" 

    $wshell = New-Object -ComObject Wscript.Shell
    switch ($wshell.Popup("Voulez vous vraiment quitter", 0, $zed_dictionnary.name, 4 + 32)) {
        6 { 
            Remove-Item -Path $startMenuPath, $desktopPath -Force
            Remove-Item -Path $zed_dictionnary.temp_folder -Recurse -Force
            Stop-Process -Id $PID
        }
        7 { 
            Write-Cancel "Cancelled"
            return
        } 
        default { return } 
    }
}

function Button_Install_Winget {

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Event "Winget is already installed"
        return $true
    }

    $url = "https://aka.ms/getwinget"
    $zed_dictionnary.temp_folder = "$env:TEMP\Microsoft.DesktopAppInstaller.appxbundle"
    Invoke-WebRequest -Uri $url -OutFile $zed_dictionnary.temp_folder
    Add-AppxPackage -Path $zed_dictionnary.temp_folder
    Remove-Item $zed_dictionnary.temp_folder

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Ok "Winget is installed"
        return $true
    }
    else {
        Write-Error "Winget failed to install" 
    }
}
function Button_Install_Choco {
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Event "Chocolatey is already installed"
        return $true
    }
   
    Set-ExecutionPolicy Bypass -Scope Process -Force

    $installScript = {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }
    & $installScript | Out-Null  

    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Ok "Chocolatey has been installed with sucess."
        return $true
    }
    else {
        Write-Error "Chocolatey failed to install" 
    }
}