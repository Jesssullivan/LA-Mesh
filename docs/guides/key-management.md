# Key Management Guide

**Audience**: LA-Mesh network operators and key custodians
**See also**: [ADR-004](../architecture/adr-004-encryption-scheme.md), [Encryption Design](../architecture/encryption-design.md)

---

## Key Types

| Key | Type | Stored Where | Rotated |
|-----|------|-------------|---------|
| Channel PSK (×3) | Symmetric (AES-256) | Operator's encrypted storage | Quarterly |
| Device PKC key pair | Asymmetric (X25519) | On-device only | On firmware update |
| MQTT credentials | Username/password | .env file on Pi (gitignored) | On compromise |
| SMS gateway/SMTP API keys | API token | .env file on Pi (gitignored) | On compromise |

---

## PSK Lifecycle

### Generate

```bash
# Use a trusted, air-gapped machine if possible
openssl rand -base64 32
```

This produces a 256-bit random key encoded as base64, e.g.:
```
K7xR2p4mN8vQwY3jH6fL0tBuI9sDcE5gA1rO7kZ4hXs=
```

Generate one unique PSK for each channel (primary, admin, emergency).

### Store (Operator Only)

- Store PSKs in an encrypted password manager (KeePassXC recommended)
- Label entries clearly: "LA-Mesh Primary PSK (Q1 2026)"
- Include the channel index and rotation date
- **NEVER** store PSKs in:
  - Git repositories
  - Plain text files
  - Email or chat messages
  - Cloud note apps
  - Shared documents

#### KeePassXC Entry Structure

Organize entries under a dedicated **LA-Mesh** group:

| Entry Title | Username Field | Password Field | Notes |
|------------|---------------|----------------|-------|
| `PSK-Primary` | `LAMESH_PSK_PRIMARY` | base64 PSK value | Channel 0, rotation date |
| `PSK-Admin` | `LAMESH_PSK_ADMIN` | base64 PSK value | Channel 1, rotation date |
| `PSK-Emergency` | `LAMESH_PSK_EMERGENCY` | base64 PSK value | Channel 2, rotation date |

The Username field stores the environment variable name so operators can export
directly:

```bash
# Export from KeePassXC CLI
export LAMESH_PSK_PRIMARY=$(keepassxc-cli show -sa password /path/to/db.kdbx "LA-Mesh/PSK-Primary")
export LAMESH_PSK_ADMIN=$(keepassxc-cli show -sa password /path/to/db.kdbx "LA-Mesh/PSK-Admin")
export LAMESH_PSK_EMERGENCY=$(keepassxc-cli show -sa password /path/to/db.kdbx "LA-Mesh/PSK-Emergency")
```

Include in each entry's Notes field:
- Device serial numbers provisioned with this key
- Last rotation date
- Channel index number

### Distribute

PSKs are distributed exclusively in-person:

1. Display PSK as QR code on a laptop/phone screen
2. Recipient scans QR and applies directly to device
3. Or: read aloud while recipient types into meshtastic CLI
4. Or: show on screen while recipient copies manually

**NEVER distribute PSKs via**:
- Text message (SMS, Signal, WhatsApp)
- Email
- Printed handouts (unless immediately destroyed)
- Phone call
- Any digital channel

### Apply

```bash
# From environment variable (recommended)
export LAMESH_PSK_PRIMARY="K7xR2p4mN8vQwY3jH6fL0tBuI9sDcE5gA1rO7kZ4hXs="
./tools/configure/apply-channels.sh /dev/ttyUSB0

# Or directly via meshtastic CLI
meshtastic --ch-set psk "K7xR2p4mN8vQwY3jH6fL0tBuI9sDcE5gA1rO7kZ4hXs=" --ch-index 0
```

### Rotate

**Scheduled**: Quarterly (January, April, July, October)

1. Generate new PSKs (all three channels)
2. Update infrastructure nodes first (RTR-01, RTR-02, GW-01)
3. Announce rotation at community meetup
4. Apply new PSKs to all client devices in-person
5. Verify all devices communicate on new PSKs
6. Record rotation date in operator log (not the PSK)

**Emergency**: On suspected compromise

1. Generate new PSK for affected channel(s)
2. Apply to infrastructure nodes immediately
3. Notify all operators via admin channel (if not compromised)
4. Schedule emergency meetup for client device updates
5. Investigate source of compromise

### Retire

When a PSK is rotated out:
1. Remove from password manager after all devices updated
2. Record retirement date in operator log
3. Old PSK provides zero value once no devices use it

---

## Operator Roles

### Key Custodian (Primary)

- Generates all PSKs
- Maintains encrypted PSK storage
- Leads rotation events
- Performs emergency rotations
- Maintains operator log

### Key Custodian (Backup)

- Has independent copy of current PSKs
- Can perform emergency rotation if primary is unavailable
- Stored in separate encrypted password manager
- Verified quarterly (can primary and backup both decrypt?)

### Community Member

- Receives PSKs at meetups
- Does NOT need to know or store the PSK after device configuration
- Reports suspected compromise to operators
- Attends rotation events to update device

---

## Operator Log Template

Keep this log in your encrypted password manager or secure notes. Never store PSK values in the log.

```
2026-02-15: Initial PSK set for all 3 channels. Applied to RTR-01, RTR-02, GW-01.
2026-02-20: Community meetup. Applied PSKs to MOB-01 through MOB-05.
2026-04-01: Q2 rotation. New PSKs generated. Infrastructure updated.
2026-04-05: Community meetup. All client devices updated.
```
