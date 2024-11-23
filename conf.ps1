
$Global:debug = $false
$Global:base_path = "https://raw.githubusercontent.com/MonsieurZed/ZTK/refs/heads/main"

if (Test-Path "$env:TEMP\zedstoolkit\debug") {
  $json_debug = Get-Content -Path "$env:TEMP\zedstoolkit\debug" -Raw | ConvertFrom-Json
  $Global:debug = $json_debug.debug
  $Global:base_path = $json_debug.path
} 

$version = "v0.2.13"

$default_dict = @{
  command     = "irm $base_path/main.ps1 | iex"
  name        = "Zed's Toolkit"
  clearname   = "zedstoolkit"
  temp_folder = "$env:TEMP\zedstoolkit"
  icon_path   = "$base_path/icon/purple-shark.ico" 
  version     = "0.2.12"
}

$var_dict = @{
  debug        = "$($default_dict.temp_folder)\debug"
  github_token = "$($default_dict.temp_folder)\github_token"
}

$xaml_dict = @{
  main = "$base_path/xaml/MainWindow.xaml"
}

$json_dict = @{
  apps    = "$base_path/json/app.json"
  web     = "$base_path/json/web.json"
  package = "$base_path/json/packages.json"
}

$script_dict = @{
  download = "$base_path/script/download.ps1"
  backup   = "$base_path/script/backup.ps1"
}

$library_dict = @{
  function    = "$base_path/library/function.ps1"
  console     = "$base_path/library/console.ps1"
  button      = "$base_path/library/button.ps1"
  drawing     = "$base_path/library/drawing.ps1"
  interaction = "$base_path/library/interaction.ps1"
}
$source = @{
  choco  = $false
  winget = $false
  github = $false
}

$conf_dict = @{
  winget = "winget"
  choco  = "choco"
  exe    = "exe"
  github = "github"
  iso    = "iso"
}

$web_dict = @{
  default = @("default")
  opera   = @(
    "C:\Users\$env:USERNAME\AppData\Local\Programs\Opera\launcher.exe",
    "C:\Users\$env:USERNAME\AppData\Local\Programs\Opera\opera.exe"
  )
  brave   = @(
    "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe",
    "C:\Users\$env:USERNAME\AppData\Local\BraveSoftware\Brave-Browser\Application\brave.exe"
  )
  chrome  = @(
    "C:\Program Files\Google\Chrome\Application\chrome.exe"
  )
  edge    = @(
    "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
  )
  firefox = @(
    "C:\Program Files\Mozilla Firefox\firefox.exe"
  )    
}
