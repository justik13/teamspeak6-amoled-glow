@echo off
chcp 65001 >nul
title TeamSpeak 6 AMOLED Glow Updater
setlocal
set "SCRIPT_DIR=%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$p = Join-Path $env:SCRIPT_DIR 'update.ps1'; if (Test-Path -LiteralPath $p) { $c = Get-Content -LiteralPath $p -Raw -Encoding utf8 } else { $c = (irm https://raw.githubusercontent.com/justik13/teamspeak6-amoled-glow/main/update.ps1) }; & ([scriptblock]::Create(($c.TrimStart([char]65279)))) %*"
endlocal
pause
