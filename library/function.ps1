# ============================================================================================= 
# ================================   Function Library  ========================================
# ============================================================================================= 


function DownloadAndExecuteScript {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$script_url,
        [object]$params
    )

    $scriptName = [System.IO.Path]::GetFileName($script_url)
    $scriptPath = [System.IO.Path]::Combine($app_dict.temp_folder, $scriptName)


    if (Test-Path -Path $scriptPath) {
        $webRequest = Invoke-WebRequest -Uri $script_url -Method Head
        $remoteFileSize = [Convert]::ToInt64($webRequest.Headers["Content-Length"])
        $localFileSize = (Get-Item -Path $scriptPath).Length
        if ($localFileSize -ne $remoteFileSize) {
            Remove-Item -Path $scriptPath -Force
        }
    }

    if (!(Test-Path -Path $scriptPath)) {
        try {
            Invoke-WebRequest -Uri $script_url -OutFile $scriptPath
        }
        catch {
            Write-Error "[$($MyInvocation.ScriptLineNumber)] Failing to get $scriptName script : $_" 
            return
        }
    }
    try {
        $encoded = EncodeHastable $params
        Start-Process powershell -ArgumentList "-NoExit", "-File", $scriptPath, $encoded -Verb RunAs
    }
    catch {
        Write-Error "[$($MyInvocation.ScriptLineNumber)] Error start $scriptName : $_"  
    }
}

function DownloadFromGithubAndRun {
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
        Write-Cancel "Aucun fichier dans la dernière release."
        exit
    }

    $asset = $response.assets | Where-Object { $_.name -match $filter }
    DownloadAndExecuteScript $script_dict.download -params @{file_url = $asset.browser_download_url; download_filename = $asset.name ; filter_filename = $filename_filter }

}
