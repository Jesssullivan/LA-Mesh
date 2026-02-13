# LA-Mesh

Work in progress LoRa mesh network and encrypted communication bridge infrastructure for Southern Maine.

## Quick Start

```bash
# Enter development environment
nix develop   # or: direnv allow

# List all commands
just

# Start documentation site
just dev

# Show environment info
just info
```

## Device Provisioning

Three commands to go from a blank device to a deployed mesh node:

```bash
# 1. Flash firmware (interactive — prompts for bootloader mode)
just flash-g2

# 2. Configure everything: LoRa, channels, owner name
just configure-g2 "LA-Mesh RTR-01" "R01"

# 3. Set ROUTER role (final step — kills USB serial on ESP32-S3)
just mesh-set-role ROUTER
```

Step 2 reads PSK values from `.env` (auto-sourced by justfile). Generate
fresh keys with `just generate-psks` and store them in KeePassXC.

Port is auto-detected (`/dev/ttyACM0` > `ttyUSB0`). Pass explicitly if
needed: `just flash-g2 /dev/ttyACM1`.

See [Node Deployment Guide](docs/guides/node-deployment.md) for full
details including Station G2 hardware notes, bootloader procedure, and
the 16MB flash partition layout.

<!-- BEGIN_FIRMWARE_SECTION -->
## Custom Firmware Downloads

LA-Mesh branded Meshtastic firmware with custom boot splash (Maine silhouette + "LA-Mesh" text).

| Device | Binary | SHA256 |
|--------|--------|--------|
| station-g2 | _built by CI_ | - |
| t-deck | _built by CI_ | - |
| t-deck-pro | _built by CI_ | - |

Run `just fetch-firmware --source custom` to download, then `sha256sum -c SHA256SUMS.txt` to verify.
<!-- END_FIRMWARE_SECTION -->

## Development

**Prerequisites**: Nix with flakes enabled, or manually install: Node.js 22, pnpm, just, meshtastic CLI, esptool

```bash
# Clone and enter dev shell
git clone https://github.com/Jesssullivan/LA-Mesh.git
cd LA-Mesh
nix develop

# First-time setup
just setup

# Build documentation site
just build
```

## License

[MIT](LICENSE)
