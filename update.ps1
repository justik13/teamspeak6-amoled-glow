# TeamSpeak 6 AMOLED Glow — Safe Theme Installer & Updater
$ErrorActionPreference = 'Stop'

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "  TeamSpeak 6 AMOLED Glow Updater" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Magenta

# 1. Папка расширения
$extDir = "$env:APPDATA\TeamSpeak\Default\extensions\amoled.dark.minimalistic"
if (-not (Test-Path $extDir)) { 
    New-Item -ItemType Directory -Path $extDir -Force | Out-Null 
}

# 2. Скачивание свежей темы с GitHub
Write-Host "`n>>> [1/2] Скачивание последней версии темы..." -ForegroundColor Cyan
$tempZip = Join-Path $env:TEMP "ts-amoled-$([guid]::NewGuid().ToString('N')).zip"
$tempDir = Join-Path $env:TEMP "ts-amoled-$([guid]::NewGuid().ToString('N'))"

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri "https://github.com/justik13/teamspeak6-amoled-glow/archive/refs/heads/main.zip" -OutFile $tempZip -UseBasicParsing
    Expand-Archive -Path $tempZip -DestinationPath $tempDir -Force

    # 3. Обновление файлов
    Write-Host ">>> [2/2] Обновление файлов темы..." -ForegroundColor Cyan
    $src = Join-Path $tempDir "teamspeak6-amoled-glow-main"
    Get-ChildItem -Path $src -Exclude ".git*", "update.*" | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination (Join-Path $extDir $_.Name) -Recurse -Force
    }
    
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "  Тема успешно обновлена на диске!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Чтобы применить обновлённую тему без краша игры и перезапуска:" -ForegroundColor Yellow
    Write-Host "1. В TeamSpeak откройте Настройки (шестерёнка в левом нижнем углу)" -ForegroundColor White
    Write-Host "2. Перейдите в раздел 'Внешний вид'" -ForegroundColor White
    Write-Host "3. Нажмите круглую стрелочку 'Обновить' рядом со списком тем" -ForegroundColor Cyan
}
catch {
    Write-Host ">>> Ошибка при скачивании: $($_.Exception.Message)" -ForegroundColor Red
    throw $_
}
finally {
    Remove-Item -Path $tempZip, $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}
