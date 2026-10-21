param(
    [switch]$NoRestart,
    [switch]$Force
)

# TeamSpeak 6 AMOLED Glow — Smart Installer & Updater
$ErrorActionPreference = 'Stop'

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "  TeamSpeak 6 AMOLED Glow Updater" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Magenta

# 1. Поиск пути к TeamSpeak
Write-Host "`n>>> [1/4] Поиск TeamSpeak..." -ForegroundColor Cyan

function Get-TeamSpeakPath {
    # Из запущенного процесса
    $proc = Get-Process -Name "TeamSpeak*" -ErrorAction SilentlyContinue | Where-Object { $_.Path } | Select-Object -First 1
    if ($proc -and (Test-Path $proc.Path)) { return $proc.Path }

    # Из ярлыков меню Пуск и рабочего стола
    $shortcutPaths = @(
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\TeamSpeak.lnk",
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\TeamSpeak.lnk",
        "$env:USERPROFILE\Desktop\TeamSpeak.lnk",
        "C:\Users\Public\Desktop\TeamSpeak.lnk"
    )
    $ws = New-Object -ComObject WScript.Shell
    foreach ($sc in $shortcutPaths) {
        if (Test-Path $sc) {
            try {
                $target = $ws.CreateShortcut($sc).TargetPath
                if ($target -and (Test-Path $target) -and ($target -like "*.exe")) {
                    return $target
                }
            } catch {}
        }
    }

    # Из системного реестра App Paths
    $regPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\TeamSpeak.exe",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\TeamSpeak.exe"
    )
    foreach ($rp in $regPaths) {
        $val = (Get-ItemProperty -Path $rp -ErrorAction SilentlyContinue).'(Default)'
        if ($val -and (Test-Path $val)) { return $val }
    }

    # Стандартные каталоги установки
    $standardPaths = @(
        "C:\Program Files\TeamSpeak\TeamSpeak.exe",
        "$env:LOCALAPPDATA\Programs\TeamSpeak\TeamSpeak.exe",
        "C:\Program Files (x86)\TeamSpeak\TeamSpeak.exe"
    )
    foreach ($sp in $standardPaths) {
        if (Test-Path $sp) { return $sp }
    }

    return $null
}

$tsExe = Get-TeamSpeakPath
if ($tsExe) {
    Write-Host ">>> Найден TeamSpeak: $tsExe" -ForegroundColor Gray
}

# Проверка запущенного процесса
$isTsRunning = [bool](Get-Process -Name "TeamSpeak*" -ErrorAction SilentlyContinue)
$shouldRestart = $false

if ($isTsRunning) {
    if ($NoRestart) {
        $shouldRestart = $false
        Write-Host ">>> Запущен TeamSpeak. Перезапуск пропущен по флагу -NoRestart." -ForegroundColor Gray
    } elseif ($Force) {
        $shouldRestart = $true
    } else {
        # Интерактивное подтверждение для защиты от краша игр
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
    Write-Host ">>> Файлы темы успешно установлены!" -ForegroundColor Green
}
catch {
    Write-Host ">>> Ошибка при установке: $($_.Exception.Message)" -ForegroundColor Red
    throw $_
}
finally {
    Remove-Item -Path $tempZip, $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}

# 4. Запуск или инструкции
Write-Host ">>> [4/4] Завершение..." -ForegroundColor Cyan
if ($shouldRestart -or (-not $isTsRunning)) {
    if ($tsExe -and (Test-Path $tsExe)) {
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
