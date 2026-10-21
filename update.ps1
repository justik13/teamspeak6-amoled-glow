$ErrorActionPreference = 'Stop'

Write-Host '========================================' -ForegroundColor Magenta
Write-Host '  TeamSpeak 6 AMOLED Glow Theme' -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Magenta

# 1. Поиск путей пользователя
$appData = if ($env:APPDATA) { $env:APPDATA } else { [Environment]::GetFolderPath('ApplicationData') }
$localAppData = if ($env:LOCALAPPDATA) { $env:LOCALAPPDATA } else { [Environment]::GetFolderPath('LocalApplicationData') }
$extDir = Join-Path $appData 'TeamSpeak\Default\extensions\amoled.dark.minimalistic'

# 2. Проверка: установлен ли TeamSpeak на компьютере
$isTsInstalled = $false

# Проверка активного процесса
if (Get-Process -Name 'TeamSpeak*' -ErrorAction SilentlyContinue) {
    $isTsInstalled = $true
}

# Проверка файлов установки (.exe)
if (-not $isTsInstalled) {
    $tsPaths = @(
        (Join-Path $env:ProgramFiles 'TeamSpeak\TeamSpeak.exe'),
        (Join-Path $localAppData 'Programs\TeamSpeak\TeamSpeak.exe'),
        (Join-Path $localAppData 'TeamSpeak\TeamSpeak.exe')
    )
    $pf86 = ${env:ProgramFiles(x86)}
    if ($pf86) { $tsPaths += (Join-Path $pf86 'TeamSpeak\TeamSpeak.exe') }

    foreach ($p in $tsPaths) {
        if ($p -and (Test-Path -LiteralPath $p)) {
            $isTsInstalled = $true
            break
        }
    }
}

# Проверка каталогов данных TeamSpeak
if (-not $isTsInstalled) {
    $tsDataPaths = @(
        (Join-Path $appData 'TeamSpeak'),
        (Join-Path $localAppData 'TeamSpeak')
    )
    foreach ($dp in $tsDataPaths) {
        if ($dp -and (Test-Path -LiteralPath $dp)) {
            $isTsInstalled = $true
            break
        }
    }
}

# Проверка записей реестра Windows
if (-not $isTsInstalled) {
    $regPaths = @(
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    foreach ($rp in $regPaths) {
        if (Get-ItemProperty $rp -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like '*TeamSpeak*' }) {
            $isTsInstalled = $true
            break
        }
    }
}

if (-not $isTsInstalled) {
    Write-Host ''
    Write-Host '[!] TeamSpeak не найден на вашем компьютере!' -ForegroundColor Yellow
    Write-Host '    Для работы темы сначала установите TeamSpeak (клиент 5 / 6):' -ForegroundColor Gray
    Write-Host '    -> Скачайте установщик с официального сайта: https://teamspeak.com' -ForegroundColor Cyan
    Write-Host '    После установки TeamSpeak запустите эту команду снова.' -ForegroundColor Gray
    Write-Host ''
    return
}

# 3. Скачивание или локальная установка
$tempZip = Join-Path $env:TEMP 'ts6-amoled-glow.zip'
$tempDir = Join-Path $env:TEMP 'ts6-amoled-glow-tmp'

try {
    $srcDir = $null
    $candidate = if ($env:LOCAL_SRC) { $env:LOCAL_SRC } elseif ($PSScriptRoot) { $PSScriptRoot } else { $null }
    if ($candidate -and (Test-Path -LiteralPath (Join-Path $candidate 'package.json')) -and (Test-Path -LiteralPath (Join-Path $candidate 'styles'))) {
        Write-Host '>>> Установка из локальной папки...' -ForegroundColor Yellow
        $srcDir = $candidate
    } else {
        Write-Host '>>> Скачивание темы с GitHub...' -ForegroundColor Yellow
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $zipUrl = 'https://github.com/justik13/teamspeak6-amoled-glow/archive/refs/heads/main.zip'
        
        try {
            Invoke-WebRequest -Uri $zipUrl -OutFile $tempZip -UseBasicParsing
        } catch {
            (New-Object System.Net.WebClient).DownloadFile($zipUrl, $tempZip)
        }
        
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

    # 4. Создаем папку темы, если её ещё нет
    if (-not (Test-Path -LiteralPath $extDir)) {
        New-Item -ItemType Directory -Path $extDir -Force | Out-Null
    }

    # 5. Копируем файлы темы
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
