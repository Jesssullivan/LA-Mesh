# LA-Mesh Network Topology

**Date**: 2026-02-11
**Region**: Southern Maine -- Lewiston-Auburn, Bates College campus and surrounding area
**Status**: Planning phase

---

## Design Goals

1. **Campus coverage**: Full Bates College campus (109 acres) with indoor penetration
2. **Community reach**: Extend to Lewiston-Auburn downtown corridor (~5 km)
3. **Emergency resilience**: Maintain mesh connectivity if internet/cellular fails
4. **Education**: Support hands-on learning for students and community members
5. **Gateway services**: SMS/email bridge for off-mesh communication

---

## Network Architecture

```
                    ┌─────────────────────────────────────┐
                    │          INTERNET / MQTT             │
                    └──────────────┬──────────────────────┘
                                   │
                    ┌──────────────┴──────────────────────┐
                    │     MeshAdv-Mini Gateway (Pi)       │
                    │  meshtasticd + SMS/Email bridge      │
                    │  Role: ROUTER_CLIENT                 │
                    │  Location: Indoor, wired power+net   │
                    └──────────────┬──────────────────────┘
                                   │ LoRa 915 MHz
                    ┌──────────────┴──────────────────────┐
                    │                                      │
           ┌────────┴────────┐                  ┌─────────┴────────┐
           │  Station G2 #1  │                  │  Station G2 #2   │
           │  Role: ROUTER   │                  │  Role: ROUTER    │
           │  30 dBm / ext   │                  │  30 dBm / ext    │
           │  antenna         │                  │  antenna          │
           │  Elevated site  │                  │  Elevated site    │
           └────────┬────────┘                  └─────────┬────────┘
                    │                                      │
        ┌───────────┼───────────┐            ┌────────────┼──────────┐
        │           │           │            │            │          │
   ┌────┴───┐  ┌───┴────┐ ┌───┴────┐  ┌───┴────┐  ┌───┴────┐    │
   │T-Deck  │  │T-Deck  │ │T-Deck  │  │T-Deck  │  │T-Deck  │    │
   │Plus #1 │  │Plus #2 │ │Pro #1  │  │Pro #2  │  │Plus #3 │    │
   │CLIENT  │  │CLIENT  │ │CLIENT  │  │CLIENT  │  │CLIENT  │    │
   └────────┘  └────────┘ └────────┘  └────────┘  └────────┘    │
                                                                   │
                                                         ┌─────────┴──────┐
                                                         │ MeshCore Eval  │
                                                         │ Station G2 #3  │
                                                         │ simple_repeater│
                                                         │ (evaluation)   │
                                                         └────────────────┘
```

---

## Tier Classification

### Tier 1: Infrastructure (Always-On)

| Node | Device | Role | Location | Power | Antenna |
|------|--------|------|----------|-------|---------|
| **GW-01** | MeshAdv-Mini + Pi 4 | ROUTER_CLIENT | Campus server room | Mains + UPS | External omnidirectional |
| **RTR-01** | Station G2 | ROUTER | Highest campus building (roof) | Mains + battery backup | External 6 dBi omni |
| **RTR-02** | Station G2 | ROUTER | Downtown L-A elevated site | Solar + battery | External 6 dBi omni |

**Requirements**:
- Always powered, never sleep
- External antenna with clear line-of-sight
- Weatherproof enclosure for outdoor installs
- GPS disabled (fixed position configured manually)
- Bluetooth disabled
- WiFi disabled (except GW-01 for MQTT)

### Tier 2: Mobile/Portable (User Devices)

| Node | Device | Role | Use Case |
|------|--------|------|----------|
| **MOB-01..N** | T-Deck Plus | CLIENT | Student/community daily carry |
| **MOB-E01..N** | T-Deck Pro (e-ink) | CLIENT | Low-power field use, extended battery |

**Requirements**:
- Power saving enabled
- GPS enabled (for position reporting)
- Bluetooth enabled (for companion app)
- CLIENT role (rebroadcasts with backoff)

### Tier 3: Evaluation

| Node | Device | Role | Purpose |
|------|--------|------|---------|
| **EVAL-MC** | Station G2 | MeshCore simple_repeater | Protocol evaluation |

**Requirements**:
- Separate from main Meshtastic mesh
- Dedicated evaluation channel/PSK
- Document performance metrics for ADR review

---

## RF Planning: Southern Maine Terrain

### Terrain Characteristics

- **Lewiston-Auburn**: Androscoggin River valley, relatively flat urban core
- **Bates College**: 109-acre campus, mix of 2-4 story brick buildings
- **Surrounding area**: Rolling hills, deciduous/coniferous mixed forest
- **Elevation range**: 60-180m ASL in target area
- **Challenge**: Dense foliage (seasonal), brick/stone buildings attenuate signal

### Link Budget Calculations (LONG_FAST preset)

| Parameter | Station G2 | T-Deck Plus |
|-----------|-----------|-------------|
| TX power | 30 dBm | 22 dBm |
| Antenna gain | 6 dBi (external) | 2 dBi (stock) |
| EIRP | 36 dBm | 24 dBm |
| Cable/connector loss | -2 dB | -1 dB |
| Effective EIRP | 34 dBm | 23 dBm |
| Receiver sensitivity | -137 dBm (SF11, 250kHz) | -137 dBm |
| **Max path loss** | **171 dB** | **160 dB** |

