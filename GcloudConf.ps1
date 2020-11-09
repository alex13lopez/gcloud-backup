# Conf File Version: 1.4

# General options	
$global:dateLogs          = Get-Date -UFormat '%Y%m%d'
$global:installDir		   = 'C:\Gcloud'
$global:logDir            = Join-Path -Path $installDir -ChildPath 'Logs'                # We use join path so we force powershell to expand $installDir
$global:logFile           = [System.IO.Path]::Combine($logDir, $dateLogs, "logFile.txt") # With Join-Path the var $dateLogs was not expanding so I changed it to [System.IO.Path]::Combine()
$global:errorLog          = [System.IO.Path]::Combine($logDir, $dateLogs, "errorLog.txt")
$global:cleanLog          = [System.IO.Path]::Combine($logDir, $dateLogs, "cleanLog.txt")
$global:removeLogFile     = [System.IO.Path]::Combine($logDir, $dateLogs, "removeLogFile.txt")
$global:removeErrorLog    = [System.IO.Path]::Combine($logDir, $dateLogs, "removeErrorLog.txt")
$global:credErrorLog	   = [System.IO.Path]::Combine($logDir, $dateLogs, "credErrorLog.txt")
$global:driveLetter       = ''       # e.g.: D: - If it is already busy and mountShare feature enabled, the next letter available will be used
$global:backupPaths       = @('','') # Comma-separated values without trailing backslashes and without the $driveLetter
$global:serverPath        = 'gs://'  # Google cloud path to your bucket without trailing forwardslashes
$global:daysToKeepBK      = 8        # 8 days because in case it's Sunday we'll keep the last full backup made on last Saturday
$global:credDir           = Join-Path -Path $installDir -ChildPath 'Credentials'

# Mailing Options
$global:mailUsrFile     = Join-Path -Path $credDir -ChildPath 'MailUsername'
$global:mailPwFile      = Join-Path -Path $credDir -ChildPath 'MailPassword'
$global:isMailingOn     = $false
$global:mailTo          = ''

# CygWin Options
$global:cygWinBash     = 'C:\cygwin64\bin\bash.exe'
$global:cygWinSDKPath  = '~/google-cloud-sdk/bin' # Must not end with trailing backslash (path of the sdk installation in CygWin)
$global:useCygWin      = $false # Set to true if you wish to use the CygWin implementation.

# We moved the instructions on how to use CygWin to the README.md because some Anti-Virus detected the instructions as Obfuscated Code 
# (Since the instructions have links and such, some paranoid Anti-Virus like Kaspersky Endpoint detected it as Obfuscated Code)

# Mount share options
$global:mountShare       = $false
$global:permanentShare   = $false # Change to true to permanently mount the share as a Drive
$global:sharePath        = ''     # Full path to the share, including the directory (e.g.: \\server\SharedDirectory)
$global:shareUsrFile     = Join-Path -Path $credDir -ChildPath 'ShareUsername'
$global:sharePwFile      = Join-Path -Path $credDir -ChildPath 'SharePassword'
