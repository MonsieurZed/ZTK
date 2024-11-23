#Run me to activate debug
Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MonsieurZed/ZTK/refs/heads/main/conf.ps1").Content
Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MonsieurZed/ZTK/refs/heads/main/library/console.ps1").Content

Write-Info "Activating Debug Mode"

if (-not (Test-Path -Path $env:TEMP\zedstoolkit\)) {
  New-Item -Path $env:TEMP\zedstoolkit\ -ItemType Directory | Out-Null
}

$success = $false
While (-not $success) {
  $path = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)
  $parentpath = (Split-Path -Path $path -parent)
  if (-not (Test-Path -Path (Join-Path -Path $parentpath -ChildPath "main.ps1"))) {
    Write-Info $parentpath
    Write-Cancel "Could not find main.ps1"
    $parentpath = Read-Host -Prompt "Please enter path to the folder of main.ps1 (ex: D:/ZMT/)"
  }
  else {
    $success = $true
  }
}

$debug = @{
  debug = $true
  path  = $parentpath 
} | ConvertTo-Json

Set-Content -Path $var_dict.debug -Value $debug -Force

if (Test-Path $var_dict.debug) {
  $json_debug = Get-Content -Path $var_dict.debug -Raw | ConvertFrom-Json
  $Global:debug = $json_debug.debug
  $Global:base_path = $json_debug.path
  write-host "Debug is activated"
  write-host "Path can be edited at $($var_dict.debug)"
} 
else {
  write-host "Debug has failed to activate"
}
