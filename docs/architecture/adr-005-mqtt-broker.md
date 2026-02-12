# ADR-005: MQTT Broker Choice

**Status**: Proposed
**Date**: 2026-02-11

## Context

The LA-Mesh gateway node needs an MQTT broker to bridge mesh messages to SMS/email services and monitoring tools.

## Options Evaluated

| Option | Pros | Cons |
|--------|------|------|
| **A: Self-hosted Mosquitto on Pi** | Full control, no external dependency, free, low latency | Single point of failure, maintenance burden |
| B: Meshtastic public MQTT | Zero setup, community map integration | No control, public data, privacy concerns |
| C: Cloud MQTT (HiveMQ/CloudMQTT) | Managed, reliable, redundant | Cost, external dependency, latency |

## Decision

**Option A: Self-hosted Mosquitto on the Raspberry Pi gateway**.

### Rationale

1. The Pi gateway already runs meshtasticd -- adding Mosquitto is minimal overhead
2. No external dependency means the bridge works even if internet is down (local MQTT still functions)
3. Full control over topics, access, and retention
4. No cost beyond the existing Pi hardware
5. LA-Mesh data stays local by default -- privacy-preserving

### Configuration

- Mosquitto runs on Pi at `localhost:1883`
- No external access by default (bind to 127.0.0.1)
- Optional TLS listener on port 8883 if remote monitoring is needed
- Bridge scripts (SMS, email) connect to local Mosquitto
- Authentication enabled (username/password for bridge scripts)

### Future Upgrade Path

If the network grows beyond a single Pi's capacity:
1. Move Mosquitto to a dedicated server
2. Add MQTT bridge to cloud for remote monitoring
3. Implement topic-based access control for multi-user scenarios

## Consequences

- Gateway Pi is the single point of failure for all bridge services
- UPS backup essential for the Pi
- Monitoring tools must run on or be accessible from the Pi
- No remote monitoring without additional configuration (VPN, SSH tunnel, or TLS listener)
