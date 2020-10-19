cd /D "%~dp0"
SET DATESTR=%date:~-4,4%%date:~-7,2%%date:~-10,2%
SET TIMESTR=%time:~0,2%%time:~3,2%%time:~6,2%
SET LOGFILE=lpr_tickets_unlink_%DATESTR%_%TIMESTR%.log

set PGPASSWORD=jbl
"C:\Program Files\PostgreSQL\9.6\bin\psql.exe" -U jbl -d jbl -c "UPDATE transient_usr_pass SET lpr_camera_recognitions_id = null WHERE lpr_camera_recognitions_id IS NOT null;" >> "%LOGFILE%" 2>&1