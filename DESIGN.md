---
version: alpha
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
      accent-light: "#4a5568"
      accent-dark: "#2d3748"
      accent-rgb: "74, 85, 104"
    cyan:
      accent-light: "#00e5ff"
      accent-dark: "#0099b8"
      accent-rgb: "0, 229, 255"
    purple:
      accent-light: "#a855f7"
      accent-dark: "#7e22ce"
      accent-rgb: "168, 85, 247"
    amber:
      accent-light: "#ffaa00"
      accent-dark: "#cc7700"
      accent-rgb: "255, 170, 0"

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
The theme provides 5 standalone accent palettes:
- **AMOLED Pink**: Primary `#f43f8e`, Dark `#be185d`, RGB `244, 63, 142`.
- **AMOLED Dark (Reaper)**: Stealth tactical accent `#4a5568`, Dark `#2d3748`, RGB `74, 85, 104`.
- **AMOLED Cyan**: Cyber electric `#00e5ff`, Dark `#0099b8`, RGB `0, 229, 255`.
- **AMOLED Purple**: Neon violet `#a855f7`, Dark `#7e22ce`, RGB `168, 85, 247`.
- **AMOLED Amber**: Warm cyber amber `#ffaa00`, Dark `#cc7700`, RGB `255, 170, 0`.

---

## 3. Typography & Contrast

- **Font Stack**: `-apple-system, BlinkMacSystemFont, "Segoe UI Variable Display", "Segoe UI", "Inter", Roboto, Helvetica, Arial, sans-serif`.
- **Code / Monospace**: `"JetBrains Mono", "Cascadia Code", "Fira Code", Consolas, monospace`.
- **Primary Ink**: `#e2e5eb` (Contrast ratio against `#000000`: **16.3:1**, exceeding WCAG AAA).
- **Secondary Ink**: `#9499a6` (Contrast ratio against `#000000`: **7.2:1**, meeting WCAG AAA).
- **Subtle / Muted Ink**: `#6b7280` (Contrast ratio against `#000000`: **4.8:1**, meeting WCAG AA).

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
