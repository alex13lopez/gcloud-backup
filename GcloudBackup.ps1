# Name: Gcloud Backup
# Author: Alex López <arendevel@gmail.com> || <alopez@hidalgosgroup.com>
# Version: 5.4b

########## Var & parms declaration #####################################################
param(
	[Parameter(Mandatory = $false)][switch]$clean = $false, 
	[Parameter(Mandatory = $false)][switch]$removeOld = $false,
	[Parameter(Mandatory = $false)][switch]$dryRun = $true # For now, we'll always go with dry run mode, until everything works like a charm
	)
	
$dateLogs      = Get-Date -UFormat "%Y%m%d"
$logDir        = "C:\Users\Admin\Desktop\GcloudLogs"
$logFile       = "$logDir\logFile_$dateLogs.txt"
$errorLog    = "$logDir\errorLog_$dateLogs.txt"
$cleanLog      = "$logDir\cleanLogFile_$dateLogs.txt"
$removeErrorLog    = "$logDir\removeErrorLog_$dateLogs.txt"
$backupPaths   = @("\\172.26.0.97\VeeamBackup\Backup-AX_QV_DC-F","\\172.26.0.97\VeeamBackup\Backup-Resto-F") #TO DO: Add VeeamBackupConfig & Replicas
$serverPath    = "gs://srvbackuphidreborn/backups"
$daysToKeepBK  = 8 # 8 days because in case it's Sunday we'll keep the last full backup made on last Saturday

#########################################################################################

function getTime() {
	return Get-Date -UFormat "%d-%m-%Y @ %H:%M"
}


function autoClean() {

		$currYear = Get-Date -UFormat "%Y"
		$prevYear = $currYear - 1
		
		
		&{
				
			$timeNow = getTime
			echo ("Autocleaning started at " + $timeNow)
			
			if (!$dryRun) {
				rm "$logDir\*_$prevYear*"
			}
				
			$timeNow = getTime
			echo ("Autocleaning finished at " + $timeNow)
			
		} 2> 1 1> $cleanLog
		
		
}


function removeOldBackups() {
	
	$lastWeek = (Get-Date (Get-Date).AddDays($daysToKeepBK * (-1)) -UFormat "%Y%m%d") # Cambiamos a negativo el $daysToKeepBK para restar dias
	
	$files = @(gsutil ls -R "$serverPath" | Select-String -Pattern "\..*$")
	
	if (! [string]::IsNullOrEmpty($files)) { 
	
		$timeNow = getTime
	    echo ("Removing old backup files' job started at " + $timeNow) 1>> $logFile
		
		foreach ($file in $files) {
		
			$fileName = ($file -Split "/")[-1]
			$fileDate = ((($file -Split "F")[1] -Split "T")[0]) -Replace "[-]"
			$fileExt = ($fileName -Split ".")[-1]
			
			if ($fileExt -ne "vbm") { # We skip '.vbm' files since they are always the same and don't have date on it
				if ($dryRun) {
					echo "File: $file"
					echo "FileName: $fileName || fileDate: $fileDate" 
					echo ""
				}
				
				&{
				
					if ($fileDate -lt $lastWeek) {
						echo "The file: '$fileName' is older than $daysToKeepBK days... Wiping out!"
						if (!$dryRun) {				
							gsutil -m -q rm -a "$file" # -m makes the operation multithreaded. -q causes gsutil to be quiet, basically: No progress reporting, only errors
						}
					}
					
				} 2>> $removeErrorLog 1>> $logFile 
			}
		}
		
		$timeNow = getTime
	    echo ("Removing old backup files' job finished at " + $timeNow) 1>> $logFile 
	}
	else {echo "Could not get the files"}
	
}


function doUpload() {

	# We wrap all the code so we can send all the stdout and stderr to files in a single line
	&{
		
		$timeNow = getTime
		echo ("Uploading Backups to Gcloud... Job started at " + $timeNow)

		foreach ($path in $backupPaths) {
			$dirName = $path -replace '.*\\'	
			
			$timeNow = getTime
			echo ("Uploading $dirName to Gcloud... Job started at " + $timeNow)
			
			if (!dryRun) {
				gsutil -m -q cp -r "$path" "$serverPath/$dirName"
			}
			
			$timeNow = getTime
			echo ("Uploading $dirName to Gcloud... Job Finished at " + $timeNow)
		}

		$timeNow = getTime
		echo ("Uploading Backups to Gcloud... Job Finished at " + $timeNow)

	}  2> $errorLog 1> $logFile
	
}


if ($clean) {
	autoClean
} 
elseif ($removeOld) {
	removeOldBackups
} 
else {
	doUpload
}

