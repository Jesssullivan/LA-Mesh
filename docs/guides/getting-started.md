# Getting Started with LA-Mesh

Welcome to the LA-Mesh community LoRa network for Southern Maine.

## What You Need

1. A compatible LoRa device (see [Supported Devices](/devices))
2. The Meshtastic companion app ([Android](https://play.google.com/store/apps/details?id=com.geeksville.mesh) / [iOS](https://apps.apple.com/app/meshtastic/id1586432531))
3. Basic familiarity with your device

## Quick Start

### Step 1: Flash Firmware

All LA-Mesh devices run Meshtastic firmware v2.7.15 or later (critical for security -- see CVE-2025-52464, CVE-2025-24797). v2.7.15 enforces PKI-only DMs.

Visit [flasher.meshtastic.org](https://flasher.meshtastic.org) to flash your device.

### Step 2: Configure Device

Connect to your device via the Meshtastic app, then:

1. Set your node name (e.g., `LA-YourName`)
2. Join the LA-Mesh channel (details provided at community meetups)
3. Set your device role:
   - **CLIENT** for portable use
   - **CLIENT_BASE** for home stations
   - **ROUTER** for fixed relay nodes (with coordinator approval)

### Step 3: Send a Test Message

Send a message to the default channel to verify connectivity.

## Security

- **All devices must run firmware v2.7.15+** (CVE-2025-52464, CVE-2025-24797 fixes)
- **Never share channel PSK keys** outside the community
- **Enable PKC** for encrypted direct messages

## Need Help?

- Check our [Troubleshooting Guide](/guides/troubleshooting)
- Open an issue on [GitHub](https://github.com/Jesssullivan/LA-Mesh/issues)
- Attend a community meetup
