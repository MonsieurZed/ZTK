

Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MonsieurZed/ZTK/refs/heads/main/conf.ps1").Content
if ($debug) {
    . "$base_path/library/console.ps1"
}
else {
    Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MonsieurZed/ZTK/refs/heads/main/library/console.ps1").Content
}


Console_Setup
Console_Header "Downloader"
write-host $zed_dictionnary.name

$params = DecodeHastable $args[0]


write-host "Getting file info"  -ForegroundColor Cyan

$outputPath = "$env:TEMP\$AppClearName\"

if ($params.file_url -notmatch "^https?://") {
    $params.file_url = "https://$($params.file_url)"
}

if ($params.PSObject.Properties.Match("download_filename")) {
    $filename = ([System.IO.Path]::GetFileName($params.file_url)).ToString()
    $params | Add-Member -MemberType NoteProperty -Name "download_filename" -Value $filename -Force
}

$filePath = Join-Path -Path $outputPath -ChildPath $params.download_filename

$webRequest = Invoke-WebRequest -Uri $params.file_url -Method Head
$remoteFileSize = [Convert]::ToInt64($webRequest.Headers["Content-Length"])

if (Test-Path -Path $filePath) {
    $localFileSize = (Get-Item -Path $filePath).Length
    if ($localFileSize -ne $remoteFileSize) {
        Remove-Item -Path $filePath -Force
    }
}

write-host "Downloading From : $($params.file_url)"
write-host "Downloading To   : $filePath" 
write-host "Downloading Size : $remoteFileSize" 

