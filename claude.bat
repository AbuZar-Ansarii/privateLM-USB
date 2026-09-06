@echo off
title THEVOIDKERNEL - PORTABLE AGENTS (Hermes, OpenClaw & Claude Code)

REM ANSI Color Setup
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "RESET=%ESC%[0m"
set "BOLD=%ESC%[1m"
set "BRIGHT_CYAN=%ESC%[96m"
set "BRIGHT_YELLOW=%ESC%[93m"
set "GRAY=%ESC%[90m"

echo %BRIGHT_CYAN%===================================================%RESET%
echo %BOLD%%BRIGHT_YELLOW%                   THEVOIDKERNEL%RESET%
echo %BRIGHT_CYAN%===================================================%RESET%
echo %GRAY%[ 🤖 Claude Code (OpenClaude) - Portable Workspace Setup ^& Run ]%RESET%
echo.

setlocal
cd /d "%~dp0OpenClaude"
call "%~dp0OpenClaude\START.bat" %*
exit /b %ERRORLEVEL%
