
Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MonsieurZed/ZTK/refs/heads/main/conf.ps1").Content
Load_Library $library_dict.console 


if ($Global:debug) {
    $json_app = Get-Content -Path $json_dict.console -Raw | ConvertFrom-Json
    $json_ext = Get-Content -Path $json_dict.web -Raw | ConvertFrom-Json
    $json_pac = Get-Content -Path $json_dict.package -Raw | ConvertFrom-Json
}
else {
    $json_app = Invoke-WebRequest -Uri $json_dict.console -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json
    $json_ext = Invoke-WebRequest -Uri $json_dict.web -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json
    $json_pac = Invoke-WebRequest -Uri $json_dict.package -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json
}

Console_Setup "Downloader"
Console_Header "Downloader"

$ExecutionContext.InvokeCommand.RegisterEngineEvent([System.Console]::CancelKeyPress, {
        # Command to execute when console is closing
        Write-Host "Console is closing. Executing cleanup..."
        Pause
    })

while ($select -eq $false) {      

    # Liste des disques logiques disponibles
    $drives = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }

    # Afficher les disques disponibles
    write-host "Choose output drive :"
    foreach ($drive in $drives) {
        write-host "$($drive.DeviceID) - $($drive.VolumeName.PadLeft((($drive.VolumeName.Length + 12) / 2), " ").PadRight(12, " ")) : $([math]::Round($drive.FreeSpace / 1GB)) Go libres"
    }

    # Demande à l'utilisateur de choisir un disque pour la sauvegarde
    $driveLetter = Read-Host -Prompt "Enter drive letter (ex: D) "

    # Vérifier que le disque choisi est valide
    $selectedDrive = $drives | Where-Object { $_.DeviceID -eq "${driveLetter}:" }
    if (!$selectedDrive) {
        write-header
        write-host "Disk is not valid or didn't exist"
        write-host "Please select again"
        write-host ""
    }
    else {
        $select = $true
    }
}

# Demander le nom du dossier de sauvegarde
$backupFolderName = "Save_$(Get-Date -Format "HH_mm_dd_MM_yyyy")"

# Créer le chemin complet pour la sauvegarde
$backupPath = Join-Path -Path "${driveLetter}:" -ChildPath $backupFolderName

# Vérifier si le dossier de destination existe, sinon le créer
if (!(Test-Path -Path $backupPath)) {
    New-Item -ItemType Directory -Path $backupPath | Out-Null
    write-host "Folder $backupPath has been created"
    write-host ""
}

# Obtenir le chemin du répertoire utilisateur
$userProfilePath = [System.Environment]::GetFolderPath("UserProfile")

# Dossiers à sauvegarder (Documents, Bureau, Téléchargements, etc.)
$foldersToBackup = @("Desktop", "Documents", "Downloads", "Pictures", "Videos", "Music")

# Utiliser Robocopy pour copier chaque dossier
foreach ($folder in $foldersToBackup) {
    $sourceFolder = Join-Path -Path $userProfilePath -ChildPath $folder
    $destinationFolder = Join-Path -Path $backupPath -ChildPath $folder

    # Vérifier si le dossier source existe avant de copier
    if (Test-Path -Path $sourceFolder) {
        # Commande Robocopy
        write-host "Copy from $sourceFolder to $destinationFolder using Robocopy..."
        Start-Process -NoNewWindow -FilePath "robocopy" -ArgumentList "`"$sourceFolder`" `"$destinationFolder`" /E /R:3 /W:5" -Wait
        write-host "Saving $folder done."
        write-host ""
    }
    else {
        write-host "Folder $folder doesn't exist."
    }
}

write-host "Backup is done"
