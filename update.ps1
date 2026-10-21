# TeamSpeak 6 AMOLED Glow — One-Click Installer & Auto-Launcher
$ErrorActionPreference = 'Stop'

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "  TeamSpeak 6 AMOLED Glow Updater" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Magenta

# 1. Поиск пути TeamSpeak
Write-Host "`n>>> [1/4] Поиск TeamSpeak..." -ForegroundColor Cyan
$knownPaths = @(
    "C:\Program Files\TeamSpeak\TeamSpeak.exe",
    "$env:LOCALAPPDATA\Programs\TeamSpeak\TeamSpeak.exe",
    "C:\Program Files (x86)\TeamSpeak\TeamSpeak.exe"
)

$tsProc = Get-Process -Name "TeamSpeak*" -ErrorAction SilentlyContinue | Where-Object { $_.Path } | Select-Object -First 1
$tsExe = if ($tsProc -and $tsProc.Path) { 
    $tsProc.Path 
} else {
    $knownPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
}

# Закрытие запущенного TeamSpeak перед обновлением
if (Get-Process -Name "TeamSpeak*" -ErrorAction SilentlyContinue) {
    Write-Host ">>> Закрытие TeamSpeak..." -ForegroundColor Yellow
    Stop-Process -Name "TeamSpeak*" -Force -ErrorAction SilentlyContinue
    while (Get-Process -Name "TeamSpeak*" -ErrorAction SilentlyContinue) {
        Start-Sleep -Milliseconds 200
    }
    Start-Sleep -Seconds 1
}

# 2. Скачивание темы
Write-Host ">>> [2/4] Скачивание последней версии темы с GitHub..." -ForegroundColor Cyan
$extDir = "$env:APPDATA\TeamSpeak\Default\extensions\amoled.dark.minimalistic"
if (-not (Test-Path $extDir)) { 
    New-Item -ItemType Directory -Path $extDir -Force | Out-Null 
}

$tempZip = Join-Path $env:TEMP "ts-amoled-$([guid]::NewGuid().ToString('N')).zip"
$tempDir = Join-Path $env:TEMP "ts-amoled-$([guid]::NewGuid().ToString('N'))"

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri "https://github.com/justik13/teamspeak6-amoled-glow/archive/refs/heads/main.zip" -OutFile $tempZip -UseBasicParsing
    Expand-Archive -Path $tempZip -DestinationPath $tempDir -Force

    # 3. Копирование файлов
    Write-Host ">>> [3/4] Установка темы..." -ForegroundColor Cyan
    $src = Join-Path $tempDir "teamspeak6-amoled-glow-main"
    Get-ChildItem -Path $src -Exclude ".git*", "update.*" | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination (Join-Path $extDir $_.Name) -Recurse -Force
    }
    Write-Host ">>> Тема успешно установлена и обновлена!" -ForegroundColor Green
}
catch {
    Write-Host ">>> Ошибка при установке: $($_.Exception.Message)" -ForegroundColor Red
    throw $_
}
finally {
    Remove-Item -Path $tempZip, $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}

# 4. Запуск TeamSpeak (гарантированное открытие окна на рабочем столе)
Write-Host ">>> [4/4] Открытие окна TeamSpeak..." -ForegroundColor Cyan
if ($tsExe -and (Test-Path $tsExe)) {
    $workDir = Split-Path -Path $tsExe -Parent
    try {
        $res = Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{
            CommandLine = "`"$tsExe`""
            CurrentDirectory = "$workDir"
        }
        if ($res.ReturnValue -ne 0) {
            Start-Process -FilePath $tsExe -WorkingDirectory $workDir
        }
    }
    catch {
        Start-Process -FilePath $tsExe -WorkingDirectory $workDir
    }
    Write-Host ">>> Окно TeamSpeak успешно открыто с обновлённой темой!" -ForegroundColor Green
} else {
    Write-Host ">>> TeamSpeak не найден по стандартным путям. Пожалуйста, запустите его вручную." -ForegroundColor Yellow
}
