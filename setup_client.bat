@echo off
setlocal EnableDelayedExpansion
echo ==========================================
echo Automated Patch Management Agent Setup
echo ==========================================

:: 1. Check for Admin Rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: 2. Check for Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Python not found. Checking standard install paths...
    
    if exist "C:\Program Files\Python311\python.exe" (
        set "PYTHON_CMD=C:\Program Files\Python311\python.exe"
    ) else if exist "%LOCALAPPDATA%\Programs\Python\Python311\python.exe" (
        set "PYTHON_CMD=%LOCALAPPDATA%\Programs\Python\Python311\python.exe"
    ) else (
        echo Python is missing. Downloading and Installing Python 3.11...
        
        powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.5/python-3.11.5-amd64.exe' -OutFile 'python_installer.exe'"
        
        if not exist python_installer.exe (
            echo Failed to download Python installer. Check internet connection.
            pause
            exit /b
        )
        
        echo Installing Python... (This may take a few minutes)
        python_installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
        del python_installer.exe
        
        :: Re-check paths after install
        if exist "C:\Program Files\Python311\python.exe" (
            set "PYTHON_CMD=C:\Program Files\Python311\python.exe"
        ) else if exist "%LOCALAPPDATA%\Programs\Python\Python311\python.exe" (
            set "PYTHON_CMD=%LOCALAPPDATA%\Programs\Python\Python311\python.exe"
        ) else (
            echo.
            echo Python installed but not found. Please restart this script.
            pause
            exit /b
        )
    )
) else (
    set "PYTHON_CMD=python"
)

echo Using Python at: !PYTHON_CMD!

:: 3. Ask for Server IP (if config missing)
if not exist "agent\config.json" (
    set /p SERVER_IP="Enter Server IP (e.g., 172.22.205.250): "
    echo Creating config.json...
    (
    echo {
    echo     "server_url": "http://!SERVER_IP!:5001"
    echo }
    ) > agent\config.json
)

:: 4. Install Dependencies (Directly)
echo Installing dependencies (requests)...
!PYTHON_CMD! -m pip install requests

:: 5. Start Agent
echo Starting Agent...
cd agent
!PYTHON_CMD! agent.py
pause
