@echo off
echo ==========================================
echo Downloading Python Installer for Offline Setup
echo ==========================================

echo Downloading Python 3.11.5...
powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.5/python-3.11.5-amd64.exe' -OutFile 'python_installer.exe'"

if exist python_installer.exe (
    echo.
    echo [SUCCESS] Installer downloaded: python_installer.exe
    echo.
    echo Please COPY this file to the Client machine along with the other files.
) else (
    echo.
    echo [ERROR] Download failed. Please check your internet connection.
)

pause
