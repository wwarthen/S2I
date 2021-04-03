@echo off
setlocal

setlocal & Powershell -ExecutionPolicy Unrestricted .\Build.ps1 %* || exit /b 1 & endlocal
