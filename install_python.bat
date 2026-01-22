@echo off
echo ==========================================
echo Python Auto-Installer
echo ==========================================

echo Python was not found. Downloading Python 3.11...
powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.5/python-3.11.5-amd64.exe' -OutFile 'python_installer.exe'"

if not exist python_installer.exe (
    echo Failed to download Python installer. Please check your internet connection.
    pause
    exit /b
)

echo Installing Python... (This may take a few minutes)
echo Please accept the Admin prompt if it appears.
python_installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0

echo.
echo Installation complete!
echo You may need to restart this terminal or your computer for changes to take effect.
echo.
echo Please run setup_client.bat again.
del python_installer.exe
pause
