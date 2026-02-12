# ADR-001: Primary Firmware Choice

**Status**: Proposed
**Date**: 2026-02-11
**Decision**: Meshtastic as primary firmware, MeshCore evaluation on single device

## Context

LA-Mesh must choose between two incompatible LoRa mesh firmware ecosystems:
- **Meshtastic**: Mature, large community, MQTT bridge, AES-256 encryption
- **MeshCore**: Newer, superior routing for infrastructure-backed networks, growing rapidly

These protocols cannot interoperate. A device running one cannot communicate with the other.

## Decision

**Meshtastic-primary** with a single MeshCore evaluation node.

### Rationale

| Factor | Meshtastic | MeshCore |
|--------|-----------|----------|
| Ecosystem maturity | High (4+ years) | Medium (13 months) |
| Community size | Very large | Growing (16K+ map nodes) |
| MQTT bridge | Built-in | Third-party |
| Device support | Universal | 65+ variants |
| Encryption | AES-256-CTR + X25519 PKC | AES-128-ECB (AEAD in progress) |
| Companion apps | Android, iOS, Web, CLI | Android, iOS, Web, Desktop |
| API | Mature Python API | Python + JS libraries |
| T-Deck dual-boot | Supported via M5Stack Launcher | Supported via M5Stack Launcher |

### Key reasons:
1. **MQTT bridge** is critical for SMS/email gateway - Meshtastic has it built-in
2. **Encryption** is stronger (AES-256-CTR vs AES-128-ECB)
3. **Community resources** are more abundant for troubleshooting
4. **AMMB bridge** (Akita-Meshtastic-Meshcore-Bridge) enables future MeshCore interop

## Consequences

- All community devices will run Meshtastic firmware
- One Station G2 will run MeshCore for evaluation
- T-Deck devices can dual-boot via M5Stack Launcher if MeshCore gains traction
- Bridge development targets Meshtastic Python API first
- Re-evaluate MeshCore when network exceeds 100 nodes or when v2 protocol ships
