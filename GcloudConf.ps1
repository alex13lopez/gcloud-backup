# Conf File Version: 2.1

# General options	
$global:dateLogs          = Get-Date -UFormat '%Y%m%d'
$global:installDir		  = 'C:\Gcloud'
$global:logDir            = Join-Path -Path $installDir -ChildPath 'Logs' # We use join path so we force powershell to expand $installDir
$global:credDir           = Join-Path -Path $installDir -ChildPath 'Credentials'
$global:logFile           = [System.IO.Path]::Combine($logDir, $dateLogs, "logFile.txt") # With Join-Path the var $dateLogs was not expanding so I changed it to [System.IO.Path]::Combine()
$global:errorLog          = [System.IO.Path]::Combine($logDir, $dateLogs, "errorLog.txt")
$global:cleanLog          = [System.IO.Path]::Combine($logDir, $dateLogs, "cleanLog.txt")
$global:removeLogFile     = [System.IO.Path]::Combine($logDir, $dateLogs, "removeLogFile.txt")
$global:removeErrorLog    = [System.IO.Path]::Combine($logDir, $dateLogs, "removeErrorLog.txt")
$global:credErrorLog	  = [System.IO.Path]::Combine($logDir, $dateLogs, "credErrorLog.txt")
$global:driveLetter       = '' # e.g.: D: - If it is already busy and mountShare feature enabled, the next letter available will be used

# Comma-separated values without trailing backslashes and without the $driveLetter. 
# So, for example, say your $driveLetter is Z: and inside Z: you have a backups folder and inside: Server1, Server2, you will have to put @('backups\Server1','backups\Server2')
# Or if you directly have your backups inside Z:, you will then put @('Server1','Server2')
# So the resulting path (after the concatenation in code later), will be $driveLetter\$backupPath, e.g.: 'Z:\Server1' or 'Z:\backups\Server1' depending on how you want to use it
$global:backupPaths  = @()

# Google cloud path to your bucket without trailing forwardslashes. E.g.: gs://yourbucket/backups
$global:serverPath   = ''

# 8 days because in case it's Sunday we'll keep the last full backup made on last Saturday
$global:daysToKeepBK = 8

# Mailing Options
$global:mailUsrFile     = Join-Path -Path $credDir -ChildPath 'MailUsername'
$global:mailPwFile      = Join-Path -Path $credDir -ChildPath 'MailPassword'
$global:isMailingOn     = $false
$global:mailTo          = ''
$global:SMTPServer      = 'smtp.gmail.com' # Your smtp server. Default is gmail, since we assume that if you use GCP, you use Gmail mail servers as well
$global:SMTPPort        = 587 # Default SMTP port that uses TLS/SSL
$global:SMTPEnableSSL   = $true # Default: $true. We want to use a ciphered connection, don't we?

# CygWin Options
# We moved the instructions on how to use CygWin to the README.md because some Anti-Virus detected the instructions as Obfuscated Code 
# (Since the instructions have links and such, some paranoid Anti-Virus like Kaspersky Endpoint detected it as Obfuscated Code)
$global:cygWinBash     = 'C:\cygwin64\bin\bash.exe'
$global:cygWinSDKPath  = '~/google-cloud-sdk/bin' # Must not end with trailing backslash (path of the sdk installation in CygWin)
$global:useCygWin      = $false # Set to true if you wish to use the CygWin implementation.

# Mount share options
$global:mountShare       = $false
$global:permanentShare   = $false # Change to true to permanently mount the share as a Drive
$global:sharePath        = ''     # Full path to the share, including the directory (e.g.: \\server\SharedDirectory)
$global:shareUsrFile     = Join-Path -Path $credDir -ChildPath 'ShareUsername'
$global:sharePwFile      = Join-Path -Path $credDir -ChildPath 'SharePassword'
