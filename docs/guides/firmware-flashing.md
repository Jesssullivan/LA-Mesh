# Firmware Flashing Guide

**Applies to**: All LA-Mesh Meshtastic devices
**Prerequisites**: USB data cable, LA-Mesh repo clone, Nix devShell (or manual tool installation)

---

## Minimum Firmware Version

**All LA-Mesh devices MUST run Meshtastic v2.7.15 or later** due to CVE-2025-52464 (duplicate crypto keys), CVE-2025-24797, CVE-2025-55293, CVE-2025-55292, and CVE-2025-53627. v2.7.15 enforces PKI-only DMs (legacy DMs disabled).

---

## Method 1: One-Command Provisioning (Recommended)

Clone the repo, enter the dev shell, and provision a device in one pipeline. This fetches the manifest-pinned firmware, verifies its SHA256 checksum, flashes it, applies the device profile, and configures LA-Mesh channels.

```bash
git clone https://github.com/Jesssullivan/LA-Mesh.git
cd LA-Mesh
direnv allow                                    # or: nix develop
just provision station-g2 /dev/ttyUSB0
```

### What `just provision` does

| Step | Action | Detail |
|------|--------|--------|
| 1 | Fetch firmware | Downloads pinned version from GitHub (cached locally) |
| 2 | Verify checksum | SHA256 checked against `firmware/manifest.json` |
| 3 | Flash device | esptool.py `write-flash` at offset `0x260000` |
| 4 | Apply profile | Device role config (ROUTER, CLIENT, etc.) |
| 5 | Set channels | LA-Mesh / LA-Admin / LA-Emergency (requires PSK env vars) |

Device types: `station-g2`, `t-deck`

---

## Method 2: Step-by-Step CLI

For operators who want explicit control over each stage.

```bash
# 1. Fetch firmware for a specific device
just fetch-firmware --device station-g2

# 2. Confirm pinned version
just firmware-versions

# 3. Flash (SHA256 verified automatically)
just flash-meshtastic firmware/.cache/firmware-station-g2-2.7.15.bin /dev/ttyUSB0

# 4. Apply device profile
just configure-profile station-g2-router /dev/ttyUSB0

# 5. Apply LA-Mesh channels (reads PSK from .env)
just configure-channels /dev/ttyUSB0
```

---

## Method 3: Web Flasher

For meetups or field use when the dev environment is unavailable.

1. Open https://flasher.meshtastic.org in Chrome/Edge (WebSerial required)
2. Connect device via USB-C (use a data cable, not charge-only)
3. Select your device type and firmware version
4. Click "Flash" and wait for completion (~2 minutes)

**Note**: Web flasher does not verify against the LA-Mesh manifest. After flashing, apply the profile and channels manually via CLI.

---

## Checksum Verification

All justfile flash commands verify firmware integrity automatically:

- `firmware/manifest.json` pins the exact version and SHA256 hash per device
- `just fetch-firmware` verifies the hash on download
- `just flash-meshtastic` verifies the hash before flashing
- `just provision` verifies the hash at step 2 -- refuses to flash on mismatch

```bash
# After first download, populate manifest hashes
just firmware-update-hashes

# Verify what's pinned
just firmware-versions
```

If you see **"CHECKSUM MISMATCH -- refusing to flash!"**, the binary is corrupted or does not match the manifest. Re-download with `just fetch-firmware`.

---

## Version Parity

All devices provisioned from the same repo clone get identical firmware versions -- the manifest is the single source of truth.

```bash
# Check pinned versions
just firmware-versions

# Check if upstream has a newer release
just firmware-check
```

To update the pinned version: edit `firmware/manifest.json`, run `just fetch-firmware`, then `just firmware-update-hashes`.

---

## Method 4: MeshAdv-Mini (Raspberry Pi)

The MeshAdv-Mini runs meshtasticd (Linux-native Meshtastic) on the Raspberry Pi. No esptool flashing needed.

```bash
sudo apt install meshtasticd
sudo nano /etc/meshtasticd/config.yaml
sudo systemctl enable --now meshtasticd
```

---

## Post-Flash Configuration

| Device | Profile | Command |
|--------|---------|---------|
| Station G2 (relay) | station-g2-router | `just configure-profile station-g2-router` |
| T-Deck Plus | tdeck-plus-client | `just configure-profile tdeck-plus-client` |
| T-Deck Pro (e-ink) | tdeck-pro-eink-client | `just configure-profile tdeck-pro-eink-client` |
| MeshAdv-Mini | meshadv-mini-gateway | `just configure-profile meshadv-mini-gateway` |

Then apply LA-Mesh channel configuration (requires PSK environment variables):

```bash
just configure-channels /dev/ttyUSB0
```

---

## Troubleshooting

| Error | Solution |
|-------|----------|
| "Failed to connect" | Enter bootloader mode (hold BOOT, press RESET, release BOOT) |
| "CHECKSUM MISMATCH" | Re-download: `just fetch-firmware`, then `just firmware-update-hashes` |
| "Invalid head of packet" | Erase flash first: `just flash-erase` |
| "Timed out" | Try lower baud rate (115200 instead of 921600) |
| Permission denied | `sudo usermod -aG dialout $USER` (re-login required) |
| Device boots but no mesh | Verify region US, modem preset LONG_FAST, channel PSK matches |
