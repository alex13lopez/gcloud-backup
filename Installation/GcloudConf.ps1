
# Conf File Version: 1.1b

# General options	
$dateLogs          = Get-Date -UFormat '%Y%m%d' # A more powershelly way of doing this is: '{0:yyyyMMdd}' -f (Get-Date)  
$installDir		   = 'C:\Gcloud'
$logDir            = Join-Path -Path $installDir -ChildPath 'GcloudLogs' # We use join path so we force powershell to expand $installDir
$logFile           = [System.IO.Path]::Combine($logDir, $dateLogs, "logFile.txt") # We may use [System.IO.Path]::Combine() as well to combine any number of paths
$errorLog          = Join-Path -Path $logDir -ChildPath '$dateLogs\errorLog.txt'
$cleanLog          = Join-Path -Path $logDir -ChildPath '$dateLogs\cleanLog.txt'
$removeLogFile     = Join-Path -Path $logDir -ChildPath '$dateLogs\removeLogFile.txt'
$removeErrorLog    = Join-Path -Path $logDir -ChildPath '$dateLogs\removeErrorLog.txt'
$credErrorLog	   = Join-Path -Path $logDir -ChildPath '$dateLogs\credErrorLog.txt'
$backupPaths       = @('', '') # Comma-separated values
$serverPath        = 'gs://' # Google cloud path to your bucket
$daysToKeepBK      = 8 # 8 days because in case it's Sunday we'll keep the last full backup made on last Saturday

# Mailing Options
$credDir     = Join-Path -Path $installDir -ChildPath 'Credentials'
$usrFile     = Join-Path -Path $credDir -ChildPath 'Username'
$pwFile      = Join-Path -Path $credDir -ChildPath 'Password'
$isMailingOn = $false
$mailTo 	 = ''