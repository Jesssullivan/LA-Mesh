# LA-Mesh

Work in progress LoRa mesh network and encrypted communication bridge infrastructure for Southern Maine.

Community-driven encrypted mesh communications covering the Lewiston-Auburn area, supporting Meshtastic, MeshCore, and LoRa radio education.

## What is LA-Mesh?

LA-Mesh deploys a resilient, encrypted mesh network using LoRa radio technology. Our goals:

- **Encrypted communications** for community members via Meshtastic mesh devices; 3 private encrypted channels plus the default public Meshtastic channel (LongFast) so LA-Mesh nodes also participate in the broader Meshtastic network.
- **Infrastructure relay nodes** We aspire to distribute, establish and help maintain high quality router nodes on rooftops and towers for wide coverage!  
- **Education** We aspire to meet fortnightly in the LA area
- **Bridges, eventually** Jess wants to connect SMS, email, and internet to the mesh network



## Supported Devices

| Device | Role | Description |
|--------|------|-------------|
| **Station G2** | Base station / relay | High-power (up to 4.46W), rooftop/tower deployment (want one?  have a roof, pole or sunny spot?  We'll giev you one) |
| **T-Deck Pro** | Mobile client | Full keyboard, GPS, portable encrypted comms; turn key (want one and in the LA area?  We'll give you one) |
| **T-Deck Pro (E-Ink)** | Low-power client | Battery-optimized, sunlight-readable |
| **FireElmo-SDR** | Custom PCB + Pi HAT gateway | SMS/email bridge, runs meshtasticd on Linux (custom PCB/software project) |
| **HackRF H4M** | SDR spectrum analysis for teaching |  Jess has curricula for basic TEMPEST attacks, packet capture, interference and range testing. |


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

Step 2 reads PSK values from `.env` if you are into that life. (auto-sourced by justfile). Generate
fresh keys with `just generate-psks` and store them in KeePassXC.  We reccomend using a proper secret
managment system, not `.env`.

Port is auto-detected (`/dev/ttyACM0` > `ttyUSB0`). Pass explicitly if
needed: `just flash-g2 /dev/ttyACM1`.


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

