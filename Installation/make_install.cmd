@echo off

:: Automated simple installer, use under your own responsibility
:: Ver: 1.0a

mkdir "C:\Gcloud"
copy /A /V /Y ".\Gcloud.ps1" "C:\Gcloud\"

if exist ".\Scheduled Tasks" (
	xcopy /S /Y ".\Scheduled Tasks" "C:\Gcloud\"
	
	set /p ch="Do you wish to automatically import the scheduled tasks? (y/n)"
	
	if "%ch%" == 'y' (
		echo Enter credentials for the user whom will execute the scheduled tasks
		set /p usr="User: "
		set /p pw="Passwd: "
		
		for %%file IN (".\Scheduled Tasks\*") DO schtasks /create /XML %%file /RU %usr% /RP %pw%
		 
	)
)



echo Installation completed succesfully, press enter to close this window...
pause>nul