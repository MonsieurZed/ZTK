$default_dict = @{
  command     = "irm $Global:base_path/main.ps1 | iex"
  name        = "Zed's Toolkit"
  clearname   = "zedstoolkit"
  temp_folder = "$env:TEMP\zedstoolkit"
  icon_path   = "$Global:base_path/icon/purple-shark.ico" 
  version     = "v0.2.17"
}

$var_dict = @{
  debug        = "$($default_dict.temp_folder)\debug"
  github_token = "$($default_dict.temp_folder)\github_token"
}

$xaml_dict = @{
  main  = "$Global:base_path/xaml/MainWindow.xaml"
  style = "$Global:base_path/xaml/Style.xaml"
}

$json_dict = @{
  apps    = "$Global:base_path/json/app.json"
  web     = "$Global:base_path/json/web.json"
  package = "$Global:base_path/json/packages.json"
}

$script_dict = @{
  download  = "$Global:base_path/script/download.ps1"
  backup    = "$Global:base_path/script/backup.ps1"
  installer = "$Global:base_path/script/installer.ps1"
}

$library_dict = @{
  function    = "$Global:base_path/library/function.ps1"
  console     = "$Global:base_path/library/console.ps1"
  script      = "$Global:base_path/library/script.ps1"
  drawing     = "$Global:base_path/library/drawing.ps1"
  interaction = "$Global:base_path/library/interaction.ps1"
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

Function Load_Library {
  param (
    [Parameter(Position = 0, Mandatory = $true)]
    [object]$lib_path
  )
  write-host $lib_name
  if ($Global:debug) {
    . $lib_path
  }
  else {
    Invoke-Expression (Invoke-WebRequest -Uri $lib_path).Content
  }
}
