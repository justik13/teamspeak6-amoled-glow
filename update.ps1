param(
    [switch]$NoRestart,
    [switch]$Force
)

# TeamSpeak 6 AMOLED Glow — Universal Installer & Updater
$ErrorActionPreference = 'Stop'

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "  TeamSpeak 6 AMOLED Glow Updater" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Magenta

# Проверка контекста запуска
$currentSessionId = [System.Diagnostics.Process]::GetCurrentProcess().SessionId
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    Write-Host ">>> [Инфо] Скрипт выполняется с повышенными привилегиями." -ForegroundColor Gray
}

# 1. Поиск пути к TeamSpeak
Write-Host "`n>>> [1/4] Поиск TeamSpeak..." -ForegroundColor Cyan

function Get-TeamSpeakPath {
    # 1.1. Из запущенного процесса в текущей пользовательской сессии
    $proc = Get-Process -Name "TeamSpeak*" -ErrorAction SilentlyContinue | 
        Where-Object { $_.SessionId -eq $currentSessionId -and $_.Path } | 
        Select-Object -First 1
    if ($proc -and (Test-Path -LiteralPath $proc.Path)) { 
        return $proc.Path 
    }

    # 1.2. Из ярлыков (Рабочий стол, Меню «Пуск», Закреплённые в панели задач)
    # Корректно определяет пути даже при включённой синхронизации OneDrive Desktop
    $shortcutDirs = @(
        [Environment]::GetFolderPath('Desktop'),
        [Environment]::GetFolderPath('CommonDesktopDirectory'),
        [Environment]::GetFolderPath('Programs'),
        [Environment]::GetFolderPath('CommonPrograms'),
        (Join-Path ([Environment]::GetFolderPath('ApplicationData')) "Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar")
    ) | Where-Object { $_ -and (Test-Path -LiteralPath $_) }

    try {
        $ws = New-Object -ComObject WScript.Shell
        foreach ($dir in $shortcutDirs) {
            $shortcuts = Get-ChildItem -LiteralPath $dir -Filter "*TeamSpeak*.lnk" -Recurse -Depth 2 -ErrorAction SilentlyContinue
            foreach ($sc in $shortcuts) {
                try {
                    $target = $ws.CreateShortcut($sc.FullName).TargetPath
                    if ($target -and (Test-Path -LiteralPath $target) -and ($target -like "*TeamSpeak*.exe")) {
                        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($ws) | Out-Null
                        return $target
                    }
                } catch {}
            }
        }
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($ws) | Out-Null
    } catch {}

    # 1.3. Из системного реестра App Paths (HKLM, HKCU, 64-bit и WOW6432Node)
    $regPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\TeamSpeak.exe",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\TeamSpeak.exe",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\App Paths\TeamSpeak.exe",
        "HKCU:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\App Paths\TeamSpeak.exe"
    )
    foreach ($rp in $regPaths) {
        $val = (Get-ItemProperty -Path $rp -ErrorAction SilentlyContinue).'(Default)'
        if ($val -and (Test-Path -LiteralPath $val)) { 
            return $val 
        }
    }

    # 1.4. Из стандартных папок Program Files, AppData и корней всех подключенных дисков
    $pf = [Environment]::GetFolderPath('ProgramFiles')
    $pfx86 = [Environment]::GetFolderPath('ProgramFilesX86')
    $localApp = [Environment]::GetFolderPath('LocalApplicationData')

    $candidates = [System.Collections.Generic.List[string]]::new()
    if ($pf) { 
        $candidates.Add((Join-Path $pf "TeamSpeak\TeamSpeak.exe"))
        $candidates.Add((Join-Path $pf "TeamSpeak 6\TeamSpeak.exe")) 
    }
    if ($localApp) { 
        $candidates.Add((Join-Path $localApp "Programs\TeamSpeak\TeamSpeak.exe"))
        $candidates.Add((Join-Path $localApp "Programs\TeamSpeak 6\TeamSpeak.exe")) 
    }
    if ($pfx86) { 
        $candidates.Add((Join-Path $pfx86 "TeamSpeak\TeamSpeak.exe"))
        $candidates.Add((Join-Path $pfx86 "TeamSpeak 6\TeamSpeak.exe")) 
    }

    $drives = (Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue).Root
    foreach ($d in $drives) {
        $candidates.Add((Join-Path $d "Program Files\TeamSpeak\TeamSpeak.exe"))
        $candidates.Add((Join-Path $d "Program Files (x86)\TeamSpeak\TeamSpeak.exe"))
        $candidates.Add((Join-Path $d "TeamSpeak\TeamSpeak.exe"))
        $candidates.Add((Join-Path $d "TeamSpeak 6\TeamSpeak.exe"))
        $candidates.Add((Join-Path $d "Games\TeamSpeak\TeamSpeak.exe"))
    }

    foreach ($c in $candidates) {
        if (Test-Path -LiteralPath $c) { 
            return $c 
        }
    }

    return $null
}

$tsExe = Get-TeamSpeakPath
if ($tsExe) {
    Write-Host ">>> Найден TeamSpeak: $tsExe" -ForegroundColor Gray
}

# Проверка запущенного процесса в текущей сессии
$sessionProcs = Get-Process -Name "TeamSpeak*" -ErrorAction SilentlyContinue | Where-Object { $_.SessionId -eq $currentSessionId }
$isTsRunning = [bool]($sessionProcs -and $sessionProcs.Count -gt 0)
$shouldRestart = $false

