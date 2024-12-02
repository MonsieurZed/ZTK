# =============================================================================================   
# ||                                                                                         ||
# ||                                  Zed's Minitools                                        ||
# ||                                                                                         ||
# =============================================================================================    

#===========================================================================
# Config
#===========================================================================

Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MonsieurZed/ZTK/refs/heads/main/entry.ps1").Content

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
        $source.winget = Script_Winget
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
        $source.choco = Script_Choco
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
catch {
    Write-Error "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed." 
    Write-Error $_
    Pause
    exit
}
 
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
    $data_app = Get-Content -Path $data_dict.apps -Raw | ConvertFrom-Json
    $data_ext = Get-Content -Path $data_dict.web -Raw | ConvertFrom-Json
    $data_pac = Get-Content -Path $data_dict.package -Raw | ConvertFrom-Json
    $data_btn = Invoke-Expression (Get-Content $data_dict.commands -Raw)
}
else {
    $data_app = Invoke-WebRequest -Uri $data_dict.apps -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json
    $data_ext = Invoke-WebRequest -Uri $data_dict.web -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json
    $data_pac = Invoke-WebRequest -Uri $data_dict.package -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json
    $data_btn = Invoke-Expression (Invoke-WebRequest -Uri $data_dict.commands).Content
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

$applications = Draw_Checkboxes -list $data_app  -wrap_panel $x_WP_Applications -source $source -resources $resource_dictionary
$x_Button_Applications.Add_Click({ Button_Applications -list $applications })

$extensions = Draw_Checkboxes -list $data_ext -wrap_panel $x_WP_Extensions -resources $resource_dictionary
$x_Button_Extensions.Add_Click({ Button_Extensions -list $extensions })

$packages = Draw_Package -list $data_pac -combo_box $x_Dropdown_Packages -resources $resource_dictionary
$x_Dropdown_Packages.Add_DropDownClosed({ Load_Application -list $applications -array $x_Dropdown_Packages.SelectedItem.Tag })

Draw_Buttons -list $data_btn[0] -wrap_panel $x_WP_Windows -resources $resource_dictionary

Draw_Buttons -list $data_btn[1] -wrap_panel $x_WP_Tools -resources $resource_dictionary

Draw_Buttons -list $data_btn[2] -wrap_panel $x_WP_Soft -resources $resource_dictionary

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

