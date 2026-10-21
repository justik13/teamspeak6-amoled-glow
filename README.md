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

## Быстрая установка и обновление (Windows)

Скрипт скачивает архив с GitHub, валидирует файлы и безопасно обновляет тему на диске с поддержкой резервной копии и отката при ошибке. Если TeamSpeak запущен, скрипт предложит перезапустить клиент (`[y/N]`, по умолчанию **нет**), гарантируя, что ваши игры и оверлеи не будут прерваны.

Откройте окно **PowerShell** и выполните команду:

```powershell
& ([scriptblock]::Create(((irm https://raw.githubusercontent.com/justik13/teamspeak6-amoled-glow/main/update.ps1).TrimStart([char]65279))))
```

Для запуска через окно **«Выполнить»** (<kbd>Win</kbd> + <kbd>R</kbd>):
```text
powershell -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create(((irm https://raw.githubusercontent.com/justik13/teamspeak6-amoled-glow/main/update.ps1).TrimStart([char]65279))))"
```

Для тихого обновления во время игры без всплывающих диалогов и без перезапуска:
```powershell
& ([scriptblock]::Create(((irm https://raw.githubusercontent.com/justik13/teamspeak6-amoled-glow/main/update.ps1).TrimStart([char]65279)))) -NoRestart
```

> [!TIP]
> Если вы скачали или клонировали репозиторий, можно просто дважды кликнуть по файлу `update.bat`.
> Чтобы сразу применить тему в работающем TeamSpeak без перезапуска: **Настройки** (шестерёнка) → **Внешний вид** → нажмите круглую стрелочку **«Обновить темы»**.

## Установка через ИИ-агента

Скопируйте промпт для Cursor, Claude, Antigravity или ChatGPT:

```text
Установи тему TeamSpeak 6: скачай zip-архив https://github.com/justik13/teamspeak6-amoled-glow/archive/refs/heads/main.zip, распакуй содержимое в "$env:APPDATA\TeamSpeak\Default\extensions\amoled.dark.minimalistic" (папка .git не должна присутствовать из-за лимита TeamSpeak 6 в 2 МБ).
```

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
teamspeak6-amoled-glow/
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
├── update.ps1            # Скрипт безопасной авто-установки и обновления (PowerShell)
├── update.bat            # 1-клик лаунчер обновления для Windows
└── README.md
```

## Лицензия и благодарности

Тема распространяется под лицензией MIT.

Основана на проекте [AMOLED Dark Minimalistic](https://github.com/c4g7-dev/amoled-dark-minimalistic) от Anthony Dac (Valhalla). Доработана и расширена неоновой подсветкой, кольцами голоса, адаптивными контролями трансляции и поддержкой пяти цветовых вариантов.
