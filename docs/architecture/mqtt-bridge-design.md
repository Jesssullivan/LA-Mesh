# MQTT Bridge Design

**Status**: Planned
**See also**: [ADR-005](adr-005-mqtt-broker.md), [MQTT Config](../../bridges/mqtt/mqtt-bridge-config.yaml)

---

## Architecture

```
Mesh Nodes ──(LoRa)──→ MeshAdv-Mini ──(SPI)──→ Pi ──→ meshtasticd ──→ Mosquitto
                                                                          │
                                                          ┌───────────────┼───────┐
                                                          │               │       │
                                                     SMS Bridge    Email Bridge  Monitor
                                                     (subscribe)   (subscribe)  (subscribe)
```

## Topic Structure

meshtasticd publishes to standard Meshtastic MQTT topics:

| Topic Pattern | Content |
|--------------|---------|
| `msh/US/2/json/LongFast/+` | All JSON-encoded messages |
| `msh/US/2/json/LongFast/!<nodeid>` | Per-node messages |

LA-Mesh bridge topics (internal):

| Topic | Publisher | Subscriber |
|-------|-----------|-----------|
| `lamesh/bridge/sms/outbound` | SMS bridge | meshtasticd (via MQTT-to-mesh) |
| `lamesh/bridge/email/outbound` | Email bridge | meshtasticd |
| `lamesh/metrics` | All bridges | Monitoring |

## Mosquitto Configuration

- Bind to localhost only (127.0.0.1:1883)
- Authentication enabled (username/password)
- No external access by default
- Persistence enabled for message queuing during bridge restarts
- Max message size: 1KB (LoRa payload limit)

## Monitoring

Three monitoring tools subscribe to MQTT:

1. **mqtt-listener.py**: Real-time colored console output
2. **mqtt-to-csv.py**: Log messages, positions, telemetry to CSV
3. **node-status.py**: Track online/offline status with timeout detection

## Resilience

- meshtasticd reconnects to Mosquitto automatically
- Bridge scripts use `Restart=always` in systemd
- Mosquitto persistence ensures messages survive restarts
- If internet fails, local MQTT still functions (SMS/email bridges wait for reconnect)
