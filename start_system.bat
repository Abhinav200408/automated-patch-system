@echo off
cd /d "%~dp0"

echo Requesting Administrator privileges...
:: Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

:: If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"

echo Starting Automated Patch Management System...

:: Start Server
start "Automated Patch Management Server" cmd /k "call venv\Scripts\activate && python server/app.py"

:: Start Agent (Wait a bit for server)
timeout /t 5
start "Automated Patch Management Agent" cmd /k "call venv\Scripts\activate && python agent/agent.py"

echo System started! You can close this window.
exit
