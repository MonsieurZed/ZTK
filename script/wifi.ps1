
Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MonsieurZed/ZTK/refs/heads/main/entry.ps1").Content
if ($Global:debug) {
    . "$base_path/library/console.ps1"
}
else {
    Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MonsieurZed/ZTK/refs/heads/$Global:branch/library/console.ps1").Content
}

Console_Setup "Backup Tool"
Console_Header "Downloader"

# Add WiFi profiles backup
write-host ""
write-host "Starting WiFi profiles backup..."

# Create WiFi backup folder
$wifiBackupPath = Join-Path -Path $default_dict.temp_folder -ChildPath "WiFi_Profiles"
New-Item -ItemType Directory -Path $wifiBackupPath -Force | Out-Null

# Get all WiFi profiles
$wifiProfiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object { ($_ -split ":")[-1].Trim() }

# Export each profile with password
foreach ($profile in $wifiProfiles) {
    netsh wlan export profile name="$profile" folder="$wifiBackupPath" key=clear | Out-Null
    write-host "Saved profile: $profile"
}

write-host "WiFi profiles backup completed"
write-host "Profiles saved to: $wifiBackupPath"