if (!(Test-Path -Path $filePath)) { 
    if ($remoteFileSize -gt (100 * 1024 * 1024)) {   
        write-host "Downloading with BitsTransfer" -ForegroundColor Cyan
        try {
            $bitsTransfer = Start-BitsTransfer -Source $params.file_url -Destination $filePath -Asynchronous -Priority Normal

            $startTime = Get-Date
            $lastBytesTransferred = 0

            while ($bitsTransfer.JobState -eq [Microsoft.BackgroundIntelligentTransfer.Management.BitsJobState]::Transferring -or 
                $bitsTransfer.JobState -eq [Microsoft.BackgroundIntelligentTransfer.Management.BitsJobState]::Connecting) {

                $bitsTransfer = Get-BitsTransfer | Where-Object { $_.JobId -eq $bitsTransfer.JobId }

                $bytesTransferred = $bitsTransfer.BytesTransferred
                $bytesTotal = $bitsTransfer.BytesTotal
                $progressPercent = [math]::Round(($bytesTransferred / $bytesTotal) * 100, 2)

                $elapsedTime = (Get-Date) - $startTime
                $downloadSpeedBytesPerSec = ($bytesTransferred - $lastBytesTransferred) / $elapsedTime.TotalSeconds
                $downloadSpeedMBps = [math]::Round($downloadSpeedBytesPerSec / 1MB, 2)
                $lastBytesTransferred = $bytesTransferred
                $startTime = Get-Date  

                if ($downloadSpeedBytesPerSec -gt 0) {
                    $secondsRemaining = ($bytesTotal - $bytesTransferred) / $downloadSpeedBytesPerSec
                    $eta = [TimeSpan]::FromSeconds($secondsRemaining)
                }
                else {
                    $eta = [TimeSpan]::FromSeconds(0)
                }

                $totalSizeMB = [math]::Round($bytesTotal / 1MB, 2)
                $downloadedSizeMB = [math]::Round($bytesTransferred / 1MB, 2)

                Write-Progress -Activity "$params.download_filename" `
                    -Status "$progressPercent% - $downloadedSizeMB MB / $totalSizeMB MB - $downloadSpeedMBps MB/s - $($eta.ToString('hh\:mm\:ss'))" `
                    -PercentComplete $progressPercent

                Start-Sleep -Seconds 1 
            }

            # Finalise le transfert
            Complete-BitsTransfer -BitsJob $bitsTransfer
            write-host "Downloaded finished : $filePath"  -ForegroundColor Cyan
        }
        catch {
            write-host "Error while downloading : $_"  -ForegroundColor Red
            pause
        }
    }
    else {
        try {
            write-host "Downloading with HttpWebRequest"  -ForegroundColor Cyan
            $startTime = Get-Date
            # Requête initiale pour obtenir la taille du fichier, en utilisant Int64 pour les grands fichiers
            $request = [System.Net.WebRequest]::Create($params.file_url)
            $request.Method = "HEAD"
            $response = $request.GetResponse()
            $totalFileSize = [Int64]$response.ContentLength  # Utiliser Int64 pour les fichiers > 2 Go
            $response.Close()

            # Début du téléchargement par morceaux
            $webRequest = [System.Net.HttpWebRequest]::Create($params.file_url)
            $webRequest.Method = "GET"
            $webResponse = $webRequest.GetResponse()
            $responseStream = $webResponse.GetResponseStream()
            $fileStream = [System.IO.File]::Create($filePath)
            $buffer = New-Object byte[] 8192
            $totalBytesRead = 0

            while (($bytesRead = $responseStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                $fileStream.Write($buffer, 0, $bytesRead)
                $totalBytesRead += $bytesRead
                
                # Calculer la progression et l'ETA
                $progressPercent = [math]::Round(($totalBytesRead / $totalFileSize) * 100, 2)
                $elapsedTime = (Get-Date) - $startTime
                if ($totalBytesRead -gt 0) {
                    # Calcul de l'ETA en secondes pour éviter les problèmes de multiplication
                    $secondsRemaining = ($elapsedTime.TotalSeconds * ($totalFileSize - $totalBytesRead)) / $totalBytesRead
                    Write-Progress -Activity "Downloading $filePath" -Status "$progressPercent% " -PercentComplete $progressPercent -SecondsRemaining $secondsRemaining
                }
            }

            # Libérer les ressources
            $fileStream.Close()
            $responseStream.Close()
            $webResponse.Close()

            write-host "Finished : $filePath"  -ForegroundColor Cyan
        }
        catch {
            write-host "Error while downloading : $_"  -ForegroundColor Red
            pause
        }
    }
}


if (Test-Path -Path $filePath) {
    try {
        write-host "Staring $filePath..."  -ForegroundColor Cyan
        switch ([System.IO.Path]::GetExtension($filePath)) {
            '.iso' {
                write-host 'File extension : .iso' -ForegroundColor Cyan
                $mountResult = Mount-DiskImage -ImagePath $filePath -PassThru
                $driveLetter = ($mountResult | Get-Volume).DriveLetter
                $exeFiles = Get-ChildItem "$driveLetter`:\" -Filter *.exe -Recurse | Select-Object -First 1
                if ($exeFiles) {
                    $exePath = $exeFiles.FullName
                    write-host "Loading $exePath"
                    Start-Process -FilePath $exePath -wait
                    Dismount-DiskImage -ImagePath $filePath
                }
                else {
                    write-host "No exe file found"
                    Start-Process "$driveLetter`:\"
                }
            }
            '.exe' {
                write-host 'File extension : .exe' -ForegroundColor Cyan
                Start-Process -FilePath $filePath
            }
            '.msi' {
                write-host 'File extension : .msi' -ForegroundColor Cyan
                Start-Process -FilePath $filePath
            }
            '.zip' {
                write-host 'File extension : .zip' -ForegroundColor Cyan
                $extractPath = "$filePath-extracted"
                Add-Type -AssemblyName System.IO.Compression.FileSystem
                if (!(Test-Path -Path $extractPath)) {
                    New-Item -ItemType Directory -Path $extractPath | Out-Null
                    [System.IO.Compression.ZipFile]::ExtractToDirectory($filePath, $extractPath )
                }   
                $exeFile = Get-ChildItem -Path $extractPath -Filter $params.filter_filename -Recurse | Select-Object -First 1
                if ($exeFile) {
                    Start-Process -FilePath  $exeFile.FullName
                }
                else {
                    Write-Host "No .exe found in archive."  -ForegroundColor Red
                }
            }
        }
    }
    catch {
        write-host "Error opening $_"  -ForegroundColor Red
        pause
    }
}
else {
    write-host "Couldn't find file"  -ForegroundColor Red
}
pause
Stop-Process -Id $PID
