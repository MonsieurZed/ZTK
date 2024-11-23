#Run me to activate debug
Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MonsieurZed/ZTK/refs/heads/main/conf.ps1").Content

if (-not (Test-Path -Path $app_dict.temp_folder)) {
  New-Item -Path "$($app_dict.temp_folder)" -ItemType Directory | Out-Null
}

$current_debug = if (Test-Path "$env:TEMP\zedstoolkit\debug") { [bool](Get-Content -Path "$env:TEMP\zedstoolkit\debug" -Raw) } else { $false }
Set-Content -Path $var_dict.debug -Value $true -Force
write-host "Debug is activated"
