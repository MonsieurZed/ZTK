
$library_dictionnary = @{
    function = "$base_path\library\functions.ps1"
}

. $library_dictionnary.function

$select=$false
Terminal_Setup "Backup"
Terminal_header "Backup"
                     
while($select -eq $false) {      

    # Liste des disques logiques disponibles
    $drives = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }

    # Afficher les disques disponibles
    write-host "Choose output drive :"
    foreach ($drive in $drives) {
        write-host "$($drive.DeviceID) - $($drive.VolumeName) : $([math]::Round($drive.FreeSpace / 1GB)) Go libres"
    }

    # Demande à l'utilisateur de choisir un disque pour la sauvegarde
    $driveLetter = Read-Host -Prompt "Enter drive letter (ex: D) : "

    # Vérifier que le disque choisi est valide
    $selectedDrive = $drives | Where-Object { $_.DeviceID -eq "${driveLetter}:" }
    if (!$selectedDrive) {
        write-header
        write-host "Disk is not valid or didn't exist"
        write-host "Please select again"
        write-host ""
    }
    else {
        $select=$true
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
    } else {
        write-host "Folder $folder doesn't exist."
    }
}

write-host "Backup is done"
