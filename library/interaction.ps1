# ============================================================================================= 
# ============================ Main Functions  ================================================
# ============================================================================================= 

function Button_Applications {
    param (
        [System.Object[]]$list
    )

    $checked = $list | Where-Object { $_.checkbox.IsChecked } 

    if ($checked.Length -eq 0) {
        Write-Cancel "No software has been selected" 
        return
    }

    if (($choco -eq $false) -or ($winget -eq $false)) {
        $result = [System.Windows.MessageBox]::Show("Cette fonctionnalité requiere Winget et Chocolatey. Voulez vous les installer?", "Package Manager", [System.Windows.MessageBoxButton]::OKCancel)
        if ($result -eq [System.Windows.MessageBoxResult]::OK) {
            $winget = CustomInstallWinget
            $choco = CustomInstallChoco
        }
        elseif ($result -eq [System.Windows.MessageBoxResult]::Cancel) {
            Write-Cancel "Installation cancelled" 
        }
    }
    

    $names = ($checked | ForEach-Object { $_.name }) -join ", "
    $result = [System.Windows.MessageBox]::Show("Voulez vous installez le(s) logiciel(s) suivant : $names", "Package Manager", [System.Windows.MessageBoxButton]::OKCancel)
   
    if ($result -eq [System.Windows.MessageBoxResult]::OK) {
        Write-Event  "Starting the multi Installer" 
        $checked |
        ForEach-Object {
            $item = $PSItem
            switch ($item.provider) {
                $default_dict.winget {  
                    Write-Host "[$($item.provider)] $($item.name) : Starting" -ForegroundColor DarkCyan
                    winget install --id $item.package --accept-package-agreements --accept-source-agreements -e | Out-String -Stream | Write-Cleaner
                    Write-Host "[$($item.provider)] $($item.name) : Finished" -ForegroundColor DarkCyan
                }
                $default_dict.choco {                             
                    Write-Host "[$($item.provider)] $($item.name) : Starting" -ForegroundColor DarkCyan
                    choco install $item.package -y 2>&1 | Out-String -Stream | Write-Cleaner
                    Write-Host "[$($item.provider)] $($item.name) : Finished" -ForegroundColor DarkCyan
                }
                $default_dict.exe {
                    $cleanedfilename = $item.name -replace '[ .:*?"<>|]', ''
                    Write-Host "[$($item.provider)] $($item.name) : Starting" -ForegroundColor DarkCyan
                    DownloadAndExecuteScript $script_dict.download  -params @{file_url = $item.package ; download_filename = "$cleanedfilename.exe" }
                    Write-Host "Download started in a other shell"
                    Write-Host "[$($item.provider)] $($item.name) : Finished" -ForegroundColor DarkCyan
                } 
                $default_dict.iso {
                    $cleanedfilename = $item.name -replace '[ .:*?"<>|]', ''
                    Write-Host "[$($item.provider)] $($item.name) : Starting" -ForegroundColor DarkCyan
                    DownloadAndExecuteScript $script_dict.download  -params @{file_url = $item.package ; download_filename = "$cleanedfilename.iso" }
                    Write-Host "Download started in a other shell"
                    Write-Host "[$($item.provider)] $($item.name) : Finished" -ForegroundColor DarkCyan
                } 
                $default_dict.github {
                    Write-Host "[$($item.provider)] $($item.name) : Starting" -ForegroundColor DarkCyan
                    DownloadFromGithubAndRun -repo $item.package -token $github_token
                    Write-Host "Download started in a other shell"
                    Write-Host "[$($item.provider)] $($item.name) : Finished" -ForegroundColor DarkCyan
                } 
            }
        }
    }
    elseif ($result -eq [System.Windows.MessageBoxResult]::Cancel) { 
        Write-Host "Canceled" 
    } 

}

function Button_Extensions {
    param (
        [System.Object[]]$list
    )

    $checked = $list | Where-Object { $_.checkbox.IsChecked } 

    if ($checked.Length -eq 0) {
        Write-Cancel "No software has been selected" 
        return
    }

    $names = ($checked | ForEach-Object { "[$($_.browser)]$($_.name)" }) -join ", "
    $result = [System.Windows.MessageBox]::Show("Voulez vous installez le(s) logiciel(s) suivant : $names", "Package Manager", [System.Windows.MessageBoxButton]::OKCancel)
   
    if ($result -eq [System.Windows.MessageBoxResult]::OK) {
        $checked |
        ForEach-Object {
            $current = $PSItem
            Write-Event "Ouverture [$($current.browser)] $($current.name)" 
            $success = $false

            $web_dict[$_.browser] |
            ForEach-Object {
                $path = $PSItem
                write-host $path
                if (Test-Path $path) {
                    Write-Event "$($current.browser) is installed"
                    Start-Process $path -ArgumentList $current.url
                    $success = $true
                }
                if ($success) {
                    break
                }
            }
            
            if ($success -eq $false) {
                write-host "Couldn't fine browser, opening in the default one."
                Start-Process $current.url     
            }
        }
    }  
    elseif ($result -eq [System.Windows.MessageBoxResult]::Cancel) { 
        Write-Cancel "Canceled"
    } 
}


function Load_Application {
    param (
        [object[]]$list,
        [object[]]$array
    )
    
    $array | ForEach-Object {
        $current = $PSItem
        $list | ForEach-Object {
            if ([string]$current -eq [string]$PSItem.id) {
                $PSitem.checkbox.IsChecked = $true
            }
        }
    }
    Write-Ok "Application Loaded"
}

function Copy_Applications {
    param (
        [object[]]$list
    )
    
    $checked = $list | Where-Object { $_.checkbox.IsChecked } 

    if ($checked.Length -eq 0) {
        Write-Cancel "No software has been selected" 
        return
    }
    
    $ids = ($checked | ForEach-Object { $_.id }) | ConvertTo-Json

    $trimmedString = ($ids | ForEach-Object { $_.Trim() }) -replace "`r?`n", "" -replace " ", ""
    Set-Clipboard -Value $trimmedString
    Write-Ok "Apps list has been copied to clipboard"
}

function Paste_Applications {
    param (
        [object[]]$list
    )
    Clear_Applications -list $list
    
    $array = (Get-Clipboard | ConvertFrom-Json)
    Load_Application -list $list -array $array
}

function Clear_Applications {
    param (
        [object[]]$list
    )
    $list | Where-Object { $_.checkbox.IsChecked = $false } 
    Write-Ok "Cleared"
}

Function Load_Configfile {
    param (
        [object[]]$config_path
    )
    Get-Content -Path $config_path | ForEach-Object {
        $key, $value = $_ -split '=', 2
        $keyValuePairs[$key.Trim()] = $value.Trim()
    }
}
