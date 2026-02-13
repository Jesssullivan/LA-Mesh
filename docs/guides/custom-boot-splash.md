# Custom Boot Splash Screen

**Status**: Implemented (CI builds via GitHub Actions)
**Applies to**: All ESP32-based devices (Station G2, T-Deck)

---

## Overview

Meshtastic firmware supports custom boot splash screens via the **OEM
customization mechanism** in `userPrefs.jsonc`. The boot logo is compiled into
the firmware binary at build time — there is no runtime-loadable splash screen.

This guide documents how to build LA-Mesh branded firmware with a custom boot
logo (e.g., a Maine state silhouette) and "LA-Mesh" boot text.

---

## How the Boot Logo Works

### Default Boot Sequence

1. Device powers on, shows the default Meshtastic "M" logo for 5 seconds
2. Logo is a **50x28 pixel XBM** (monochrome bitmap) in `src/graphics/img/icon.xbm`
3. Text "meshtastic.org" renders below the icon
4. After timeout, transitions to the normal UI

### OEM Boot Sequence (with custom splash)

1. Device shows the default Meshtastic logo for 5 seconds
2. Then shows the **OEM custom logo** for another 5 seconds (10s total)
3. OEM logo uses `USERPREFS_OEM_IMAGE_DATA` (compiled-in XBM hex array)
4. OEM text uses `USERPREFS_OEM_TEXT` (e.g., "LA-Mesh")

### Key Source Files

| File | Purpose |
|------|---------|
| `src/graphics/img/icon.xbm` | Default boot logo (50x28, guarded by `#ifndef USERPREFS_HAS_SPLASH`) |
| `src/graphics/images.h` | Includes the appropriate icon.xbm |
| `src/graphics/draw/UIRenderer.cpp` | `drawIconScreen()` (default) and `drawOEMIconScreen()` (OEM) |
| `src/graphics/Screen.cpp` | Boot sequence logic, timeouts |
| `userPrefs.jsonc` | OEM customization settings (converted to `-D` flags by build system) |
| `bin/platformio-custom.py` | Converts `userPrefs.jsonc` into C preprocessor defines |

---

## Display Specifications

| Device | Display | Resolution | Type |
|--------|---------|------------|------|
| Station G2 | 1.3" SH1107 OLED | 128x64 | Monochrome |
| T-Deck | 2.8" ST7789 TFT | 320x240 | Color (logo still monochrome XBM) |

The same XBM logo works on both displays — the rendering code centers it
based on screen dimensions.

---

## Recommended Approach: `userPrefs.jsonc` OEM Mechanism

This is the same approach used by **DEF CON 33** and **38C3 (Chaos
Communication Congress)** for their event-branded firmware. It only modifies
one file and has zero merge conflicts with upstream.

### Step 1: Create the Logo Image

Design a **monochrome** (black and white only) image:
- **Recommended size**: 50x28 (matches default) or up to 68x58 (DEF CON 33 size)
- For Station G2's 128x64 OLED, keep under ~100x50 to leave room for text
- Maine state silhouette with "LA-Mesh" text works well

### Step 2: Convert to XBM Hex Array

**Option A: Online converter** (easiest)
- https://windows87.github.io/xbm-viewer-converter/
- Upload image, copy the hex array

**Option B: ImageMagick CLI**
```bash
convert maine-logo.png -resize 50x28! -monochrome -negate output.xbm
```

Note: `-negate` may be needed because XBM treats 1=foreground, 0=background.

### Step 3: Configure `userPrefs.jsonc`

In the Meshtastic firmware repository root:

```jsonc
{
    // LA-Mesh Custom Boot Splash
    "USERPREFS_OEM_TEXT": "LA-Mesh",
    "USERPREFS_OEM_FONT_SIZE": "1",
    "USERPREFS_OEM_IMAGE_WIDTH": "50",
    "USERPREFS_OEM_IMAGE_HEIGHT": "28",
    "USERPREFS_OEM_IMAGE_DATA": "{ 0x00, 0x00, ... YOUR HEX DATA ... }",

    // Optional: bake in LA-Mesh defaults
    "USERPREFS_CONFIG_LORA_REGION": "US",
    "USERPREFS_OWNER_LONG_NAME": "LA-Mesh",
    "USERPREFS_OWNER_SHORT_NAME": "LAM"
}
```

### Step 4: Build Firmware

```bash
git clone https://github.com/meshtastic/firmware.git
cd firmware
git submodule update --init
git checkout v2.7.15.567b8ea

# Edit userPrefs.jsonc (step 3)

# Build for Station G2
pio run -e station-g2

# Build for T-Deck
pio run -e t-deck
```

### Step 5: Flash

Use the existing LA-Mesh provisioning pipeline — just point it at the
custom-built binary instead of the upstream release.

---

## CI/CD: GitHub Actions Auto-Build

The `.github/workflows/build-firmware.yml` workflow builds custom firmware
for all three device targets automatically.

### How it works

1. Workflow triggers on push to `main` (when `userPrefs.jsonc` or `manifest.json`
   changes) or via manual dispatch
2. Reads the pinned Meshtastic version from `firmware/manifest.json`
3. Clones `meshtastic/firmware` at that version tag
4. Copies our `firmware/meshtastic/userPrefs.jsonc` into the firmware repo root
5. Builds for each device in parallel using `meshtastic/gh-action-firmware` (official Docker action)
6. Creates a GitHub Release (`la-mesh-v{version}`) with binaries + `SHA256SUMS.txt`
7. Auto-updates `firmware/manifest.json` and `README.md` with checksums and download links

### Build targets

| Device | PlatformIO Environment |
|--------|----------------------|
| Station G2 | `station-g2` |
| T-Deck Plus | `t-deck` |
| T-Deck Pro (E-Ink) | `t-deck-pro` |

### Trigger a build manually

Go to **Actions > Build Custom Firmware > Run workflow** in the GitHub UI.
Optionally override the Meshtastic version.

### Local builds

```bash
# Requires PlatformIO CLI
just build-firmware station-g2
just build-firmware t-deck
just build-firmware t-deck-pro
```

### Fetch pre-built custom firmware

```bash
# Download LA-Mesh builds (default: auto-detects custom vs upstream)
just fetch-firmware --source custom

# Verify
cd firmware/.cache && sha256sum -c SHA256SUMS.txt
```

---

## What Does NOT Work

- **LittleFS**: Boot logo cannot be loaded from filesystem at runtime
- **Web Flasher**: Overwrites custom firmware with stock images
- **Runtime API**: No Protobuf/BLE/serial command to change boot logo
- **Per-variant icon**: Cannot add per-device `icon.xbm` in variant directories

---

## XBM Format Reference

- **XBM (X BitMap)**: Monochrome 1-bit-per-pixel image format
- Data is a C `unsigned char` array; each byte holds 8 pixels
- **Bit 0 (LSB) = leftmost pixel** in each group of 8
- 1 = foreground (drawn), 0 = background (not drawn)
- Extra bits in the last byte of each row are padding if width % 8 != 0

---

## Current Status

- Maine state silhouette logo (60x50 pixels) designed and committed
  (`firmware/meshtastic/assets/maine-logo.xbm`)
- `userPrefs.jsonc` configured with OEM boot splash data
- GitHub Actions CI pipeline builds for Station G2, T-Deck, T-Deck Pro
- `just fetch-firmware --source custom` downloads pre-built LA-Mesh binaries
- `just build-firmware` supports local PlatformIO builds
