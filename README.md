# LA-Mesh

LoRa mesh network infrastructure for Southern Maine.

Community-driven encrypted mesh communications covering the Lewiston-Auburn area, supporting Meshtastic, MeshCore, and LoRa radio education.

## What is LA-Mesh?

LA-Mesh deploys a resilient, encrypted mesh network using LoRa radio technology. Our goals:

- **Encrypted communications** for community members via Meshtastic mesh devices
- **Infrastructure relay nodes** on rooftops and towers for wide coverage
- **Education** in RF engineering, SDR analysis, and secure communications
- **Bridges** connecting SMS, email, and internet to the mesh network
- **Community resilience** through distributed, infrastructure-independent communications

## Supported Devices

| Device | Role | Description |
|--------|------|-------------|
| **Station G2** | Base station / relay | High-power (up to 4.46W), rooftop/tower deployment |
| **T-Deck Pro** | Mobile client | Full keyboard, GPS, portable encrypted comms |
| **T-Deck Pro (E-Ink)** | Low-power client | Battery-optimized, sunlight-readable |
| **MeshAdv-Mini** | Pi HAT gateway | SMS/email bridge, runs meshtasticd on Linux |
| **HackRF H4M** | Education tool | SDR spectrum analysis, LoRa protocol education |

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

## Project Structure

```
LA-Mesh/
├── site/              # SvelteKit documentation site (GitHub Pages)
├── docs/              # Documentation content
│   ├── architecture/  # Architecture decision records
│   ├── devices/       # Per-device setup guides
│   ├── guides/        # User guides
│   └── research/      # Protocol and device research
├── firmware/          # Firmware configurations
│   ├── meshtastic/    # Meshtastic device configs
│   └── meshcore/      # MeshCore evaluation configs
├── configs/           # Network and device profiles
├── bridges/           # Gateway/bridge software
│   ├── sms/           # SMS-to-mesh bridge
│   ├── email/         # GPG email-to-mesh bridge
│   └── mqtt/          # MQTT bridge configs
├── curriculum/        # Education materials
│   ├── sdr/           # HackRF/SDR labs
│   ├── tails/         # TAILS and secure comms
│   ├── mesh-basics/   # Mesh networking fundamentals
│   └── security/      # Encryption and OPSEC
├── hardware/          # Hardware BOMs, antenna calcs, enclosures
├── tools/             # Flash, test, and monitoring scripts
├── flake.nix          # Nix development environment
├── MODULE.bazel       # Bazel build configuration
└── justfile           # Task runner
```

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

## Community

LA-Mesh serves the Lewiston-Auburn and Southern Maine community. If you're interested in joining the mesh network or contributing to the project, check the documentation site for getting started guides.

## License

[MIT](LICENSE)
