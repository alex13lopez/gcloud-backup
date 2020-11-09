# Name: Gcloud Backup
# Author: Alex López <arendevel@gmail.com>
# Contributor: Iván Blasco
# Version: 10.3.0b

########## Var & parms declaration #####################################################
param(
    [Parameter(Mandatory = $false)][switch]$all         				= $false,
	[Parameter(Mandatory = $false)][switch]$clean						= $false, 
	[Parameter(Mandatory = $false)][switch]$removeOld					= $false,
	[Parameter(Mandatory = $false)][switch]$dryRun						= $false,  				   # This will cause script to run without making any changes
	[Parameter(Mandatory = $false)][switch]$unattended					= $false,  				   # Turn this flag on if script is going tu run unattended
	[Parameter(Mandatory = $false)][switch]$genCreds 					= $false,  			 	   # Generate credentials only
	[Parameter(Mandatory = $false)][System.IO.FileInfo]$confFile   		= '.\GcloudConf.ps1'       # We may indicate an alternate conf file
	)
	
Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

# Conf loading
try {
	if (Test-Path $confFile) {
		. $confFile
	}
	else {
		Write-Host 'Configuration file not found, please reinstall!' -ForegroundColor Red -BackgroundColor Black
		exit 1
	}
}
catch {
	Write-Host "Please, check your configuration file, there's something incorrect in it. " -ForegroundColor Red -BackgroundColor Black
	exit 1
}
#########################################################################################

# If we're debugging we set the $DebugPreference to continue to avoid Powershell asking annoyingly if we want to continue every time it finds a "Write-Debug"
If ($PSBoundParameters['Debug']) {
    $DebugPreference = 'Continue'
}

function getTime() {
	return Get-Date -UFormat "%d-%m-%Y @ %H:%M"
}

function createFolder($path) {
	
	try {
		mkdir "$path" -ErrorAction Continue 2>&1> $null
	}
	catch {
		continue
	}
	
}

function chkCredentials($usrFile, $pwFile) {
	return (Test-Path -Path $usrFile) -and (Test-Path -Path $pwFile)
}

function genCredentials($usrFile, $pwFile) {
	
	createFolder $credDir
	
	if ([string]::IsNullOrEmpty($usrFile) -or [string]::IsNullOrEmpty($pwFile)){
		$mailCred =  [ChoiceDescription]::new('&Mail', 'Credential Type: Mail')
		$shareCred = [ChoiceDescription]::new('&Share', 'Credential Type: Share')

		$options = [ChoiceDescription[]]($mailCred, $shareCred)
		$result = $host.UI.PromptForChoice("Credential Types", "What type of credential do you wish to create?", $options, 0)

		switch ($result) {
			0 { genCredentials "$mailUsrFile" "$mailPwFile"}
			1 { genCredentials "$shareUsrFile" "$sharePwFile" }
			Default {
				Write-Host "Invalid option, try again." -ForegroundColor Red -BackgroundColor Black 
				genCredentials
			}
		}
	}
	else {
		$creds = (Get-Credential)
	
		$creds.UserName | Out-File $usrFile
		$creds.Password | ConvertFrom-SecureString | Out-File $pwFile
	}
	
	
	Write-Host "Credentials generated succesfully!" -ForegroundColor green -BackgroundColor black
}

function getCredentials($usrFile, $pwFile) {
	$chkCredentials = chkCredentials "$usrFile" "$pwFile"

	if (!$chkCredentials){
		
		if ($unattended) {
			Write-Output "Credentials ('$usrFile', '$pwFile') not found, please run this script again in interactive mode (No unattended flag activated) to generate them." 1> $credErrorLog
			Write-Output "Notice that whilst you do NOT delete '$credDir' your credentials will be safely secured with Windows Data Protection API (DPAPI) which can only be used in this machine." 1>> $credErrorLog
			return $false # Creds not found and running in 'unattended mode' so we cannot send the email
		}
		else {
			Write-Host "Credentials ('$usrFile', '$pwFile') not found, please introduce your login information." -ForegroundColor Yellow -BackgroundColor Black
			Write-Host "Notice that whilst you do NOT delete '$credDir' your credentials will be safely secured with Windows Data Protection API (DPAPI) which can only be used in this machine." -fore blue -back black
			genCredentials "$usrFile" "$pwFile"
		}				
		
		
	}
	return  New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList (Get-Content $usrFile), (Get-Content $pwFile | ConvertTo-SecureString)
}

