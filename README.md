# PROJECT DESCRIPTION
This project first aim was to provide an easy-to-setup and ready-to-deploy script (without any or minimal dependencies) to sync backups to Google's Cloud Storage. The first versions were a simple script with little to no configuration at all, to upload file's to the cloud and remove them when they were old enough. But more and more features were needed and nowadays it's a very complete tool to upload and manage your backup files to Gcloud.

# TLDR;
This project provides an easy-to-setup and ready-to-deploy script to sync backups to Google's Cloud Storage.

# FEATURES
* **Upload** your backups to Gcloud
* **Remove Old Backups** (You may define what "old" means to you [in days]) from the cloud
* **AutoClean** Old logs of past year's (Logs are important, but why would you want to keep logs forever and ever?. All of this is optional of course.)
* **Mailing feature** so you can see what the application is doing or has been doing and you need not to be present at the moment.
  * The script mails every time it uploads a folder, sends an email if any error ocurred and attaches the error logging file for further details and sends a log of what has been deleted when the option -removeOld it's provided.
* **DryRun** Want to test out uploading or removing what you had already in your bucket, do not want to delete your cloud file's without checking if everything looks good? Try -dryRun so you can see what is going to be done without actually doing it. 
  * (**Important Note:** You actually "don't see anything" because everything goes to the log, even when -dryRun is enabled, because this script is intended to run -unattended.)
* **CygWin (NEW)** feature thanks to @HieiOne that stops the Window's Google SDK from limiting your total speed aproximately at 4.5 MiB/s (real bs if you ask me...). So you may use CygWin to use the Linux's Google SDK that works nicely and smoothly as it should.

# FUTURE IDEAS
* Port to C# .NET Core

# PARAMETERS
* Action parameters:
  * Default (aka no action parameters): --> doUpload.
  * -clean: Executes action --> AutoClean.
  * -removeOld: Executes action --> Remove Old Backups
  * -all: Executes all actions in order --> autoClean, doUpload, removeOldBackups
* Optional parameters:
  * -dryRun: Performs a test of the action you selected.
  * -unattended: When the script needs user input won't wait for it when this flag is on, so the script will still run. But the warning/error will be logged in the log file. (This might happen for example, if you enabled mailing feature but haven't generated the credentials yet. If you don't -unattended, the script will understand you're attending to the script's behaviour and ask for credentials, instead, if you --unattended the script will log missing credentials to the log and disable temporarily the mailing feature.)
  * -genCreds: Script runs only to generate the credentials you want for the mailing feature.

# HOW TO USE CYGWIN
The CygWin implementation must have the Gcloud SDK configured, plus all the dependencies the SDK has, how to prepare CygWin to work properly:
**IMPORTANT!** In case you have an old installation in the OS of SDK you have to remove it from the Path (and uninstall it if you wish)
* Packages for cygwin: wget, curl, gcc-core, python27, python27-devel, python27-pip, python27-setuptools
* Download the SDK with `wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-287.0.0-linux-x86_64.tar.gz`
* Extract with `tar -zxvf google-cloud-sdk-287.0.0-linux-x86_64.tar.gz`
* Add to the path with `export PATH=$PATH:~/google-cloud-sdk/bin` and update the CygWinSDKPath variable (if its different than in home directory)
* Also install CRCMOD with `pip2 install crcmod`
* Run `gcloud init` to finish with the installation

# UPDATE NOTES
**Important:** as of version 9.1.2b: Log folder name changed to "Logs" instead of GcloudLogs, if you still want to use the old naming system you're free to change it in the Conf file.

**Update!** Version 9.4b now you can use a Cygwin installation to run the gsutil commands increasing perfomance (Some newer versions of windows showed a big performance decrease with Google's SDF of Windows) and upload speed (steps to do this in the config file)


# DISCLAIMER
This software is provided "as is" with absolute no warranty. Consider that this software it's still in the beta version and although it's very stable and has no known problems, if you detect a bug, you either can issue an #issue here at github or you can fix it yourself if you want and create a pull request.
