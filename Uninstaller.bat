@echo off
:: FixResolution Uninstaller
:: Removes scheduled tasks and installation directory

setlocal
set LOGFILE="%ProgramData%\FixResolution\uninstall.log"
set INSTALL_DIR="%ProgramData%\FixResolution"
set TASK1="FixResolution_Startup"
set TASK2="FixResolution_Logon"

:: Admin check
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This uninstaller requires administrator privileges.
    echo Please right-click and select "Run as administrator".
    pause
    exit /b 1
)

:: Logging function
:log
echo [%date% %time%] %* >> %LOGFILE%
echo %*
goto :eof

:: Start uninstallation
call :log "Starting uninstallation of FixResolution"

:: 1. Remove scheduled tasks
call :log "Removing scheduled tasks..."
schtasks /delete /tn %TASK1% /f 2>&1 | findstr /v "WARNING:" || call :log "Task %TASK1% not found or already removed"
schtasks /delete /tn %TASK2% /f 2>&1 | findstr /v "WARNING:" || call :log "Task %TASK2% not found or already removed"

:: 2. Kill running processes if any
call :log "Stopping any running resolution.exe processes..."
taskkill /f /im resolution.exe >nul 2>&1 && call :log "Stopped resolution.exe" || call :log "No resolution.exe processes found"

:: 3. Remove installation directory
if exist %INSTALL_DIR% (
    call :log "Removing installation directory..."
    rmdir /s /q %INSTALL_DIR%
    if exist %INSTALL_DIR% (
        call :log "ERROR: Failed to remove installation directory"
    ) else (
        call :log "Successfully removed installation directory"
    )
) else (
    call :log "Installation directory not found"
)

:: Completion
call :log "Uninstallation completed"
echo.
echo Uninstallation of FixResolution has been completed.
echo A log has been created at %LOGFILE%
echo.
pause
exit /b 0
