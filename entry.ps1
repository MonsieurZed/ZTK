# =============================================================================================   
# ||                                                                                         ||
# ||                                  Zed's Minitools                                        ||
# ||                                                                                         ||
# =============================================================================================    

#===========================================================================
# Conf loader
#===========================================================================

$Global:debug = $false

if (Test-Path "$env:TEMP\zedstoolkit\debug") {
  $json_debug = Get-Content -Path "$env:TEMP\zedstoolkit\debug" -Raw | ConvertFrom-Json
  $Global:debug = $json_debug.debug
  $Global:base_path = $json_debug.path
  . "$($Global:base_path)/conf.ps1"
} 
else {
  $Global:branch = if ($MyInvocation.MyCommand -match "dev") { "dev" }else { "main" }
  $Global:base_path = "https://raw.githubusercontent.com/MonsieurZed/ZTK/refs/heads/$branch"
  Invoke-Expression (Invoke-WebRequest -Uri "$($Global:base_path)/conf.ps1").Content
}
