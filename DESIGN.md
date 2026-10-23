---
version: 1.6.1
name: AMOLED-Cyber-Glow-TeamSpeak6
description: "A pure-black AMOLED & QD-OLED calibrated theme for TeamSpeak 6 with Dark Glass, Voice Activity Glow Rings, and tactile Emil Kowalski spring physics. Designed for zero optical fringing, 16:1 text contrast, and battery/panel longevity."

colors:
  canvas: "#000000"
  canvas-subtle: "#050608"
  surface-1: "#0a0b10"
  surface-2: "#0f1118"
  surface-card: "#151822"
  surface-elevated: "#1b1f2c"
  surface-glass: "rgba(9, 11, 16, 0.72)"
  surface-glass-modal: "rgba(13, 16, 22, 0.85)"
  hairline: "rgba(255, 255, 255, 0.08)"
  hairline-strong: "rgba(255, 255, 255, 0.14)"
  hairline-bevel: "inset 0 1px 0 0 rgba(255, 255, 255, 0.12)"
  ink: "#e2e5eb"
  ink-secondary: "#9499a6"
  ink-tertiary: "#6b7280"
  status-online: "#10b981"
  status-away: "#f59e0b"
  status-error: "#f43f5e"
  status-accept: "#10b981"
  variants:
    pink:
      accent-light: "#f43f8e"
      accent-dark: "#be185d"
      accent-rgb: "244, 63, 142"
    reaper:
      accent-light: "#9061f9"
      accent-dark: "#6d28d9"
      accent-rgb: "144, 97, 249"
    cyan:
      accent-light: "#06b6d4"
      accent-dark: "#0891b2"
      accent-rgb: "6, 182, 212"
    purple:
      accent-light: "#a855f7"
      accent-dark: "#7e22ce"
      accent-rgb: "168, 85, 247"
    amber:
      accent-light: "#f97316"
      accent-dark: "#c2410c"
      accent-rgb: "249, 115, 22"
    emerald:
      accent-light: "#10b981"
      accent-dark: "#059669"
      accent-rgb: "16, 185, 129"
    ruby:
      accent-light: "#f43f5e"
      accent-dark: "#be123c"
      accent-rgb: "244, 63, 94"
    silver:
      accent-light: "#e2e8f0"
      accent-dark: "#94a3b8"
      accent-rgb: "226, 232, 240"
    abyss:
      accent-light: "#0ea5e9"
      accent-dark: "#0284c7"
      accent-rgb: "14, 165, 233"
    slate:
      accent-light: "#38bdf8"
      accent-dark: "#0284c7"
      accent-rgb: "56, 189, 248"
      canvas: "#0d1117"
    graphite:
      accent-light: "#38bdf8"
      accent-dark: "#0284c7"
      accent-rgb: "56, 189, 248"
      canvas: "#18191c"
    catppuccin:
      accent-light: "#cba6f7"
      accent-dark: "#8839ef"
      accent-rgb: "203, 166, 247"
      canvas: "#11111b"

typography:
  font-family: '-apple-system, BlinkMacSystemFont, "Segoe UI Variable Display", "Segoe UI", "Inter", Roboto, Helvetica, Arial, sans-serif'
  font-family-mono: '"JetBrains Mono", "Cascadia Code", "Fira Code", Consolas, monospace'
  smoothing: 'antialiased'

motion:
  spring: 'cubic-bezier(0.16, 1, 0.3, 1)'
  micro-interaction-hover: '120ms'
  micro-interaction-press: '80ms'
  voice-ring-pulse: '1.35s infinite ease-in-out'
  reduced-motion: 'prefers-reduced-motion: reduce (zeroes transitions and animations)'
  reduced-transparency: 'prefers-reduced-transparency: reduce (disables backdrop-filter to solid #090b10)'

components:
  voice-rings:
    talking: 'box-shadow: 0 0 0 2px var(--custom-color-accent-light), 0 0 14px var(--accent-glow)'
  buttons:
    bevel: 'inset 0 1px 0 0 rgba(255, 255, 255, 0.12)'
    border: '1px solid rgba(255, 255, 255, 0.08)'
    active: 'transform: scale(0.98)'
  sliders:
    rail: 'rgba(255, 255, 255, 0.16)'
    fill: 'var(--custom-color-accent-light) with box-shadow: 0 0 10px var(--accent-glow)'
---

# AMOLED Cyber Glow — Design System Specification

A design specification document conforming to the [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md) and [ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) standards.

---

## 1. Overview & Aesthetic Philosophy

**AMOLED Cyber Glow** combines three distinct design traditions:
1. **True OLED Physics (Style 7)**: `#000000` true pitch black canvas allowing display self-emissive pixels to power down, delivering infinite contrast ratio and zero backlight leakage.
2. **Apple Dark Glass Materials (Style 3 & 14)**: Multilayered `backdrop-filter: blur(12px)` frosted glass surfaces with 1px top bevel highlight reflections (`inset 0 1px 0 0 rgba(255, 255, 255, 0.12)`).
3. **Tactile Spring Physics (Emil Kowalski)**: Micro-interactions tuned to `120ms` with `cubic-bezier(0.16, 1, 0.3, 1)`, providing responsive feedback without sluggishness.

---

## 2. Color Palette & Surface Ladder

