# Firmware Flashing Guide

**Applies to**: All LA-Mesh Meshtastic and MeshCore devices
**Prerequisites**: USB cable, device in bootloader mode, esptool.py (provided by Nix devShell)

---

## Before You Flash

### 1. Back Up Your Config

Always export your current configuration before flashing:

```bash
meshtastic --export-config > backup-$(date +%Y%m%d).yaml
```

### 2. Check Minimum Firmware Version

**All LA-Mesh devices MUST run Meshtastic v2.6.11 or later** due to CVE-2025-52464 (duplicate cryptographic keys from vendor image cloning, CVSSv4 9.5).

### 3. Identify Your Device

| Device | Chip | Flash Method |
|--------|------|-------------|
| Station G2 | ESP32-S3 | esptool.py (USB) |
| T-Deck Plus | ESP32-S3 | esptool.py (USB) |
| T-Deck Pro (e-ink) | ESP32-S3 | esptool.py (USB) |
| RAK WisBlock | nRF52840 | adafruit-nrfutil or web flasher |
| MeshAdv-Mini | SX1262 (via Pi) | meshtasticd package install |

---

## Method 1: Web Flasher (Recommended for Beginners)

### Meshtastic Web Flasher

1. Open https://flasher.meshtastic.org in Chrome/Edge (WebSerial required)
2. Connect device via USB
3. Select your device variant
4. Click "Flash"
5. Wait for completion -- do NOT disconnect during flash

### MeshCore Web Flasher

1. Open https://flasher.meshcore.co.uk in Chrome/Edge
2. Connect device via USB
3. Select firmware variant (`companion_radio`, `simple_repeater`, or `simple_room_server`)
4. Click "Flash"

---

## Method 2: Command Line (esptool.py)

### Enter Nix DevShell

```bash
# From LA-Mesh repo root
nix develop
# or
direnv allow
```

This provides `esptool.py`, `meshtastic` CLI, and all required tools.

### Flash Meshtastic

```bash
# Download firmware from https://meshtastic.org/downloads
# Choose the correct variant for your device

# Flash (auto-detects chip type)
just flash firmware-2.7.x-station-g2.bin

# Or manually:
./tools/flash/flash-meshtastic.sh firmware-2.7.x.bin /dev/ttyUSB0
```

### Flash MeshCore

```bash
# Download from https://github.com/meshcore-dev/MeshCore/releases

just flash firmware-meshcore-1.12.0.bin

# Or manually:
./tools/flash/flash-meshcore.sh firmware.bin /dev/ttyUSB0
```

### Bootloader Mode (if device isn't detected)

For ESP32-S3 devices (Station G2, T-Deck):

1. Hold the **BOOT** button
2. Press and release **RESET** while holding BOOT
3. Release BOOT
4. Device should appear as `/dev/ttyUSB0` or `/dev/ttyACM0`

Check available ports:

```bash
ls /dev/ttyUSB* /dev/ttyACM*
```

---

## Method 3: MeshAdv-Mini (Raspberry Pi)

The MeshAdv-Mini runs meshtasticd (Linux-native Meshtastic) on the Raspberry Pi. No esptool flashing needed -- the SX1262 radio is controlled directly by the Pi.

### Install meshtasticd

```bash
# On the Raspberry Pi
# Follow meshtasticd installation for your Pi OS
# See: https://meshtastic.org/docs/software/linux-native/
```

### Configure for MeshAdv-Mini HAT

```bash
# Apply the gateway profile
meshtastic --configure configs/profiles/meshadv-mini-gateway.yaml

# Set the channel PSK (get from LA-Mesh admin)
meshtastic --ch-set psk <base64-psk> --ch-index 0
```

---

## Post-Flash Configuration

### 1. Apply Device Profile

```bash
# Station G2 router
meshtastic --configure configs/profiles/station-g2-router.yaml

# T-Deck Plus client
meshtastic --configure configs/profiles/tdeck-plus-client.yaml

# T-Deck Pro e-ink client
meshtastic --configure configs/profiles/tdeck-pro-eink-client.yaml

# MQTT gateway
meshtastic --configure configs/profiles/mqtt-gateway.yaml
```

### 2. Set Channel PSK

```bash
# Primary channel
meshtastic --ch-set name "LA-Mesh" --ch-index 0
meshtastic --ch-set psk <base64-psk> --ch-index 0

# Admin channel (operators only)
meshtastic --ch-set name "LA-Admin" --ch-index 1
meshtastic --ch-set psk <different-base64-psk> --ch-index 1

# Emergency channel
meshtastic --ch-set name "LA-Emergency" --ch-index 2
meshtastic --ch-set psk <another-base64-psk> --ch-index 2
```

PSK values are distributed at community meetups only. Generate new ones with:

```bash
openssl rand -base64 32
```

### 3. Verify Configuration

```bash
meshtastic --info
meshtastic --nodes
```

### 4. Set Fixed Position (Routers Only)

```bash
# For infrastructure nodes with known locations
meshtastic --setlat 44.1003 --setlon -70.2148 --setalt 60
```

---

## Troubleshooting

### Device not detected

- Try a different USB cable (some are charge-only)
- Enter bootloader mode (BOOT + RESET sequence)
- Check `dmesg | tail -20` for USB device messages
- Try a different USB port

### Flash fails partway through

- Do NOT disconnect -- try again
- Erase flash first: `just flash-erase`
- Lower baud rate: edit flash script, change 921600 to 115200

### Device boots but no mesh activity

- Verify firmware version: `meshtastic --info`
- Check channel PSK matches other devices
- Verify region is set to `US`
- Check LoRa modem preset matches network (`LONG_FAST`)

### "No response from device" after flash

- Wait 30 seconds for first boot
- Reset device manually (press RESET button)
- Re-flash if persistent
