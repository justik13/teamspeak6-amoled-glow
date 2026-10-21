@echo off
chcp 65001 >nul
title TeamSpeak 6 AMOLED Glow Updater
powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Test-Path '%~dp0update.ps1') { & '%~dp0update.ps1' } else { irm https://raw.githubusercontent.com/justik13/teamspeak6-amoled-glow/main/update.ps1 | iex }"
pause
