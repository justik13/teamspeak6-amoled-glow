@echo off
chcp 65001 >nul
title TeamSpeak 6 AMOLED Glow Updater
setlocal
cd /d "%~dp0"
set "LOCAL_SRC=%~dp0"
if exist "%~dp0package.json" (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& { [IO.File]::ReadAllText('update.ps1', [Text.Encoding]::UTF8) | iex }"
) else (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/justik13/teamspeak6-amoled-glow/main/update.ps1 | iex"
)
pause