### Surface Ladder (Elevation Hierarchy)
- **Canvas (Deep Background)**: `#000000` (True OLED pitch black).
- **Surface 1 (Sidebar / Server Tree)**: `#050608` (Near black, 1% lift).
- **Surface 2 (Chat Canvas / Main Panels)**: `#0a0b10` (Low-emission dark).
- **Surface 3 (Input Fields / Cards)**: `#0f1118` (Translucent container).
- **Surface Elevated (Floating Modals / Context Menus)**: `rgba(13, 16, 22, 0.85)` with `-webkit-backdrop-filter: blur(14px)`.

### Chromatic Variants
The theme provides 12 calibrated standalone accent palettes matching `package.json`:
- **AMOLED Pink**: Primary `#f43f8e`, Dark `#be185d`, RGB `244, 63, 142`.
- **AMOLED Dark (Reaper)**: Cyber electric violet `#9061f9`, Dark `#6d28d9`, RGB `144, 97, 249` (WCAG AA compliant 5.26:1 text contrast).
- **AMOLED Cyan**: Cyber electric teal `#06b6d4`, Dark `#0891b2`, RGB `6, 182, 212`.
- **AMOLED Purple**: Neon violet `#a855f7`, Dark `#7e22ce`, RGB `168, 85, 247`.
- **AMOLED Amber**: Warm cyber amber `#f97316`, Dark `#c2410c`, RGB `249, 115, 22`.
- **AMOLED Emerald**: Matrix emerald green `#10b981`, Dark `#059669`, RGB `16, 185, 129`.
- **AMOLED Ruby**: Crimson ruby `#f43f5e`, Dark `#be123c`, RGB `244, 63, 94`.
- **AMOLED Silver (Platinum)**: Crisp metallic silver `#e2e8f0`, Dark `#94a3b8`, RGB `226, 232, 240`.
- **AMOLED Abyss (Deep Teal)**: Deep ocean cerulean `#0ea5e9`, Dark `#0284c7`, RGB `14, 165, 233`.
- **Midnight Slate (IPS Edition)**: Deep slate canvas `#0d1117`, surface `#161b22`, calibrated to mask IPS backlight bleed and IPS glow, with electric sky blue accent `#38bdf8` (RGB `56, 189, 248`).
- **Cyber Graphite**: Neutral charcoal gray canvas `#18191c`, surface `#202225`, sky blue accent `#38bdf8` (RGB `56, 189, 248`).
- **Catppuccin Mocha**: Authentic pastel dark palette with Crust (`#11111b`), Mantle (`#181825`), Base (`#1e1e2e`), lavender accent `#cba6f7` (RGB `203, 166, 247`).

---

## 3. Typography & Contrast

- **Font Stack**: `-apple-system, BlinkMacSystemFont, "Segoe UI Variable Display", "Segoe UI", "Inter", Roboto, Helvetica, Arial, sans-serif`.
- **Code / Monospace**: `"JetBrains Mono", "Cascadia Code", "Fira Code", Consolas, monospace`.
- **Primary Ink**: `#f1f3f7` / `#e2e5eb` (Contrast ratio against `#000000`: **18.9:1**, exceeding WCAG AAA).
- **Secondary Ink**: `#a3abb8` / `#9499a6` (Contrast ratio against `#000000`: **9.1:1**, meeting WCAG AAA).
- **Subtle / Muted Ink**: `#94a3b8` / `#6b7280` (Contrast ratio against `#0a0c11`: **7.6:1**, meeting WCAG AAA).

---

## 4. Components

### Voice Activity Ring
Active speaker indicator uses a 2px outer ring and soft radial aura:
```css
box-shadow: 0 0 0 2px var(--custom-color-accent-light), 0 0 14px var(--accent-glow) !important;
animation: ts-voice-glow 1.35s infinite ease-in-out !important;
```

### Sliders & Volume Controls
- **Track Rail**: `rgba(255, 255, 255, 0.16)` with 4px border radius.
- **Active Progress Fill**: Neon accent `var(--custom-color-accent-light)` with `box-shadow: 0 0 10px var(--accent-glow)`.
- **Thumb Knob**: High-contrast illuminated indicator with drag tooltip bubble.
- **Stream Overlay Volume**: Fixed width un-collapsed container (`min-width: 130px`) for zero accidental collapse.

### Buttons
- **Hero & Primary**: Subtle gradient `linear-gradient(135deg, rgba(var(--accent-rgb), 0.22), rgba(var(--accent-rgb), 0.08))`, 1px border `rgba(var(--accent-rgb), 0.45)`, Apple top bevel `inset 0 1px 0 0 rgba(255, 255, 255, 0.12)`.
- **Secondary**: Soft frosted glass `rgba(255, 255, 255, 0.06)`, border `rgba(255, 255, 255, 0.09)`.
- **Active / Pressed**: `transform: scale(0.98)` tactile press feel.

---

## 5. Accessibility (WCAG 2.2 AA/AAA)

1. **Reduced Motion**: Under `@media (prefers-reduced-motion: reduce)`, all pulse animations, voice glow rings, and transforms are zeroed out (`animation: none; transform: none; transition-duration: 0.01ms`).
2. **Reduced Transparency**: Under `@media (prefers-reduced-transparency: reduce)`, backdrop filters are disabled in favor of solid high-contrast dark panels (`#090b10`).
3. **Keyboard Focus Visible**: Explicit `:focus-visible` ring (`outline: 2px solid var(--custom-color-accent-light); outline-offset: 2px; box-shadow: 0 0 8px var(--accent-glow-soft)`).
4. **Dark Engine**: `color-scheme: dark !important` enforced across the entire Chromium engine.
