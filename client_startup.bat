@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

:: Simple Python Detection (Same as setup script)
set "PYTHON_CMD="
if exist "C:\PatchAgent\Python\python.exe" (
    set "PYTHON_CMD=C:\PatchAgent\Python\python.exe"
) else if exist "C:\Program Files\Python311\python.exe" (
    set "PYTHON_CMD=C:\Program Files\Python311\python.exe"
) else if exist "%LOCALAPPDATA%\Programs\Python\Python311\python.exe" (
    set "PYTHON_CMD=%LOCALAPPDATA%\Programs\Python\Python311\python.exe"
) else (
    python --version >nul 2>&1
    if !errorlevel! equ 0 set "PYTHON_CMD=python"
)

if "!PYTHON_CMD!"=="" (
    exit /b
)

:: Start Agent Hidden/Minimized
cd agent
start "" /min !PYTHON_CMD! agent.py