function mailLogs($jobType, $server, $startedTime, $endTime, $attachment) {
    
	# Mail Setup
	$cred = getCredentials "$mailUsrFile" "$mailPwFile"

	if ($cred -eq $false) { return $false}

	$EmailTo = $mailTo
	$EmailFrom = $cred.UserName
	
	if ($jobType -eq "upload") {
		$Subject = "[Completed] Gcloud Backups - $server" 
		$Body = "Salutations master, <br><br>Google Cloud '$server' upload job which started at $startedTime --> Finished at $endTime<br><br>Greetings, <br><br> <strong>Your automated, Gcloud Backup script.</strong>" 
	}
	elseif ($jobType -eq "remove") {
		$Subject = "[Completed] Gcloud Backups - Removing old cloud backups"
		$Body = "Salutations master, <br><br>Google Cloud 'Removing old backup files' job which started at $startedTime --> Finished at $endTime<br><br>Greetings, <br><br> <strong>Your automated, Gcloud Backup script.</strong>" 
	}
	elseif ($jobType -eq "sendErrorLog") {
		$Subject = "[Failed] Gcloud Backups - $server"
		$Body = "Bad news master, <br><br>Something just broke. I attach the error file.<br><br>Greetings, <br><br> <strong>Your automated, Gcloud Backup script.</strong>" 
	}

	# SMTP Server Setup 
	$SMTPServer = "smtp.gmail.com" 

	# SMTP Message
	$SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
	$SMTPMessage.isBodyHTML = $true
	
	if (! [string]::IsNullOrEmpty($attachment)) {
		$attachThis = new-object Net.Mail.Attachment($attachment) 
		$SMTPMessage.Attachments.Add($attachThis)
	}

	# SMTP Client Setup
	$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
	$SMTPClient.EnableSsl = $true
	$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($cred.UserName, $cred.Password); 
	$SMTPClient.Send($SMTPMessage)
	
	return $true
	
}

function sendErrorLog($subject, $errorLogFile) {
	
	if (Test-Path $errorLogFile) {
	
		$fileContents = Get-Content $errorLogFile
		
		if (! [string]::isNullOrEmpty($fileContents)) {
			$ret = mailLogs "sendErrorLog" $subject "" "" $errorLogFile
		}
		
	}
	
	return $ret
	
}

function getFileName([string]$file, [string]$nameLimitator) {
	# We force $file into being an string because otherwise the .IndexOf() and the .Substring() functions will fail	
	$limitatorPosition = $file.IndexOf($nameLimitator)
	return $file.Substring($limitatorPosition)
}

function cygWinCommand($command, $ForceRun) {

	if ($ForceRun -eq $null) { $ForceRun = $false }

	if (Test-Path $cygWinBash -PathType Leaf)
	{
		if ($dryRun) # If DryRun we say what we're going to do
		{
			& $cygWinBash --login -c "echo Running in CygWin: $command" | Out-Host #TestRun command
		}
		
		if ($ForceRun -or !$dryRun) # If we're running in DryRun we don't run the command unless we force it
		{
			& $cygWinBash --login -c "$cygWinSDKPath/$command" #Run command
		}
	}
	else 
	{
		Write-Output "CygWin bash file doesn't exist, incorrect path."
	}
	
}

