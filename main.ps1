# =============================================================================================   
# ||                                                                                         ||
# ||                                  Zed's Minitools                                        ||
# ||                                                                                         ||
# =============================================================================================    

#===========================================================================
# Config
#===========================================================================

Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MonsieurZed/ZTK/refs/heads/main/conf.ps1").Content

# ===========================================================================
# Admin     
# ============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


$admin = $false
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "$($default_dict.command)" -Verb RunAs
    exit
}
else {
    $admin = $true
}

$currentProcess = Get-Process | Where-Object { $_.Id -eq $PID }
Get-Process -Name $currentProcess.Name | Where-Object { $_.Id -ne $currentProcess.Id } | Stop-Process -Force


# ===========================================================================
# Load libraries    
# ============================================================================

if ($Global:debug) {
    Get-ChildItem -Path "$base_path\library\" -Filter "*.ps1" | ForEach-Object { . $_.FullName }

}
else {
    $library_dict.GetEnumerator() | ForEach-Object { Invoke-Expression (Invoke-WebRequest -Uri $_.Value).Content }
}

# ===========================================================================
# Configure console   
# ============================================================================

Console_Setup 
Console_Header 

if (-not (Test-Path -Path $default_dict.temp_folder)) {
    New-Item -Path "$($default_dict.temp_folder)" -ItemType Directory | Out-Null
}

# =============================================================================================     
#  Package manager  
# =============================================================================================  

if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Sucess "Winget is installed"
    $source.winget = $true
}
else {
    Write-Event "Some packages need Winget to be installed" 
    $result = Read-Host " - Would you like to install it now? (Y/n)"
    if ($result.ToLower() -ieq "y") {
        $source.winget = Install_Winget
    }
}

if (Get-Command choco -ErrorAction SilentlyContinue) {
    $source.choco = $true
    Write-Sucess "Choco is installed"

}
else {
    Write-Event "Some packages need Choloatey to be installed" 
    $result = Read-Host "Would you like to install it now? (Y/n)"
    if ($result.ToLower() -ieq "y") {
        $source.choco = Install_Choco
    }
}

$github_token = if (Test-Path $var_dict.github_token) { Get-Content -Path $var_dict.github_token -Raw } else { $null }

if ($github_token -eq $null) { 
    $github_token = Read-Host "(Optionel) Enter your GitHub token (https://github.com/settings/tokens)" 
    if (-not [string]::IsNullOrWhiteSpace($github_token)) {
        $save = Read-Host "Do you want to save the token for later use  (Y/n)" 
    }
    if ($github_token) {
        if ($save.ToLower() -ieq "y") { 
            Set-Content -Path $var_dict.github_token -Value $github_token
            Write-Event "Github token saved at $($var_dict.github_token)"
        }
    } 
}

if ($github_token) {
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
        if ($Global:debug) {
            Write-Error "Error : $($_.Exception.Message)" 
        }
    }
}
else {
    Write-Cancel "User did not specify an github token" 
}

#===========================================================================
# Load XAML  and Forms
#===========================================================================

Write-Info "Loading xaml..."

if ($Global:debug) { 
    Write-Info "Debug mode"
    $inputXML = Get-Content $xaml_dict.main
}
else {
    $inputXML = Invoke-WebRequest -Uri $xaml_dict.main -UseBasicParsing | Select-Object -ExpandProperty Content
}

$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
 
 
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
 
$reader = (New-Object System.Xml.XmlNodeReader $xaml) 
try { $form = [Windows.Markup.XamlReader]::Load( $reader ) }
catch { Write-Error "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed." }
 
$xaml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name "x_$($_.Name)" -Value $form.FindName($_.Name) }
$form.GetType().GetProperties() | ForEach-Object {
    $elementName = $_.Name
    Set-Variable -Name "x_$elementName" -Value $form.FindName($elementName)
}

#===========================================================================
# WPF Loading
#===========================================================================

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class User32 {
   [DllImport("user32.dll")]
   [return: MarshalAs(UnmanagedType.Bool)]
   public static extern bool ReleaseCapture();
   
   [DllImport("user32.dll")]
   public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
}
"@

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

$resource_dictionary = Load_Resource_Dictionary -xamlFilePath $xaml_dict.style

if ($Global:debug) {
    $json_app = Get-Content -Path $json_dict.apps -Raw | ConvertFrom-Json
    $json_ext = Get-Content -Path $json_dict.web -Raw | ConvertFrom-Json
    $json_pac = Get-Content -Path $json_dict.package -Raw | ConvertFrom-Json
}
else {
    $json_app = Invoke-WebRequest -Uri $json_dict.apps -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json
    $json_ext = Invoke-WebRequest -Uri $json_dict.web -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json
    $json_pac = Invoke-WebRequest -Uri $json_dict.package -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json
}

$x_Button_Copy_Applications.Add_Click({ Copy_Applications -list $applications })
$x_Button_Paste_Applications.Add_Click({ Paste_Applications -list $applications })
$x_Button_Clear_Applications.Add_Click({ Clear_Applications -list $applications })

