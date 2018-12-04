@echo off

:: Author: alopez
:: Version: 2.1
::TO-DO Fix fucking LOGs not logging the way they should

SET dateLogs=%date:~0,2%-%date:~3,2%-%date:~6,4%
SET outputFile="C:\Users\Admin\Desktop\GcloudLogs\outputFile_%dateLogs%.txt"
SET logFile="C:\Users\Admin\Desktop\GcloudLogs\logFile_%dateLogs%.txt"
SET errorLog="C:\Users\Admin\Desktop\GcloudLogs\errorLogFile_%dateLogs%.txt"

cd /d "C:\Users\Admin\AppData\Local\Google\Cloud SDK>" >>%outputFile% 2>>%errorLog%


goto getTimeNow1

:backupInterno
echo Copying NAS_backup interno AX_QV_DC... %dateNow% @ %timeNow% >>%logFile%
gsutil cp -n -r "\\172.26.0.97\VeeamBackup\NAS_backup interno AX_QV_DC" "gs://srvbackuphid/backups" >%outputFile% 2>%errorLog%
goto getTimeFinish1


:backupResto
echo Copying NAS_backup interno Resto... %dateNow% @ %timeNow% >>%logFile%
gsutil cp -n -r "\\172.26.0.97\VeeamBackup\NAS_backup interno Resto" "gs://srvbackuphid/backups" >>%outputFile% 2>>%errorLog%
goto getTimeFinish2



:: Empieza la fiesta
:getTimeNow1
for /f %%i in ('date /t') do set dateNow=%%i
for /f %%i in ('time /t') do set timeNow=%%i
goto backupInterno

:getTimeFinish1
for /f %%i in ('date /t') do set dateNow=%%i
for /f %%i in ('time /t') do set timeNow=%%i
echo Copying NAS_backup interno AX_QV_DC... Completado... %dateNow% @ %timeNow% >>%logFile%

:getTimeNow2
for /f %%i in ('date /t') do set dateNow=%%i
for /f %%i in ('time /t') do set timeNow=%%i
goto backupResto

:getTimeFinish2
for /f %%i in ('date /t') do set dateNow=%%i
for /f %%i in ('time /t') do set timeNow=%%i
echo Copying NAS_backup interno Resto... Completado %dateNow% @ %timeNow% >>%logFile%
:: Se acaba la fiesta


:end
echo All backup jobs finished [successfully] >>%outputFile%
exit 0