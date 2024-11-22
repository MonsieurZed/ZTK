$version = "v0.2.00"
$debug = $env:USERNAME -eq "Zed"
$base_path = if ($debug) { "D:\ZMT" } else { "https://raw.githubusercontent.com/MonsieurZed/ZTK/refs/heads/main/" }


$zed_dictionnary = @{
  command     = "irm $base_path/main.ps1 | iex"
  name        = "Zed's Toolkit"
  clearname   = "zedstoolkit"
  temp_folder = "$env:TEMP\zedstoolkit"
  icon_path   = "$base_path/icon/purple-shark.ico" 
}

$xaml_dictionnary = @{
  main = "$base_path/xaml/MainWindow.xaml"
}

$json_dictionnary = @{
  apps    = "$base_path/json/app.json"
  web     = "$base_path/json/web.json"
  package = "$base_path/json/packages.json"
}

$script_dictionary = @{
  download = "$base_path/script/download.ps1"
  backup   = "$base_path/script/backup.ps1"
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

$web_dictionnary = @{
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
