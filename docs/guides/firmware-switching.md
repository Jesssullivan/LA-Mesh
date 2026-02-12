# Firmware Switching: MeshCore <-> Meshtastic

This guide covers switching between Meshtastic and MeshCore firmware on ESP32-S3
devices (Station G2, T-Deck). This is useful for evaluating MeshCore on a
dedicated test device.

> **Important**: MeshCore and Meshtastic use different partition table layouts,
> NVS schemas, and radio configurations. There is no dual-boot capability.
> Switching firmware requires a full flash erase and reflash.

---

## Why Not Dual-Boot?

The two firmwares are fundamentally incompatible at the storage level:

| Aspect | Meshtastic | MeshCore |
|--------|-----------|----------|
| Partition table | Custom (app + littlefs) | Different layout |
| NVS schema | Meshtastic-specific keys | MeshCore-specific keys |
| Configuration | YAML profiles via CLI | Web config tool |
| Channel format | PSK + channel index | Room/password model |

Switching requires erasing flash and reflashing, which takes approximately
60 seconds with a USB connection.

---

## Before Switching

### Back Up Current Configuration

```bash
# If currently running Meshtastic
meshtastic --export-config > backup-meshtastic-$(date +%Y%m%d).yaml

# Record current firmware version
meshtastic --info | grep Firmware

# Note your channel PSK (you'll need it when switching back)
# PSK is available from LA-Mesh admin or your .env file
```

### What You'll Lose

- All device configuration (restored from backup/profile after switch)
- Message history on the device
- Node list and contact list
- Bluetooth pairings

What is preserved:
- Nothing -- flash erase is complete. All state must be restored from backups.

---

## Switching to MeshCore (Evaluation)

### Step 1: Erase Flash

```bash
# Enter bootloader mode: Hold BOOT, press RESET, release BOOT
just flash-erase /dev/ttyUSB0
```

### Step 2: Flash MeshCore

The recommended method is the MeshCore web flasher:

1. Open https://flasher.meshcore.co.uk in Chrome/Edge
2. Connect device via USB
3. Select your device type (Station G2, T-Deck, etc.)
4. Click Flash

Or via CLI (if you have the MeshCore binary):
```bash
just flash-meshcore meshcore-firmware.bin /dev/ttyUSB0
```

### Step 3: Configure MeshCore

1. Open https://config.meshcore.co.uk in Chrome/Edge
2. Connect to the device via WebSerial
3. Set radio parameters:
   - Frequency: 915 MHz
   - Bandwidth: 250 kHz
   - Spreading Factor: varies by use case
4. Set a device name and admin password

### Important Notes for MeshCore Evaluation

- Use a **dedicated evaluation device** -- do not use your primary LA-Mesh device
- MeshCore uses AES-128-ECB encryption (weaker than Meshtastic's AES-256-CTR)
- MeshCore has no key revocation mechanism
- MeshCore devices are **not compatible** with the LA-Mesh Meshtastic network
- See `docs/architecture/security-comparison.md` for detailed analysis

---

## Switching Back to Meshtastic

### Step 1: Erase Flash

```bash
# Enter bootloader mode: Hold BOOT, press RESET, release BOOT
just flash-erase /dev/ttyUSB0
```

### Step 2: Flash Meshtastic

```bash
# One-command provisioning (fetches firmware if needed)
just provision station-g2 /dev/ttyUSB0

# Or manual steps:
just fetch-firmware --device station-g2
just flash-meshtastic firmware/.cache/firmware-station-g2-2.7.15.bin /dev/ttyUSB0
just configure-profile station-g2-router /dev/ttyUSB0
just configure-channels /dev/ttyUSB0
```

### Step 3: Restore Configuration

If you backed up before switching:
```bash
meshtastic --configure backup-meshtastic-YYYYMMDD.yaml
```

Or apply the standard LA-Mesh profile:
```bash
just configure-profile station-g2-router /dev/ttyUSB0
just configure-channels /dev/ttyUSB0
```

### Step 4: Verify

```bash
meshtastic --port /dev/ttyUSB0 --info
```

Check:
- Firmware version is v2.7.15+
- Region is US
- Modem preset is LONG_FAST
- Hop limit is 5
- Channels are configured (LA-Mesh, LA-Admin, LA-Emergency)

---

## Quick Reference

| Action | Time | Command |
|--------|------|---------|
| Erase flash | ~5s | `just flash-erase /dev/ttyUSB0` |
| Flash Meshtastic | ~30s | `just provision station-g2 /dev/ttyUSB0` |
| Flash MeshCore | ~30s | Web flasher or `just flash-meshcore` |
| Configure Meshtastic | ~15s | Automatic with `just provision` |
| Configure MeshCore | ~2min | Web config tool |
| **Total switch time** | **~60s** | Erase + flash + configure |

---

## Automation Script

For convenience, a guided switch script is available:

```bash
./tools/flash/switch-firmware.sh /dev/ttyUSB0
```

This script will:
1. Ask which firmware you want to switch to
2. Back up current configuration (if Meshtastic)
3. Erase flash
4. Flash the selected firmware
5. Apply configuration
