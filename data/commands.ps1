@{
    windows   = @{
        column_title = 'Windows'
        column_items = @{
            title = 'Connectivity'
            items = @(
                @{
                    name        = "Internet"
                    action      = { Start-Process "ms-settings:network" }
                    description = "Paramètres réseau et Internet"
                },
                @{
                    name        = "Bluetooth"
                    action      = { Start-Process "ms-settings:bluetooth" }
                    description = "Ouvrir les paramètres Bluetooth"
                },
                @{
                    name        = "VPN"
                    action      = { Start-Process "ms-settings:network-vpn" }
                    description = "Gérer les connexions VPN"
                }
            )
        },
        @{ 
            title = 'Audio Video'
            items = @(
                @{
                    name        = "Audio"
                    action      = { Start-Process "ms-settings:sound" }
                    description = "Gérer les paramètres audio"
                },
                @{
                    name        = "Display Settings"
                    action      = { Start-Process "ms-settings:display" }
                    description = "Ajuster les paramètres d’affichage"
                },
                @{
                    name        = "Personalization"
                    action      = { Start-Process "ms-settings:personalization" }
                    description = "Personnaliser l’apparence"
                }
            ) 
        },
        @{
            title = 'Configuration'
            items = @(
                @{
                    name        = "Defender"
                    action      = { Start-Process "windowsdefender:" }
                    description = "Ouvrir Windows Defender"
                },
                @{
                    name        = "Power Plan"
                    action      = { Start-Process "powercfg.cpl" }
                    description = "Modifier les options d’alimentation"
                },
                @{
                    name        = "Printer"
                    action      = { Start-Process "ms-settings:printers" }
                    description = "Ouvrir les paramètres des imprimantes"
                },
                @{
                    name        = "Reset PC"
                    action      = { Start-Process "ms-settings:recovery" }
                    description = "Réinitialiser ou restaurer le PC"
                },
                @{
                    name        = "Update"
                    action      = { Start-Process "ms-settings:windowsupdate" }
                    description = "Rechercher des mises à jour Windows"
                }
            ) 
        },
        @{
            title = 'Manager'
            items = @(
                @{
                    name        = "Disk Manager"
                    action      = { Start-Process "diskmgmt.msc" }
                    description = "Ouvrir la gestion des disques"
                },
                @{
                    name        = "Task Manager"
                    action      = { Start-Process "taskmgr" }
                    description = "Voir les processus et performances"
                },
                @{
                    name        = "Device Manager"
                    action      = { Start-Process "devmgmt.msc" }
                    description = "Gérer les périphériques matériels"
                }
            ) 
        }
    }
    tools     = @{
        column_title = 'Outils'
        column_items = @{
            title = 'Folder'
            items = @(
                @{
                    name        = 'User'
                    action      = { Invoke-Item -Path $env:USERPROFILE }
                    description = $null
                },
                @{
                    name        = 'Desktop'
                    action      = { Invoke-Item -Path "$env:USERPROFILE\Desktop" }
                    description = $null
                },
                @{
                    name        = 'Documents'
                    action      = { Invoke-Item -Path "$env:USERPROFILE\Documents" }
                    description = $null
                },
                @{
                    name        = 'Downloads'
                    action      = { Invoke-Item -Path "$env:USERPROFILE\Downloads" }
                    description = $null
                },
                @{
                    name        = 'Videos'
                    action      = { Invoke-Item -Path "$env:USERPROFILE\Videos" }
                    description = $null
                },
                @{
                    name        = 'Pictures'
                    action      = { Invoke-Item -Path "$env:USERPROFILE\Pictures" }
                    description = $null
                },
                @{
                    name        = 'Exclusion'
                    action      = { Script_Add_Exclusion_Folder }
                    description = $null
                },
                @{
                    name        = 'Appdata'
                    action      = { Invoke-Item -Path $env:APPDATA }
                    description = $null
                },
                @{
                    name        = 'Temp'
                    action      = { Invoke-Item -Path $env:TEMP }
                    description = $null
                }
            )
        },
        @{
            title = 'Zed Toolkit'
            items = @(
                @{
                    name        = 'Add Shortcut'
                    action      = { Script_Add_Shortcut }
                    description = 'Ajoute ZMT à ton ordinateur'
                },
                @{
                    name        = 'Backup User'
                    action      = { Execute_Script $script_dict.backup }
                    description = 'Copie le contenu de $([System.Environment]::GetFolderPath("UserProfile")) sur un disque de votre choix'
                },
                @{
                    name        = 'Temp Folder'
                    action      = { Invoke-Item -Path $default_dict.temp_folder }
                    description = 'Ouvre le dossier temporaire de ZMT'
                },
                @{
                    name        = 'Clean and Exit'
                    action      = { Script_Clean_App }
                    description = 'Vide le dossier Temp, retire les raccouci et ferme ZMT'
                },
                @{
                    name        = 'Github Token'
                    action      = { Script_Github_Token }
                    description = ''
                }
            )
        },
        @{
            title = 'Utility'
            items = @(
                @{
                    name        = 'Winget'
                    action      = { Script_Winget }
                    description = 'Install Winget Packet Manager'
                },
                @{
                    name        = 'Choco'
                    action      = { Script_Choco }
                    description = 'Install Choco Packet Manager'
                },
                @{
                    name        = 'Upgrade All'
                    action      = { Script_Upgrade_All_Package }
                    description = 'Met à jour tous les logiciels'
                }
            )
        }
    }
    softwares = @{
        column_title = 'Software'
        column_items = @{
            title = 'Tools'
            items = @(
                @{
                    name        = 'Powershell'
                    action      = { Start-Process powershell }
                    description = 'Ouvre un powershell'
                },
                @{
                    name        = 'Debloat'
                    action      = { New_Shell_Command "irm https://win11debloat.raphi.re/ | iex; exit" }
                    description = 'Supprime les application bloatware de windows'
                },
                @{
                    name        = 'Titus'
                    action      = { New_Shell_Command "irm https://christitus.com/win| iex; exit" }
                    description = 'Package installer + Windows optimisation'
                }
            )
        },
        @{
            title = 'Portable'
            items = @(
                @{
                    name        = 'Dipiscan'
                    action      = { Execute_Script $script_dict.download -params @{file_url = "https://www.dipisoft.com/file/Dipiscan274_portable.zip" ; filter_filename = "Dipiscan.exe" } 
                    }
                    description = $null
                },
                @{
                    name        = 'TreeSize'
                    action      = { Execute_Script $script_dict.download -params @{file_url = "https://downloads.jam-software.de/treesize_free/TreeSizeFreeSetup.exe" ; filter_filename = "TreeSizeFree.exe" } }
                    description = $null
                },
                @{
                    name        = 'Sublime Text'
                    action      = { Execute_Script $script_dict.download -params @{file_url = "https://download.sublimetext.com/Sublime%20Text%20Build%203211.zip" ; filter_filename = "sublime_text.exe" } }
                    description = $null
                },
                @{
                    name        = 'Revo Uninstaller'
                    action      = { Execute_Script $script_dict.download -params @{file_url = "https://download.revouninstaller.com/download/RevoUninstaller_Portable.zip" ; download_filename = "revo.zip" ; filter_filename = "RevoUPort.exe" } }
                    description = $null
                },
                @{
                    name        = 'Office Tool Plus'
                    action      = { Execute_Script $script_dict.download -params @{file_url = "https://download.coolhub.top/Office_Tool_Plus/10.18.11.0/Office_Tool_with_runtime_v10.18.11.0_x64.zip" ; filter_filename = "Plus.exe" } }
                    description = $null
                }
            )
        },
        @{
            title = 'Hack'
            items = @(
                @{
                    name        = 'SpotX'
                    action      = { Start-Process cmd.exe -ArgumentList "/c", "curl -sSL https://raw.githack.com/amd64fox/SpotX/main/scripts/Install_Auto.bat | cmd" -Verb RunAs }
                    description = 'Spotify No Ads Mods'
                },
                @{
                    name        = 'MassGrave'
                    action      = { New_Shell_Command -cmd "irm https://get.activated.win | iex; exit" }
                    description = 'Windows et Office Activateur'
                }
            )
        }
    
    }
}