function manageShare([string]$action) {

	if ($action -eq 'mount') {
		
		Write-Debug "manageShare(): sharePath: $sharePath"
		$driveLetterRoot = (Get-PSDrive -PSProvider FileSystem -Name ("X:" -Replace ":")).DisplayRoot

		Write-Debug "manageShare(): driveLetterRoot: $driveLetterRoot"

		if (-not ($driveLetterRoot -eq "$sharePath"))  {
			
			$newDriveLetter = ""

			Write-Debug "manageShare(): driveLetter: $driveLetter"

			if (-not (Test-Path -Path "$driveLetter")) {
				# If the drive letter we want to use it's not being used already, we mount it

				Write-Debug "Drive letter is not being used."

				$creds = getCredentials "$shareUsrFile" "$sharePwFile"

				$driveLetterName = $driveLetter -Replace ":" # We need to remove the semicolon for New-PSDrive
				New-PSDrive -Name $driveLetterName -PSProvider FileSystem -Root "$sharePath" -Persist:$permanentShare -Scope Global  -Credential $creds > $null	
			}
			else {
				# We find next available drive letter and we mount it
				# 68 - 90 are the Unicode represented characters of letters D..Z
				$newDriveLetter = (68..90 | ForEach-Object {$L=[char]$_; if ((Get-PSDrive -PSProvider FileSystem).Name -notContains $L) {$L}})[0]
				
				Write-Debug "Drive letter is being used already, next available drive letter is: ${newDriveLetter}:"

				$creds = getCredentials "$shareUsrFile" "$sharePwFile"
				
				New-PSDrive -Name $newDriveLetter -PSProvider FileSystem -Root "$sharePath" -Persist:$permanentShare -Scope Global -Credential $creds > $null

				# We warn the user in the log that he might want to change the drive letter in the conf
				Write-Output "Drive letter: $driveLetter is not available. You might want to change the drive letter in GcloudConf.ps1 to ${newDriveLetter}:" >> $logFile

				$global:driveLetter = $newDriveLetter + ":"
			}
		}
	}
	elseif ($action -eq 'unmount') {
		$driveLetterName = $driveLetter -Replace ":" # We need to remove the semicolon for Remove-PSDrive
		Remove-PSDrive -PSProvider FileSystem -Name "$driveLetterName" -Force -ErrorAction Continue 
	}	
}

function autoClean() {

		$currYear = Get-Date -UFormat "%Y"
		$prevYear = $currYear - 1	
		
		&{
			if ($dryRun) {
				Write-Output "Running in 'dryRun' mode: No changes will be made."
			}
				
			$timeNow = getTime
			Write-Output ("Autocleaning started at " + $timeNow)
			
			if (!$dryRun) {
				Remove-Item "$logDir\*$prevYear*"
			}
				
			$timeNow = getTime
			Write-Output ("Autocleaning finished at " + $timeNow)
			
		} 2>> $errorLog 1>> $logFile
}

function removeOldBackups() {
	
	[datetime]$lastWeek = (Get-Date (Get-Date).AddDays($daysToKeepBK * (-1)) -UFormat "%Y-%m-%d") # Cambiamos a negativo el $daysToKeepBK para restar dias
	
	if($useCygWin) # We run the CygWin implementation
	{
		$files = @(cygWinCommand "gsutil -m ls -lR `'$serverPath`'" $true | Select-String -Pattern "\..*$" | Select-String -Pattern "TOTAL" -NotMatch)
	}
	else 
	{
		$files = @(gsutil -m ls -lR "$serverPath" | Select-String -Pattern "\..*$" | Select-String -Pattern "TOTAL" -NotMatch)
	}
	
	if (! [string]::IsNullOrEmpty($files)) { 
	
		$timeNow = getTime
	    $startedTime = $timeNow
		Write-Output ("Removing old backup files' job started at " + $timeNow) 1>> $logFile
				
		&{
			if ($dryRun) {
				Write-Output "Running in 'dryRun' mode: No changes will be made."
			}
		
			foreach ($file in $files) {
				# We force $file into being a string cause otherwise the .trim() function below will sometimes fail
				$file = [string]$file
				
				# We trim spaces, then replace multiple spaces with one space only and then we split it into variables
				$fileSize,$fileDate = (($file.trim()) -Replace '\s+', ' ').Split(' ')[0,1]
				
				[datetime]$fileDate = Get-Date -Date $fileDate -UFormat "%Y-%m-%d"

				$nameLimitator = "gs://" # We use this variable to get the name
				$filePath = getFileName $file $nameLimitator

				$fileName = ($filePath -Split "/")[-1]				
				$fileExt  = ($fileName -Split "\.")[-1]
				
				if ($fileExt -ne "vbm") {
					# We skip '.vbm' files since they are always the same and don't have date on it																							
					
					Write-Debug "FilePath: $filePath | FileName: $fileName | FileDate: $fileDate | LastWeekDate: $lastWeek | FileExt: $fileExt"

					if ($fileDate -lt $lastWeek) {
						Write-Output "The file: '$fileName' is older than $daysToKeepBK days... Wiping out!"						
										
						# Moved dryRun down because cygWinCommand() handles $dryRun differently						
						if($useCygWin) # We run the CygWin implementation
						{
							Write-Debug "Removing with CygWin: $filePath"
							cygWinCommand("gsutil -m -q rm -a ""$filePath""")
						}
						elseif (!$dryRun) 							
						{
							Write-Debug "Removing without CygWin: $filePath"
							gsutil -m -q rm -a "$filePath" # -m makes the operation multithreaded. -q causes gsutil to be quiet, basically: No progress reporting, only errors
						}					
					}											
				}				
			}
			
		} 2>> $removeErrorLog 1> $removeLogFile
		
		
		$timeNow = getTime
	    Write-Output ("Removing old backup files' job finished at " + $timeNow) 1>> $logFile 
		
		if ($isMailingOn) {
			$isMailingOn = mailLogs "remove" "" $startedTime $timeNow $removeLogFile
		}
	}
	else {Write-Output "Could not get the files" 1>> $errorLog}
	
}