if ($isTsRunning) {
    if ($NoRestart) {
        $shouldRestart = $false
        Write-Host ">>> Запущен TeamSpeak. Перезапуск пропущен по флагу -NoRestart." -ForegroundColor Gray
    } elseif ($Force) {
        $shouldRestart = $true
    } else {
        # Интерактивное подтверждение для защиты от краша игр и сброса оверлеев
        Write-Host "`n[!] TeamSpeak сейчас запущен." -ForegroundColor Yellow
        Write-Host "    Если вы сейчас в игре, закрытие TeamSpeak может сбросить игровой оверлей!" -ForegroundColor Yellow
        Write-Host -NoNewline ">>> Перезапустить TeamSpeak сейчас? [Y/n] (по умолчанию Y): " -ForegroundColor Cyan
        
        $answer = Read-Host
        if ([string]::IsNullOrWhiteSpace($answer) -or $answer.Trim().ToLower() -eq 'y' -or $answer.Trim().ToLower() -eq 'yes' -or $answer.Trim() -eq 'д' -or $answer.Trim().ToLower() -eq 'да') {
            $shouldRestart = $true
        } else {
            $shouldRestart = $false
            Write-Host ">>> Авто-перезапуск отменён. Тема обновится на диске без закрытия клиента." -ForegroundColor Gray
        }
    }
}

if ($shouldRestart) {
    Write-Host ">>> Закрытие TeamSpeak перед обновлением..." -ForegroundColor Yellow
    Get-Process -Name "TeamSpeak*" -ErrorAction SilentlyContinue | 
        Where-Object { $_.SessionId -eq $currentSessionId } | 
        Stop-Process -Force -ErrorAction SilentlyContinue

    # Безопасное ожидание завершения с таймаутом (не зависает бесконечно при блокировках)
    $stopTimeout = [DateTime]::UtcNow.AddSeconds(10)
    while ((Get-Process -Name "TeamSpeak*" -ErrorAction SilentlyContinue | Where-Object { $_.SessionId -eq $currentSessionId }) -and ([DateTime]::UtcNow -lt $stopTimeout)) {
        Start-Sleep -Milliseconds 200
    }
    Start-Sleep -Milliseconds 500
}

# 2. Скачивание темы
Write-Host ">>> [2/4] Скачивание последней версии темы с GitHub..." -ForegroundColor Cyan
$appDataDir = [Environment]::GetFolderPath('ApplicationData')
if (-not $appDataDir) { $appDataDir = $env:APPDATA }
$extDir = Join-Path $appDataDir "TeamSpeak\Default\extensions\amoled.dark.minimalistic"

if (-not (Test-Path -LiteralPath $extDir)) { 
    New-Item -ItemType Directory -Path $extDir -Force | Out-Null 
}

$tempBase = [System.IO.Path]::GetTempPath()
$tempZip = Join-Path $tempBase "ts-amoled-$([guid]::NewGuid().ToString('N')).zip"
$tempDir = Join-Path $tempBase "ts-amoled-$([guid]::NewGuid().ToString('N'))"

try {
    # Отключение прогресс-бара ускоряет загрузку в PowerShell 5.1 в разы
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri "https://github.com/justik13/teamspeak6-amoled-glow/archive/refs/heads/main.zip" -OutFile $tempZip -UseBasicParsing
    Expand-Archive -LiteralPath $tempZip -DestinationPath $tempDir -Force

    # 3. Копирование файлов
    Write-Host ">>> [3/4] Установка темы..." -ForegroundColor Cyan
    $src = Join-Path $tempDir "teamspeak6-amoled-glow-main"
    Get-ChildItem -LiteralPath $src | Where-Object { $_.Name -notmatch '^(\.git|update\.)' } | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $extDir $_.Name) -Recurse -Force
    }
    Write-Host ">>> Файлы темы успешно установлены!" -ForegroundColor Green
}
catch {
    Write-Host ">>> Ошибка при установке: $($_.Exception.Message)" -ForegroundColor Red
    throw $_
}
finally {
    if (Test-Path -LiteralPath $tempZip) { Remove-Item -LiteralPath $tempZip -Force -ErrorAction SilentlyContinue }
    if (Test-Path -LiteralPath $tempDir) { Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue }
}

# 4. Запуск или инструкции
Write-Host ">>> [4/4] Завершение..." -ForegroundColor Cyan
if ($shouldRestart -or (-not $isTsRunning)) {
    if ($tsExe -and (Test-Path -LiteralPath $tsExe)) {
        Write-Host ">>> Запуск окна TeamSpeak..." -ForegroundColor Cyan
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
        Write-Host ">>> TeamSpeak не найден для авто-запуска. Пожалуйста, откройте его вручную." -ForegroundColor Yellow
    }
} else {
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "  Тема успешно обновлена на диске!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Клиент TeamSpeak не закрывался, ваша игра не прервана." -ForegroundColor White
    Write-Host "Чтобы применить тему:" -ForegroundColor White
    Write-Host "  1. В TeamSpeak откройте Настройки (шестерёнка) -> Внешний вид" -ForegroundColor Cyan
    Write-Host "  2. Нажмите круглую стрелочку 🔄 («Обновить темы»)" -ForegroundColor Cyan
    Write-Host "  Или перезапустите клиент вручную, когда закончите играть." -ForegroundColor Gray
}
