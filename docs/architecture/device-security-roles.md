# Device Security Roles

This document maps LA-Mesh device types to their security roles and
operational considerations. Each device has different physical security
requirements, attack surface, and privacy implications.

---

## Role Matrix

| Device | Firmware Role | Physical Security | Key Exposure Risk | Network Role |
|--------|--------------|-------------------|-------------------|-------------|
| Station G2 | ROUTER | High (rooftop/tower) | Medium (physical access hard) | Infrastructure relay |
| T-Deck Plus | CLIENT | Low (carried by user) | High (can be lost/stolen) | Personal messaging |
| T-Deck Pro (e-ink) | CLIENT | Low (carried by user) | High (can be lost/stolen) | Personal messaging |
| MeshAdv-Mini | ROUTER_CLIENT | Medium (indoors, wired) | Medium (behind locked door) | Gateway bridge |
| HackRF H4M | N/A (receive-only) | Low (carried by user) | None (no mesh keys) | Education/monitoring |

---

## Infrastructure Nodes (Station G2)

**Role**: `ROUTER` -- always-on relay, highest TX power

### Security Profile

- **Physical security is critical**: These nodes hold the channel PSK and relay
  all traffic. A compromised router can record all encrypted traffic passing
  through it.
- **Placement**: Rooftop, tower, or elevated outdoor location in a weatherproof
  enclosure. Physical access should require tools (locked enclosure, elevated
  mounting).
- **Bluetooth**: Disabled (no phone pairing needed)
- **WiFi**: Disabled (no internet connectivity)
- **Position**: Fixed (set once, broadcast periodically)
- **Power**: Always-on, mains powered with battery backup if possible

### Threat Mitigations

- Use tamper-evident enclosure seals
- Document physical location with GPS coordinates
- If a router is physically compromised, rotate channel PSK for all devices
- Consider: A compromised ROUTER can selectively drop/delay messages it relays

---

## Personal Devices (T-Deck Plus / T-Deck Pro)

**Role**: `CLIENT` or `CLIENT_HIDDEN`

### Security Profile

- **Highest loss/theft risk**: Carried daily by community members
- **Contains**: Channel PSK, personal DM keys (X25519), message history
- **Bluetooth**: Enabled (for phone app pairing)
- **GPS**: Enabled (position shared with mesh -- can be disabled)

### Recommended Configuration

For privacy-conscious users, use `CLIENT_HIDDEN`:

- Does not appear in other nodes' node lists
- Does not broadcast NodeInfo
- Does not rebroadcast other nodes' messages
- Minimal RF footprint (harder to direction-find)
- Can still send/receive DMs using PKC

See [Stealth Mode Guide](../guides/stealth-mode.md) for configuration details.

### Threat Mitigations

- Enable PKC (Public Key Cryptography) for DMs -- provides end-to-end encryption
  that even other LA-Mesh members cannot read
- Consider disabling GPS if location privacy is important
- If device is lost/stolen: notify LA-Mesh admin for PSK rotation at next meetup
- Keep firmware updated (security patches)
- Device lock screen is available on T-Deck (protects casual access, not forensic)

### What a Lost Device Exposes

1. Channel PSK (all channels the device was configured for)
2. DM private keys (all historical DM conversations can be decrypted)
3. Message history stored on device
4. GPS position history
5. Node list (other devices seen on the mesh)

**Mitigation**: PSK rotation at next community meetup invalidates the channel
key. DM keys cannot be rotated retroactively (no forward secrecy).

---

## Gateway Nodes (MeshAdv-Mini)

**Role**: `ROUTER_CLIENT` -- bridge between mesh and internet services

### Security Profile

- **Runs on Raspberry Pi**: Full Linux system with meshtasticd
- **Network connected**: Has internet access (for SMS/email bridge, MQTT)
- **Contains**: Channel PSK, MQTT credentials, SMS gateway API keys, bridge config
- **Multiple attack surfaces**: Mesh radio + network + OS

### Threat Mitigations

- Keep behind physical security (indoors, locked room)
- Use firewall rules (ufw/iptables) -- only allow outbound MQTT, SMS API
- Keep Raspberry Pi OS updated
- Use strong MQTT passwords (not defaults)
- Run bridge services as unprivileged user
- Monitor logs: `journalctl -u meshtasticd -u lamesh-sms-bridge`
- If compromised: Rotate channel PSK, MQTT credentials, SMS gateway API keys

### Additional Concerns

- Gateway sees **decrypted** mesh traffic (it must decrypt to bridge to SMS/email)
- MQTT messages may traverse the internet -- use TLS for MQTT connections
- SMS bridge sends plaintext SMS -- messages are not encrypted end-to-end to phone

---

## Education/Monitoring Device (HackRF H4M)

**Role**: Receive-only RF analysis tool

### Security Profile

- **No mesh keys**: HackRF does not participate in the mesh network
- **Passive receiver**: Can observe RF spectrum but does not transmit
- **No key material**: Cannot decrypt mesh traffic (no PSK)
- **Education tool**: Used for spectrum analysis, RF propagation study

### Appropriate Uses

- Spectrum monitoring during community events
- Verifying antenna performance and signal quality
- Teaching RF fundamentals in the SDR / RF workshop
- Detecting interference or unauthorized transmissions

### Restrictions

- Never transmit on mesh frequencies (ISM band regulations still apply)
- PortaPack Mayhem firmware for receive-only analysis
- Keep firmware updated for bug fixes

---

## Key Rotation Procedures

### When to Rotate Channel PSK

| Event | Action | Urgency |
|-------|--------|---------|
| Device lost/stolen | Rotate at next meetup | High |
| Member leaves community | Rotate at next meetup | Medium |
| Routine rotation | Every 3-6 months | Low |
| Router node compromised | Rotate immediately | Critical |
| Gateway node compromised | Rotate immediately + change all bridge creds | Critical |

### Rotation Process

1. Generate new PSK at meetup (in-person only)
2. Update all infrastructure nodes first (routers, gateway)
3. Update client devices at meetup
4. Devices not updated at meetup will lose connectivity (by design)
5. Update encrypted keystores on all operator machines

---

## Summary

The most security-critical nodes are **infrastructure routers** (physical
security) and **gateways** (multiple attack surfaces). Personal devices are the
most likely to be lost/stolen but have the most limited blast radius if
CLIENT_HIDDEN is used. The HackRF has no mesh key material and poses no risk to
the network.
