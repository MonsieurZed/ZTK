# =============================================================================================   
# ||                                                                                         ||
# ||                                  Zed's Minitools                                        ||
# ||                                                                                         ||
# =============================================================================================    

#===========================================================================
# Config
#===========================================================================
Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MonsieurZed/ZTK/refs/heads/main/conf.ps1").Content

Get-ChildItem -Path "$base_path\library\" -Filter "*.ps1" | ForEach-Object { . $_.FullName }

Console_Setup
Console_Header 

Write-Info "Debug: $debug - Loading from $base_path"
# ===========================================================================
# Init     
# ============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$admin = $false
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as admin"
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "$($app_dict.command)" -Verb RunAs
    exit
}
else {
    $admin = $true
}
$currentProcess = Get-Process | Where-Object { $_.Id -eq $PID }

Get-Process -Name $currentProcess.Name | Where-Object { $_.Id -ne $currentProcess.Id } | Stop-Process -Force

if (-not (Test-Path -Path $app_dict.temp_folder)) {
    New-Item -Path "$($app_dict.temp_folder)" -ItemType Directory | Out-Null
}
# =============================================================================================     
#  Package manager  
# =============================================================================================  

if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Sucess "Winget is installed"
    $source.winget = $true
}
else {
    Write-Error "[$($MyInvocation.ScriptLineNumber)] Winget is not installed" 

}

if (Get-Command choco -ErrorAction SilentlyContinue) {
    $source.choco = $true
    Write-Sucess "Choco is installed"

}
else {
    Write-Error "[$($MyInvocation.ScriptLineNumber)] Choco is not installed" 
    
}


$github_token = if (Test-Path $var_dict.github_token) { Get-Content -Path $var_dict.github_token -Raw } else { $null }

if ($null -eq $github_token) { 
    $github_token = Read-Host "Enter your GitHub token (https://github.com/settings/tokens)" 
    $save = Read-Host "Do you want to save the key for later use { Y/N }" 

    if ($save.ToLower() -ieq "y") { 
        Set-Content -Path $var_dict.github_token -Value $github_token
    } 
}

if (!($null -eq $github_token)) {
    $url = "https://api.github.com/user"

    $headers = @{
        Authorization = "token $github_token"
        Accept        = "application/vnd.github.v3+json"
    }

    try {
        $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get 
        Write-Sucess "Github User is: $($response.name)"
        $source.github = $true
        
    }
    catch {
        Write-Error "Github user validation failed" 
        if ($debug) {
            Write-Error "Error : $($_.Exception.Message)" 
        }
    }
}
else {
    Write-Error "User did not specify an github token" 
}

#===========================================================================
# Load XAML  and Forms
#===========================================================================\

Write-Info "Loading xaml..."

$inputXML = Get-Content $xaml_dict.main
$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
 
 
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
 
$reader = (New-Object System.Xml.XmlNodeReader $xaml) 
try { $form = [Windows.Markup.XamlReader]::Load( $reader ) }
catch { Write-Error "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed." }
 

 
$xaml.SelectNodes("//*[@Name]") | % { Set-Variable -Name "x_$($_.Name)" -Value $form.FindName($_.Name) }

#===========================================================================
# WPF Loading
#===========================================================================

$x_Button_Copy_Applications.Add_Click({ Copy_Applications -list $applications })
$x_Button_Paste_Applications.Add_Click({ Paste_Applications -list $applications })
$x_Button_Clear_Applications.Add_Click({ Clear_Applications -list $applications })


$x_Grid_MenuBar.Background = '#111111'
$x_Grid_MainWindow.Background = '#222222'
$x_Grid_StatusBar.Background = '#111111'
$x_Grid_ButtonZone.Background = '#131313'
$x_Grid_AutoInstallZone.Background = '#111111'
$x_Grid_ExtensionZone.Background = '#121212'
$x_Grid_StatusBar.Background = '#242424'
$x_Dropdown_Packages.Background = '#222222'

$x_R_Winget.Foreground = if ($source.winget) { 'Green' }else { 'red' }
$x_R_Choco.Foreground = if ($source.choco) { 'Green' }else { 'red' }
$x_R_Github.Foreground = if ($source.github) { 'Green' }else { 'red' }
$x_R_Admin.Foreground = if ($admin) { 'Green' }else { 'red' }

$applications = Draw_Applications -json_path $json_dict.apps -wrap_panel $x_WP_Applications -source $source
$x_Button_Applications.Add_Click({ Button_Applications -list $applications })

$extensions = Draw_Applications -json_path $json_dict.web  -wrap_panel $x_WP_Extensions
$x_Button_Extensions.Add_Click({ Button_Extensions -list $extensions })

$packages = Draw_Package -json_path $json_dict.package -combo_box $x_Dropdown_Packages
$x_Dropdown_Packages.Add_DropDownClosed({ Load_Application -list $applications -array $x_Dropdown_Packages.SelectedItem.Tag })


