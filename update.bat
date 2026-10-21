@echo off
chcp 65001 >nul
title TeamSpeak 6 AMOLED Glow Updater
setlocal
set "SCRIPT_DIR=%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$p = Join-Path $env:SCRIPT_DIR 'update.ps1'; if (Test-Path -LiteralPath $p) { & ([scriptblock]::Create((Get-Content -LiteralPath $p -Raw))) %* } else { & ([scriptblock]::Create((irm https://raw.githubusercontent.com/justik13/teamspeak6-amoled-glow/main/update.ps1))) %* }"
endlocal
pause
