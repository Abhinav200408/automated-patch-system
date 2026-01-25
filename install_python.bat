@echo off
setlocal EnableDelayedExpansion
echo ==========================================
echo Python Auto-Installer (Robust)
echo ==========================================

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

echo Status: ADMIN

:: 2. Download Python (if not present)
if exist "python_installer.exe" (
    echo Found local installer: python_installer.exe
    echo Skipping download...
) else (
    echo Local installer not found. Downloading Python 3.11...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.5/python-3.11.5-amd64.exe' -OutFile 'python_installer.exe'"
    
    if not exist python_installer.exe (
        echo Failed to download Python installer. Please check your internet connection.
        pause
        exit /b
    )
)

:: 3. Install Python
echo Installing Python to "%~dp0python"...
if not exist "%~dp0python" mkdir "%~dp0python"

echo This may take a few minutes...
start /wait "" python_installer.exe /quiet InstallAllUsers=0 PrependPath=0 Include_test=0 TargetDir="%~dp0python" /log python_install.log
del python_installer.exe

:: 4. Verify Install
if exist "%~dp0python\python.exe" (
    echo.
    echo Python installed successfully!
    echo Location: "%~dp0python\python.exe"
    echo.
    echo You can now close this window and run setup_client.bat again.
) else (
    echo.
    echo Python installation FAILED.
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
)

pause
