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
 
    $names = ($checked | ForEach-Object { $_.name }) -join ", "
    $result = [System.Windows.MessageBox]::Show("Voulez vous installez le(s) logiciel(s) suivant : $names", "Package Manager", [System.Windows.MessageBoxButton]::OKCancel)
   
    if ($result -eq [System.Windows.MessageBoxResult]::OK) {
        Write-Info "Multi-install : Starting"
        $checked |
        ForEach-Object {
            $item = $_
            Write-Info "- [$($item.provider)] $($item.name)" 
            switch ($item.provider) {
                $conf_dict.winget {  
                    Write-Info "[$($item.provider)] $($item.name) : Starting"
                    winget install --id $item.package --accept-package-agreements --accept-source-agreements -e | Out-String -Stream | Write-Cleaner
                    Write-Info "[$($item.provider)] $($item.name) : Finished"
                }
                $conf_dict.choco {                             
                    Write-Info "[$($item.provider)] $($item.name) : Starting"
                    choco install $item.package -y 2>&1 | Out-String -Stream | Write-Cleaner
                    Write-Info "[$($item.provider)] $($item.name) : Finished"
                }
                $conf_dict.exe {
                    $cleanedfilename = $item.name -replace '[ .:*?"<>|]', ''
                    Write-Info "[$($item.provider)] $($item.name) : Starting"
                    Execute_Script $script_dict.download  -params @{file_url = $item.package ; download_filename = "$cleanedfilename.exe" }
                    Write-Info "Download started in a other shell"
                    Write-Info "[$($item.provider)] $($item.name) : Finished"
                } 
                $conf_dict.iso {
                    $cleanedfilename = $item.name -replace '[ .:*?"<>|]', ''
                    Write-Info "[$($item.provider)] $($item.name) : Starting"
                    Execute_Script $script_dict.download  -params @{file_url = $item.package ; download_filename = "$cleanedfilename.iso" }
                    Write-Info "Download started in a other shell"
                    Write-Info "[$($item.provider)] $($item.name) : Finished"
                } 
                $conf_dict.github {
                    Write-Info "[$($item.provider)] $($item.name) : Starting"
                    Write-Info ($item.package -split ";")
                    $repo, $ghf, $ff = $item.package -split ";"
                    Github_Download -repo $repo -token $github_token -github_filename_filter $ghf -filename_filter $ff
                    Write-Info "Download started in a other shell"
                    Write-Info "[$($item.provider)] $($item.name) : Finished"
                } 
            }
        }
        Write-Info  "Multi-install : Finished" 
    }
    elseif ($result -eq [System.Windows.MessageBoxResult]::Cancel) { 
        Write-Cancel "Canceled" 
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
    $result = [System.Windows.MessageBox]::Show("Voulez vous installez le(s) site(s) suivant : $names", "Package Manager", [System.Windows.MessageBoxButton]::OKCancel)
   
    if ($result -eq [System.Windows.MessageBoxResult]::OK) {
        $checked |
        ForEach-Object {
            $current = $PSItem
            Write-Info "Ouverture [$($current.browser)] $($current.name)" 

            $success = $false
            $web_dict[$current.browser] |
            ForEach-Object {
                $path = $PSItem
                if (Test-Path $path) {
                    Write-Info "Found $($current.browser)"
                    Start-Process $path -ArgumentList $current.url
                    $success = $true
                }
                if ($success) {
                    break
                }
            }
            
            if ($success -eq $false) {
                Write-Canel "Couldn't fine browser, opening in the default one."
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
    Write-Sucess "Application Loaded"
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
    Write-Sucess "Apps list has been copied to clipboard"
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
    Write-Sucess "Cleared"
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

Function New_Shell_Command {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$cmd
    )
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $cmd -Verb RunAs
}
