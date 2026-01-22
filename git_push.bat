@echo off
echo ==========================================
echo Git Push Helper
echo ==========================================

echo This script will help you push your code to a new repository.
echo First, create a new empty repository on GitHub/GitLab/Bitbucket.

set /p REPO_URL="Paste your Repository URL here: "

echo Adding remote origin...
git remote add origin %REPO_URL%

echo Renaming branch to main...
git branch -M main

echo Pushing code...
git push -u origin main

echo Done!
pause
