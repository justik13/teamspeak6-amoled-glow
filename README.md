# AMOLED Cyber Glow для TeamSpeak 6

Тёмная тема для TeamSpeak 6 с калибровкой под AMOLED и QD-OLED дисплеи, полупрозрачными панелями, анимированными кольцами голоса и неоновым контуром элементов.

Шрифты настроены на оттенок `#e2e5eb`: это смягчает контрастный ореол субпикселей (fringing) на треугольной структуре субпикселей QD-OLED по сравнению с резким белым `#ffffff`. Основной фон задан как `#000000`, поэтому пиксели OLED-панели в этих зонах отключаются.

## Особенности

- Фон `#000000` для отключения пикселей на OLED-панелях.
- Смягчённая типографика (`#e2e5eb`) снижает зрительное напряжение и ореол на QD-OLED.
- Анимированные кольца войса (Voice Rings): пульсирующий изумрудный ореол вокруг аватара при разговоре.
- Аура статусов: рубиновое свечение замученного микрофона и янтарная подсветка статуса «Отошёл».
- Стилизация Markdown и блоков кода в чате под тёмный терминал с акцентной рамкой и размытием.
- Тонкие полупрозрачные скроллбары с неоновой подсветкой бегунка при наведении.
- Размытие фона (`backdrop-filter: blur(...)`) на карточках, в боковой панели, блоках чата и модальных окнах.
- Пружинная анимация всплывающих контекстных меню и подсказок.
- Неоновый контур активных и наведённых каналов, кнопок и переключателей.
- Полупрозрачные кнопки с контурной подсветкой вместо сплошной заливки.
- Исправлено дерево серверов: синий фон оригинальной темы при наведении на канал больше не просвечивает.
- Пять вариантов оформления:
  - AMOLED Dark: титановый серый акцент.
  - AMOLED Pink: неоновый розовый акцент.
  - AMOLED Cyan: неоновый лёд / циан.
  - AMOLED Purple: электрический фиолетовый.
  - AMOLED Amber: тёплый янтарно-оранжевый.

## Установка через PowerShell

Работает в Windows без установки Git. Откройте PowerShell, вставьте команду и нажмите Enter:

```powershell
$dest = "$env:APPDATA\TeamSpeak\Default\extensions\amoled.dark.minimalistic"; $tDir = Join-Path $env:TEMP ([Guid]::NewGuid().ToString()); New-Item -ItemType Directory -Path $tDir -Force | Out-Null; $zip = Join-Path $tDir "theme.zip"; Invoke-WebRequest -Uri "https://github.com/justik13/teamspeak6-amoled-glow/archive/refs/heads/main.zip" -OutFile $zip; Expand-Archive -Path $zip -DestinationPath $tDir -Force; $src = Get-ChildItem -Path $tDir -Directory | Where-Object { $_.Name -like "teamspeak6-amoled-glow*" } | Select-Object -First 1; if ($src -and (Test-Path (Join-Path $src.FullName "package.json"))) { New-Item -ItemType Directory -Path "$env:APPDATA\TeamSpeak\Default\extensions" -Force | Out-Null; if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }; Move-Item $src.FullName $dest; Write-Host "Тема успешно установлена!" -ForegroundColor Green } else { Write-Error "Ошибка распаковки архива темы" }; Remove-Item $tDir -Recurse -Force -ErrorAction SilentlyContinue
```

## Установка через ИИ-агента

Скопируйте промпт для Cursor, Claude, Antigravity или ChatGPT:

```text
Установи тему TeamSpeak 6: скачай zip-архив https://github.com/justik13/teamspeak6-amoled-glow/archive/refs/heads/main.zip, распакуй содержимое в "$env:APPDATA\TeamSpeak\Default\extensions\amoled.dark.minimalistic" (папка .git не должна присутствовать из-за лимита TeamSpeak 6 в 2 МБ).
```

## Обновление

1. Запустите ту же команду PowerShell. Скрипт безопасно скачает свежую версию во временный каталог, проверит целостность и обновит файлы темы.
2. В TeamSpeak 6 откройте **Настройки** → **Внешний вид** и нажмите кнопку со стрелкой по кругу (Обновить).
3. При ручной установке скачайте новый ZIP и распакуйте с заменой файлов.

## Ручная установка

1. Нажмите зелёную кнопку **Code** вверху страницы и выберите **Download ZIP**.
2. Распакуйте архив и переименуйте полученную папку в `amoled.dark.minimalistic`.
3. Переместите папку в каталог расширений TeamSpeak:
   - Windows: `%APPDATA%\TeamSpeak\Default\extensions\`  
     (полный путь: `C:\Users\<Имя_Пользователя>\AppData\Roaming\TeamSpeak\Default\extensions\amoled.dark.minimalistic`)
   - Linux: `~/.local/share/TeamSpeak/Default/extensions/amoled.dark.minimalistic`  
     (или `~/.config/TeamSpeak/Default/extensions/` на устаревших сборках)
   - macOS: `~/Library/Application Support/TeamSpeak/Default/extensions/amoled.dark.minimalistic`

> [!IMPORTANT]
> Не клонируйте репозиторий через `git clone` прямо в папку `extensions`. TeamSpeak 6 отклоняет расширения, если внутри есть файлы крупнее 2 МБ. Служебные файлы `.git/` превышают этот лимит, и клиент выдаёт ошибку `Invalid extension`.

4. Откройте **TeamSpeak 6** → **Настройки** → **Внешний вид**.
5. Включите пункт **Пользовательская тема**, нажмите кнопку обновления со стрелкой по кругу и выберите любой из пяти вариантов.

## Структура файлов

```
amoled.dark.minimalistic/
├── package.json          # Манифест и метаданные темы для TeamSpeak 6
├── TeamSpeak.css         # Стили интерфейса, переменные и эффекты подсветки
├── Glassmorphism.css     # Размытие и прозрачность панелей
├── Pink.css              # Вариант AMOLED Pink
├── Pink.png              # Превью розового варианта
├── Reaper.css            # Вариант AMOLED Dark
├── Reaper.png            # Превью тёмного варианта
├── Cyan.css              # Вариант AMOLED Cyan
├── Cyan.png              # Превью цианового варианта
├── Purple.css            # Вариант AMOLED Purple
├── Purple.png            # Превью фиолетового варианта
├── Amber.css             # Вариант AMOLED Amber
├── Amber.png             # Превью янтарного варианта
├── Thumbnail.png         # Иконка расширения в настройках
└── README.md
```

## Лицензия и благодарности

Тема распространяется под лицензией MIT.

Основана на проекте [AMOLED Dark Minimalistic](https://github.com/c4g7-dev/amoled-dark-minimalistic) от Anthony Dac (Valhalla). Доработана и расширена неоновой подсветкой, кольцами голоса, адаптивными контролями трансляции и поддержкой пяти цветовых вариантов.