function doUpload() {

	# If it is a shared path, we make sure it is mounted otherwise the job will fail
	if ($mountShare) { manageShare "mount" }

	# We wrap all the code so we can send all the stdout and stderr to files in a single line
	&{
		if ($dryRun) {
				Write-Output "Running in 'dryRun' mode: No changes will be made."
		}
		
		$timeNow = getTime
		Write-Output ("Uploading Backups to Gcloud... Job started at " + $timeNow)

		foreach ($backupPath in $backupPaths) {
			
			$dirName = $backupPath -replace '.*\\'
			
			$fullPath = "$driveLetter\$backupPath"

			$timeNow = getTime
			Write-Output ("Uploading $dirName to Gcloud... Job started at " + $timeNow)
			
			$startedTime = $timeNow
						
			createFolder "$logDir\$dateLogs"
			
			Write-Debug "doUpload(): fullPath: $fullPath"

			if (Test-Path $fullPath) {

				if (!$dryRun) {
					# Changed back to rsync because copy does copy all the files whether they are changed or not
					# But now, -d option is skipped since we deal with the old backup files manually with removeOldBackups
					
					if($useCygWin) # We run the CygWin implementation
					{
						$cygWinPath = $fullPath -replace "\\","/" # Convert to UNIX path
						cygWinCommand("gsutil -m -q rsync -r  `'$cygWinPath`' `'$serverPath/$dirName`'")
					}
					else 
					{						
						gsutil -m -q rsync -r "$fullPath" "$serverPath/$dirName"
					}
				}
			}
			else {
				Write-Error -Message "Cannot find backup path '$fullPath'"	
			}
			

			$timeNow = getTime
			Write-Output ("Uploading $dirName to Gcloud... Job finished at " + $timeNow)
			
			if ($isMailingOn) {
				$isMailingOn = mailLogs "upload" $dirName $startedTime $timeNow # In case that sending email fails, we switch off the mailing option until script is restarted
			}
			
		}
		$timeNow = getTime
		Write-Output ("Uploading Backups to Gcloud... Job finished at " + $timeNow)

		# We unmount the temporary mounted drive
		if (-not ($permanentShare)) {
			manageShare "unmount"
		}
		

	}  2>> $errorLog 1>> $logFile
	
	if ($isMailingOn) {
		$isMailingOn = sendErrorLog "Upload job" $errorLog
	}
}

try {
	if ($clean) {
		createFolder "$logDir\$dateLogs"
		autoClean
	} 
	elseif ($removeOld) {
		createFolder "$logDir\$dateLogs"
		removeOldBackups
	}
	elseif ($All) {
		createFolder "$logDir\$dateLogs"
		autoClean
		doUpload
		removeOldBackups
	}
	elseif ($genCreds) {
		genCredentials
	}
	else {
		createFolder "$logDir\$dateLogs"
		doUpload
	}
}
catch [System.IO.DirectoryNotFoundException] {
	Write-Host 'Please, check that file paths are well configured' -fore red -back black
}
