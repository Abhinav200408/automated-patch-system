@echo off
cd /d "%~dp0"
powershell -Command "Start-Process cmd -ArgumentList '/k cd /d %CD% && .\venv\Scripts\python.exe server/app.py' -Verb RunAs"
