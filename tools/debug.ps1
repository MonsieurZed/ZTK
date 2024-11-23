#Run me to activate debug
Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MonsieurZed/ZTK/refs/heads/main/conf.ps1").Content

if (-not (Test-Path -Path $env:TEMP\zedstoolkit\)) {
  New-Item -Path $env:TEMP\zedstoolkit\ -ItemType Directory | Out-Null
}
Set-Content -Path $var_dict.debug -Value $true -Force
write-host "Debug is activated"
