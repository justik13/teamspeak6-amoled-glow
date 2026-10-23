param(
    [switch]$Force
)
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

# TeamSpeak 6 AMOLED Glow — Автоматический установщик и модуль обновления
$ErrorActionPreference = 'Stop'

# Поддержка принудительной установки через аргументы или переменную окружения
$isForce = ($args -contains '-Force') -or ($args -contains '/Force') -or ($args -contains '-f') -or ($env:FORCE_INSTALL -eq '1') -or ($Force -eq $true)

Write-Host '========================================' -ForegroundColor Magenta
Write-Host '  Тема AMOLED Cyber Glow для TeamSpeak 6' -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Magenta

# 1. Определение путей пользователя
$appData = if ($env:APPDATA) { $env:APPDATA } else { [Environment]::GetFolderPath('ApplicationData') }
$localAppData = if ($env:LOCALAPPDATA) { $env:LOCALAPPDATA } else { [Environment]::GetFolderPath('LocalApplicationData') }
$extDir = Join-Path $appData 'TeamSpeak\Default\extensions\amoled.dark.minimalistic'

# 2. Проверка, установлен ли TeamSpeak на компьютере
$isTsInstalled = $false

# Проверка активного процесса
if (Get-Process -Name 'TeamSpeak*' -ErrorAction SilentlyContinue) {
    $isTsInstalled = $true
}

# Проверка исполняемых файлов (.exe)
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

# Проверка реестра Windows
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

if (-not $isTsInstalled -and -not $isForce) {
    Write-Host ''
    Write-Host '[!] Клиент TeamSpeak не обнаружен на вашем компьютере!' -ForegroundColor Yellow
    Write-Host '    Пожалуйста, сначала установите TeamSpeak 6: https://teamspeak.com' -ForegroundColor Gray
    Write-Host '    (Для принудительной установки запустите скрипт с ключом: -Force или FORCE_INSTALL=1)' -ForegroundColor DarkGray
    Write-Host ''
    return
}

# 3. Загрузка с GitHub или установка из локальной папки
$tempFolder = if ($env:TEMP) { $env:TEMP } else { [System.IO.Path]::GetTempPath() }
$tempZip = Join-Path $tempFolder 'ts6-amoled-glow.zip'
$tempDir = Join-Path $tempFolder 'ts6-amoled-glow-tmp'

try {
    $srcDir = $null
    $candidate = if ($env:LOCAL_SRC) { $env:LOCAL_SRC } elseif ($PSScriptRoot) { $PSScriptRoot } elseif (Test-Path -LiteralPath '.\package.json') { (Get-Location).Path } else { $null }

    # Проверка, не запущен ли скрипт непосредственно из целевой папки расширения
    $isSelfDirectory = $false
    if ($candidate -and (Test-Path -LiteralPath $candidate)) {
        try {
            $canFull = [System.IO.Path]::GetFullPath($candidate).TrimEnd('\', '/')
            $extFull = [System.IO.Path]::GetFullPath($extDir).TrimEnd('\', '/')
            if ([string]::Equals($canFull, $extFull, [System.StringComparison]::OrdinalIgnoreCase)) {
                $isSelfDirectory = $true
            }
        } catch {}
    }

    if ($candidate -and -not $isSelfDirectory -and (Test-Path -LiteralPath (Join-Path $candidate 'package.json')) -and (Test-Path -LiteralPath (Join-Path $candidate 'TeamSpeak.css'))) {
        Write-Host '>>> Установка из локальной директории...' -ForegroundColor Yellow
        $srcDir = $candidate
    } else {
        Write-Host '>>> Загрузка последней версии темы с GitHub...' -ForegroundColor Yellow
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
        } catch {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        }

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
            Expand-Archive -LiteralPath $tempZip -DestinationPath $tempDir -Force
        } catch {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            [System.IO.Compression.ZipFile]::ExtractToDirectory($tempZip, $tempDir)
        }
        
        $innerFolder = Get-ChildItem -LiteralPath $tempDir -Directory | Select-Object -First 1
        if (-not $innerFolder -or -not (Test-Path -LiteralPath (Join-Path $innerFolder.FullName 'package.json'))) {
            throw 'Не удалось распаковать архив темы или архив поврежден.'
        }
        $srcDir = $innerFolder.FullName
    }

    # 4. Создание целевого каталога расширения, если он не существует
    if (-not (Test-Path -LiteralPath $extDir)) {
        New-Item -ItemType Directory -Path $extDir -Force | Out-Null
    }

    # 5. Копирование файлов темы
    Write-Host '>>> Копирование файлов темы...' -ForegroundColor Yellow
    $newItems = @(Get-ChildItem -LiteralPath $srcDir | Where-Object { $_.Name -ne '.git' })
    if (-not $newItems -or $newItems.Count -eq 0) {
        throw 'Папка с исходными файлами темы пуста.'
    }

    # Удаление устаревших файлов в целевой папке расширения
    $newNames = @($newItems | Select-Object -ExpandProperty Name)
    Get-ChildItem -LiteralPath $extDir | Where-Object { $_.Name -notin $newNames -and $_.Name -ne '.git' } | ForEach-Object {
        Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }

    foreach ($item in $newItems) {
        Copy-Item -LiteralPath $item.FullName -Destination (Join-Path $extDir $item.Name) -Recurse -Force
    }

    Write-Host ''
    Write-Host '[OK] Тема успешно установлена / обновлена!' -ForegroundColor Green
    Write-Host '----------------------------------------' -ForegroundColor DarkGray
    Write-Host 'Чтобы применить изменения в TeamSpeak 6:' -ForegroundColor White
    Write-Host '  1. Откройте: Настройки -> Внешний вид (включите "Использовать внешнюю тему")' -ForegroundColor Cyan
    Write-Host '  2. Полностью закройте TeamSpeak (значок в трее -> Выход) и запустите снова' -ForegroundColor Yellow
    Write-Host ''
}
catch {
    Write-Host ''
    Write-Host ('[!] Ошибка при установке: ' + $_.Exception.Message) -ForegroundColor Red
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