$windows_list = @(
    ('Connectivity', @(
        ("Internet", { Start-Process "ms-settings:network" }, "Paramètres réseau et Internet", ""),
        ("Bluetooth", { Start-Process "ms-settings:bluetooth" }, "Ouvrir les paramètres Bluetooth", ""),
        ("VPN", { Start-Process "ms-settings:network-vpn" }, "Gérer les connexions VPN", ""))
    ),
    ('Audio Video', @(
        ("Audio", { Start-Process "ms-settings:sound" }, "Gérer les paramètres audio", ""),
        ("Display Settings", { Start-Process "ms-settings:display" }, "Ajuster les paramètres d’affichage", ""),
        ("Personalization", { Start-Process "ms-settings:personalization" }, "Personnaliser l’apparence", ""))
    ),
    ('Configuration', @(
        ("Defender", { Start-Process "windowsdefender:" }, "Ouvrir Windows Defender", ""),
        ("Power Plan", { Start-Process "powercfg.cpl" }, "Modifier les options d’alimentation", ""),
        ("Printer", { Start-Process "ms-settings:printers" }, "Ouvrir les paramètres des imprimantes", ""),
        ("Reset PC", { Start-Process "ms-settings:recovery" }, "Réinitialiser ou restaurer le PC", ""),
        ("Update", { Start-Process "ms-settings:windowsupdate" }, "Rechercher des mises à jour Windows", ""))
    ),
    ('Manager', @(
        ("Disk Manager", { Start-Process "diskmgmt.msc" }, "Ouvrir la gestion des disques", ""),
        ("Task Manager", { Start-Process "taskmgr" }, "Voir les processus et performances", ""),
        ("Device Manager", { Start-Process "devmgmt.msc" }, "Gérer les périphériques matériels", ""))
    ))

Draw_Buttons -button_list $windows_list -wrap_panel $x_WP_Windows

$tools_list = @(
    ('Folder', @(
        ('User', { Invoke-Item -Path $env:USERPROFILE }, $null, "shell32.dll,-1024"),
        ('Desktop', { Invoke-Item -Path "$env:USERPROFILE\Desktop" }, $null, "shell32.dll,-108"),
        ('Documents', { Invoke-Item -Path "$env:USERPROFILE\Documents" }, $null, "shell32.dll,-112"),
        ('Downloads', { Invoke-Item -Path "$env:USERPROFILE\Downloads" }, $null, "shell32.dll,-226"),
        ('Videos', { Invoke-Item -Path "$env:USERPROFILE\Videos" }, $null, "shell32.dll,-116"),
        ('Pictures', { Invoke-Item -Path "$env:USERPROFILE\Pictures" }, $null, "shell32.dll,-113"),
        ('Exclusion', { Button_Add_Exclusion_Folder }, $null, "shell32.dll,-45"),
        ('Appdata', { Invoke-Item -Path $env:APPDATA }, $null, "shell32.dll,-154"),
        ('Temp', { Invoke-Item -Path $env:TEMP }, $null, "shell32.dll,-152"))
    ),
    ("Zed Toolkit", @(
        ("Add Shortcut", { Button_Add_Shortcut }, "Ajoute ZMT à ton ordinateur", ""),
        ("Backup User", { DownloadAndExecuteScript $script_dictionary.backup }, "Copie le contenu de $([System.Environment]::GetFolderPath("UserProfile")) sur un disque de votre choix", ""),
        ("Temp Folder", { Invoke-Item -Path $app_dict.temp_folder }, "Ouvre le dossier temporaire de ZMT", ""),
        ("Clean and Exit", { Button_CleanMyMess }, "Vide le dossier Temp, retire les raccouci et ferme ZMT", ""))
    ),
    ("Utility", @(
        ("Winget", { Button_Install_Winget }, "Install Winget Packet Manager", ""),
        ("Choco", { Button_Install_Choco }, "Install Choco Packet Manager", ""))
    )
)

Draw_Buttons -button_list $tools_list -wrap_panel $x_WP_Tools

$soft_list = @(
    ('Tools', @(
        ('Powershell', { Start-Process powershell }, ''),
        ('Debloat', { Button_Debloat }, 'Supprime les application bloatware de windows'),
        ('Titus', { Button_Titus }, 'Package installer + Windows Button_isation'))
    ),
    ('Software', @(
        ('Dipiscan', { DownloadAndExecuteScript $script_dictionary.download -params @{file_url = "zedcorp.fr/t/z/Dipiscan274_portable.zip" ; download_filename = "Dipiscan.exe" } }, $null),
        ('TreeSize', { DownloadAndExecuteScript $script_dictionary.download  -params @{file_url = "zedcorp.fr/t/z/TreeSizeFree-Portable.zip" ; download_filename = "TreeSizeFree.exe" } }, $null),
        ('Office Tool Plus', { DownloadAndExecuteScript $script_dictionary.download -params @{file_url = "https://download.coolhub.top/Office_Tool_Plus/10.18.11.0/Office_Tool_with_runtime_v10.18.11.0_x64.zip" ; download_filename = "Plus.exe" } }, $null),
        ('Vscode', { DownloadFromGithubAndRun -repo "portapps/vscode-portable" -github_token $github_token -github_filename_filter ".zip" -filename_filter "Code.exe" }, $null))
    ),
    ('Hack', @(
        ('SpotX', 
        {
            Write-Host "Installation de $($current.Text) [$($current.name)]"
            Invoke-Expression "& { $(Invoke-WebRequest -useb 'https://raw.githubusercontent.com/SpotX-Official/spotx-official.github.io/main/run.ps1') } -confirm_uninstall_ms_spoti -confirm_spoti_recomended_over -podcasts_off -block_update_on -start_spoti -new_theme -adsections_off -lyrics_stat spotify"
            Write-Host "Installation terminé de $($current.Text) : $rt"
        },
        "Spotify No Ads Mods"),
        ('MassGrave',
        {
            $job = Start-Job -ScriptBlock {
                Invoke-RestMethod https://get.activated.win | Invoke-Expression | Write-Host
            }
            $job | Wait-Job | Receive-Job
        },
        'Windows et Office Activateur'))
    )
)
Draw_Buttons -button_list $soft_list -wrap_panel $x_WP_Soft

Write-Info "Ready to go !"

#===========================================================================
# Closing
#===========================================================================

$form.add_Closing({
        Stop-Process -Id $PID
    })

$form.ShowDialog() | out-null

