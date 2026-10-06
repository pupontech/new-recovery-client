@echo off
setlocal
set "RUNNER=%LOCALAPPDATA%\NewRecoveryClient\New-RecoveryClient.ps1"

if not exist "%RUNNER%" (
    echo New Recovery Client is not installed.
    echo.
    echo Run Install.cmd first.
    echo.
    pause
    exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -STA -File "%RUNNER%"
endlocal
