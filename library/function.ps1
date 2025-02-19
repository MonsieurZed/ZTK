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
    $headers = @{
        Accept = "application/vnd.github.v3+json"
    }
    if ($github_token -and ($github_token -ne 'no_token')) { $headers.Authorization = "token $github_token" }

    $response = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases/latest" -Headers $headers

    if ($response.assets.Count -eq 0) {
        Write-Cancel "No file in last release"
        return
    }

    $file_url = ""
    if ($github_filename_filter -eq $null) {
        $file_url = $response.assets[0].browser_download_url
    }
    else {
        $response.assets | ForEach-Object {
            if (($_.name -like $github_filename_filter) -or ($_.name -match $github_filename_filter)) {
                $file_url = $_.browser_download_url
            }
        }
    }

    if ($file_url -eq "") {
        if ($Global:debug) {
            $response.assets  | ForEach-Object { Write-Base $_.name }
        }
        Write-Cancel "Couldn't file $github_filename_filter in $repo"
        return
    }
    else {
        Execute_Script $script_dict.download -params @{file_url = $file_url; download_filename = $asset.name ; filter_filename = $filename_filter }
    }
    
}
