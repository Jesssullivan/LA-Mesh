# MeshCore Flash Instructions

**Target device**: Station G2 (ESP32-S3)
**Firmware**: MeshCore simple_repeater
**Purpose**: LA-Mesh evaluation node (EVAL-MC)

---

## Download Firmware

1. Go to https://github.com/meshcore-dev/MeshCore/releases
2. Download the latest `simple_repeater` binary for ESP32-S3
3. Note the version number for the evaluation report

---

## Flash via Web Flasher (Recommended)

1. Open https://flasher.meshcore.co.uk in Chrome/Edge
2. Connect Station G2 via USB
3. Select "Simple Repeater" firmware variant
4. Select your device model
5. Click "Flash"
6. Wait for completion

---

## Flash via Command Line

```bash
# Enter Nix devshell
nix develop

# Flash MeshCore firmware
./tools/flash/flash-meshcore.sh firmware-meshcore-simple-repeater.bin /dev/ttyUSB0
```

If device is not detected, enter bootloader mode:
1. Hold BOOT button
2. Press and release RESET
3. Release BOOT

---

## Post-Flash Configuration

### Via Web Config Tool

1. Connect device via USB
2. Open https://config.meshcore.dev in Chrome/Edge
3. Configure:
   - Node name: `EVAL-MC`
   - Frequency: 915 MHz (US ISM)
   - TX power: 30 dBm
   - Role: Simple Repeater

### Configuration Notes

MeshCore configuration is different from Meshtastic:
- No YAML profile import
- Configuration via web tool or companion app
- Repeater nodes are configured to relay all traffic
- No channel PSK equivalent -- uses Ed25519 identity keys

---

## Verification

After flashing and configuring:

1. Power on the device
2. Verify on MeshCore companion app (Android/iOS) that the node is visible
3. Send a test message from a companion device
4. Verify the repeater relays the message
5. Record the node ID for the evaluation report

---

## Important Differences from Meshtastic

| Aspect | Meshtastic | MeshCore |
|--------|-----------|----------|
| Configuration tool | CLI (`meshtastic`) | Web config or companion app |
| Profile import | `--configure profile.yaml` | Manual via web tool |
| Channel encryption | PSK per channel | Ed25519 + ECDH per-node |
| Node roles | ROUTER, CLIENT, etc. | companion_radio, simple_repeater, room_server |
| MQTT bridge | Built-in | Not available |
| CLI management | Full Python CLI | Limited CLI |
