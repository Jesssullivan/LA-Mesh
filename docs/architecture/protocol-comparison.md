# Protocol Comparison: Meshtastic vs MeshCore

**Date**: 2026-02-11
**Purpose**: Technical comparison for LA-Mesh firmware decisions
**See also**: [ADR-001](adr-001-firmware-choice.md)

---

## Overview

Both Meshtastic and MeshCore are open-source LoRa mesh networking firmwares targeting ESP32 and nRF52-based devices. They are **completely incompatible** -- a Meshtastic device cannot communicate with a MeshCore device. Third-party bridges (AMMB) can provide limited interop.

---

## Protocol Architecture

### Meshtastic

| Layer | Implementation |
|-------|---------------|
| **Physical** | LoRa modulation (SX1262/SX1276/SX1280/LR11xx), configurable modem presets |
| **Link** | Time-slotted ALOHA, duty-cycle-aware |
| **Network** | Modified flooding with managed flood algorithm, hop limits (1-7, default 3) |
| **Transport** | Protobufs over mesh, reliable delivery for DMs, best-effort for broadcast |
| **Encryption** | AES-256-CTR (channel), X25519 + AES-256-CCM (DM PKC) |
| **Application** | Text, position, telemetry, traceroute, range test, remote admin |

- **Routing**: Managed flooding -- all nodes rebroadcast unless they've already seen the packet or hop limit is exceeded
- **Device roles** control rebroadcast behavior:
  - `ROUTER` / `ROUTER_CLIENT` -- always rebroadcast, higher airtime allowance
  - `CLIENT` -- rebroadcast with backoff
  - `CLIENT_MUTE` -- never rebroadcast
  - `REPEATER` -- rebroadcast only, no display/BLE
- **Node limit**: 80-100 per channel before congestion becomes problematic
- **Airtime budget**: ~10% duty cycle target (FCC Part 15 allows 100% at 915 MHz ISM)

### MeshCore

| Layer | Implementation |
|-------|---------------|
| **Physical** | LoRa modulation (SX1262/SX1276), fixed presets |
| **Link** | Carrier-sense with random backoff |
| **Network** | **Hybrid flood-then-direct routing** (infrastructure-aware) |
| **Transport** | Custom binary protocol, store-and-forward via room servers |
| **Encryption** | Ed25519 signing, ECDH key exchange, AES-128-ECB (ChaChaPoly AEAD in progress) |
| **Application** | Text, position, repeater management, BBS/room server |

- **Routing**: Initial messages flood through repeaters. Once a path is discovered, subsequent messages use **direct routing** through known repeaters -- significantly reducing airtime on larger networks
- **Node roles**:
  - `companion_radio` -- end-user device connecting to phone via BLE
  - `simple_repeater` -- infrastructure relay (mesh backbone)
  - `simple_room_server` -- BBS-style message store-and-forward
- **Key insight**: Clients never repeat/rebroadcast. Only infrastructure nodes relay traffic. This is fundamentally different from Meshtastic's flood model.
- **Scalability**: Better theoretical scaling due to directed routing after path discovery

---

## Encryption Comparison

| Feature | Meshtastic | MeshCore |
|---------|-----------|----------|
| **Channel encryption** | AES-256-CTR | AES-128-ECB |
| **Key size** | 256-bit | 128-bit |
| **Block mode** | CTR (stream-like, no padding) | ECB (deterministic, pattern-leaking) |
| **DM encryption** | X25519 ECDH + AES-256-CCM (PKC) | Ed25519 + ECDH + AES-128-ECB |
| **Forward secrecy** | Per-session with PKC | Not yet |
| **Key distribution** | Pre-shared (channel), auto (PKC) | Pre-shared + Ed25519 identity |
| **Upcoming** | Stable | ChaChaPoly AEAD replacing ECB |

**Assessment**: Meshtastic has stronger encryption today. MeshCore's ECB mode is a known weakness (identical plaintext blocks produce identical ciphertext), but the ChaChaPoly migration is in progress.

---

## MQTT and Bridge Capabilities

| Feature | Meshtastic | MeshCore |
|---------|-----------|----------|
| **MQTT bridge** | Built-in (native module) | Third-party only |
| **JSON output** | Native JSON MQTT option | Via external tools |
| **Map reporting** | Built-in (meshmap) | Via MeshCore map API |
| **Serial API** | Protobuf serial, Python CLI | Python + JS libraries |
| **HTTP API** | REST API on device | Limited |
| **SMS bridge** | Via meshtasticd + external scripts | Via room server API |
| **Email bridge** | Via meshtasticd + external scripts | Via room server API |

**For LA-Mesh**: The MeshAdv-Mini gateway requires meshtasticd (Linux-native Meshtastic). MQTT bridge is critical for SMS/email gateway functionality. Meshtastic's native MQTT support is a significant advantage.

---

## Device Support Matrix

| Device | Meshtastic | MeshCore |
|--------|-----------|----------|
| Station G2 | Full support | Full support |
| T-Deck Plus | Full support | Full support |
| T-Deck Pro (e-ink) | Full support (BaseUI) | Supported |
| RAK WisBlock (nRF52) | Full support | Limited variants |
| Heltec V3 | Full support | Full support |
| LILYGO T-Beam | Full support | Full support |
| MeshAdv-Mini (Pi HAT) | Via meshtasticd | Not supported |
| ESP32 generic | Full support | Limited |

