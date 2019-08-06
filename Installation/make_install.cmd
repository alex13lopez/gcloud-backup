@echo off

:: Automated simple installer, use under your own responsibility
:: Ver: 1.2.2b

:: Do not touch below line, it is used to activate delayed expansion of variables in order to use vars inside IF block
setlocal EnableDelayedExpansion

:: We change directory where the script is, better pushd than cd so we don't have to use cd /d to change drive letter
pushd %~dp0

mkdir "C:\Gcloud" 1>nul 2>nul
copy /A /V /Y ".\GcloudBackup.ps1" "C:\Gcloud\" 1>nul

if exist ".\GcloudConf.ps1" (
	set /p ch="Old config has been found, do you wish to keep it? (y/n): "
	
	if "!ch!" == "n" (
		copy /A /V /Y ".\GcloudConf.ps1" "C:\Gcloud\" 1>nul
	)
	
	if "!ch!" == "y" (
		echo.
		echo.
		echo Configuration file not updated:
		echo             Please check the new version of the config file so you make sure you're not lacking anything
		echo.
	)
)


if exist ".\Scheduled Tasks\" (
	xcopy /S /Y ".\Scheduled Tasks" "C:\Gcloud\" 1>nul
	
	set /p ch="Do you wish to automatically import the scheduled tasks? (y/n): "
	
	:: Using delayed expansion of var ch
	if "!ch!" == "y" (
		echo Enter credentials for the user whom will execute the scheduled tasks
		set /p usr="User: "
		set /p pw="Pw: "
		cls		
		
		for %%f IN (".\Scheduled Tasks\*") DO schtasks /create /tn "%%~nf" /XML "%%f" /RU !usr! /RP "!pw!"
		 
	)
)

echo.
echo Remember Gcloud has an automated mailing module which you can activate in GcloudConf.ps1
echo In case you want to use it, remember to generate the email credentials using GcloudBackup.ps1 -genCreds
echo.
echo.
echo Installation completed succesfully, press enter to close this window...

:: Good practise to clean the "pushd"
popd 

pause>nul