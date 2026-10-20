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

## 🚀 Installation (TeamSpeak 6)

### Option 1: Download ZIP (Recommended)
1. Download this repository as a `.zip` archive:
   - Click the green **Code** button above → **Download ZIP**.
2. Extract the archive.
3. Rename the extracted folder to:
   ```
   amoled.dark.minimalistic
   ```
4. Move this folder into your TeamSpeak extensions directory:
   - **Windows**:
     ```
     %APPDATA%\TeamSpeak\Default\extensions\
     ```
     *(Full path: `C:\Users\<YourUser>\AppData\Roaming\TeamSpeak\Default\extensions\amoled.dark.minimalistic`)*
   - **Linux**:
     ```
     ~/.config/TeamSpeak/Default/extensions/amoled.dark.minimalistic
     ```
   - **macOS**:
     ```
     ~/Library/Application Support/TeamSpeak/Default/extensions/amoled.dark.minimalistic
     ```

> [!IMPORTANT]
> **Do not use `git clone` directly into the `extensions` directory!**
> TeamSpeak 6 enforces a strict **2 MB file limit** on all files in extension folders. Git's internal `.git/` pack files exceed 2 MB, which will cause TeamSpeak 6 to reject the extension (`Invalid extension`). If cloning via git, clone elsewhere and copy the files without the `.git` folder.

5. Open **TeamSpeak 6** → **Settings** (⚙️) → **Appearance** (*Внешний вид*).
6. Enable **User Theme** (*Пользовательская тема*) and click the **Refresh** (🔄) button.
7. Click on the **AMOLED Cyber Glow** tile and select **AMOLED Pink** or **AMOLED Dark**.

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