### Expected Range (conservative estimates)

| Link | Conditions | Expected Range |
|------|-----------|---------------|
| G2 ↔ G2 | LOS, elevated | 15-25 km |
| G2 ↔ G2 | Urban, rooftop | 8-15 km |
| G2 → T-Deck | LOS | 10-15 km |
| G2 → T-Deck | Urban, ground level | 3-8 km |
| T-Deck ↔ T-Deck | Urban | 1-3 km |
| G2 → T-Deck | Through forest | 2-5 km |
| Any → Indoor | 1 brick wall | -10 to -15 dB loss |
| Any → Indoor | 2+ brick walls | -20 to -30 dB loss |

### Recommended Relay Placement

```
                  N
                  │
    ┌─────────────┼─────────────┐
    │             │             │
    │  Auburn     │  Lewiston   │
    │  (future)   │             │
    │      ·      │  ┌──────┐  │
    │             │  │Bates │  │
    │             │  │Campus│  │
    │   RTR-02 ★  │  │RTR-01★│  │
    │  (downtown) │  │GW-01 ★│  │
    │             │  └──────┘  │
    │             │             │
    │     Androscoggin River    │
    │  ════════════════════════ │
    │             │             │
    └─────────────┼─────────────┘
                  │
                  S

    ★ = Infrastructure node (Tier 1)
```

**Phase 1 (Weeks 1-4)**: RTR-01 on campus + GW-01 indoor. Covers campus and ~2 km radius.
**Phase 2 (Weeks 5-6)**: RTR-02 downtown L-A. Extends to downtown corridor.
**Phase 3 (Weeks 7-8)**: Evaluate coverage gaps, add relay nodes as needed.

---

## Channel Configuration

| Channel | Index | Purpose | PSK |
|---------|-------|---------|-----|
| **LA-Mesh** | 0 | Primary community channel | Custom 32-byte (distributed in-person) |
| **LA-Admin** | 1 | Network operator channel | Custom 32-byte (operators only) |
| **LA-Emergency** | 2 | Emergency broadcast | Custom 32-byte (all devices) |

See [la-mesh-default.yaml](../../configs/channels/la-mesh-default.yaml) for configuration template.

**PSK Policy**:
- Generate with `openssl rand -base64 32`
- Distribute at community meetups only (never digital)
- Rotate quarterly or on suspected compromise
- Default PSK (`AQ==`) is NEVER used -- it is publicly known

---

## MQTT Bridge Architecture

```
┌──────────────┐     LoRa     ┌──────────────┐     Serial    ┌──────────────┐
│  Mesh Nodes  │ ─────────── │  MeshAdv-Mini │ ──────────── │  Raspberry   │
│  (T-Decks,   │              │  (SX1262 HAT) │              │  Pi 4        │
│   G2 routers)│              │               │              │              │
└──────────────┘              └──────────────┘              └──────┬───────┘
                                                                    │
                                           ┌────────────────────────┤
                                           │                        │
                                    ┌──────┴───────┐        ┌──────┴───────┐
                                    │  meshtasticd  │        │  Bridge      │
                                    │  (Linux-native│        │  Scripts     │
                                    │   Meshtastic) │        │  (SMS/Email) │
                                    └──────┬───────┘        └──────┬───────┘
                                           │                        │
                                    ┌──────┴───────┐        ┌──────┴───────┐
                                    │  MQTT Broker  │        │  SMS Gateway │
                                    │  (Mosquitto)  │        │  (TBD)       │
                                    └──────────────┘        └──────────────┘
```

**Bridge Components** (on Raspberry Pi):
1. **meshtasticd**: Linux-native Meshtastic daemon, connects to MeshAdv-Mini via SPI/UART
2. **MQTT client**: Publishes mesh messages to MQTT broker, subscribes for inbound
3. **SMS bridge**: Watches MQTT for messages tagged with phone numbers, forwards via SMS gateway API (provider TBD)
4. **Email bridge**: Watches MQTT for messages tagged with email addresses, forwards via SMTP

---

## Monitoring and Health

### Metrics to Track

| Metric | Source | Frequency |
|--------|--------|-----------|
| Node online status | MQTT nodeinfo messages | Real-time |
| Battery levels | Telemetry channel | Every 15 min |
| Airtime usage | Device telemetry | Every 15 min |
| SNR per link | Position/telemetry packets | Per packet |
| Hop count | Traceroute | On demand |
| Message delivery rate | MQTT logs | Aggregated daily |
| Channel utilization | Device API | Every 5 min |

### Health Check Commands

```bash
# Check all visible nodes
meshtastic --nodes

# Run traceroute to specific node
meshtastic --traceroute '!aabbccdd'

# Get device telemetry
meshtastic --info

# Export full config for backup
meshtastic --export-config > backup-$(date +%Y%m%d).yaml
```

---

## Failure Modes and Mitigation

| Failure | Impact | Mitigation |
|---------|--------|------------|
| Gateway power loss | No SMS/email bridge | UPS on Pi, mesh continues P2P |
| Router power loss | Reduced coverage area | Battery backup, solar option |
| PSK compromise | Messages readable | Rotate PSK, re-key all devices |
| Firmware bug | Node offline | Keep spare devices, test updates on eval node first |
| RF interference | Reduced range | Multiple routers provide redundant paths |
| Internet outage | No MQTT bridge | Mesh operates independently, messages queue |
