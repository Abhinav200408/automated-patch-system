@echo off
echo ==========================================
echo Automated Patch Management Agent Setup
echo ==========================================

:: Check for Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Python is not installed!
    echo.
    echo We have included an automatic installer.
    echo Please run: install_python.bat
    echo.
    echo After installing, close this window and run setup_client.bat again.
    pause
    exit /b
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
echo Installing dependencies...
pip install -r requirements.txt

:: Start Agent
echo Starting Agent...
cd agent
python agent.py
pause
