$BackupName = ""
$Backup = Get-VBRBackup -Name ($BackupName + "_imported")
$VBMFile = "$env:UserProfileDesktop" + "$BackupName" + ".vbm"

$Data = [Veeam.Backup.Core.CBackupMetaGenerator]::GenerateMeta($Backup)
$Data.Serialize() | Out-File $VBMFile
$xml = New-Object XML
$xml.Load($VBMFile)
$xml.BackupMeta.JobName = $BackupName
$xml.Save($VBMFile)
Remove-VBRBackup -Backup $Backup -Confirm:$false