**Dual-boot**: T-Deck Plus and T-Deck Pro support M5Stack Launcher for dual-booting Meshtastic and MeshCore on the same device.

---

## Modem Presets (915 MHz ISM)

### Meshtastic Presets

| Preset | Bandwidth | SF | CR | Data Rate | Range | Link Budget |
|--------|-----------|----|----|-----------|-------|-------------|
| SHORT_FAST | 250 kHz | 7 | 4/5 | 6.8 kbps | ~3 km | 137 dB |
| SHORT_SLOW | 250 kHz | 8 | 4/5 | 3.9 kbps | ~5 km | 140 dB |
| MEDIUM_FAST | 250 kHz | 9 | 4/5 | 2.2 kbps | ~8 km | 143 dB |
| MEDIUM_SLOW | 250 kHz | 10 | 4/5 | 1.2 kbps | ~12 km | 146 dB |
| **LONG_FAST** | **250 kHz** | **11** | **4/5** | **0.67 kbps** | **~20 km** | **149 dB** |
| LONG_MODERATE | 125 kHz | 11 | 4/8 | 0.34 kbps | ~30 km | 152 dB |
| LONG_SLOW | 125 kHz | 12 | 4/8 | 0.18 kbps | ~40 km | 155 dB |
| VERY_LONG_SLOW | 62.5 kHz | 12 | 4/8 | 0.09 kbps | ~50+ km | 158 dB |

**LA-Mesh default**: `LONG_FAST` -- best balance of range and throughput for Southern Maine terrain. Station G2 at 30 dBm TX provides ~153 dB link budget with this preset.

### MeshCore Presets

MeshCore uses fewer, fixed presets optimized for its routing protocol. The default is comparable to Meshtastic's LONG_FAST.

---

## Network Scaling Characteristics

### Meshtastic Flood Model

```
Message → All nodes rebroadcast → Exponential airtime growth
                                  ↓
                          ~80-100 nodes before congestion
                          Mitigated by: hop limits, CLIENT_MUTE roles
```

- **Pros**: Simple, reliable delivery, no infrastructure required
- **Cons**: Airtime grows with node count, channel congestion, broadcast storms possible
- **Mitigation**: Use CLIENT_MUTE for most devices, ROUTER only on infrastructure nodes, careful hop limit tuning

### MeshCore Directed Model

```
Message → Flood to discover path → Direct route via repeaters only
                                    ↓
                            Airtime stabilizes after path discovery
                            Better theoretical scaling
```

- **Pros**: Efficient at scale, reduced airtime after path discovery, clients don't relay
- **Cons**: Requires infrastructure repeaters, less resilient to topology changes, newer/less tested

---

## Community and Ecosystem

| Metric | Meshtastic | MeshCore |
|--------|-----------|----------|
| **Age** | 4+ years (2020) | ~18 months (mid-2024) |
| **GitHub stars** | 4,700+ | 1,957+ |
| **Active map nodes** | 42,000+ | 16,000+ |
| **Firmware releases** | Stable + Beta tracks | Single track |
| **Current version** | v2.7.15 beta (≈stable) | v1.12.0 |
| **Companion apps** | Android, iOS, Web, CLI | Android, iOS, Web, Desktop |
| **Python API** | Mature, well-documented | Functional, growing |
| **Documentation** | Extensive official docs | Improving |

---

## Security Advisories

### CVE-2025-52464 (Meshtastic) -- CRITICAL

- **CVSSv4**: 9.5
- **Issue**: Duplicate cryptographic keys from vendor image cloning
- **Affected**: Firmware < v2.7.15
- **Fix**: Update to v2.7.15+ (forces key regeneration)
- **LA-Mesh policy**: ALL devices MUST run v2.7.15 or later

### MeshCore Security Notes

- AES-128-ECB mode is cryptographically weak (pattern leaking)
- ChaChaPoly AEAD migration is in progress but not yet shipped
- No CVE tracking (smaller project, less formal security process)

---

## Decision Matrix for LA-Mesh

| Criterion | Weight | Meshtastic | MeshCore | Notes |
|-----------|--------|-----------|----------|-------|
| Encryption strength | High | 5/5 | 3/5 | AES-256-CTR vs AES-128-ECB |
| MQTT bridge (native) | High | 5/5 | 1/5 | Critical for SMS/email gateway |
| Community resources | Medium | 5/5 | 3/5 | Documentation, troubleshooting |
| Network scaling | Medium | 3/5 | 5/5 | MeshCore better at scale |
| Device support | Medium | 5/5 | 4/5 | Meshtastic slightly broader |
| meshtasticd (Pi HAT) | High | 5/5 | 0/5 | MeshAdv-Mini requires this |
| Dual-boot capability | Low | 4/5 | 4/5 | Both support M5Stack Launcher |

**Result**: Meshtastic-primary (see [ADR-001](adr-001-firmware-choice.md))

---

## Bridge: AMMB (Akita-Meshtastic-Meshcore-Bridge)

For future interop between ecosystems:

- **Project**: AMMB (third-party bridge)
- **Function**: Relays messages between Meshtastic and MeshCore networks
- **Requirements**: Dedicated device per protocol (one Meshtastic node + one MeshCore node)
- **Status**: Functional but early-stage
- **LA-Mesh plan**: Evaluate when MeshCore evaluation node is deployed (Week 4-5)
