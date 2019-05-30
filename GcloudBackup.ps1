# Name: Gcloud Backup
# Author: Alex López <arendevel@gmail.com> || <alopez@hidalgosgroup.com>
# Version: 7.0a

########## Var & parms declaration #####################################################
param(
    [Parameter(Mandatory = $false)][switch]$all       = $false,
	[Parameter(Mandatory = $false)][switch]$clean     = $false, 
	[Parameter(Mandatory = $false)][switch]$removeOld = $false,
	[Parameter(Mandatory = $false)][switch]$dryRun    = $false
	)
	
$dateLogs          = Get-Date -UFormat "%Y%m%d"
$logDir            = "C:\Gcloud\GcloudLogs"
$logFile           = "$logDir\$dateLogs\logFile.txt"
$errorLog          = "$logDir\$dateLogs\errorLog.txt"
$cleanLog          = "$logDir\$dateLogs\cleanLogFile.txt"
$removeLogFile     = "$logDir\$dateLogs\removeLogFile.txt"
$removeErrorLog    = "$logDir\$dateLogs\removeOldErrorLog.txt"
$backupPaths       = @("Z:\Backups\SRVAXAPTA", "Z:\Backups\SERVERTS", "Z:\Backups\SRVDATOS", "Z:\Backups\SRVDC", "Z:\Backups\QLIKSERVER", "Z:\Backups\SRVAPPS", "Z:\Backups\vCenter", "Z:\Backups\SRVVEEAM")
$serverPath        = "gs://srvbackuphidreborn/backups"
$daysToKeepBK      = 8 # 8 days because in case it's Sunday we'll keep the last full backup made on last Saturday

#########################################################################################

function getTime() {
	return Get-Date -UFormat "%d-%m-%Y @ %H:%M"
}

function genEncryptedPassword() {
	(Get-Credential).Password | ConvertFrom-SecureString | Out-File ".\MailPassword.txt"
}

function mailLogs($subject, $message) {
	
	# Credentials Setup
	$User = "hidalgosgroupSL@gmail.com"
	$File = ".\Veeam-MailPassword.txt"
	$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (Get-Content $File | ConvertTo-SecureString)
	
	# Mail Setup
	$EmailTo = "informatica@hidalgosgroup.com"
	$EmailFrom = "hidalgosgroupSL@gmail.com"
	$Subject = "Test Mailing - Gcloud Backups" 
	$Body = "<h2>This is a test, ignore this message, bitches.</h2><br><br>Saludos, TOPOTAMADRE." 

	# SMTP Server Setup 
	$SMTPServer = "smtp.gmail.com" 

	# SMTP Message
	$SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
	$SMTPMessage.isBodyHTML = $true

	# SMTP Client Setup
	$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
	$SMTPClient.EnableSsl = $true
	$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($cred.UserName, $cred.Password); 
	$SMTPClient.Send($SMTPMessage)
	
	# Continue here boyyyyy....
	
}

function createLogFolder() {
	mkdir "$logDir\$dateLogs" -ErrorAction Continue 2>&1> $null
}

function autoClean() {

		$currYear = Get-Date -UFormat "%Y"
		$prevYear = $currYear - 1	
		
		&{
			if ($dryRun) {
				echo "Running in 'dryRun' mode: No changes will be made."
			}
				
			$timeNow = getTime
			echo ("Autocleaning started at " + $timeNow)
			
			if (!$dryRun) {
				rm "$logDir\*$prevYear*"
			}
				
			$timeNow = getTime
			echo ("Autocleaning finished at " + $timeNow)
			
		} 2>> $errorLog 1>> $logFile
		
		
}


function removeOldBackups() {
	
	$lastWeek = (Get-Date (Get-Date).AddDays($daysToKeepBK * (-1)) -UFormat "%Y%m%d") # Cambiamos a negativo el $daysToKeepBK para restar dias
	
	$files = @(gsutil ls -R "$serverPath" | Select-String -Pattern "\..*$")
	
	if (! [string]::IsNullOrEmpty($files)) { 
	
		$timeNow = getTime
	    echo ("Removing old backup files' job started at " + $timeNow) 1>> $logFile
		
		&{
			if ($dryRun) {
				echo "Running in 'dryRun' mode: No changes will be made."
			}
		
			foreach ($file in $files) {
			
				$fileName = ($file -Split "/")[-1]
				$fileDate = ((($file -Split "D")[-1] -Split "T")[0]) -Replace '-'
				$fileExt  = ($fileName -Split "\.")[-1]
				
					if ($fileExt -ne "vbm") { # We skip '.vbm' files since they are always the same and don't have date on it					
							
							if ($fileDate -lt $lastWeek) {
								echo "The file: '$fileName' is older than $daysToKeepBK days... Wiping out!"
													
								if (!$dryRun) {				
									gsutil -m -q rm -a "$file" # -m makes the operation multithreaded. -q causes gsutil to be quiet, basically: No progress reporting, only errors
								}
							}
											
					}
				 
			}
			
		} 2>> $removeErrorLog 1> $removeLogFile
		
		$timeNow = getTime
	    echo ("Removing old backup files' job finished at " + $timeNow) 1>> $logFile 
	}
	else {echo "Could not get the files"}
	
}


function doUpload() {

	# We wrap all the code so we can send all the stdout and stderr to files in a single line
	&{
		if ($dryRun) {
				echo "Running in 'dryRun' mode: No changes will be made."
		}
		
		$timeNow = getTime
		echo ("Uploading Backups to Gcloud... Job started at " + $timeNow)

		foreach ($path in $backupPaths) {
			$dirName = $path -replace '.*\\'
			
			$timeNow = getTime
			echo ("Uploading $dirName to Gcloud... Job started at " + $timeNow)
			
			# In case the first upload takes more than 24h we make sure that there is a folder for today's logs
			try {
				createLogFolder
			}
			catch {
				continue
			}
			
			if (!$dryRun) {
				# Changed back to rsync because copy does copy all the files whether they are changed or not
				# But now, -d option is skipped since we deal with the old backup files manually with removeOldBackups
				gsutil -m -q rsync -r "$path" "$serverPath/$dirName"
			}
			
			$timeNow = getTime
			echo ("Uploading $dirName to Gcloud... Job finished at " + $timeNow)
			
		}

		$timeNow = getTime
		echo ("Uploading Backups to Gcloud... Job finished at " + $timeNow)

	}  2>> $errorLog 1>> $logFile
	
}

try {
	if ($clean) {
		createLogFolder
		autoClean
	} 
	elseif ($removeOld) {
		createLogFolder
		removeOldBackups
	}
	elseif ($All) {
		createLogFolder
		autoClean
		doUpload
		removeOldBackups
	}
	else {
		createLogFolder
		doUpload
	}
}
catch [System.IO.DirectoryNotFoundException] {
	Write-Host 'Please, check that file paths are well configured' -fore red -back black
}
catch {
	# We catch all exceptions and show the fullname of the exception so we can handle it better
	Write-Host 'Unknown error. Caught exception:' $_.Exception.GetType().FullName -fore red -back black
}



