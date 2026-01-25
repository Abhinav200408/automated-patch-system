@echo off
echo Updating repository...

if not exist ".git" (
    echo.
    echo [ERROR] This folder is not a Git repository.
    echo You cannot use 'git pull' here because you likely copied the files manually.
    echo.
    echo To update: Please copy the new files from the Server again.
    pause
    exit /b
)

git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Git is not installed on this machine.
    echo.
    echo To update: Please copy the new files from the Server again.
    pause
    exit /b
)

git pull
echo.
echo Update complete.
pause
