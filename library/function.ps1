# ============================================================================================= 
# ================================   Function Library  ========================================
# ============================================================================================= 
function Execute_Script {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$script_url,
        [object]$params = $null 
    )
    try {

        if ($null -eq $params) {
            Start-Process powershell -ArgumentList @(
                "-NoProfile",
                "-Command",
                "irm $script_url | iex;"
            )
        }
        else {
            $encoded = EncodeHastable $params
            Start-Process powershell -ArgumentList @(
                "-NoProfile",
                "-Command",
                "irm $script_url | iex; '$encoded'"
            )
        }
        

        # Start-Process powershell -ArgumentList "-NoExit", "-File", $scriptPath, $encoded -Verb RunAs
    }
    catch {
        Write-Error "Error starting $([System.IO.Path]::GetFileName($script_url)) : $_"  
    }
}

function Github_Download {
    param (
        [string]$repo,
        [string]$github_token,
        [string]$github_filename_filter = $null,
        [string]$filename_filter = $null
    )
    write-host $repo

    $apiUrl = "https://api.github.com/repos/$repo/releases/latest"
    $response = Invoke-RestMethod -Uri $apiUrl

    $asset = $response.assets | Where-Object { $_.name -like $github_filename_filter } | Select-Object -First 1

    if ($response.assets.Count -eq 0) {
        Write-Cancel "No file in last release"
        return
    }

    else {
        Execute_Script $script_dict.download -params @{file_url = $asset.browser_download_url; download_filename = $asset.name ; filter_filename = $filename_filter }
    }
    
}
