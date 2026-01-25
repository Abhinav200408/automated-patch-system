@echo off
echo ==========================================
echo Repairing Server Environment
echo ==========================================

cd /d "%~dp0"

if exist venv (
    echo Removing broken virtual environment...
    rmdir /s /q venv
)

echo Creating new virtual environment...
python -m venv venv

if not exist venv (
    echo Failed to create venv. Please check if Python is installed.
    pause
    exit /b
)

echo Installing dependencies...
call venv\Scripts\activate
pip install -r requirements.txt

echo.
echo ==========================================
echo Repair Complete!
echo ==========================================
echo You can now run start_system.bat
pause
