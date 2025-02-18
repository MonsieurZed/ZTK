# =============================================================================================   
# ||                                                                                         ||
# ||                                  Zed's Minitools                                        ||
# ||                                                                                         ||
# =============================================================================================    

#===========================================================================
# Conf loader
#===========================================================================

$Global:debug = $false

if (Test-Path "$env:TEMP\zedstoolkit\local.json") {
  $Global:local_json = Get-Content -Path "$env:TEMP\zedstoolkit\local.json" -Raw | ConvertFrom-Json
  $Global:debug = $local_json.debug
  $Global:base_path = $local_json.path
  $Global:branch = "debug"
  . "$($Global:base_path)/conf.ps1"
} 
else {
  $Global:branch = if ($MyInvocation.MyCommand -match "dev") { "dev" }else { "main" }
  $Global:base_path = "https://raw.githubusercontent.com/MonsieurZed/ZTK/refs/heads/$branch"
  Invoke-Expression (Invoke-WebRequest -Uri "$($Global:base_path)/conf.ps1").Content
}