$x_R_Winget.Foreground = if ($source.winget) { 'Green' }else { 'red' }
$x_R_Winget.Tooltip = if (!$source.winget) { "Winget n'est pas installé, certaine applications ne seront donc pas accessible." }
$x_R_Choco.Foreground = if ($source.choco) { 'Green' }else { 'red' }
$x_R_Choco.Tooltip = if (!$source.choco) { "Chocolatey n'est pas installé, certaine applications ne seront donc pas accessible." }
$x_R_Github.Foreground = if ($source.github) { 'Green' }else { 'red' }
$x_R_Github.Tooltip = if (!$source.github) { "Pas de Token Github, certaine applications ne seront donc pas accessible." }
$x_R_Admin.Foreground = if ($admin) { 'Green' }else { 'red' }

$applications = Draw_Checkboxes -json $json_app  -wrap_panel $x_WP_Applications -source $source -resources $resource_dictionary
$x_Button_Applications.Add_Click({ Button_Applications -list $applications })

$extensions = Draw_Checkboxes -json $json_ext -wrap_panel $x_WP_Extensions -resources $resource_dictionary
$x_Button_Extensions.Add_Click({ Button_Applications -list $extensions })

$packages = Draw_Package -json $json_pac -combo_box $x_Dropdown_Packages -resources $resource_dictionary
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

Draw_Buttons -button_list $windows_list -wrap_panel $x_WP_Windows -resources $resource_dictionary

$tools_list = @(
    ('Folder', @(
        ('User', { Invoke-Item -Path $env:USERPROFILE }, $null, "shell32.dll,-1024"),
        ('Desktop', { Invoke-Item -Path "$env:USERPROFILE\Desktop" }, $null, "shell32.dll,-108"),
        ('Documents', { Invoke-Item -Path "$env:USERPROFILE\Documents" }, $null, "shell32.dll,-112"),
        ('Downloads', { Invoke-Item -Path "$env:USERPROFILE\Downloads" }, $null, "shell32.dll,-226"),
        ('Videos', { Invoke-Item -Path "$env:USERPROFILE\Videos" }, $null, "shell32.dll,-116"),
        ('Pictures', { Invoke-Item -Path "$env:USERPROFILE\Pictures" }, $null, "shell32.dll,-113"),
        ('Exclusion', { Script_Add_Exclusion_Folder }, $null, "shell32.dll,-45"),
        ('Appdata', { Invoke-Item -Path $env:APPDATA }, $null, "shell32.dll,-154"),
        ('Temp', { Invoke-Item -Path $env:TEMP }, $null, "shell32.dll,-152"))
    ),
    ("Zed Toolkit", @(
        ("Add Shortcut", { Script_Add_Shortcut }, "Ajoute ZMT à ton ordinateur", ""),
        ("Backup User", { Execute_Script $script_dict.backup }, "Copie le contenu de $([System.Environment]::GetFolderPath("UserProfile")) sur un disque de votre choix", ""),
        ("Temp Folder", { Invoke-Item -Path $default_dict.temp_folder }, "Ouvre le dossier temporaire de ZMT", ""),
        ("Clean and Exit", { Script_Clean_App }, "Vide le dossier Temp, retire les raccouci et ferme ZMT", ""))
    ),
    ("Utility", @(
        ("Winget", { Install_Winget }, "Install Winget Packet Manager", ""),
        ("Choco", { Install_Choco }, "Install Choco Packet Manager", ""))
    )
)

Draw_Buttons -button_list $tools_list -wrap_panel $x_WP_Tools -resources $resource_dictionary

$soft_list = @(
    ('Tools', @(
        ('Powershell', { Start-Process powershell }, ''),
        ('Debloat', { Script_Debloat }, 'Supprime les application bloatware de windows'),
        ('Titus', { Script_Titus }, 'Package installer + Windows Script_isation'))
    ),
    ('Software', @(
        ('Dipiscan', { Execute_Script $script_dict.download -params @{file_url = "https://www.dipisoft.com/file/Dipiscan274_portable.zip" ; filter_filename = "Dipiscan.exe" } }, $null),
        ('TreeSize', { Execute_Script $script_dict.download  -params @{file_url = "https://downloads.jam-software.de/treesize_free/TreeSizeFreeSetup.exe" ; filter_filename = "TreeSizeFree.exe" } }, $null),
        ('Sublime Text', { Execute_Script $script_dict.download  -params @{file_url = "https://download.sublimetext.com/Sublime%20Text%20Build%203211.zip" ; filter_filename = "sublime_text.exe" } }, $null),
        ('Office Tool Plus', { Execute_Script $script_dict.download -params @{file_url = "https://download.coolhub.top/Office_Tool_Plus/10.18.11.0/Office_Tool_with_runtime_v10.18.11.0_x64.zip" ; filter_filename = "Plus.exe" } }, $null))
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
Draw_Buttons -button_list $soft_list -wrap_panel $x_WP_Soft -resources $resource_dictionary

Write-Info "Ready to go !"

#===========================================================================
# Closing
#===========================================================================
$form.add_Closing({
        Write-Info "Closing..."
        Get-ChildItem -Path $default_dict.temp_folder -File -Filter "*.tmp" -Force | Remove-Item -Force
        Stop-Process -Id $PID
    })
$form.ShowDialog() | out-null

