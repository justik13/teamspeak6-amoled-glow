param(
    [switch]$NoRestart,
    [switch]$Force
)

# TeamSpeak 6 AMOLED Glow — Safe Universal Installer & Updater
$prevErrorAction = $ErrorActionPreference
$prevProgress = $ProgressPreference
$prevOutputEncoding = [Console]::OutputEncoding
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

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

    # Компиляция безопасного Win32-хелпера закрытия (если ещё не загружен)
    if (-not ([System.Management.Automation.PSTypeName]'TSGracefulCloser').Type) {
        $closerSource = @'
using System;
using System.Text;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public class TSGracefulCloser {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern IntPtr OpenInputDesktop(uint dwFlags, bool fInherit, uint dwDesiredAccess);

    [DllImport("user32.dll")]
    public static extern bool EnumDesktopWindows(IntPtr hDesktop, EnumWindowsProc lpfn, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern bool EnumWindows(EnumWindowsProc lpfn, IntPtr lParam);

    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern int GetClassName(IntPtr hWnd, StringBuilder lpClassName, int nMaxCount);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool PostMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern bool CloseDesktop(IntPtr hDesktop);

    public const uint WM_CLOSE = 0x0010;

    public static int SendGracefulClose(int[] pids) {
        int messagesSent = 0;
        var pidSet = new HashSet<int>(pids);

        EnumWindowsProc callback = (hWnd, lParam) => {
            uint pid;
            GetWindowThreadProcessId(hWnd, out pid);
            if (pidSet.Contains((int)pid)) {
                var sbClass = new StringBuilder(256);
                GetClassName(hWnd, sbClass, 256);
                string cls = sbClass.ToString();
                if (cls == "TS Client" || cls == "Chrome_WidgetWin_1") {
                    PostMessage(hWnd, WM_CLOSE, IntPtr.Zero, IntPtr.Zero);
                    messagesSent++;
                }
            }
            return true;
        };

        IntPtr hDesk = OpenInputDesktop(0, false, 0x0100);
        if (hDesk != IntPtr.Zero) {
            EnumDesktopWindows(hDesk, callback, IntPtr.Zero);
            CloseDesktop(hDesk);
        } else {
            EnumWindows(callback, IntPtr.Zero);
        }

        return messagesSent;
    }
}
'@
        Add-Type -TypeDefinition $closerSource
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

    # 4. Применение темы и безопасное завершение
    Write-Host "`n>>> [4/4] Завершение..." -ForegroundColor Cyan

    $sessionProcs = Get-Process -Name "TeamSpeak*" -ErrorAction SilentlyContinue | Where-Object { $_.SessionId -eq $currentSessionId }
    $isTsRunning = [bool]($sessionProcs -and $sessionProcs.Count -gt 0)
    $shouldRestart = $false

    if ($isTsRunning) {
        Write-Host "`n========================================" -ForegroundColor Green
        Write-Host "  Тема успешно обновлена на диске!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "Файлы темы уже обновлены. Перезапуск клиента НЕ ОБЯЗАТЕЛЕН!" -ForegroundColor White
        Write-Host "Чтобы применить тему прямо сейчас без выхода из войса и без призраков:" -ForegroundColor Cyan
        Write-Host "  -> В TeamSpeak откройте Настройки (шестерёнка) -> Внешний вид" -ForegroundColor Cyan
        Write-Host "  -> Нажмите круглую стрелочку 🔄 («Обновить темы»)" -ForegroundColor Cyan

        if (-not $NoRestart) {
            Write-Host "`nХотите штатно перезапустить TeamSpeak сейчас через скрипт?" -ForegroundColor Yellow
            Write-Host "(Скрипт пошлёт штатный сигнал выхода в трей, чтобы корректно покинуть войс-канал)" -ForegroundColor Gray
            Write-Host -NoNewline ">>> Перезапустить TeamSpeak? [y/N] (по умолчанию N — не закрывать): " -ForegroundColor Cyan
            
            $answer = Read-Host
            if ($answer -and ($answer.Trim().ToLower() -in @('y', 'yes', 'д', 'да'))) {
                $shouldRestart = $true
            }
        }
    } elseif ($Force -or (-not $NoRestart)) {
        # TeamSpeak не запущен
        if ($tsExe -and (Test-Path -LiteralPath $tsExe)) {
            if ($Force) {
                $shouldRestart = $true
            } else {
                Write-Host "`n========================================" -ForegroundColor Green
                Write-Host "  Тема успешно установлена!" -ForegroundColor Green
                Write-Host "========================================" -ForegroundColor Green
                Write-Host -NoNewline ">>> Запустить TeamSpeak сейчас? [Y/n] (по умолчанию Y): " -ForegroundColor Cyan
                $answer = Read-Host
                if ([string]::IsNullOrWhiteSpace($answer) -or ($answer.Trim().ToLower() -in @('y', 'yes', 'д', 'да'))) {
                    $shouldRestart = $true
                }
            }
        } else {
            Write-Host "`n========================================" -ForegroundColor Green
            Write-Host "  Тема успешно установлена!" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "TeamSpeak сейчас не запущен. Тема активируется при следующем запуске." -ForegroundColor White
        }
    }

    if ($shouldRestart) {
        if ($isTsRunning) {
            Write-Host ">>> Отправка сигнала штатного выхода TeamSpeak (как через меню трея)..." -ForegroundColor Yellow
            
            $pids = [int[]]($sessionProcs | Select-Object -ExpandProperty Id)
            $sent = [TSGracefulCloser]::SendGracefulClose($pids)
            if ($sent -eq 0) {
                Write-Host ">>> Окно трея не обнаружено, пробуем штатное закрытие через Windows..." -ForegroundColor Gray
                foreach ($p in $sessionProcs) {
                    try { $p.CloseMainWindow() | Out-Null } catch {}
                }
            }

            # Ожидание чистого выхода из войса и завершения процесса до 8 секунд
            Write-Host ">>> Ожидание чистого отключения от сервера..." -ForegroundColor Gray
            $graceTimeout = [DateTime]::UtcNow.AddSeconds(8)
            while ((Get-Process -Name "TeamSpeak*" -ErrorAction SilentlyContinue | Where-Object { $_.SessionId -eq $currentSessionId }) -and ([DateTime]::UtcNow -lt $graceTimeout)) {
                Start-Sleep -Milliseconds 250
            }

            $remaining = Get-Process -Name "TeamSpeak*" -ErrorAction SilentlyContinue | Where-Object { $_.SessionId -eq $currentSessionId }
            if ($remaining) {
                # КРИТИЧЕСКИ ВАЖНО: Мы НЕ вызываем Stop-Process -Force!
                # Принудительное завершение обрывает сокет, и на сервере остаётся призрак-аккаунт.
                Write-Host "`n[!] Внимание: TeamSpeak не завершился автоматически (активно голосовое соединение или открыт диалог)." -ForegroundColor Yellow
                Write-Host "    Принудительное убийство процесса ОТМЕНЕНО во избежание зависания «призрака» в войсе!" -ForegroundColor Yellow
                Write-Host "    Пожалуйста, закройте TeamSpeak вручную через трей (ПКМ -> Выход) или примените тему через Настройки -> Внешний вид -> 🔄." -ForegroundColor Cyan
                return
            }

            # Небольшая пауза для освобождения сетевых портов и аудиоустройств
            Start-Sleep -Seconds 1
        }

        # Штатный запуск TeamSpeak
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
        }
    }
}
catch {
    Write-Host "`n[!] Ошибка: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    $ErrorActionPreference = $prevErrorAction
    $ProgressPreference = $prevProgress
    [Console]::OutputEncoding = $prevOutputEncoding
}
