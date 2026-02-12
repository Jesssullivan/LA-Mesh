# Meshtastic Firmware & Ecosystem Deep Dive

**Research Date:** 2026-02-11
**Project:** LA-Mesh (Lewiston-Auburn / Bates College Community LoRa Mesh)
**Researcher:** Claude Agent (LA-Mesh Sprint Research)

---

## Table of Contents

1. [Current Firmware State (2025-2026)](#1-current-firmware-state-2025-2026)
2. [Channel & Encryption Configuration](#2-channel--encryption-configuration)
3. [High-Power Configuration & Range](#3-high-power-configuration--range)
4. [Relay/Router Mode & Fixed Installations](#4-relayrouter-mode--fixed-installations)
5. [Device Firmware Flashing](#5-device-firmware-flashing)
6. [Companion Apps](#6-companion-apps)
7. [MQTT Bridge](#7-mqtt-bridge)
8. [Meshtastic + MeshCore](#8-meshtastic--meshcore)
9. [Community Network Deployment](#9-community-network-deployment)
10. [Range Testing](#10-range-testing)
11. [Sprint Integration Points](#sprint-integration-points)

---

## 1. Current Firmware State (2025-2026)

### Version Landscape

| Branch | Version | Status | Date |
|--------|---------|--------|------|
| **Latest Beta** | 2.7.15.567b8ea | Beta (recommended for most users) | 2024-11-19 |
| **Latest Alpha** | 2.7.19.bb3d6d5 | Alpha (bleeding edge) | 2025-02-11 |
| **2.6.x Series** | 2.6.0 - 2.6.8 | Alpha/Preview | 2025 Q1-Q2 |
| **2.5.x Series** | 2.5.19 - 2.5.23 | Mature/Stable | 2024 |

**Key Insight:** Meshtastic does not use traditional "stable" releases. The project considers **Beta** releases to be "like stable versions" for most users. The small team iterates rapidly, so Beta is the recommended track for production deployments.

Sources:
- [Meshtastic Firmware Releases (GitHub)](https://github.com/meshtastic/firmware/releases)
- [Meshtastic Downloads](https://meshtastic.org/downloads/)
- [Release Alert Tracker](https://releasealert.dev/github/meshtastic/firmware)

### Major Feature Timeline

#### Version 2.5 (Foundation)
- **Public Key Cryptography (PKC)** for Direct Messages (DMs)
- **Session IDs** for Admin Messages (replay attack prevention)
- End of legacy unencrypted DMs
- x25519 key exchange + AES-CCM for DM encryption

#### Version 2.6 (Major Feature Release)
- **MUI (Meshtastic UI)**: Brand-new touchscreen interface for standalone devices
  - 12,000+ lines of custom code
  - Dashboard, node list, chat, dynamic map, traceroute, signal meter
  - 10 device types supported, 18 languages
  - No phone needed for basic operation
- **Next-Hop Routing**: Intelligent routing for direct messages
  - Uses 2 previously unused header bytes for relayer + next-hop identification
  - Starts with managed flood, learns optimal routes over time
  - Automatic fallback to flooding when conditions change
  - Backwards compatible with older firmware
- **InkHUD**: E-ink heads-up display (Heltec Vision Master, T-Echo)
- **LAN/UDP Meshing**: ESP32 devices communicate over local networks
- **Optimized LoRa Slot-Time**: Reduced collision rates

#### Version 2.7 (Current Development)
- Device telemetry broadcasts disabled by default over mesh (reduces congestion)
- nRF52 power usage optimization
- BLE TX power configurability for nRF52
- GPS soft-sleep with wake-up pin support
- RAK3112 support, meshtasticd systemd wrapper
- Advanced LoRa configuration options
- BaseUI improvements

Sources:
- [Meshtastic 2.6 Preview Blog](https://meshtastic.org/blog/meshtastic-2-6-preview/)
- [NHMesh 2.6 Release Guide](https://www.nhmesh.com/blog/meshtastic-2-6-release)
- [Iowa Mesh v2.6 Feature Summary](https://iowamesh.net/blog/2025/03/28/meshtastic-v2.6-a-feature-packed-release/)

### Roadmap Direction

The project is moving toward:
- More efficient routing (next-hop becoming standard)
- Reduced network congestion (telemetry off by default)
- Better standalone device experience (MUI, InkHUD)
- Enhanced security (PKC everywhere, legacy DM removal)
- Better power management for solar/remote deployments

---

## 2. Channel & Encryption Configuration

### Encryption Architecture

Meshtastic uses a **two-layer encryption model**:

```
Layer 1: Channel Encryption (PSK) - Group messages
  - AES256-CTR encryption on SubPacket payload
  - Packet header remains UNENCRYPTED (enables relay)
  - PSK shared among all channel members

Layer 2: Direct Message Encryption (PKC) - Point-to-point
  - x25519 public key exchange
  - AES-CCM encryption + authentication
  - Each node has unique public/private keypair
  - Introduced in firmware 2.5.0
```

### Pre-Shared Key (PSK) Details

| PSK Length | Encryption | Notes |
|-----------|-----------|-------|
| 0 bytes | None | Plaintext - avoid |
| 1 byte (AQ==) | AES128 | **DEFAULT** - publicly known, NOT secure |
| 16 bytes | AES128 | Moderate security |
| 32 bytes | AES256 | **Recommended** for community networks |

**Critical Warning:** The default primary channel PSK (`AQ==` = hex 0x01) is publicly known. Any Meshtastic device can read default-channel traffic. For LA-Mesh, a custom 32-byte PSK is mandatory.

### Public Key Cryptography (PKC) - v2.5+

- **DMs** are encrypted with recipient's public key
- **Digital signatures** verify sender identity
- **Session IDs** prevent replay attacks on admin messages
- Each device auto-generates a keypair on first boot
- Public keys are visible in device Security settings

### Known Limitations

| Gap | Impact | Mitigation |
|-----|--------|------------|
| No Perfect Forward Secrecy | "Harvest now, decrypt later" risk | Rotate PSKs periodically |
| No channel message integrity verification | Potential tampering | Use PKC DMs for critical comms |
| Hardware-based node IDs | Impersonation possible with PSK | Use PKC for identity verification |
| Not quantum-resistant (PKC) | Future risk | AES256 channel encryption IS quantum-resistant |

### LA-Mesh Channel Plan Recommendation

```
Channel 0 (Primary): "LA-Mesh"
  - PSK: Custom 32-byte key (AES256)
  - Purpose: Main community channel
  - Position sharing: Enabled (configurable precision)

Channel 1 (Secondary): "LongFast"
  - PSK: AQ== (default)
  - Purpose: Public interoperability with visiting devices
  - Position sharing: Disabled

Channel 2 (Secondary): "LA-Admin"
  - PSK: Separate 32-byte key
  - Purpose: Network administration
  - Position sharing: Disabled

Channel 3 (Secondary): "Bates-EM"
  - PSK: Separate 32-byte key
  - Purpose: Bates College emergency comms
  - Position sharing: Enabled
```

Sources:
- [Meshtastic Encryption Overview](https://meshtastic.org/docs/overview/encryption/)
- [PKC Blog Post](https://meshtastic.org/blog/introducing-new-public-key-cryptography-in-v2_5/)
- [Channel Configuration](https://meshtastic.org/docs/configuration/radio/channels/)
- [Security Configuration](https://meshtastic.org/docs/configuration/radio/security/)
- [Encryption Limitations](https://meshtastic.org/docs/about/overview/encryption/limitations/)
- [NHMesh Channel Setup Guide](https://nhmesh.com/guides/channel-setup)

---

## 3. High-Power Configuration & Range

### LoRa Modem Presets

| Preset | Data Rate | SF | CR | BW | Link Budget | Use Case |
|--------|-----------|----|----|-----|-------------|----------|
| Short Turbo | 21.88 kbps | 7 | 4/5 | 500 kHz | 140 dB | Dense urban, high throughput |
| Short Fast | 10.94 kbps | 7 | 4/5 | 250 kHz | 143 dB | Urban, many nodes |
| Short Slow | 6.25 kbps | 8 | 4/5 | 250 kHz | 145.5 dB | Suburban dense |
| Medium Fast | 3.52 kbps | 9 | 4/5 | 250 kHz | 148 dB | Suburban balanced |
| Medium Slow | 1.95 kbps | 10 | 4/5 | 250 kHz | 150.5 dB | Suburban/rural |
| Long Turbo | 1.34 kbps | 11 | 4/8 | 500 kHz | 150 dB | Wide area fast |
| **Long Fast** | **1.07 kbps** | **11** | **4/5** | **250 kHz** | **153 dB** | **Default - good starting point** |
| Long Moderate | 0.34 kbps | 11 | 4/8 | 125 kHz | 156 dB | Maximum range |

**LA-Mesh Recommendation:** Start with **LongFast** (default). If the network grows beyond 60 nodes or experiences congestion in the L-A urban core, migrate to **MediumSlow** (150.5 dB link budget, 1.82x faster data rate). The BayMesh network (150+ nodes) successfully migrated to MediumSlow.

### TX Power by Region

| Region | Max TX Power | Frequency Band |
|--------|-------------|----------------|
| **US (915 MHz)** | **30 dBm ERP** | 902-928 MHz |
| EU_868 | 27 dBm | 863-870 MHz |
| EU_433 | 12 dBm | 433-434 MHz |
| ANZ | 30 dBm | 915-928 MHz |
| China | 19 dBm | 470-510 MHz |

**Note:** Default TX power is 0 (which means "use regional maximum"). For US, this is effectively 22 dBm from the radio + antenna gain. The Station G2 with its PA can reach 35+ dBm.

### Duty Cycle Considerations

- **US 915 MHz**: No duty cycle restrictions (FCC Part 15.247 - frequency hopping)
- **EU 868 MHz**: 10% hourly duty cycle (can be overridden but violates regulations)
- **EU 433 MHz**: 10% hourly duty cycle
- Meshtastic calculates duty cycle on a rolling 1-hour basis
- LongFast preset consumes more airtime per message than faster presets

### Station G2 High-Power Specifications

The Unit Engineering Station G2 is the reference high-power base station:

| Spec | Value |
|------|-------|
| P1dB (1 dB compression) | 35 dBm (3.16 W) |
| Max RF Output (US915) | 36.5 dBm (4.46 W) |
| Max RF Output (EU868) | 37 dBm (5 W) |
| LNA Noise Figure | ~4 dB better than standard devices |
| MCU | ESP32-S3 |
| Power Input | 15V USB-C PD or 9-19V DC external |
| Use Case | Fixed base station, vehicle mount |

Sources:
- [LoRa Configuration](https://meshtastic.org/docs/configuration/radio/lora/)
- [Radio Settings Overview](https://meshtastic.org/docs/overview/radio-settings/)
- [Why Switch from LongFast](https://meshtastic.org/blog/why-your-mesh-should-switch-from-longfast/)
- [Station G2 Wiki](https://wiki.uniteng.com/en/meshtastic/station-g2)
- [Station G2 on Meshtastic Docs](https://meshtastic.org/docs/hardware/devices/b-and-q-consulting/station-series/)
- [Power Configuration](https://meshtastic.org/docs/configuration/radio/power/)

---

## 4. Relay/Router Mode & Fixed Installations

### Complete Device Role Reference

| Role | Rebroadcasts | Visible | Telemetry | Best For |
|------|-------------|---------|-----------|----------|
| **CLIENT** | Yes (smart) | Yes | Yes | General use, default |
| **CLIENT_MUTE** | No | Yes | Yes | Dense areas, personal handhelds near routers |
| **CLIENT_HIDDEN** | Minimal | No | Minimal | Stealth, power savings |
| **CLIENT_BASE** | Yes (favorites) | Yes | Yes | Rooftop base stations for weaker indoor devices |
| **ROUTER** | Always (priority) | Yes | Minimal | **Tower/rooftop infrastructure** |
| **ROUTER_LATE** | Always (last) | Yes | Minimal | Dead-spot coverage, backup relay |
| **REPEATER** | Always (priority) | No | None | **Pure relay, no user interaction** |
| **TRACKER** | Yes | Yes | GPS priority | Asset/person tracking |
| **SENSOR** | Yes | Yes | Telemetry priority | Environmental monitoring |
| **TAK** | Reduced | Yes | TAK-optimized | ATAK integration |
| **TAK_TRACKER** | Reduced | Yes | TAK PLI | ATAK position tracking |
| **LOST_AND_FOUND** | Yes | Yes | Location broadcast | Device recovery |

### LA-Mesh Role Assignments

```
Bates College Tower(s):    ROUTER or REPEATER
  - Strategic high point, clear line of sight
  - Solar-powered with battery backup
  - Station G2 hardware for maximum range

Downtown L-A Rooftops:     ROUTER_LATE
  - Fill coverage gaps in urban core
  - Lower priority than tower nodes
  - Standard Heltec V3 or T-Beam hardware

Member Home Nodes:         CLIENT_BASE
  - Rooftop/attic installations
  - Prioritize forwarding for household devices
  - Help extend coverage to weaker indoor handhelds

Personal Handhelds:        CLIENT
  - T-Deck, T-Beam, or Heltec portables
  - Smart rebroadcast when no other node has done so

Dense Gathering Areas:     CLIENT_MUTE
  - Classrooms, events, meetings at Bates
  - Prevents congestion from too many rebroadcasters
```

### Fixed Installation Best Practices

**Tower/Rooftop ROUTER Configuration:**
```bash
meshtastic --set device.role ROUTER
meshtastic --set lora.tx_power 30           # Maximum legal power
meshtastic --set lora.hop_limit 3           # Default, don't increase
meshtastic --set power.is_power_saving false # Always on
meshtastic --set device.rebroadcast_mode ALL
```

**Solar-Powered Node Considerations:**
- Power consumption in relay mode: ~48 mA @ 3.3V (24/7 capable with solar)
- Deep sleep idle: ~1.3 uA
- Minimum viable: 5W solar panel + 3350 mAh 18650 battery (2-3 days autonomy)
- Recommended: 6W panel + 7000 mAh (2+ weeks autonomy without sun)
- SenseCAP Solar Node P1-Pro: 5W + 4x3350 mAh = 2+ weeks no-sun autonomy
- Standard node (correct settings): 15-35 mA depending on load

**Hop Limit Guidance:**
- **Default 3 is strongly recommended** -- do not increase unless necessary
- Higher hop counts create instability and congestion
- If more hops needed, apply only to edge nodes, not central ones
- With proper ROUTER placement, 3 hops covers most community networks

Sources:
- [Device Configuration & Roles](https://meshtastic.org/docs/configuration/radio/device/)
- [Choosing the Right Device Role (Blog)](https://meshtastic.org/blog/choosing-the-right-device-role/)
- [Demystifying ROUTER_LATE](https://meshtastic.org/blog/demystifying-router-late/)
- [Configuration Tips](https://meshtastic.org/docs/configuration/tips/)
- [Solar Powered Nodes](https://meshtastic.org/docs/solar-powered/)
- [Solar Node Build Guide (MeshMentor)](https://meshmentor.com/2025/09/how-to-begin-your-first-solar-powered-meshtastic-node-project/)

---

## 5. Device Firmware Flashing

### Flashing Methods Overview

| Method | Devices | Difficulty | Notes |
|--------|---------|-----------|-------|
| **Web Flasher** | ESP32 only | Easy | Chrome/Edge required, recommended for beginners |
| **CLI Script** | ESP32 only | Medium | `meshtastic` Python package |
| **External Serial** | ESP32 | Hard | Last resort, external adapter needed |
| **Filesystem (UF2/drag-drop)** | nRF52, RP2040 | Easy | T-Echo, RAK4631, RAK11300 |

### Web Flasher (Primary Method for LA-Mesh)

**URL:** https://flasher.meshtastic.org

**Steps:**
1. Connect device via USB to computer
2. Open Chrome or Edge browser
3. Navigate to flasher.meshtastic.org
4. Select your board from the dropdown
5. Choose "Update" (preserve settings) or "Full Install" (wipe and flash)
6. Click Flash and wait for 100% progress
7. Disconnect and reboot

**Important:** The web client at `meshtastic.local` is only updated with a full wipe and reinstall.

### Device-Specific Bootloader Entry

#### Heltec V3
1. Hold **BOOT** (or **PRG**) button
2. Press and release **RST**
3. Release **BOOT**
4. (Alternative: hold BOOT while plugging in USB)

#### LilyGo T-Beam
1. Unplug device
2. Press and hold **BOOT** button
3. Plug in USB
4. After 2-3 seconds, release **BOOT**

#### LilyGo T-Deck / T-Deck Plus
1. Toggle power switch **OFF**
2. Press and hold **TRACKBALL**
3. Toggle power switch **ON**
4. After 2-3 seconds, release **TRACKBALL**
5. Screen black + backlight off = download mode

#### LilyGo T-Deck Pro (E-Ink)
- Same process as T-Deck Plus
- Firmware file: `firmware-t-deck-pro-X.X.X.xxxxxxx.bin`

### Firmware File Naming

| Device | Firmware File Pattern |
|--------|----------------------|
| Heltec V3 | `firmware-heltec_v3-X.X.X.bin` |
| T-Beam | `firmware-tbeam-X.X.X.bin` |
| T-Deck / T-Deck Plus | `firmware-t-deck-X.X.X.bin` |
| T-Deck Pro (E-Ink) | `firmware-t-deck-pro-X.X.X.bin` |
| Station G2 | `firmware-station-g2-X.X.X.bin` |
| RAK4631 (nRF52) | `firmware-rak4631-X.X.X.uf2` |
| T-Echo (nRF52) | `firmware-t-echo-X.X.X.uf2` |

**Always use the exact firmware file for your device.** Using generic ESP32 firmware will cause problems.

### Configuration Backup Before Flashing

```bash
# Export config (preserves keys, channels, settings)
meshtastic --export-config > config_backup.yaml

# Restore after flash
meshtastic --configure config_backup.yaml
```

**Critical:** Keys regenerate on full erase if not backed up. Always export before major firmware updates.

### T-Deck Pro (E-Ink) Status

The T-Deck Pro is supported with recent firmware (v2.7.10+ for V1.0, v2.7.13+ for V1.1). However, the UI experience on e-ink is currently limited:
- Navigation is difficult (cycle-through instead of touch)
- GPS enabled by default (high power draw)
- Not yet ideal as a standalone radio without phone app
- Best used with companion app for configuration

Sources:
- [Flashing Firmware Overview](https://meshtastic.org/docs/getting-started/flashing-firmware/)
- [ESP32 Flashing](https://meshtastic.org/docs/getting-started/flashing-firmware/esp32/)
- [Web Flasher](https://meshtastic.org/docs/getting-started/flashing-firmware/esp32/web-flasher/)
- [CLI Flashing](https://meshtastic.org/docs/getting-started/flashing-firmware/esp32/cli-script/)
- [T-Deck Hardware Docs](https://meshtastic.org/docs/hardware/devices/lilygo/tdeck/)
- [T-Beam Hardware Docs](https://meshtastic.org/docs/hardware/devices/lilygo/tbeam/)
- [T-Deck Pro GitHub](https://github.com/Xinyuan-LilyGO/T-Deck-Pro)

---

## 6. Companion Apps

### App Status Matrix (February 2026)

| Platform | Version | Connection Methods | Status |
|----------|---------|-------------------|--------|
| **Android** | Active development | Bluetooth, USB OTG | Most mature, frequent updates |
| **iOS/iPadOS/macOS** | Active development | Bluetooth | Requires iOS 17.5+, supports last 2 major versions |
| **Web Client** | Active development | HTTP, Bluetooth (Chromium), Serial (ESP32 only) | client.meshtastic.org |
| **Python CLI** | 2.7.7 (Jan 2026) | Serial, TCP, BLE | Full configuration + scripting |

### Android App
- Available on [Google Play](https://play.google.com/store/apps/details?id=com.geeksville.mesh) and [F-Droid](https://f-droid.org/en/packages/com.geeksville.mesh/)
- Minimum Android 8.0 (Oreo)
- Most feature-complete client
- Emoji reactions, improved node handling, location support
- Last updated February 2, 2026

### iOS/iPadOS/macOS App
- Available on [App Store](https://apps.apple.com/us/app/meshtastic/id1586432531)
- Native Apple platform application
- Mesh map, compass, relay visibility
- Performance improvements ongoing

### Web Client
- **URL:** https://client.meshtastic.org
- Works in all major browsers; Chromium recommended for full features
- Connection options:
  - **HTTP**: Most broadly supported (`http://meshtastic.local`)
  - **Web Bluetooth**: Chromium-only, direct BLE to device
  - **Web Serial**: Chromium-only, ESP32 devices, USB direct
- No installation required
- Device-hosted version available at `meshtastic.local` (requires full erase + reinstall to update)

### Python CLI
- **Install:** `pip install meshtastic`
- **Latest:** v2.7.7 (January 2026)
- Essential commands for LA-Mesh:

```bash
# Device info
meshtastic --info

# Set owner/name
meshtastic --set-owner "LA-Mesh Tower1" --set-owner-short "LT1"

# Configure LoRa
meshtastic --set lora.region US --set lora.tx_power 30

# Set device role
meshtastic --set device.role ROUTER

# Add channel
meshtastic --ch-add "LA-Mesh"

# Set fixed position (for tower nodes)
meshtastic --setlat 44.1003 --setlon -70.2148 --setalt 60

# Export/import config
meshtastic --export-config > tower1_config.yaml
meshtastic --configure tower1_config.yaml

# Remote admin (v2.5+)
meshtastic --dest '!nodeid' --set lora.tx_power 30
```

### JavaScript Library
- `@meshtastic/js` npm package
- Powers the official Web Client
- Enables custom integrations and tools

Sources:
- [Software Overview](https://meshtastic.org/docs/software/)
- [Python CLI Guide](https://meshtastic.org/docs/software/python/cli/)
- [Python CLI Installation](https://meshtastic.org/docs/software/python/cli/installation/)
- [Python CLI Usage](https://meshtastic.org/docs/software/python/cli/usage/)
- [Web Client Overview](https://meshtastic.org/docs/software/web-client/)
- [Meshtastic Python (GitHub)](https://github.com/meshtastic/python)
- [Meshtastic Android (GitHub)](https://github.com/meshtastic/Meshtastic-Android)

---

## 7. MQTT Bridge

### How MQTT Works in Meshtastic

Any Meshtastic node with internet connectivity (WiFi, Ethernet, 4G, satellite, or via companion app) can serve as an **MQTT gateway**, bridging the local mesh to/from the internet.

```
[Remote Mesh Nodes] <--LoRa--> [Gateway Node] <--WiFi/Eth--> [MQTT Broker] <--Internet--> [Other Gateways/Clients]
```

### Configuration

**Basic Gateway Setup:**
```bash
# Connect to WiFi
meshtastic --set network.wifi_ssid "MyNetwork"
meshtastic --set network.wifi_psk "MyPassword"
meshtastic --set network.wifi_enabled true

# Enable MQTT
meshtastic --set mqtt.enabled true
meshtastic --set mqtt.address "mqtt.example.com"  # blank = public meshtastic broker
meshtastic --set mqtt.username "user"
meshtastic --set mqtt.password "pass"

# Per-channel uplink/downlink
meshtastic --ch-set uplink_enabled true --ch-index 0
meshtastic --ch-set downlink_enabled true --ch-index 0
```

### Topic Structure

```
Protobuf: msh/US/2/e/CHANNELNAME/USERID
JSON:     msh/US/2/json/CHANNELNAME/USERID
Downlink: msh/US/2/json/mqtt/
```

### Public Broker Restrictions

The Meshtastic public broker (`mqtt.meshtastic.org`) enforces:
1. **Zero-hop policy** -- only directly connected nodes receive data
2. **Traffic filtering** -- limited to specific port numbers (NodeInfo, TextMessage, Position, Telemetry)
3. **Location precision** -- limited to 10-16 bit precision for privacy

### LA-Mesh MQTT Strategy

For LA-Mesh, consider:

1. **Self-hosted MQTT broker** (Mosquitto on a Bates server or VPS)
   - Full control over data retention and access
   - No public broker restrictions
   - Can bridge to public broker selectively

2. **Gateway placement**: One MQTT gateway node at each major installation
   - Bates College (campus WiFi)
   - Downtown L-A node with backhaul

3. **Encryption**: Enable `mqtt.encryption_enabled true` to keep channel PSK encryption intact over MQTT transit

4. **RAK WisMesh Gateway**: Purpose-built Ethernet MQTT gateway hardware option

### Third-Party Tools

- **meshtastic-bridge** (GitHub: geoffwhittington/meshtastic-bridge): Multi-server MQTT bridge
- Can forward to both `mqtt.meshtastic.org` and custom brokers simultaneously

Sources:
- [MQTT Overview](https://meshtastic.org/docs/software/integrations/mqtt/)
- [MQTT Module Configuration](https://meshtastic.org/docs/configuration/module/mqtt/)
- [RAK WisMesh Gateway](https://meshtastic.org/docs/hardware/devices/rak-wireless/wismesh/gateway/)
- [Philly Mesh MQTT Bridge Setup](https://phillymesh.net/2025/03/24/mqtt-bridge-setup/)
- [meshtastic-bridge (GitHub)](https://github.com/geoffwhittington/meshtastic-bridge)
- [RAK WisMesh Gateway Setup](https://docs.rakwireless.com/product-categories/meshtastic/meshtastic-gateway-setup/)

---

## 8. Meshtastic + MeshCore

### Fundamental Differences

| Aspect | Meshtastic | MeshCore |
|--------|-----------|----------|
| **Architecture** | Flat peer-to-peer; all nodes can relay | Repeater-centric; only repeaters relay |
| **Routing** | Managed flood + next-hop (v2.6+) | Flood-then-direct; learns paths |
| **Hop Limit** | Default 3, max 7 | Up to 64 internally |
| **Default Bandwidth** | 250 kHz (LongFast) | 62.5 kHz (narrower, optimized) |
| **Telemetry** | Push model (reduced in 2.7+) | Pull model (minimal by default) |
| **Responsiveness** | Good at small scale | Very responsive with infrastructure |
| **Community Size** | ~40,000 Discord members | ~3,500 Discord members |
| **License** | GPL | MIT |
| **Best For** | Roaming groups, events, ad-hoc | City-scale, infrastructure-backed |

### Compatibility

**MeshCore and Meshtastic are NOT compatible.** Devices running one firmware cannot communicate with devices running the other, even though both use LoRa radios on the same frequency bands.

### Dual-Boot / Coexistence

- **No official dual-boot mechanism exists**
- Same hardware can run either firmware (reflash to switch)
- Switching requires full firmware flash (not a settings change)
- Some vendors (Rokland) are beginning to support MeshCore alongside Meshtastic (expected Q1 2026)
- MeshCore community Discord is the best resource for switching guidance

### LA-Mesh Recommendation

**GO with Meshtastic as primary platform.** Rationale:
- Much larger community and ecosystem
- Better documentation and tooling
- More companion apps (Android, iOS, Web, Python CLI)
- PKC encryption for DMs
- MQTT bridge capability
- MUI standalone interface
- Active development with frequent releases

**Consider MeshCore for specific infrastructure nodes** if/when:
- Network scales beyond 100+ nodes and congestion becomes an issue
- Dedicated repeater infrastructure is well-established
- The community wants to experiment with the repeater-centric model

**Dual firmware is feasible** at a hardware level -- keep spare devices flashed with MeshCore for evaluation, but run the production network on Meshtastic.

Sources:
- [MeshCore vs Meshtastic (Austin Mesh)](https://www.austinmesh.org/learn/meshcore-vs-meshtastic/)
- [Key Differences Explained (LoRaMeshDevices)](https://www.lorameshdevices.com/blog/meshcore/meshtastic-vs-meshcore-key-differences-explained.html)
- [Meshtastic vs MeshCore Comparison (QuadMeUp)](https://blog.quadmeup.com/2026/01/09/meshtastic-vs-meshcore-which-one-is-better/)
- [MeshCore Pros & Cons (Lucifernet)](https://lucifernet.com/2025/08/29/meshtastic-and-meshcore-pros-cons/)
- [MeshCore GitHub](https://github.com/meshcore-dev/MeshCore)
- [MeshCore FAQ](https://github.com/meshcore-dev/MeshCore/blob/main/docs/faq.md)
- [Rokland MeshCore Support Policy](https://store.rokland.com/blogs/news/meshscore-support-policy)

---

## 9. Community Network Deployment

### Deployment Architecture

Based on successful community networks (NHMesh, BayMesh, PhillyMesh, Chicagoland Mesh):

```
                    [MQTT Gateway]
                         |
                    [MQTT Broker]
                         |
    [Tower ROUTER] ---- mesh ---- [Tower ROUTER]
         |                              |
    [Rooftop ROUTER_LATE]    [Rooftop ROUTER_LATE]
         |                              |
    [CLIENT_BASE homes]       [CLIENT_BASE homes]
         |                              |
    [CLIENT handhelds]        [CLIENT handhelds]
```

### Node Naming Convention for LA-Mesh

**Long Name Format:** `[Location]-[Type] [Identifier]`
**Short Name Format:** 4 characters, ALL CAPS

Examples:
```
Long Name               Short Name    Role
---------               ----------    ----
Bates-Tower-Main        BTWM          ROUTER
Bates-Tower-East        BTWE          ROUTER
LA-Downtown-Relay       LADR          ROUTER_LATE
Elm-St-Base             ELSB          CLIENT_BASE
John-Mobile             JMOB          CLIENT
Bates-EM-Admin          BEMA          CLIENT (admin)
```

**Conventions:**
- Infrastructure nodes: Location-based naming
- Personal nodes: Owner initials or name
- Short names: All caps for visibility
- Consider adding "LA-Mesh" or "LAM" to long names for community identification

### Channel Configuration

Following the NHMesh model adapted for LA-Mesh:

**Option A: LA-Mesh as Primary (Recommended for core members)**
```
Channel 0: "LA-Mesh" (custom PSK, AES256)
  - All broadcasts stay within LA-Mesh
  - Enhanced privacy
Channel 1: "LongFast" (default PSK AQ==)
  - Public interoperability
```

**Option B: Default Primary (Easier onboarding)**
```
Channel 0: "LongFast" (default PSK AQ==)
  - Compatible with any Meshtastic device
Channel 1: "LA-Mesh" (custom PSK, AES256)
  - Private community channel
```

**Frequency Slot:** US devices use the default for LongFast (slot 20).

### Administrative Structure

1. **Network Admins** (2-3 people)
   - Hold PKC admin keys for all infrastructure nodes
   - Can remotely configure routers/repeaters
   - Manage PSK rotation
   - Monitor network health via MQTT

2. **Remote Administration Setup (v2.5+)**
   ```bash
   # On admin device: get public key
   meshtastic --get security.public_key

   # On remote node: add admin key
   meshtastic --set security.admin_key "BASE64_PUBLIC_KEY"

   # Remote commands
   meshtastic --dest '!nodeid' --set lora.tx_power 30
   meshtastic --dest '!nodeid' --set device.role ROUTER
   ```

3. **PSK Distribution**
   - In-person key exchange preferred
   - Use QR codes in Meshtastic app for easy channel sharing
   - Never transmit PSKs over unencrypted channels
   - Rotate PSKs quarterly or when member leaves

### Site Planning

The **Meshtastic Site Planner** (https://site.meshtastic.org) is essential for LA-Mesh deployment:

- Uses ITM/Longley-Rice propagation model
- NASA SRTM terrain data
- Configure: TX power, antenna gain, cable loss, receiver sensitivity
- Model multiple radio sites simultaneously
- Visualize overlapping coverage areas
- Free and open source

**LA-Mesh should model:**
1. Bates College tower coverage (primary)
2. Downtown L-A rooftop coverage (secondary)
3. Overlap verification between tower and rooftop nodes
4. Coverage gaps in Androscoggin River valley

Sources:
- [Configuration Tips](https://meshtastic.org/docs/configuration/tips/)
- [NHMesh Channel Setup](https://nhmesh.com/guides/channel-setup)
- [NHMesh Guides](https://www.nhmesh.com/guides)
- [Remote Admin](https://meshtastic.org/docs/configuration/remote-admin/)
- [Meshtastic Site Planner](https://site.meshtastic.org/)
- [Site Planner Blog](https://meshtastic.org/blog/meshtastic-site-planner-introduction/)
- [Site Planner GitHub](https://github.com/meshtastic/meshtastic-site-planner)
- [Chicagoland Mesh Configuration](https://chicagolandmesh.org/guides/getting-started/configure/)
- [NHMesh Home](https://nhmesh.com/)
- [PhillyMesh](https://phillymesh.net/)
- [BayMesh Basics](https://bayme.sh/docs/getting-started/meshtastic-basics/)
- [Community Network Building Guide (Heartland)](https://heartlandemergencypreparedness.com/2025/08/25/building-a-community-meshtastic-network-step-by-step-guide-for-emergency-preparedness/)

---

## 10. Range Testing

### Built-in Range Test Module

**Setup:**
```bash
# Sender node (fixed location)
meshtastic --set range_test.enabled true
meshtastic --set range_test.sender 60  # Send every 60 seconds

# Receiver node (mobile, carried by tester)
meshtastic --set range_test.enabled true
meshtastic --set range_test.sender 0   # Receive only
meshtastic --set range_test.save true  # Save CSV to ESP32 flash
```

**Data Collected:**
- Sequential packet reception (identifies range boundary)
- GPS coordinates (lat/lon)
- RSSI and SNR metrics
- Timestamps

**Data Retrieval:**
- Access CSV via WiFi: `http://meshtastic.local/rangetest.csv`
- Visualize with Google Earth, Google My Maps, or OpenStreetMap uMap

**Auto-disable:** Module turns off after 8 hours to prevent excessive airtime.

**Recommended sender intervals by preset:**
- LongFast: 60 seconds
- MediumSlow: 30 seconds
- ShortFast: 15 seconds

### Traceroute Module

The Traceroute module reveals the path packets take through the mesh:

```bash
# From Python CLI
meshtastic --traceroute '!destination_nodeid'
```

**Returns (v2.5+):**
- Complete route to destination
- Return route back to origin
- SNR for each link in both directions
- Unknown nodes (without channel key) shown as ID 0xFFFFFFFF

**Available on:** Android, iOS, CLI, Web, and MUI (built into device UI in 2.6+)

### Antenna Testing (MeshTenna)

[MeshTenna](https://github.com/OE3JGW/MeshTenna) is a Windows/Android tool for comparing antennas:
- Measures RSSI and SNR between test node and fixed destination
- Helps identify optimal antenna choice and placement
- Compare stock vs. aftermarket antennas

### Signal Quality Reference

| RSSI | Quality | Notes |
|------|---------|-------|
| -80 to 0 dBm | Excellent | Very close range |
| -100 to -80 dBm | Good | Reliable communication |
| -110 to -100 dBm | Fair | Moderate reliability |
| -120 to -110 dBm | Poor | At range limit |
| Below -120 dBm | Unreliable | Packet loss likely |

| SNR | Quality | Notes |
|-----|---------|-------|
| > 10 dB | Excellent | Strong, clear signal |
| 0 to 10 dB | Good | Reliable |
| -5 to 0 dB | Fair | LoRa spreading factor advantage |
| -10 to -5 dB | Poor | Near demodulation limit |
| < -10 dB | Unreliable | Below LoRa threshold |

### LA-Mesh Range Test Plan

1. **Phase 1: Tower Coverage Mapping**
   - Station G2 sender at Bates tower, fixed position
   - Drive/walk test with receiver through L-A area
   - Map coverage boundary with GPS overlay

2. **Phase 2: Urban Relay Testing**
   - Traceroute between endpoints through downtown nodes
   - Identify dead spots and relay effectiveness
   - Test with MUI signal meter tool

3. **Phase 3: Antenna Comparison**
   - Compare stock antennas vs. external directional/omni
   - Use MeshTenna for systematic comparison
   - Document gain/pattern differences for each location

Sources:
- [Range Test Module](https://meshtastic.org/docs/configuration/module/range-test/)
- [Traceroute Module](https://meshtastic.org/docs/configuration/module/traceroute/)
- [Antenna Testing](https://meshtastic.org/docs/hardware/antennas/antenna-testing/)
- [MeshTenna (GitHub)](https://github.com/OE3JGW/MeshTenna)
- [Maximize Range Deep Dive (MeshUnderground)](https://meshunderground.com/posts/maximize-meshtastic-range-tips-and-deep-dive/)
- [Range Tests Archive](https://meshtastic.org/docs/overview/range-tests/)

---

## Sprint Integration Points

### GO Decisions

| Decision | Rationale | Confidence |
|----------|-----------|------------|
| **Meshtastic as primary platform** | Larger ecosystem, better apps, PKC encryption, MQTT, MUI | HIGH |
| **LongFast modem preset to start** | Best range, proven default, easy migration later | HIGH |
| **Custom 32-byte PSK for LA-Mesh channel** | AES256 encryption, privacy from default mesh | HIGH |
| **Web Flasher as primary flash method** | Simplest, no toolchain needed, browser-based | HIGH |
| **Station G2 for tower/base stations** | Highest power, best sensitivity, purpose-built | HIGH |
| **Python CLI for admin automation** | Scriptable, full config access, remote admin | HIGH |
| **Meshtastic Site Planner for coverage modeling** | Free, proven, terrain-aware propagation model | HIGH |

### NO-GO / DEFER Decisions

| Decision | Rationale | When to Revisit |
|----------|-----------|----------------|
| **MeshCore deployment** | Incompatible with Meshtastic, smaller ecosystem | When network exceeds 100 nodes |
| **Switching from LongFast** | Only needed at 60+ nodes or congestion | Month 6+ if growth warrants |
| **T-Deck Pro as primary handheld** | E-ink UI still immature for standalone use | Firmware 2.8+ with improved InkHUD |
| **Public MQTT broker** | Privacy concerns, zero-hop limitation | After self-hosted broker proven |
| **Hop limit > 3** | Creates instability, usually unnecessary | Only if proven needed by traceroute data |

### Sprint Gaps / Action Items

#### Week 1-2: Foundation
- [ ] Procure initial hardware (2x Station G2, 4x Heltec V3, 2x T-Deck Plus)
- [ ] Flash all devices to firmware 2.7.15 (latest beta)
- [ ] Generate 32-byte PSK for LA-Mesh primary channel
- [ ] Set up Python CLI development environment
- [ ] Create configuration templates (YAML exports) for each role

#### Week 3-4: Infrastructure
- [ ] Run Meshtastic Site Planner for Bates College tower coverage
- [ ] Run Site Planner for downtown L-A candidate sites
- [ ] Install Station G2 at primary Bates tower location (ROUTER role)
- [ ] Deploy 2x Heltec V3 as ROUTER_LATE at downtown rooftop sites
- [ ] Configure remote admin PKC keys on all infrastructure nodes

#### Week 5-6: Testing & Expansion
- [ ] Conduct range test from Bates tower (drive test through L-A)
- [ ] Run traceroute tests between all infrastructure nodes
- [ ] Map coverage boundary with GPS overlay
- [ ] Test antenna alternatives at each site
- [ ] Deploy CLIENT_BASE nodes at 2-3 member homes

#### Week 7-8: Operations & Community
- [ ] Set up self-hosted MQTT broker (Mosquitto)
- [ ] Configure MQTT gateway at Bates (campus WiFi backhaul)
- [ ] Create onboarding documentation (channel QR codes, setup guide)
- [ ] Distribute T-Deck Plus handhelds to initial community members
- [ ] Establish PSK rotation procedure and admin key management
- [ ] Document LA-Mesh node naming convention
- [ ] Create network monitoring dashboard (MQTT + web)

### Hardware Budget Estimate

| Item | Qty | Est. Cost | Role |
|------|-----|-----------|------|
| Station G2 | 2 | $140-160 ea | Tower ROUTER |
| Heltec V3 | 4 | $20-25 ea | ROUTER_LATE, CLIENT_BASE |
| T-Deck Plus | 4 | $65-80 ea | Handheld CLIENT |
| T-Deck Pro (E-Ink) | 1 | $80-100 | Evaluation |
| Solar panels (6W) | 2 | $15-20 ea | Tower power |
| 18650 batteries | 8 | $5-8 ea | Battery backup |
| Weatherproof enclosures | 4 | $10-15 ea | Outdoor nodes |
| External antennas (915MHz) | 4 | $10-30 ea | Range optimization |
| **Total Estimate** | | **$800-1200** | |

### Critical Dependencies

1. **Bates College tower access** -- Required for primary ROUTER placement; without this, coverage will be significantly reduced
2. **WiFi/Ethernet backhaul** at tower site for MQTT gateway
3. **Firmware stability** -- 2.7.15 is beta; test thoroughly before mass deployment; fall back to 2.5.23 if issues arise
4. **Member device procurement** -- Lead time on Station G2 and T-Deck Plus varies; order early
5. **Admin key management** -- Need secure method to distribute and store PKC admin keys and channel PSKs

### Risk Register

| Risk | Impact | Likelihood | Mitigation |
|------|--------|-----------|------------|
| Tower access denied | HIGH | LOW | Scout alternative high points (church steeples, municipal buildings) |
| Firmware regression in 2.7.x | MEDIUM | MEDIUM | Test on 2 devices first; maintain 2.5.23 fallback |
| PSK compromise | HIGH | LOW | Quarterly rotation, in-person distribution only |
| LoRa congestion at scale | MEDIUM | LOW (< 60 nodes) | Monitor airtime; migrate to MediumSlow if needed |
| Solar node failure (winter) | MEDIUM | MEDIUM | Size panels for Maine winter sun angles; battery for 3+ days |
| T-Deck Pro UI too immature | LOW | HIGH | Use phone app as primary interface; T-Deck Pro for evaluation only |
