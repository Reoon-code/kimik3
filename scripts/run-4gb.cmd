@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0run-4gb.ps1" %*
exit /b %ERRORLEVEL%
