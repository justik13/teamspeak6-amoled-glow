# AMOLED Cyber Glow для TeamSpeak 6

Чисто чёрная тема для TeamSpeak 6 с калибровкой под **AMOLED и QD-OLED** дисплеи, матовым тёмным стеклом (*Dark Glassmorphism*) и деликатным неоновым свечением (*Cyber Glow*).

Специально оптимизирована для экранов QD-OLED: устраняет цветную кайму вокруг букв (субпиксельный fringing), снижает нагрузку на глаза и сохраняет истинный глубокий чёрный цвет (`#000000`), отключая пиксели панели.

---

## ✨ Особенности

- **Истинный чёрный AMOLED (`#000000`)** — основной фон полностью отключает пиксели OLED для бесконечного контраста и энергоэффективности.
- **Калиброванная типографика под QD-OLED** — смягчённые оттенки шрифтов (`#e2e5eb`) полностью убирают зелёно-розовые ореолы и слепящие блики на треугольной структуре субпикселей QD-OLED.
- **Тёмное матовое стекло (*Glassmorphism*)** — полупрозрачные карточки, сайдбар и блоки чата с эффектом глубокого матового размытия (`backdrop-filter: blur(...)`).
- **Неоновое свечение (*Cyber Glow*)** — аккуратный неоновый контур активных и наведённых войс-каналов, кнопок, тумблеров и индикатора говорящего в войсе.
- **Стеклянные кнопки** — стильные полупрозрачные капсулы со светящейся каймой вместо сплошных заливок.
- **Исправлено дерево серверов** — устранён баг оригинальной темы, из-за которого при наведении на войс-канал просвечивал старый синий фон.
- **Два отобранных варианта**:
  - 🩷 **AMOLED Pink** — неоновый розовый акцент со стеклом.
  - 🖤 **AMOLED Dark** — благородный монохромный титановый / белый акцент.

---

## 🤖 Установка в один клик / через ИИ (без Git)

Работает на любом компьютере с Windows — **Git устанавливать не нужно**:

### Команда для PowerShell в одну строку (вставьте и нажмите Enter):

```powershell
$dest = "$env:APPDATA\TeamSpeak\Default\extensions\amoled.dark.minimalistic"; $zip = "$env:TEMP\ts6_theme.zip"; $temp = "$env:TEMP\ts6_temp"; Invoke-WebRequest -Uri "https://github.com/justik13/teamspeak6-amoled-glow/archive/refs/heads/main.zip" -OutFile $zip; Expand-Archive -Path $zip -DestinationPath $temp -Force; New-Item -ItemType Directory -Path "$env:APPDATA\TeamSpeak\Default\extensions" -Force | Out-Null; if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }; Move-Item "$temp\teamspeak6-amoled-glow-main" $dest; Remove-Item $zip, $temp -Recurse -Force -ErrorAction SilentlyContinue
```

### Промпт для любого ИИ-агента (Cursor, Claude, Antigravity, ChatGPT):

```text
Установи тему TeamSpeak 6: скачай zip-архив https://github.com/justik13/teamspeak6-amoled-glow/archive/refs/heads/main.zip, распакуй содержимое в "$env:APPDATA\TeamSpeak\Default\extensions\amoled.dark.minimalistic" (папка .git не должна присутствовать из-за лимита TeamSpeak 6 в 2 МБ).
```

---

## 🚀 Ручная установка

### Вариант 1: Скачать ZIP-архив (Рекомендуется)
1. Скачайте архив репозитория:
   - Нажмите зелёную кнопку **Code** вверху страницы → **Download ZIP**.
2. Распакуйте скачанный архив.
3. Переименуйте распакованную папку в:
   ```
   amoled.dark.minimalistic
   ```
4. Переместите эту папку в каталог расширений TeamSpeak:
   - **Windows**:
     ```
     %APPDATA%\TeamSpeak\Default\extensions\
     ```
     *(Полный путь: `C:\Users\<ВашПользователь>\AppData\Roaming\TeamSpeak\Default\extensions\amoled.dark.minimalistic`)*
   - **Linux**:
     ```
     ~/.config/TeamSpeak/Default/extensions/amoled.dark.minimalistic
     ```
   - **macOS**:
     ```
     ~/Library/Application Support/TeamSpeak/Default/extensions/amoled.dark.minimalistic
     ```

> [!IMPORTANT]
> **Не клонируйте через `git clone` напрямую в папку `extensions`!**  
> В движке TeamSpeak 6 действует жёсткое ограничение: **любой файл размером более 2 МБ блокирует всё расширение**. Служебные файлы `.git/` превышают этот размер, и клиент откажется загружать тему с ошибкой `Invalid extension`. При клонировании через git всегда удаляйте скрытую папку `.git`.

5. Откройте **TeamSpeak 6** → **Настройки** (значок шестерёнки) → **Внешний вид**.
6. Включите тумблер **Пользовательская тема** и нажмите кнопку **Обновить** (круговая стрелка).
7. Выберите карточку **AMOLED Cyber Glow** и переключитесь на **AMOLED Pink** или **AMOLED Dark**.

---

## 📁 Структура файлов

```
amoled.dark.minimalistic/
├── package.json          # Манифест и метаданные темы для TeamSpeak 6
├── TeamSpeak.css         # Основные CSS-стили, переменные и эффекты свечения
├── Glassmorphism.css     # Стили матового стекла и прозрачности
├── Pink.css              # Вариант AMOLED Pink
├── Pink.png              # Превью розового варианта
├── Reaper.css            # Вариант AMOLED Dark (титановый монохром)
├── Reaper.png            # Превью тёмного варианта
├── Thumbnail.png         # Главная иконка расширения в настройках
└── README.md
```

---

## 📄 Лицензия

MIT License.
