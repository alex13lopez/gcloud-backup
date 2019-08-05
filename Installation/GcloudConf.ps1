# General options	
$dateLogs          = Get-Date -UFormat '%Y%m%d'
$installDir		   = 'C:\Gcloud'
$logDir            = '$installDir\GcloudLogs'
$logFile           = '$logDir\$dateLogs\logFile.txt'
$errorLog          = '$logDir\$dateLogs\errorLog.txt'
$cleanLog          = '$logDir\$dateLogs\cleanLogFile.txt'
$removeLogFile     = '$logDir\$dateLogs\removeLogFile.txt'
$removeErrorLog    = '$logDir\$dateLogs\removeOldErrorLog.txt'
$credErrorLog	   = '$logDir\$dateLogs\credErrorLog.txt'
$backupPaths       = @('', '') # Comma-separated paths
$serverPath        = ''
$daysToKeepBK      = 8 # 8 days because in case it's Sunday we'll keep the last full backup made on last Saturday

# Mailing Options
$credDir     = '$installDir\Credentials\'
$usrFile     = '$credDir\Username'
$pwFile      = '$credDir\Password'
$isMailingOn = $false
$mailTo 	 = ''