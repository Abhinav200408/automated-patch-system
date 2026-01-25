@echo off
setlocal EnableDelayedExpansion
echo ==========================================
echo Automated Patch Management Agent Setup
echo ==========================================

:: 0. Check for broken venv (Common mistake: copying venv from server)
if exist "venv" (
    echo.
    echo [WARNING] 'venv' folder detected!
    echo.
    echo If you copied this folder from the Server, the 'venv' folder
    echo will NOT work on this machine and will cause errors.
    echo.
    echo Please DELETE the 'venv' folder and run this script again.
    echo.
    echo (You can delete it manually, or I can try to delete it for you)
    set /p DEL_VENV="Delete 'venv' folder now? (y/n): "
    if /i "!DEL_VENV!"=="y" (
        rmdir /s /q venv
        echo 'venv' deleted. Please restart this script to be safe.
        pause
        exit /b
    ) else (
        echo Okay, proceeding... (But expect errors if you use that venv)
        echo.
    )
)

:: 1. Check for Python
echo Checking for Python...

set "PYTHON_CMD="

:: Check our local portable path first
if exist "%~dp0python\python.exe" (
    set "PYTHON_CMD=%~dp0python\python.exe"
) else if exist "C:\PatchAgent\Python\python.exe" (
    set "PYTHON_CMD=C:\PatchAgent\Python\python.exe"
) else if exist "C:\Program Files\Python311\python.exe" (
    set "PYTHON_CMD=C:\Program Files\Python311\python.exe"
) else if exist "%LOCALAPPDATA%\Programs\Python\Python311\python.exe" (
    set "PYTHON_CMD=%LOCALAPPDATA%\Programs\Python\Python311\python.exe"
) else (
    :: Check global path
    python --version >nul 2>&1
    if !errorlevel! equ 0 set "PYTHON_CMD=python"
)

if "!PYTHON_CMD!"=="" (
    echo Python not found.
    echo.
    echo Launching installer...
    call install_python.bat
    
    :: Re-check after installer returns
    if exist "%~dp0python\python.exe" (
        set "PYTHON_CMD=%~dp0python\python.exe"
    ) else if exist "C:\PatchAgent\Python\python.exe" (
        set "PYTHON_CMD=C:\PatchAgent\Python\python.exe"
    ) else (
        echo.
        echo Python still not found. Please check the installer window for errors.
        pause
        exit /b
    )
)

echo Using Python at: !PYTHON_CMD!

:: 2. Ask for Server IP (if config missing)
if not exist "agent\config.json" (
    set /p SERVER_IP="Enter Server IP (e.g., 172.22.205.250): "
    echo Creating config.json...
    (
    echo {
    echo     "server_url": "http://!SERVER_IP!:5001"
    echo }
    ) > agent\config.json
)

:: 4. Install Dependencies
echo Installing dependencies (requests)...
!PYTHON_CMD! -m pip install requests

:: 5. Configure Auto-Start (Persistence)
echo.
echo Configuring Auto-Start...
set "STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "SHORTCUT_PATH=%STARTUP_FOLDER%\PatchAgent.lnk"
set "TARGET_PATH=%~dp0client_startup.bat"

:: Create Shortcut using VBScript
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%temp%\makeshortcut.vbs"
echo sLinkFile = "%SHORTCUT_PATH%" >> "%temp%\makeshortcut.vbs"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%temp%\makeshortcut.vbs"
echo oLink.TargetPath = "%TARGET_PATH%" >> "%temp%\makeshortcut.vbs"
echo oLink.WorkingDirectory = "%~dp0" >> "%temp%\makeshortcut.vbs"
echo oLink.Save >> "%temp%\makeshortcut.vbs"
cscript /nologo "%temp%\makeshortcut.vbs"
del "%temp%\makeshortcut.vbs"

echo Auto-start configured! (Agent will start when you login)

:: 6. Start Agent Now
echo Starting Agent...
cd agent
!PYTHON_CMD! agent.py
pause
