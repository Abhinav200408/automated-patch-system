@echo off
setlocal EnableDelayedExpansion
echo ==========================================
echo Automated Patch Management Agent Setup
echo ==========================================
echo Debug Mode: Checking if script starts...
net session >nul 2>&1 && echo Status: ADMIN || echo Status: NOT ADMIN
pause

:: 1. Check for Admin Rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting Administrator privileges...
    echo.
    echo A NEW WINDOW will open asking for permission.
    echo Please click YES.
    echo.
    pause
    
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /b
)
echo Debug: Admin check passed.
pause

:: 2. Check for Python
python --version >nul 2>&1
echo Debug: Python check done. ErrorLevel: %errorlevel%
pause
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
        
        REM Try installing to default location (Program Files) with logging
        start /wait "" python_installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0 /log python_install.log
        del python_installer.exe
        
        REM Re-check paths after install
        if exist "C:\Program Files\Python311\python.exe" (
            set "PYTHON_CMD=C:\Program Files\Python311\python.exe"
        ) else if exist "%LOCALAPPDATA%\Programs\Python\Python311\python.exe" (
            set "PYTHON_CMD=%LOCALAPPDATA%\Programs\Python\Python311\python.exe"
        ) else if exist "C:\Windows\py.exe" (
            set "PYTHON_CMD=py"
        ) else (
            echo.
            echo Python installation seemed to fail.
            echo.
            echo ==========================================
            echo INSTALLER LOG (Last 20 lines):
            echo ==========================================
            if exist python_install.log (
                powershell -Command "Get-Content python_install.log -Tail 20"
            ) else (
                echo Log file not found.
            )
            echo ==========================================
            echo.
            echo Please share the above log with support.
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
