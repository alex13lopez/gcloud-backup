# Conf File Version: 1.3.2.1

# General options	
$dateLogs          = Get-Date -UFormat '%Y%m%d' # A more powershelly way of doing this is: '{0:yyyyMMdd}' -f (Get-Date)  
$installDir		   = 'C:\Gcloud'
$logDir            = Join-Path -Path $installDir -ChildPath 'Logs' # We use join path so we force powershell to expand $installDir
$logFile           = [System.IO.Path]::Combine($logDir, $dateLogs, "logFile.txt") # With Join-Path the var $dateLogs was not expanding so I changed it to [System.IO.Path]::Combine()
$errorLog          = [System.IO.Path]::Combine($logDir, $dateLogs, "errorLog.txt")
$cleanLog          = [System.IO.Path]::Combine($logDir, $dateLogs, "cleanLog.txt")
$removeLogFile     = [System.IO.Path]::Combine($logDir, $dateLogs, "removeLogFile.txt")
$removeErrorLog    = [System.IO.Path]::Combine($logDir, $dateLogs, "removeErrorLog.txt")
$credErrorLog	   = [System.IO.Path]::Combine($logDir, $dateLogs, "credErrorLog.txt")
$backupPaths       = @('', '') # Comma-separated values without trailing backslashes
$serverPath        = 'gs://' # Google cloud path to your bucket without trailing forwardslashes
$daysToKeepBK      = 8 # 8 days because in case it's Sunday we'll keep the last full backup made on last Saturday

# Mailing Options
$credDir     = Join-Path -Path $installDir -ChildPath 'Credentials'
$usrFile     = Join-Path -Path $credDir -ChildPath 'Username'
$pwFile      = Join-Path -Path $credDir -ChildPath 'Password'
$isMailingOn = $false
$mailTo 	 = ''

# CygWin Options
$CygWinBash = 'C:\cygwin64\bin\bash.exe'
$CygWinSDKPath = '~/google-cloud-sdk/bin' # Must not end with trailing backslash (path of the sdk installation in CygWin)
$useCygWin = $false #Set to false if you don't wish to use the CygWin implementation

# We moved the instructions on how to use CygWin to the README.md because some Anti-Virus detected the instructions as Ofuscated Code 
# (Since the instructions have links and such, some paranoid Anti-Virus like Kaspersky Endpoint detected it as Obfuscated Code)
