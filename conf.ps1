
try {
  $debug = if (Test-Path "$env:TEMP\zedstoolkit\debug") { Get-Content -Path "$env:TEMP\zedstoolkit\debug" -Raw }
}
catch {
  $debug = $false
}

$version = "v0.2.12"
$base_path = if ($debug) { "D:\ZMT" } else { "https://raw.githubusercontent.com/MonsieurZed/ZTK/refs/heads/main/" }


$app_dict = @{
  command     = "irm $base_path/main.ps1 | iex"
  name        = "Zed's Toolkit"
  clearname   = "zedstoolkit"
  temp_folder = "$env:TEMP\zedstoolkit"
  icon_path   = "$base_path/icon/purple-shark.ico" 
  version     = "0.2.12"
}

$var_dict = @{
  debug        = "$($app_dict.temp_folder)\debug"
  github_token = "$($app_dict.temp_folder)\github_token"
}

$xaml_dict = @{
  main = "$base_path/xaml/MainWindow.xaml"
}

$json_dict = @{
  apps    = "$base_path/json/app.json"
  web     = "$base_path/json/web.json"
  package = "$base_path/json/packages.json"
}

$script_dictionary = @{
  download = "$base_path/script/download.ps1"
  backup   = "$base_path/script/backup.ps1"
}

$library_dictionary = @{
  function = "$base_path/library/function.ps1"
  console  = "$base_path/library/console.ps1"
}

$source = @{
  choco  = $false
  winget = $false
  github = $false
}

$app_dictionary = @{
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
