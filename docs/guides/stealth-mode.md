# Stealth Mode: Minimizing RF Footprint

This guide explains how to configure a Meshtastic device for minimal RF
visibility on the LA-Mesh network. This is appropriate for users who want to
participate in the mesh with enhanced privacy.

---

## What is CLIENT_HIDDEN?

Meshtastic offers several device roles that control how a node participates in
the mesh. `CLIENT_HIDDEN` is the most privacy-oriented:

| Role | Appears in Node List | Broadcasts NodeInfo | Rebroadcasts Others | Sends Position |
|------|---------------------|--------------------|--------------------|----------------|
| ROUTER | Yes | Yes | Yes (all) | Yes |
| CLIENT | Yes | Yes | Yes | Yes |
| CLIENT_MUTE | Yes | Yes | No | Yes |
| **CLIENT_HIDDEN** | **No** | **No** | **No** | **No** (unless enabled) |

A CLIENT_HIDDEN node:

- Does **not** appear in other nodes' device lists
- Does **not** broadcast its NodeInfo (name, hardware, firmware version)
- Does **not** rebroadcast other nodes' messages
- Can still **send and receive** messages on all configured channels
- Can still **send and receive** direct messages (DMs) via PKC
- Has the **smallest RF footprint** of any active role

---

## When to Use Stealth Mode

- You want to participate in the mesh but minimize your visibility
- You are in an area where RF direction-finding is a concern
- You want to receive mesh traffic without contributing to the routing topology
- You prefer not to share your position or device information

### When NOT to Use Stealth Mode

- You are operating a relay/router node (the network needs ROUTER nodes to function)
- You want to help extend mesh coverage (CLIENT_HIDDEN does not rebroadcast)
- You are the only node in an area (no one will be able to reach you via multi-hop)

---

## Configuration

### Via Meshtastic CLI

```bash
# Set device role to CLIENT_HIDDEN
meshtastic --set device.role CLIENT_HIDDEN

# Disable position sharing
meshtastic --set position.gps_mode DISABLED
meshtastic --set position.fixed_position false
meshtastic --set position.position_broadcast_secs 0

# Disable NodeInfo broadcast interval (0 = never)
meshtastic --set device.node_info_broadcast_secs 0

# Optional: Disable Bluetooth when not pairing
meshtastic --set bluetooth.enabled false
```

### Via LA-Mesh Profile

If you want a pre-configured stealth profile, you can create a custom profile
based on the T-Deck client profile:

```yaml
# configs/profiles/tdeck-stealth-client.yaml
owner: "Anonymous"
owner_short: "ANON"

device:
  role: CLIENT_HIDDEN
  node_info_broadcast_secs: 0

position:
  gps_mode: DISABLED
  position_broadcast_secs: 0
  fixed_position: false

lora:
  region: US
  modem_preset: LONG_FAST
  hop_limit: 5
  tx_power: 17

bluetooth:
  enabled: true
  mode: FIXED_PIN
  fixed_pin: 123456

power:
  is_power_saving: true
  ls_secs: 300
```

Apply with:
```bash
meshtastic --configure configs/profiles/tdeck-stealth-client.yaml
```

---

## PKC-Only Communication

For maximum privacy, combine CLIENT_HIDDEN with PKC (Public Key Cryptography)
for direct messages only:

1. **Enable PKC**: PKC is enabled by default on Meshtastic 2.5+
2. **Exchange public keys in person**: At a meetup, pair with trusted contacts
3. **Use DMs exclusively**: Send messages only via direct message, not channel
4. **Channel messages**: Still received (you have the PSK) but consider not
   sending on shared channels if minimizing your footprint

### DM vs Channel Privacy

| Method | Who Can Read | RF Visibility |
|--------|-------------|--------------|
| Channel message | Anyone with PSK | All nodes see your transmission |
| Direct message (PKC) | Only sender + recipient | All nodes see encrypted packet, only recipient can decrypt |
| CLIENT_HIDDEN + DM only | Only sender + recipient | Minimal RF footprint, packet still relayed but sender not identified in node lists |

---

## Limitations

### What Stealth Mode Does NOT Protect Against

1. **RF direction-finding**: Any transmission can be located with appropriate
   equipment (SDR + directional antenna). CLIENT_HIDDEN reduces how often you
   transmit but does not eliminate transmissions.

2. **Traffic analysis**: An observer can see encrypted packets even if they
   cannot decrypt them or identify the sender by name.

3. **Physical compromise**: If your device is seized, all keys and message
   history are accessible (keys stored in plaintext NVS).

4. **Network-level identification**: Your LoRa radio has a unique physical
   layer signature. Sophisticated adversaries may fingerprint individual radios.

5. **Packet correlation**: If you are the only CLIENT_HIDDEN node and you send
   a DM, an observer may correlate the timing of your transmission with the
   recipient's response.

### Tradeoffs

- CLIENT_HIDDEN nodes **reduce mesh coverage** -- they don't relay messages for
  others. If too many nodes use CLIENT_HIDDEN, the mesh becomes less resilient.
- You still need the channel PSK to receive channel messages (shared at meetups).
- GPS disable means your position won't appear on the mesh map -- useful for
  privacy but means others can't see your coverage area.

---

## Verification

After configuring stealth mode, verify your settings:

```bash
meshtastic --info
```

Check for:
- `Role: CLIENT_HIDDEN`
- `GPS Mode: DISABLED` (or your preference)
- `Position Broadcast: 0` (never)
- `NodeInfo Broadcast: 0` (never)

Ask a nearby mesh operator to check their node list -- your device should **not**
appear.
