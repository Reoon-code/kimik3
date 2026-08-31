@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0bootstrap-windows.ps1" %*
exit /b %ERRORLEVEL%
