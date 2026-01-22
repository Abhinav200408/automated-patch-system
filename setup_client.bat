@echo off
echo ==========================================
echo Automated Patch Management Agent Setup
echo ==========================================

:: Check for Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Python is not installed!
    echo Automatically installing Python...
    call install_python.bat
    
    :: Check standard install paths since PATH won't update in this session
    if exist "C:\Program Files\Python311\python.exe" (
        set PYTHON_CMD="C:\Program Files\Python311\python.exe"
    ) else if exist "%LOCALAPPDATA%\Programs\Python\Python311\python.exe" (
        set PYTHON_CMD="%LOCALAPPDATA%\Programs\Python\Python311\python.exe"
    ) else (
        echo.
        echo Python installed, but we couldn't find it automatically.
        echo Please close this window and run setup_client.bat again.
        pause
        exit /b
    )
) else (
    set PYTHON_CMD=python
)

:: Ask for Server IP
set /p SERVER_IP="Enter the IP address of the Automated Patch Management Server (e.g., 192.168.1.5): "

:: Create config.json
echo Creating config.json...
(
echo {
echo     "server_url": "http://%SERVER_IP%:5001"
echo }
) > agent\config.json

:: Install Dependencies
:: Install Dependencies
echo Installing dependencies...
%PYTHON_CMD% -m pip install -r requirements.txt

:: Start Agent
echo Starting Agent...
cd agent
%PYTHON_CMD% agent.py
pause
