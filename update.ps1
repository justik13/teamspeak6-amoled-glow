$ErrorActionPreference = 'Stop'

Write-Host '========================================' -ForegroundColor Magenta
Write-Host '  TeamSpeak 6 AMOLED Glow Theme' -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Magenta

# Папка расширений TeamSpeak 6 в профиле пользователя
$appData = if ($env:APPDATA) { $env:APPDATA } else { [Environment]::GetFolderPath('ApplicationData') }
$extDir = Join-Path $appData 'TeamSpeak\Default\extensions\amoled.dark.minimalistic'

$tempZip = Join-Path $env:TEMP 'ts6-amoled-glow.zip'
$tempDir = Join-Path $env:TEMP 'ts6-amoled-glow-tmp'

try {
    # 1. Проверяем: установка из локальной папки или скачивание с GitHub
    $srcDir = $null
    $candidate = if ($env:LOCAL_SRC) { $env:LOCAL_SRC } elseif ($PSScriptRoot) { $PSScriptRoot } else { $null }
    if ($candidate -and (Test-Path -LiteralPath (Join-Path $candidate 'package.json')) -and (Test-Path -LiteralPath (Join-Path $candidate 'styles'))) {
        Write-Host '>>> Установка из локальной папки...' -ForegroundColor Yellow
        $srcDir = $candidate
    } else {
        Write-Host '>>> Скачивание темы с GitHub...' -ForegroundColor Yellow
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $zipUrl = 'https://github.com/justik13/teamspeak6-amoled-glow/archive/refs/heads/main.zip'
        
        Invoke-WebRequest -Uri $zipUrl -OutFile $tempZip -UseBasicParsing
        
        if (Test-Path -LiteralPath $tempDir) {
            Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        
        try {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            [System.IO.Compression.ZipFile]::ExtractToDirectory($tempZip, $tempDir)
        } catch {
            Expand-Archive -LiteralPath $tempZip -DestinationPath $tempDir -Force
        }
        
        $innerFolder = Get-ChildItem -LiteralPath $tempDir -Directory | Select-Object -First 1
        if (-not $innerFolder) {
            throw 'Не удалось распаковать архив темы.'
        }
        $srcDir = $innerFolder.FullName
    }

    # 2. Создаем папку темы, если её ещё нет
    if (-not (Test-Path -LiteralPath $extDir)) {
        New-Item -ItemType Directory -Path $extDir -Force | Out-Null
    }

    # 3. Копируем файлы темы
    Write-Host '>>> Копирование файлов темы...' -ForegroundColor Yellow
    Get-ChildItem -LiteralPath $srcDir | Where-Object { $_.Name -ne '.git' } | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $extDir $_.Name) -Recurse -Force
    }

    Write-Host ''
    Write-Host '[OK] Тема успешно установлена / обновлена!' -ForegroundColor Green
    Write-Host '----------------------------------------' -ForegroundColor DarkGray
    Write-Host 'Как применить:' -ForegroundColor White
    Write-Host '  1. В TeamSpeak откройте Настройки (шестерёнка) -> Внешний вид' -ForegroundColor Gray
    Write-Host '  2. Нажмите круглую стрелочку (🔄) для обновления тем' -ForegroundColor Gray
    Write-Host '  (Либо просто перезапустите TeamSpeak в удобное время)' -ForegroundColor DarkGray
    Write-Host ''
}
catch {
    Write-Host ''
    Write-Host "[!] Ошибка при установке: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ''
}
finally {
    if (Test-Path -LiteralPath $tempZip) {
        Remove-Item -LiteralPath $tempZip -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path -LiteralPath $tempDir) {
        Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
