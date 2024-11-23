# ============================================================================================= 
# ================================   Function Library  ========================================
# ============================================================================================= 
function ExecuteScript {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$script_url,
        [object]$params
    )
    $scriptName = [System.IO.Path]::GetFileName($script_url)
    try {
        $encoded = EncodeHastable $params
        Start-Process powershell -ArgumentList @(
            "-NoProfile",
            "-Command",
            "irm $script_url | iex; '$encoded'"
        )
        # Start-Process powershell -ArgumentList "-NoExit", "-File", $scriptPath, $encoded -Verb RunAs
    }
    catch {
        Write-Error "[$($MyInvocation.ScriptLineNumber)] Error start $scriptName : $_"  
    }
}

function GithubDownload {
    param (
        [string]$repo,
        [string]$github_token,
        [string]$github_filename_filter = ".exe",
        [string]$filename_filter = ".exe"
    )

    $headers = @{
        Accept = "application/vnd.github.v3+json"
    }
    if ($github_token) { $headers.Authorization = "token $github_token" }

    $response = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases/latest" -Headers $headers

    if ($response.assets.Count -eq 0) {
        Write-Cancel "No file in last release"
        exit
    }

    $file_url = ""
    $response.assets | ForEach-Object {
        if ($_.name -match $github_filename_filter) {
            $file_url = $_.browser_download_url
        }
    }
    
    if ($file_url -eq "") {
        Write-Cancel "Couldn't file $github_filename_filter in $repo"

    }
    else {
        ExecuteScript $script_dict.download -params @{file_url = $file_url; download_filename = $asset.name ; filter_filename = $filename_filter }
    }
}
