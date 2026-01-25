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

:: Check our custom path first
if exist "C:\PatchAgent\Python\python.exe" (
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
    if exist "C:\PatchAgent\Python\python.exe" (
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

:: 3. Install Dependencies
echo Installing dependencies (requests)...
!PYTHON_CMD! -m pip install requests

:: 4. Start Agent
echo Starting Agent...
cd agent
!PYTHON_CMD! agent.py
pause
