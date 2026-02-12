# LA-Mesh Channel Plan

**See also**: [ADR-004](adr-004-encryption-scheme.md), [Channel Config](../../configs/channels/la-mesh-default.yaml)

---

## Channel Architecture

| Index | Name | Role | Access | Purpose |
|-------|------|------|--------|---------|
| 0 | **LA-Mesh** | PRIMARY | All members | Community messaging, position sharing |
| 1 | **LA-Admin** | SECONDARY | Operators only | Network management, diagnostics |
| 2 | **LA-Emergency** | SECONDARY | All members | Emergency broadcast (high priority) |
| 3-7 | Reserved | -- | -- | Available for events, classes, experiments |

---

## Channel 0: LA-Mesh (Primary)

- **Purpose**: General community communication
- **Encryption**: AES-256-CTR with custom 32-byte PSK
- **Uplink/Downlink**: Disabled (no MQTT bridge for general messages by default)
- **Who has access**: All LA-Mesh community members
- **Message types**: Text, position, telemetry

## Channel 1: LA-Admin

- **Purpose**: Network operator communications and remote device management
- **Encryption**: AES-256-CTR with separate custom PSK
- **Uplink/Downlink**: Disabled
- **Who has access**: Network operators and maintainers only
- **Message types**: Admin commands, diagnostics, firmware update coordination
- **Note**: Meshtastic remote admin feature uses the admin channel

## Channel 2: LA-Emergency

- **Purpose**: Emergency broadcast for disaster communications
- **Encryption**: AES-256-CTR with separate custom PSK
- **Uplink/Downlink**: Disabled
- **Who has access**: All LA-Mesh members
- **Message types**: Emergency alerts, shelter locations, resource coordination
- **Policy**: Only for genuine emergencies. False alarms undermine trust.

---

## PSK Management

### Generation

```bash
# Generate a cryptographically secure 32-byte PSK
openssl rand -base64 32
```

Generate one PSK per channel. All three channels must have different PSKs.

### Distribution

PSKs are distributed **in-person only**:
- At community meetups
- Via QR code displayed on a screen (not sent digitally)
- Written on paper that is immediately destroyed after device configuration

### Rotation Schedule

| Trigger | Action |
|---------|--------|
| Quarterly (Jan, Apr, Jul, Oct) | Scheduled rotation of all channel PSKs |
| Suspected compromise | Immediate rotation of affected channel(s) |
| Device theft | Rotate all channels, wipe stolen device via remote admin |
| Member departure (operator) | Rotate LA-Admin channel PSK |

### Applying Channels

```bash
# Set environment variables (never hardcode)
export LAMESH_PSK_PRIMARY="<base64>"
export LAMESH_PSK_ADMIN="<base64>"
export LAMESH_PSK_EMERGENCY="<base64>"

# Apply to device
./tools/configure/apply-channels.sh /dev/ttyUSB0
```
