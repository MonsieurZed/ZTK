#Run me to activate debug
Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MonsieurZed/ZTK/refs/heads/main/conf.ps1").Content

if (-not (Test-Path -Path $env:TEMP\zedstoolkit\)) {
  New-Item -Path $env:TEMP\zedstoolkit\ -ItemType Directory | Out-Null
}

$debug = @{
  debug = $true
  path  = "D:/ZMT/"
} | ConvertTo-Json

Set-Content -Path $var_dict.debug -Value $debug -Force

if (Test-Path $var_dict.debug) {
  $json_debug = Get-Content -Path $var_dict.debug -Raw | ConvertFrom-Json
  $Global:debug = $json_debug.debug
  $Global:base_path = $json_debug.path
  write-host "Debug is activated"
} 
else {
  write-host "Debug has failed to activate"
}
