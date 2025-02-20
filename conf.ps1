$default_dict = @{
  command     = "irm $Global:base_path/main.ps1 | iex"
  name        = "Zed's Toolkit"
  clearname   = "zedstoolkit"
  temp_folder = "$env:TEMP\zedstoolkit"
  icon_path   = "$Global:base_path/icon/logo.ico"
  version     = "$Global:branch.0.2.24"
}

$var_dict = @{
  local_json = "$($default_dict.temp_folder)\local.json"
}

$xaml_dict = @{
  main  = "$Global:base_path/xaml/MainWindow.xaml"
  style = "$Global:base_path/xaml/Style.xaml"
}

$data_dict = @{
  apps     = "$Global:base_path/data/app.json"
  web      = "$Global:base_path/data/web.json"
  package  = "$Global:base_path/data/packages.json"
  commands = "$Global:base_path/data/commands.ps1"
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
  opera   = @{
    path = @(
      "C:\Users\$env:USERNAME\AppData\Local\Programs\Opera\launcher.exe",
      "C:\Users\$env:USERNAME\AppData\Local\Programs\Opera\opera.exe"
    )
    reg  = @()
  }
  brave   = @{
    path = @(
      "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe",
      "C:\Users\$env:USERNAME\AppData\Local\BraveSoftware\Brave-Browser\Application\brave.exe"
    )
    reg  = @()
  }
  chrome  = @{
    path = @(
      "C:\Program Files\Google\Chrome\Application\chrome.exe"
    )
    reg  = @("HKEY_LOCAL_MACHINE\Software\Wow6432Node\Google\Chrome\Extensions\")
  }
  edge    = @{
    path = @(
      "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    )
    reg  = @()
  }
  firefox = @{
    path = @(
      "C:\Program Files\Mozilla Firefox\firefox.exe"
    )
    reg  = @()
  }    
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
      password = "about:logins"
    }
    reg  = @()
  }    
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
