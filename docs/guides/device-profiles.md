# Device Configuration Profiles

**Applies to**: All LA-Mesh Meshtastic devices
**Profiles location**: `configs/profiles/`

---

## Overview

LA-Mesh provides pre-built configuration profiles for each device role. Profiles set LoRa parameters, power management, GPS behavior, and network settings appropriate for each use case.

### Apply a Profile

```bash
meshtastic --configure configs/profiles/<profile>.yaml
```

---

## Available Profiles

### station-g2-router.yaml

**Purpose**: Backbone infrastructure relay node
**Device**: Station G2
**Role**: ROUTER

| Setting | Value | Rationale |
|---------|-------|-----------|
| tx_power | 30 dBm | Maximum legal power (FCC Part 15) |
| hop_limit | 5 | Extended reach for backbone |
| device.role | ROUTER | Always rebroadcasts, high airtime budget |
| gps_enabled | false | Fixed position, no GPS needed |
| bluetooth.enabled | false | No user interaction |
| wifi_enabled | false | Air-gapped from internet |
| ls_secs | 0 | Never sleep |
| position_broadcast_secs | 43200 | Every 12 hours (position rarely changes) |

### tdeck-plus-client.yaml

**Purpose**: Daily-carry user device
**Device**: T-Deck Plus (2.8" IPS LCD)
**Role**: CLIENT

| Setting | Value | Rationale |
|---------|-------|-----------|
| tx_power | 22 dBm | Balance of range and battery life |
| hop_limit | 3 | Standard community range |
| device.role | CLIENT | Rebroadcasts with backoff |
| gps_enabled | true | Position sharing (2 min interval) |
| bluetooth.enabled | true | Companion app connection |
| is_power_saving | true | Extend battery life |
| position_broadcast_secs | 900 | Every 15 minutes |

### tdeck-pro-eink-client.yaml

**Purpose**: Extended field operations, low-power use
**Device**: T-Deck Pro (3.1" e-paper)
**Role**: CLIENT

| Setting | Value | Rationale |
|---------|-------|-----------|
| tx_power | 22 dBm | Standard power |
| device.role | CLIENT | Standard rebroadcast |
| gps_enabled | true | Position sharing (5 min interval) |
| is_power_saving | true | Aggressive power saving for e-ink |
| ls_secs | 300 | 5-minute light sleep |
| position_broadcast_secs | 1800 | Every 30 minutes (less frequent) |
| screen_on_secs | 60 | E-ink retains image, screen timeout short |

### meshadv-mini-gateway.yaml

**Purpose**: SMS/email bridge gateway on Raspberry Pi
**Device**: MeshAdv-Mini Pi HAT
**Role**: ROUTER_CLIENT

| Setting | Value | Rationale |
|---------|-------|-----------|
| tx_power | 22 dBm | Standard power |
| device.role | ROUTER_CLIENT | Routes traffic AND acts as bridge endpoint |
| rebroadcast_mode | ALL | Rebroadcast everything (gateway sees all) |
| serial_enabled | true | Pi connects via serial/SPI |
| debug_log_enabled | true | Essential for bridge debugging |
| bluetooth.enabled | false | Pi handles connectivity |
| wifi_enabled | false | Pi handles networking |
| ls_secs | 0 | Never sleep (always-on gateway) |

### mqtt-gateway.yaml

**Purpose**: Internet-connected MQTT bridge
**Device**: Any Meshtastic device with WiFi
**Role**: CLIENT

| Setting | Value | Rationale |
|---------|-------|-----------|
| device.role | CLIENT | Standard client with MQTT uplink |
| rebroadcast_mode | LOCAL_ONLY | Don't re-inject internet-sourced messages into mesh |
| wifi_enabled | true | Required for MQTT |
| mqtt.enabled | true | Core function |
| mqtt.encryption_enabled | true | Encrypt MQTT traffic |
| mqtt.json_enabled | true | JSON output for bridge scripts |
| mqtt.tls_enabled | true | TLS to MQTT broker |
| bluetooth.enabled | false | Not needed for MQTT node |

---

## Customizing Profiles

Profiles are YAML files matching the Meshtastic `--export-config` format. To create a custom profile:

1. Start from the closest existing profile
2. Modify values as needed
3. Apply: `meshtastic --configure configs/profiles/my-profile.yaml`
4. Verify: `meshtastic --info`

### Common Customizations

```bash
# Override TX power
meshtastic --set lora.tx_power 20

# Change modem preset
meshtastic --set lora.modem_preset LONG_MODERATE

# Set owner name
meshtastic --set-owner "YourName"
meshtastic --set-owner-short "YN"

# Set fixed position (infrastructure nodes)
meshtastic --setlat 44.1003 --setlon -70.2148 --setalt 60
```

---

## Profile Selection Flowchart

```
Is this an infrastructure node (always-on, fixed location)?
├── YES → Does it need internet connectivity?
│   ├── YES → mqtt-gateway.yaml
│   └── NO → Is it a Pi with MeshAdv-Mini?
│       ├── YES → meshadv-mini-gateway.yaml
│       └── NO → station-g2-router.yaml
└── NO → Is battery life the top priority?
    ├── YES → tdeck-pro-eink-client.yaml
    └── NO → tdeck-plus-client.yaml
```
