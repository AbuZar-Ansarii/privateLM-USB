@echo off
title THEVOIDKERNEL - PORTABLE AGENTS (Hermes, OpenClaw & Claude Code)

REM ANSI Color Setup
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "RESET=%ESC%[0m"
set "BOLD=%ESC%[1m"
set "BRIGHT_CYAN=%ESC%[96m"
set "BRIGHT_GREEN=%ESC%[92m"
set "GRAY=%ESC%[90m"

echo %BRIGHT_CYAN%===================================================%RESET%
echo %BOLD%%BRIGHT_GREEN%                   THEVOIDKERNEL%RESET%
echo %BRIGHT_CYAN%===================================================%RESET%
echo %GRAY%[ 🦞 OpenClaw Agent - Portable Workspace Setup ^& Run ]%RESET%
echo.

setlocal

set "ROOT=%~dp0openclaw\"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%ROOT%bin\windows.ps1"
set "EXITCODE=%ERRORLEVEL%"

if not "%EXITCODE%"=="0" (
  echo.
  echo Portable OpenClaw stopped with error code %EXITCODE%.
  pause
)

exit /b %EXITCODE%
