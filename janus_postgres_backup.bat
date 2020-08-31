@echo off
setlocal ENABLEDELAYEDEXPANSION

REM ======================================================
REM Backup script for PostgreSQL database

REM This script can be used to perform a periodical backup (using pg_dump) of an JBL DB on a PostgreSQL server instance.
REM Only the 3 latest backups will be kept, older ones will be deleted.

REM Optionally, create a .pgass-file with the following content: hostname:port:database:username:password and set the corresponding pgpassfile variable
REM Adapt the variables below
REM Create a scheduled task: schtasks /create /SC daily /TN "JBL Postgre Backup" /TR "C:\Windows\System32\cmd.exe /c %BAT_LOCATION%\jbl_postgres_backup.bat" /ST 03:00
REM Configure the scheduled task to be run by the SYSTEM user

REM ======================================================


REM *********************************************
REM Variable definition
REM *********************************************

SET POSTGRES_HOME=C:\Program Files\PostgreSQL\9.6
SET POSTGRES_USER=backup
SET PGPASSWORD=
SET DB_HOST=127.0.0.1
SET DB_NAME=janus
SET BACKUP_LOCATION=D:\Backup_JMS\janus


IF NOT EXIST D:\ GOTO reset_location
IF NOT EXIST %BACKUP_LOCATION% (
	mkdir %BACKUP_LOCATION%)
GOTO backup

:reset_location:
SET BACKUP_LOCATION=C:\Backup_JMS\janus
IF NOT EXIST %BACKUP_LOCATION% (
				mkdir %BACKUP_LOCATION%)	
GOTO backup

REM *********************************************
REM Perform backup
REM *********************************************

:backup:

IF NOT EXIST "%BACKUP_LOCATION%\logs" (
				mkdir "%BACKUP_LOCATION%\logs")

SET DATESTR=%date:~-4,4%%date:~-7,2%%date:~-10,2%
SET TIMESTR=%time:~0,2%%time:~3,2%%time:~6,2%
SET BACKUP_FILE=janus_%DATESTR%_%TIMESTR%.backup
SET LOGFILE=%BACKUP_LOCATION%\logs\janus_postgres_backup_%DATESTR%_%TIMESTR%.log

echo    --
echo    Perform database backup (%BACKUP_LOCATION%\%BACKUP_FILE%)

IF %ERRORLEVEL% == 0 (

	"%POSTGRES_HOME%\bin\pg_dump.exe" -U %POSTGRES_USER% --no-password -h %DB_HOST% -F c -b -v -f "%BACKUP_LOCATION%\%BACKUP_FILE%" %DB_NAME% >> "%LOGFILE%" 2>&1

	IF %ERRORLEVEL% == 0 (
		echo    SUCCESS
	) ELSE (
		echo    FAILED: %LOGFILE%
	)
) ELSE (
	echo    SKIPPED
)


REM *********************************************
REM Cleanup
REM *********************************************
echo    --
echo    Clean up: keeping latest 7 backups only

IF %ERRORLEVEL% == 0 (

	SET BACKUP_COUNT=0
	for /f %%i in ('dir /b /a-d "%BACKUP_LOCATION%\*.backup" ^| find /c /v ""') do @call set BACKUP_COUNT=%%i
	IF !BACKUP_COUNT! gtr 7 (
		for /f "skip=7 eol=: delims=" %%F in ('dir /b /o-d "%BACKUP_LOCATION%\*.backup"') do @del "%BACKUP_LOCATION%"\"%%F" >> "%LOGFILE%" 2>&1
	)

	IF %ERRORLEVEL% == 0 (
		echo    SUCCESS
	) ELSE (
		echo    FAILED: %LOGFILE%
	)
) ELSE (
	echo    SKIPPED
)


echo    --

exit /B %ERRORLEVEL%
