# Name: Gcloud Backup
# Author: alopez
# Version: 4.1

### Var declaration
$dateLogs    = Get-Date -UFormat "%Y%m%d"
$logFile     = "C:\Users\Admin\Desktop\GcloudLogs\logFile_$dateLogs.txt"
$outputFile    = "C:\Users\Admin\Desktop\GcloudLogs\outputFile_$dateLogs.txt"
$backupPaths = @("\\172.26.0.97\VeeamBackup\NAS_backup interno AX_QV_DC","\\172.26.0.97\VeeamBackup\NAS_backup interno Resto")
###

function getTime() {
	return Get-Date -UFormat "%d-%m-%Y @ %H:%M"
}


# We wrap all the code so we can send all the stdout and stderr to files in a single line
&{
	$timeNow = getTime
	echo ("Uploading Backups to Gcloud... Job started at " + $timeNow)

	foreach ($path in $backupPaths) {
		$dir = $path -replace '.*\\'
		gsutil -m rsync -d  -r "$path" "gs://srvbackuphid/backups/$dir"
	}

	$timeNow = getTime
	echo ("Uploading Backups to Gcloud... Job Finished at " + $timeNow)

}  2> $outputFile 1> $logFile

