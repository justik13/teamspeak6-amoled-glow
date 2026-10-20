# AMOLED Cyber Glow for TeamSpeak 6

A pure-black AMOLED & QD-OLED calibrated theme for TeamSpeak 6 with Dark Glass, translucent surfaces, and subtle neon glow accents.

Designed specifically for OLED / QD-OLED monitors to eliminate chromatic fringing, reduce eye strain, and deliver deep true blacks (`#000000`).

---

## ✨ Features

- **True AMOLED Black (`#000000`)** — True black base allows OLED pixels to turn completely off for infinite contrast and power efficiency.
- **QD-OLED Calibrated Typography** — Softened off-white font tones (`#e2e5eb`) prevent subpixel color fringing and harsh glare on triangular QD-OLED matrices.
- **Dark Glassmorphism** — Translucent cards, sidebars, and chat containers with frosted glass blur effects (`backdrop-filter: blur(...)`).
- **Cyber Glow Effects** — Delicate neon glow on active and hovered voice channels, buttons, toggles, and speaking indicators.
- **Glass Buttons** — Subtle glass pill buttons with glowing outlines instead of harsh solid blocks.
- **Clean Server Tree** — Fixed channel hover bug where default TeamSpeak blue background was bleeding through.
- **Two Curated Variants**:
  - 🩷 **AMOLED Pink** — Neon pink cyber glow accent with glassmorphism.
  - 🖤 **AMOLED Dark** — Pure titanium / white monochrome glow.

---

## 🤖 1-Prompt AI Agent Install (Установка через ИИ в один промпт)

Скопируйте и отправьте этот промпт вашему ИИ-ассистенту (Cursor, Antigravity, Claude, ChatGPT, Windsurf):

```text
Установи тему TeamSpeak 6: склонируй https://github.com/justik13/teamspeak6-amoled-glow в "$env:APPDATA\TeamSpeak\Default\extensions\amoled.dark.minimalistic" и сразу удали внутри папку .git (из-за лимита TeamSpeak 6 на размер файлов в 2 МБ).
```

### Или PowerShell-команда в одну строку / 1-line PowerShell command:

```powershell
powershell -Command "$p = \"$env:APPDATA\TeamSpeak\Default\extensions\amoled.dark.minimalistic\"; git clone --depth 1 https://github.com/justik13/teamspeak6-amoled-glow.git $p; Remove-Item \"$p\.git\" -Recurse -Force"
```

---

## 🚀 Manual Installation (Ручная установка)

### Option 1: Download ZIP (Рекомендуется)
1. Скачайте архив репозитория:
   - Нажмите зелёную кнопку **Code** вверху страницы → **Download ZIP**.
2. Распакуйте архив.
3. Переименуйте распакованную папку строго в:
   ```
   amoled.dark.minimalistic
   ```
4. Переместите эту папку в директорию расширений TeamSpeak:
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
> В движок TeamSpeak 6 встроен строгий лимит **2 МБ на размер любого файла** внутри папки расширения. Внутренние файлы `.git/` превышают этот лимит, и TeamSpeak 6 отклонит тему с ошибкой `Invalid extension`. При клонировании через git обязательно удаляйте папку `.git`.

5. Откройте **TeamSpeak 6** → **Настройки** (⚙️) → **Внешний вид** (*Appearance*).
6. Включите **Пользовательская тема** (*User Theme*) и нажмите **Обновить** (🔄).
7. Выберите плитку **AMOLED Cyber Glow** и включите **AMOLED Pink** или **AMOLED Dark**.

---

## 📁 File Structure

```
amoled.dark.minimalistic/
├── package.json          # Theme metadata and manifest
├── TeamSpeak.css         # Core CSS overrides & glow variables
├── Glassmorphism.css     # Translucent glass & blur effects
├── Pink.css              # AMOLED Pink variant
├── Pink.png              # Pink preview thumbnail
├── Reaper.css            # AMOLED Dark (Monochrome / Titanium) variant
├── Reaper.png            # Dark preview thumbnail
├── Thumbnail.png         # Main extension icon
└── README.md
```

---

## 📄 License

MIT License.
