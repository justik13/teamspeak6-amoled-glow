param(
    [switch]$NoRestart,
    [switch]$Force
)

# TeamSpeak 6 AMOLED Glow — Safe Universal Installer & Updater
$prevErrorAction = $ErrorActionPreference
$prevProgress = $ProgressPreference
$ErrorActionPreference = 'Stop'

try {
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host "  TeamSpeak 6 AMOLED Glow Updater" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Magenta

    # Проверка контекста запуска
    $currentSessionId = [System.Diagnostics.Process]::GetCurrentProcess().SessionId
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($isAdmin) {
        Write-Host ">>> [Инфо] Скрипт выполняется с правами администратора." -ForegroundColor Gray
    }

    # 1. Поиск пути к TeamSpeak
    Write-Host "`n>>> [1/4] Поиск TeamSpeak..." -ForegroundColor Cyan

    function Get-TeamSpeakPath {
        # 1.1. Из запущенного процесса в текущей сессии
        $proc = Get-Process -Name "TeamSpeak*" -ErrorAction SilentlyContinue | 
            Where-Object { $_.SessionId -eq $currentSessionId -and $_.Path } | 
            Select-Object -First 1
        if ($proc -and (Test-Path -LiteralPath $proc.Path)) { 
            return $proc.Path 
        }

        # 1.2. Из ярлыков (Рабочий стол, Меню «Пуск», Закреплённые в панели задач)
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

        # 1.3. Из системного реестра App Paths
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

        # 1.4. Из стандартных папок и корней всех подключенных дисков
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

    # 2. Скачивание и валидация архива (БЕЗ закрытия TeamSpeak)
    Write-Host "`n>>> [2/4] Загрузка и проверка обновления..." -ForegroundColor Cyan
    $appDataDir = [Environment]::GetFolderPath('ApplicationData')
    if (-not $appDataDir) { $appDataDir = $env:APPDATA }
    $extDir = Join-Path $appDataDir "TeamSpeak\Default\extensions\amoled.dark.minimalistic"

    $tempBase = [System.IO.Path]::GetTempPath()
    $tempZip = Join-Path $tempBase "ts-amoled-$([guid]::NewGuid().ToString('N')).zip"
    $tempDir = Join-Path $tempBase "ts-amoled-$([guid]::NewGuid().ToString('N'))"
    $bakDir  = Join-Path $tempBase "ts-ext-bak-$([guid]::NewGuid().ToString('N'))"

    try {
        $ProgressPreference = 'SilentlyContinue'
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        Write-Host ">>> Скачивание архива темы с GitHub (таймаут 30 сек)..." -ForegroundColor Gray
        try {
            Invoke-WebRequest -Uri "https://github.com/justik13/teamspeak6-amoled-glow/archive/refs/heads/main.zip" `
                -OutFile $tempZip -UseBasicParsing -TimeoutSec 30
        } catch {
            throw "Не удалось загрузить архив с GitHub: $($_.Exception.Message). Проверьте интернет-соединение."
        }

        Write-Host ">>> Распаковка и проверка целостности файлов..." -ForegroundColor Gray
        Expand-Archive -LiteralPath $tempZip -DestinationPath $tempDir -Force

        $src = Join-Path $tempDir "teamspeak6-amoled-glow-main"
        if (-not (Test-Path -LiteralPath $src)) {
            throw "Неверная структура архива темы: отсутствует папка teamspeak6-amoled-glow-main."
        }

        # Валидация обязательных файлов темы перед установкой
        $requiredFiles = @("package.json", "TeamSpeak.css", "Reaper.css", "Pink.css", "Cyan.css", "Purple.css", "Amber.css")
        foreach ($rf in $requiredFiles) {
            $rfPath = Join-Path $src $rf
            if (-not (Test-Path -LiteralPath $rfPath)) {
                throw "Архив темы повреждён: отсутствует обязательный файл $rf."
            }
        }
        Write-Host ">>> Проверка целостности пройдена успешно!" -ForegroundColor Green

        # 3. Безопасная установка с резервной копией и откатом при ошибке
        Write-Host "`n>>> [3/4] Установка темы..." -ForegroundColor Cyan

        # Создание резервной копии текущей версии темы (если она существует)
        if (Test-Path -LiteralPath $extDir) {
            Copy-Item -LiteralPath $extDir -Destination $bakDir -Recurse -Force
        }

        if (-not (Test-Path -LiteralPath $extDir)) { 
            New-Item -ItemType Directory -Path $extDir -Force | Out-Null 
        }

        try {
            Get-ChildItem -LiteralPath $src | Where-Object { $_.Name -notmatch '^(\.git|update\.)' } | ForEach-Object {
                Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $extDir $_.Name) -Recurse -Force
            }
            Write-Host ">>> Файлы темы успешно установлены на диск!" -ForegroundColor Green
        }
        catch {
            Write-Host ">>> Сбой при копировании файлов: $($_.Exception.Message)" -ForegroundColor Red
            if (Test-Path -LiteralPath $bakDir) {
                Write-Host ">>> Восстановление предыдущей рабочей версии темы..." -ForegroundColor Yellow
                Remove-Item -LiteralPath $extDir -Recurse -Force -ErrorAction SilentlyContinue
                Copy-Item -LiteralPath $bakDir -Destination $extDir -Recurse -Force
                Write-Host ">>> Предыдущая версия успешно восстановлена." -ForegroundColor Yellow
            }
            throw $_
        }
    }
    finally {
        # Очистка временных файлов
        if (Test-Path -LiteralPath $tempZip) { Remove-Item -LiteralPath $tempZip -Force -ErrorAction SilentlyContinue }
        if (Test-Path -LiteralPath $tempDir) { Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue }
        if (Test-Path -LiteralPath $bakDir)  { Remove-Item -LiteralPath $bakDir -Recurse -Force -ErrorAction SilentlyContinue }
    }

    # 4. Применение темы и безопасный перезапуск
    Write-Host "`n>>> [4/4] Завершение..." -ForegroundColor Cyan

    $sessionProcs = Get-Process -Name "TeamSpeak*" -ErrorAction SilentlyContinue | Where-Object { $_.SessionId -eq $currentSessionId }
    $isTsRunning = [bool]($sessionProcs -and $sessionProcs.Count -gt 0)
    $shouldRestart = $false

    if ($isTsRunning) {
        if ($NoRestart) {
            $shouldRestart = $false
            Write-Host ">>> TeamSpeak активен. Перезапуск пропущен по флагу -NoRestart." -ForegroundColor Gray
        } elseif ($Force) {
            $shouldRestart = $true
        } else {
            # Безопасный запрос перезапуска: по умолчанию НЕТ [y/N], чтобы не сломать игры и оверлеи
            Write-Host "`n[!] TeamSpeak сейчас запущен." -ForegroundColor Yellow
            Write-Host "    Тема уже успешно обновлена на диске." -ForegroundColor Green
            Write-Host "    Если вы сейчас в игре, перезапуск может сбросить игровой оверлей!" -ForegroundColor Yellow
            Write-Host -NoNewline ">>> Перезапустить TeamSpeak сейчас для применения? [y/N] (по умолчанию N — не перезапускать): " -ForegroundColor Cyan
            
            $answer = Read-Host
            if ($answer -and ($answer.Trim().ToLower() -in @('y', 'yes', 'д', 'да'))) {
                $shouldRestart = $true
            } else {
                $shouldRestart = $false
                Write-Host ">>> Перезапуск отклонён. Клиент не закрывался, игра не прервана." -ForegroundColor Gray
            }
        }
    } elseif ($Force -or (-not $NoRestart)) {
        # TeamSpeak не был запущен. Если найден exe, спросить о запуске
        if ($tsExe -and (Test-Path -LiteralPath $tsExe)) {
            if ($Force) {
                $shouldRestart = $true
            } else {
                Write-Host -NoNewline "`n>>> Запустить TeamSpeak сейчас? [Y/n] (по умолчанию Y): " -ForegroundColor Cyan
                $answer = Read-Host
                if ([string]::IsNullOrWhiteSpace($answer) -or ($answer.Trim().ToLower() -in @('y', 'yes', 'д', 'да'))) {
                    $shouldRestart = $true
                }
            }
        }
    }

    if ($shouldRestart) {
        if ($isTsRunning) {
            Write-Host ">>> Мягкое закрытие TeamSpeak..." -ForegroundColor Yellow
            $tsProcs = Get-Process -Name "TeamSpeak*" -ErrorAction SilentlyContinue | Where-Object { $_.SessionId -eq $currentSessionId }
            foreach ($p in $tsProcs) {
                try { $p.CloseMainWindow() | Out-Null } catch {}
            }

            # Ожидание штатного закрытия окна до 3 секунд
            $graceTimeout = [DateTime]::UtcNow.AddSeconds(3)
            while ((Get-Process -Name "TeamSpeak*" -ErrorAction SilentlyContinue | Where-Object { $_.SessionId -eq $currentSessionId }) -and ([DateTime]::UtcNow -lt $graceTimeout)) {
                Start-Sleep -Milliseconds 200
            }

            # Если процессы всё ещё активны — принудительное завершение
            $remaining = Get-Process -Name "TeamSpeak*" -ErrorAction SilentlyContinue | Where-Object { $_.SessionId -eq $currentSessionId }
            if ($remaining) {
                $remaining | Stop-Process -Force -ErrorAction SilentlyContinue
                $stopTimeout = [DateTime]::UtcNow.AddSeconds(5)
                while ((Get-Process -Name "TeamSpeak*" -ErrorAction SilentlyContinue | Where-Object { $_.SessionId -eq $currentSessionId }) -and ([DateTime]::UtcNow -lt $stopTimeout)) {
                    Start-Sleep -Milliseconds 200
                }
            }
            Start-Sleep -Milliseconds 500
        }

        # Запуск TeamSpeak
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
        if ($isTsRunning) {
            Write-Host "Клиент TeamSpeak не перезапускался, ваши игры и звонки не прерваны." -ForegroundColor White
            Write-Host "Чтобы применить обновлённую тему прямо сейчас:" -ForegroundColor White
            Write-Host "  1. В TeamSpeak откройте Настройки (шестерёнка) -> Внешний вид" -ForegroundColor Cyan
            Write-Host "  2. Нажмите круглую стрелочку 🔄 («Обновить темы»)" -ForegroundColor Cyan
            Write-Host "  Или просто перезапустите клиент, когда закончите игру." -ForegroundColor Gray
        } else {
            Write-Host "TeamSpeak сейчас не запущен. Тема активируется при следующем запуске." -ForegroundColor White
        }
    }
}
catch {
    Write-Host "`n[!] Ошибка: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    $ErrorActionPreference = $prevErrorAction
    $ProgressPreference = $prevProgress
}
