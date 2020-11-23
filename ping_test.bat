for /f "tokens=*" %%A in ('ping -n 1 %1 ^|find "Pinging %1"') Do echo %%A >>c:\HUBsupport\ping_test\CHECK_LOG_LX_%1.log

:START

FOR /f "tokens=3 delims=," %%A IN ('ping -n 1 %1 ^|find "Lost = 1"') DO echo %date% %time% - [%%A] >>c:\HUBsupport\ping_test\CHECK_LOG_LX_%1.log

choice /c x /t 1 /d x >nul

goto START