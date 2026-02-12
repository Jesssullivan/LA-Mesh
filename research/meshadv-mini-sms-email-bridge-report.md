# MeshAdv-Mini + SMS/GPG Email-to-Mesh Bridge: Deep Research Report

**Date**: 2026-02-11
**Project**: LA-Mesh (Southern Maine Community LoRa Mesh Network)
**Scope**: MeshAdv-Mini hardware, SMS bridge, GPG email bridge, API landscape, security architecture

---

## Table of Contents

1. [MeshAdv-Mini Device](#1-meshadv-mini-device)
2. [SMS to Meshtastic Bridge](#2-sms-to-meshtastic-bridge)
3. [GPG Signed/Encrypted Email to Mesh](#3-gpg-signedencrypted-email-to-mesh)
4. [Meshtastic/MeshCore API Landscape](#4-meshtasticmeshcore-api-landscape)
5. [Security Architecture](#5-security-architecture)
6. [Similar Projects](#6-similar-projects)
7. [Implementation Architecture](#7-implementation-architecture)
8. [Sprint Integration Points](#8-sprint-integration-points)

---

## 1. MeshAdv-Mini Device

### What Is It?

The MeshAdv-Mini is a **compact LoRa/GPS Raspberry Pi HAT** designed specifically for the Linux-native Meshtastic daemon (`meshtasticd`). Created by Chris Myers (Frequency Labs), it is a custom PCB approximately half the size of the predecessor MeshAdv Pi Hat, fitting perfectly on Raspberry Pi Zero form factors.

**Repository**: https://github.com/chrismyers2000/MeshAdv-Mini
**Purchase**: https://frequencylabs.etsy.com
**Configuration Tool**: https://github.com/chrismyers2000/Meshtasticd-Configuration-Tool

### Hardware Specifications

| Component | Specification |
|-----------|--------------|
| **LoRa Module** | Ebyte E22-900M22S (SX1262, 915 MHz) or E22-400M22S (SX1268, 400 MHz) |
| **TX Power** | +22 dBm |
| **GPS** | ATGM336H-5NR32 (GPS + BeiDou constellations, PPS output) |
| **Temperature Sensor** | TMP102 (I2C, 0x48, +/-0.5C accuracy) |
| **EEPROM** | HAT+ EEPROM for auto-configuration |
| **Fan Header** | 5V PWM fan (2-wire always-on or 4-pin PWM) |
| **I2C** | Two Qwiic connectors + I2C bus breakout |
| **Form Factor** | Raspberry Pi HAT (40-pin GPIO) |

### GPIO Pin Mapping

```
LoRa Module:  CS=GPIO8, IRQ=GPIO16, BUSY=GPIO20, Reset=GPIO24, RXen=GPIO12
GPS:          TX=GPIO14, RX=GPIO15, Enable=GPIO4, PPS=GPIO17
I2C:          SDA=GPIO2, SCL=GPIO3 (sensor bus); GPIO0/1 (HAT+ EEPROM)
Fan:          PWM=GPIO18
```

### Compatible Raspberry Pi Models

- Pi 2 Model B, Pi 3 (all variants), Pi 4, Pi 400, Pi 5, Pi 500
- Pi Zero, Pi Zero W, Pi Zero 2 W
- NOT compatible: Original Pi 1 Models A/B, Pi Pico (no 40-pin header)

### Firmware: meshtasticd

The MeshAdv-Mini runs **meshtasticd**, the Linux-native implementation of Meshtastic. This is NOT the standard ESP32 Meshtastic firmware -- it runs as a daemon on Raspberry Pi OS (Bookworm). Configuration is via YAML:

```yaml
Lora:
  Module: sx1262  # Ebyte E22-900M22S
  CS: 8
  IRQ: 16
  Busy: 20
  Reset: 24
  RXen: 12
  DIO2_AS_RF_SWITCH: true
  DIO3_TCXO_VOLTAGE: true
GPS:
  SerialPath: /dev/ttyS0   # /dev/ttyAMA0 on Pi 5
I2C:
  I2CDevice: /dev/i2c-1
Logging:
  LogLevel: info
Webserver:
  Port: 443
  RootPath: /usr/share/meshtasticd/web
General:
  MaxNodes: 200
```

### Relationship to Meshtastic/MeshCore

The MeshAdv-Mini is a **Meshtastic device** (via meshtasticd). It does NOT natively run MeshCore firmware. However, since it exposes the full Meshtastic API (serial, TCP, MQTT), it can be bridged to MeshCore networks using the Akita Meshtastic-MeshCore Bridge (AMMB).

### Key Advantages for LA-Mesh

1. **Remote firmware updates** -- no physical access needed (unlike ESP32 nodes)
2. **Full Linux OS** -- can run Python scripts, bridges, gateways directly on the device
3. **MQTT connectivity** -- native internet bridging
4. **PPS-based NTP** -- precise time synchronization
5. **Sensor integration** via I2C/Qwiic ecosystem
6. **POE-powered pole mounting** -- ideal for community infrastructure nodes

**Critical Warning**: Always have an antenna connected when powered on. The SX1262 module can be permanently damaged without an antenna load.

---

## 2. SMS to Meshtastic Bridge

### Existing SMS Gateway Components

No single turnkey "SMS-to-Meshtastic" project exists. The bridge must be composed from two layers:

#### Layer 1: SMS Reception (GSM/LTE Modem)

| Project | Description | URL |
|---------|-------------|-----|
| **sms2mqtt** | SMS <-> MQTT gateway using USB GSM dongle + Gammu | https://github.com/Domochip/sms2mqtt |
| **sms-server** | Rust-based SMS server with HTTP/WebSocket APIs | https://github.com/morgverd/sms-server |
| **smsgateway-gammu** | Python REST API for SMS via Gammu | https://pypi.org/project/smsgateway-gammu/ |
| **Gammu SMS Daemon** | Mature GSM modem toolkit (send/receive/daemon) | https://wammu.eu/gammu/ |
| **python-gammu** | Python bindings for Gammu | `pip install python-gammu` |

**Gammu** is the most mature and widely deployed option. It supports hundreds of GSM modems (see https://wammu.eu/phones/) and can trigger Python scripts on SMS receipt via the `RunOnReceive` directive in `gammu-smsd`.

#### Layer 2: Meshtastic Injection

The Meshtastic Python API (`pip install meshtastic`) provides programmatic message sending:

```python
import meshtastic
import meshtastic.serial_interface

interface = meshtastic.serial_interface.SerialInterface()
interface.sendText("Hello from SMS!")  # Broadcast
interface.sendText("Direct message", destinationId="!abcd1234")  # DM
interface.close()
```

### Recommended Hardware for SMS Gateway

| Component | Product | Price Range |
|-----------|---------|-------------|
| **GSM/LTE HAT** | Waveshare SIM7600G-H 4G HAT | $45-65 |
| **Alternative** | Waveshare SIM800C GSM/GPRS HAT (2G only) | $20-30 |
| **USB Dongle** | Huawei E3372 LTE USB Stick | $25-40 |
| **SIM Card** | Any data/SMS plan (Mint Mobile, Google Fi, etc.) | $5-15/mo |
| **Pi** | Raspberry Pi Zero 2 W or Pi 4 | $15-55 |

The Waveshare SIM7600G-H is the recommended choice: LTE Cat-4, supports SMS/TCP/UDP/HTTP, global band coverage, compatible with Pi 5/4/3/Zero, and has GNSS positioning built in.

### SMS-to-Mesh Architecture

```
[Mobile Phone] --SMS--> [GSM Modem/HAT]
                              |
                        [gammu-smsd]
                              |
                     [Python Bridge Script]
                              |
                    [meshtastic Python API]
                              |
                       [MeshAdv-Mini]
                              |
                     [LoRa Mesh Network]
```

### MQTT as Alternative Bridge Path

The **sms2mqtt** project bridges SMS directly to MQTT topics. Since Meshtastic supports MQTT natively, this creates an alternative path:

```
[SMS] -> [sms2mqtt] -> [MQTT Broker] -> [Meshtastic MQTT Gateway] -> [Mesh]
```

MQTT topic for sending messages to mesh: `msh/US/2/json/mqtt/` with JSON payload:

```json
{
  "from": 1234567890,
  "type": "sendtext",
  "payload": "Hello from SMS via MQTT!"
}
```

**Caveat**: Messages injected via the public Meshtastic MQTT broker have a **zero-hop policy** (they reach only directly-connected gateway nodes, not the wider mesh). Self-hosted MQTT brokers do not have this limitation.

---

## 3. GPG Signed/Encrypted Email to Mesh

### The meshmail Precedent

The **meshmail** project (https://github.com/mertrois/meshmail) is the closest existing implementation of email-over-Meshtastic. Written in Kotlin, it provides:

- **Relay Mode**: Internet-connected node managing IMAP/SMTP
- **Client Mode**: Mesh-only device requesting email fragments
- **Fragmentation Protocol**: Emails converted to protobuf, split into chunks, announced via "message shadows" (sender, subject preview, fingerprint, fragment count)
- **Reassembly**: Clients request individual fragments and reassemble

However, meshmail is alpha-quality (last updated December 2022, 12 stars) and does NOT implement GPG. It uses Meshtastic's native encryption only.

### Python GPG Toolchain

| Library | Purpose | Install |
|---------|---------|---------|
| **python-gnupg** | GPG encrypt/decrypt/sign/verify | `pip install python-gnupg` |
| **gpgmailencrypt** | Email gateway with GPG per-recipient encryption | `pip install gpgmailencrypt` |
| **envelope** | Email parsing + GPG operations in one library | https://github.com/CZ-NIC/envelope |
| **imaplib** | IMAP email retrieval (Python stdlib) | Built-in |
| **smtplib** | SMTP email sending (Python stdlib) | Built-in |

### GPG Operations in Python

```python
import gnupg

gpg = gnupg.GPG(gnupghome='/home/bridge/.gnupg')

# Verify signature
verified = gpg.verify(signed_data)
if verified.trust_level >= verified.TRUST_FULLY:
    print(f"Verified: {verified.username} ({verified.fingerprint})")

# Decrypt
decrypted = gpg.decrypt(encrypted_data, passphrase='bridge_key_passphrase')
if decrypted.ok:
    plaintext = str(decrypted)

# Encrypt for mesh relay (re-encrypt with mesh key if needed)
encrypted = gpg.encrypt(plaintext, recipient_fingerprint)
```

### Message Size Constraints

This is the critical engineering challenge. The numbers:

| Metric | Value |
|--------|-------|
| **LoRa max packet** | 256 bytes |
| **Meshtastic max payload** | 233 bytes (after headers) |
| **MeshCore max text** | 160 bytes |
| **Practical reliable delivery** | ~200 bytes (per community reports) |
| **GPG signature (ED25519)** | 64 bytes |
| **GPG encrypted overhead** | ~100-200 bytes (varies by key size) |
| **Typical email** | 500 - 50,000+ bytes |

**Conclusion**: Even a short GPG-signed email will require multi-packet transmission. GPG encryption/signing MUST happen at the gateway level, NOT over the air. The mesh carries plaintext (protected by Meshtastic's native AES256-CTR channel encryption).

### Compression Strategies

1. **zlib/deflate**: Typically 40-60% compression on text; Python stdlib
2. **LZMA**: Better ratio but slower; good for batch processing
3. **smaz**: Specialized short-string compressor (ideal for SMS-length text)
4. **Custom dictionary compression**: Pre-shared dictionary of common phrases
5. **Header stripping**: Remove email headers, transmit only body text
6. **Subject-only mode**: For alerts, transmit only subject line (~50 chars)

### Chunking/Reassembly Protocol Design

```
Chunk Header (10 bytes):
  [MSG_ID: 4 bytes] [SEQ: 2 bytes] [TOTAL: 2 bytes] [FLAGS: 1 byte] [CRC8: 1 byte]

Available payload per chunk: 233 - 10 = 223 bytes
Practical payload per chunk: ~200 bytes (reliability margin)

Example: 1KB email after compression (~600 bytes)
  -> 3 chunks of 200 bytes each
  -> ~15 seconds total transmission at LongFast settings
```

Reassembly requires:
- Sequence numbering
- Total chunk count
- Message ID for correlation
- CRC or checksum per chunk
- Timeout/retry logic
- ACK mechanism (Meshtastic `want_ack` flag)

### Key Management for Community

| Approach | Pros | Cons |
|----------|------|------|
| **GPG Web of Trust** | Decentralized, established tooling | Complex for non-technical users |
| **Key signing parties** | Community building, physical verification | Requires in-person meetings |
| **Keyserver** | Automated distribution | Requires internet, trust issues |
| **Mesh key distribution** | Works offline | Slow over LoRa, bootstrap problem |
| **QR code key exchange** | Simple UX at meetups | Requires camera/app |
| **Pre-shared USB drives** | Offline, bulk distribution | Physical logistics |

**Recommended**: GPG Web of Trust with QR-code key exchange at community meetings. Gateway node maintains the community keyring. Members submit their public keys via signed email or in-person.

---

## 4. Meshtastic/MeshCore API Landscape

### Meshtastic Python API

**Install**: `pip install meshtastic`
**Documentation**: https://python.meshtastic.org/
**Repository**: https://github.com/meshtastic/python

#### Connection Methods

```python
# Serial (USB)
from meshtastic.serial_interface import SerialInterface
interface = SerialInterface()  # Auto-detect
interface = SerialInterface(devPath='/dev/ttyUSB0')

# TCP (WiFi/Ethernet)
from meshtastic.tcp_interface import TCPInterface
interface = TCPInterface(hostname='meshtastic.local')

# BLE (Bluetooth)
from meshtastic.ble_interface import BLEInterface
interface = BLEInterface(address='AA:BB:CC:DD:EE:FF')
```

#### Event System (Pub/Sub)

```python
from pubsub import pub

# Text messages
pub.subscribe(on_text, "meshtastic.receive.text")

# All packets
pub.subscribe(on_receive, "meshtastic.receive")

# Position updates
pub.subscribe(on_position, "meshtastic.receive.position")

# Connection events
pub.subscribe(on_connect, "meshtastic.connection.established")
pub.subscribe(on_disconnect, "meshtastic.connection.lost")

# Node database changes
pub.subscribe(on_node_update, "meshtastic.node.updated")
```

#### Packet Structure

Received packets are Python dicts:
```python
{
    'decoded': {
        'payload': b'raw_bytes',
        'text': 'decoded text message',
        'portnum': 'TEXT_MESSAGE_APP',
    },
    'from': 1234567890,    # Source node number
    'to': 4294967295,      # BROADCAST_NUM (0xFFFFFFFF)
    'id': 12345,
    'rxTime': 1700000000,
    'rxSnr': 10.5,
    'hopLimit': 3,
}
```

#### Sending Messages

```python
# Broadcast text
interface.sendText("Hello mesh!")

# Direct message
interface.sendText("Private message", destinationId="!abcd1234")

# Binary data
interface.sendData(
    data=b'\x01\x02\x03',
    portNum=256,  # PRIVATE_APP
    destinationId="!abcd1234",
    wantAck=True,
    wantResponse=False
)
```

### Meshtastic Client API (Serial Protocol)

**Frame Format** (Serial/TCP):
```
Byte 0: 0x94 (START1)
Byte 1: 0xc3 (START2)
Byte 2-3: Protobuf length (MSB/LSB)
Byte 4+: Protobuf payload (ToRadio or FromRadio)
Max packet: 512 bytes (corruption detection threshold)
```

Protocol uses Google Protocol Buffers. Core message types defined in https://github.com/meshtastic/protobufs/blob/master/meshtastic/mesh.proto

### Meshtastic MQTT Integration

```
Topic structure: msh/{REGION}/2/{format}/{CHANNEL}/{USERID}
  format: "e" (protobuf) or "json" (JSON)

Downlink (send to mesh): POST to msh/US/2/json/mqtt/
  { "from": nodeId, "type": "sendtext", "payload": "message" }

Uplink (receive from mesh): Subscribe to msh/US/2/json/{channel}/#
```

**Self-hosted MQTT** is strongly recommended for LA-Mesh to avoid the public broker's zero-hop restriction.

### MeshCore Python API

**Install**: `pip install meshcore`
**Repository**: https://github.com/meshcore-dev/meshcore_py
**Protocol Spec**: https://github.com/meshcore-dev/MeshCore/wiki/Companion-Radio-Protocol

#### Connection Methods

```python
from meshcore import create_serial, create_ble, create_tcp

# Serial (USB companion radio)
device = await create_serial('/dev/ttyUSB0', baud=115200)

# BLE (with optional PIN)
device = await create_ble(address='AA:BB:CC:DD:EE:FF', pin='1234')

# TCP
device = await create_tcp(host='192.168.1.100', port=5000)
```

#### Key Commands

```python
await device.send_device_query()      # Handshake
await device.get_contacts()           # List contacts
await device.send_msg(contact, "Hello")  # Send message
await device.send_advert()            # Broadcast advertisement
await device.get_bat()                # Battery level
```

#### Companion Radio Protocol (Binary Framing)

```
USB Frame: [Direction: 1 byte] [Length: 2 bytes LE] [Payload]
  Direction: '>' (0x3E) = outbound (radio->app)
             '<' (0x3C) = inbound  (app->radio)

Key Commands:
  CMD_DEVICE_QUERY (22)    - Initial handshake
  CMD_APP_START (1)        - First request, get self info
  CMD_SEND_TXT_MSG (2)     - Direct text message
  CMD_SEND_CHANNEL_TXT_MSG (3) - Channel broadcast
  CMD_GET_CONTACTS (4)     - Sync contacts
  CMD_SYNC_NEXT_MESSAGE (10) - Retrieve queued messages
  CMD_SEND_BINARY_REQ (50) - Binary request to node

Push Notifications (async):
  0x80 - New advertisement
  0x82 - Message ACK (includes RTT)
  0x83 - Message waiting
  0x84 - Raw data packet
  0x85 - Login success
```

#### MeshCore on Raspberry Pi

The **meshcore-pi** project (https://github.com/brianwiddas/meshcore-pi) implements the full MeshCore protocol in Python for Raspberry Pi, supporting:
- Direct SPI/GPIO connection to SX1262 LoRa modules (Waveshare HAT, HT-RA62)
- ESP-NOW mesh via WiFi monitor mode
- Companion Radio, Room Server, and Repeater roles simultaneously
- Modified ED25519 cryptography

### Meshtastic-MeshCore Bridge (AMMB)

The **Akita Meshtastic-MeshCore Bridge** (https://github.com/AkitaEngineering/Akita-Meshtastic-Meshcore-Bridge) bridges between the two firmware ecosystems:

- Bidirectional message relay
- Supports Serial (direct) and MQTT external transports
- Three serial protocol handlers: `raw_serial`, `companion_radio` (MeshCore binary), `json_newline`
- REST API (FastAPI) at `http://127.0.0.1:8080`
- Async architecture (recommended for production)
- Rate limiting and reconnection logic

---

## 5. Security Architecture

### Meshtastic Native Encryption

| Layer | Algorithm | Details |
|-------|-----------|---------|
| **Channel Encryption** | AES256-CTR | Pre-shared key per channel; default key is publicly known ("AQ==") |
| **DM Encryption (v2.5+)** | x25519 + AES-CCM | Public key cryptography for direct messages |
| **Message Signing (planned)** | ED25519 (XEdDSA) | 64-byte signatures; HAS_XEDDSA_SIGNED bit |
| **Admin Messages (v2.5+)** | Session-based | Unique session IDs prevent replay attacks |

### Known Weaknesses

1. **No Perfect Forward Secrecy**: Compromised keys expose all historical communications
2. **No channel message integrity**: No tamper detection on channel messages
3. **No channel authentication**: Anyone with PSK can impersonate any user
4. **Trust On First Use (TOFU)**: No central key verification for DMs
5. **NodeDB overflow**: 100-node limit; purged nodes can be impersonated
6. **IV predictability**: Relies on sender node number + packet ID
7. **PKC not quantum-resistant**: x25519 vulnerable to quantum attacks (AES256 is resistant)

### GPG Overlay Architecture for LA-Mesh

Since Meshtastic's native encryption has significant limitations, a GPG overlay provides defense-in-depth:

```
Email/SMS Sender
       |
  [GPG Sign + Encrypt]
       |
  [Email/SMS Transport]
       |
  [Gateway Node: GPG Verify + Decrypt]
       |
  [Extract plaintext, validate sender]
       |
  [Meshtastic API: Send to mesh]
       |
  [AES256-CTR channel encryption (native)]
       |
  [LoRa transmission]
```

**Key insight**: GPG protects the **ingress path** (email/SMS to gateway). Meshtastic native encryption protects the **mesh path** (gateway to end nodes). This is a **trust boundary** at the gateway.

### Preventing Relay Abuse

| Threat | Mitigation |
|--------|------------|
| **SMS spam flooding mesh** | Allowlist of authorized phone numbers |
| **Email spam flooding mesh** | GPG signature required; reject unsigned |
| **Message replay** | Timestamp + nonce in GPG-signed messages; reject stale (>5 min) |
| **Gateway impersonation** | Gateway has known GPG fingerprint published to community |
| **Key compromise** | Revocation certificates pre-generated; distributed at key signing |
| **Traffic analysis** | Fixed-interval dummy traffic (optional, consumes airtime) |
| **Physical device theft** | Encrypted filesystem on gateway Pi; remote wipe capability |

### Key Distribution Strategy

```
Phase 1: Bootstrapping
  - Gateway operator generates master GPG key (4096-bit RSA or ED25519)
  - Public key published on LA-Mesh website/GitHub
  - Community members generate personal GPG keys
  - Key exchange at in-person community meetups (QR codes or USB)

Phase 2: Web of Trust
  - Community members sign each other's keys at meetups
  - Gateway maintains curated keyring of verified members
  - Minimum 2 community signatures required for "trusted" status

Phase 3: Operational
  - Incoming email must be signed by a trusted key to relay
  - SMS gateway uses phone number allowlist (simpler trust model)
  - Gateway signs all outbound mesh messages with its key
  - Quarterly key rotation recommended for gateway operational keys
```

---

## 6. Similar Projects

### Bridge/Gateway Projects

| Project | Bridges | URL | Status |
|---------|---------|-----|--------|
| **MMRelay** | Meshtastic <-> Matrix | https://github.com/geoffwhittington/meshtastic-matrix-relay | Active, 165 stars |
| **meshtastic-signal-bridge** | Meshtastic <-> Signal | https://github.com/ccwod/meshtastic-signal-bridge | Active |
| **meshtastic-telegram-gateway** | Meshtastic <-> Telegram | https://github.com/tb0hdan/meshtastic-telegram-gateway | Active |
| **AMMB** | Meshtastic <-> MeshCore | https://github.com/AkitaEngineering/Akita-Meshtastic-Meshcore-Bridge | Active, 93 commits |
| **meshtastic-bridge** (Geoff) | Meshtastic <-> MQTT (encrypted) | https://github.com/geoffwhittington/meshtastic-bridge | Active |
| **meshtastic-bridge** (Jared) | Meshtastic <-> APRS/Prometheus/MQTT | https://github.com/jaredquinn/meshtastic-bridge | Active |
| **Meshtastic IRC Gateway** | Meshtastic <-> IRC | https://github.com/AkitaEngineering/Akita-Meshtastic-IRC-Gateway | Active |
| **meshtastic-bitchat-bridge** | Meshtastic <-> Bitchat | https://github.com/GigaProjects/meshtastic-bitchat-bridge | Active |
| **meshmail** | Email <-> Meshtastic | https://github.com/mertrois/meshmail | Alpha, stale (2022) |

### Key Takeaways from Similar Projects

1. **MMRelay** is the gold standard for bridge architecture -- supports E2EE, multi-meshnet, Docker/K8s deployment, SQLite state management
2. **Signal bridge** demonstrates the trusted-gateway trust model clearly: the bridge operator is a decryption point
3. **Telegram gateway** shows MQTT-based multi-gateway coordination for city-wide coverage
4. **AMMB** proves Meshtastic-MeshCore interop is feasible via companion radio protocol
5. **meshmail** validates the email-over-mesh concept but needs modernization and GPG support
6. **geoffwhittington/meshtastic-bridge** demonstrates PEM-based asymmetric encryption for MQTT relay -- relevant pattern for our GPG architecture

### Commercial Products

No commercial SMS-to-LoRa gateway products were found specifically targeting Meshtastic/MeshCore. The Waveshare SIM7600G-H HAT is the closest commercial hardware component, but software integration remains DIY.

RAKwireless offers the WisMesh MQTT Gateway setup guide for their hardware, which demonstrates the MQTT bridge pattern with commercial hardware.

---

## 7. Implementation Architecture

### Proposed System Architecture

```
                    +-----------------+
                    |   INTERNET      |
                    +-----------------+
                         |     |
              +----------+     +----------+
              |                           |
    +---------v---------+     +-----------v-----------+
    |   EMAIL (IMAP)    |     |    SMS (GSM Modem)    |
    |                   |     |                       |
    | GPG verify/decrypt|     | Phone # allowlist     |
    +--------+----------+     +----------+------------+
             |                           |
             +----------+  +-------------+
                        |  |
              +---------v--v----------+
              |   BRIDGE DAEMON       |
              |   (Python asyncio)    |
              |                       |
              |  - Message validation |
              |  - Rate limiting      |
              |  - Compression        |
              |  - Chunking           |
              |  - Logging/audit      |
              +---------+-------------+
                        |
              +---------v-------------+
              |   MESHTASTIC API      |
              |   (Serial or TCP)     |
              +---------+-------------+
                        |
              +---------v-------------+
              |   MeshAdv-Mini HAT    |
              |   (meshtasticd)       |
              |   SX1262 +22dBm       |
              +---------+-------------+
                        |
              +---------v-------------+
              |   LoRa MESH NETWORK   |
              |   (LA-Mesh nodes)     |
              +--------+--------------+
                       |
              (Optional MeshCore bridge via AMMB)
                       |
              +--------v--------------+
              |   MeshCore Nodes      |
              +-----------------------+
```

### Hardware Bill of Materials (Gateway Node)

| Component | Product | Est. Cost |
|-----------|---------|-----------|
| **SBC** | Raspberry Pi 4 (4GB) or Pi 5 | $55-80 |
| **LoRa HAT** | MeshAdv-Mini (pre-assembled) | ~$45-65 |
| **GSM/LTE HAT** | Waveshare SIM7600G-H 4G HAT | $50-65 |
| **Antenna (LoRa)** | 915 MHz antenna + SMA pigtail | $10-20 |
| **Antenna (LTE)** | LTE antenna (included with HAT) | $0 |
| **SIM Card** | Prepaid data+SMS plan | $5-15/mo |
| **SD Card** | 32GB+ Class 10 | $8-12 |
| **Power** | 5V 3A+ PSU or POE HAT | $10-25 |
| **Enclosure** | Weatherproof box (outdoor) | $15-30 |
| **Total (one-time)** | | **~$200-300** |
| **Total (recurring)** | SIM plan | **~$5-15/mo** |

**Note on HAT stacking**: The MeshAdv-Mini and Waveshare SIM7600G-H cannot both be standard Pi HATs simultaneously (GPIO conflicts). Solutions:
1. Use USB version of the LTE modem instead of HAT
2. Use GPIO multiplexer/extender
3. Connect LTE modem via USB dongle (Huawei E3372)

**Recommended**: Use MeshAdv-Mini as the HAT and connect the LTE modem via USB.

### Software Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **OS** | Raspberry Pi OS (Bookworm) | Base operating system |
| **Meshtastic** | meshtasticd | LoRa mesh daemon |
| **Meshtastic API** | meshtastic Python lib | Programmatic mesh access |
| **SMS** | gammu-smsd + python-gammu | GSM modem control |
| **Email** | imaplib + smtplib (stdlib) | Email retrieval/sending |
| **GPG** | python-gnupg | Signature verification, decryption |
| **Bridge** | Custom Python daemon (asyncio) | Orchestration layer |
| **MQTT** | mosquitto (local) | Internal message bus |
| **Monitoring** | systemd journal + optional Prometheus | Observability |
| **Config** | YAML + environment variables | Configuration management |

### Bridge Daemon Design

```python
# Simplified architecture sketch
import asyncio
from dataclasses import dataclass

@dataclass
class BridgeMessage:
    source: str          # "sms", "email"
    sender: str          # Phone number or email address
    body: str            # Plaintext message body
    gpg_verified: bool   # GPG signature verified
    gpg_fingerprint: str # Signer's fingerprint (if verified)
    timestamp: float     # Unix timestamp
    priority: int        # 0=normal, 1=urgent

class MeshBridge:
    async def run(self):
        await asyncio.gather(
            self.sms_listener(),
            self.email_poller(),
            self.mesh_listener(),      # Mesh -> SMS/Email (bidirectional)
            self.message_processor(),
        )

    async def sms_listener(self):
        """Listen for incoming SMS via gammu-smsd or MQTT"""
        # Validate sender against allowlist
        # Create BridgeMessage
        # Push to processing queue

    async def email_poller(self):
        """Poll IMAP for new GPG-signed/encrypted email"""
        # Fetch new messages
        # Verify GPG signature
        # Decrypt if encrypted
        # Strip headers, extract body
        # Create BridgeMessage (gpg_verified=True)
        # Push to processing queue

    async def message_processor(self):
        """Process queued messages and send to mesh"""
        # Rate limit (max N messages per minute)
        # Compress message body
        # If > 200 bytes: chunk into fragments
        # Send via Meshtastic API with appropriate channel
        # Log to audit trail

    async def mesh_listener(self):
        """Listen for mesh messages destined for SMS/email"""
        # Subscribe to meshtastic.receive.text
        # Parse command prefix (e.g., "SMS:+12075551234:message")
        # Route to appropriate outbound transport
```

### Hosting Considerations

| Option | Pros | Cons |
|--------|------|------|
| **Dedicated Raspberry Pi** | Low power, always-on, co-located with antenna | Single point of failure |
| **Home server** | More resources, existing infrastructure | Antenna placement constraints |
| **Cloud VM + remote Pi** | Reliability, monitoring | Split architecture, latency |
| **Multiple gateway nodes** | Redundancy, coverage | Complexity, coordination |

**Recommended for PoC**: Single dedicated Raspberry Pi 4 with MeshAdv-Mini + USB LTE modem, mounted at a good elevation point with clear line-of-sight.

---

## 8. Sprint Integration Points

### Phase 0: Foundation (Week 1-2)

**Goal**: Basic Meshtastic Python API send/receive working on MeshAdv-Mini

| Task | Description | Go/No-Go Criteria |
|------|-------------|-------------------|
| Assemble MeshAdv-Mini | Solder/connect to Pi, install meshtasticd | meshtasticd running, LoRa region set |
| Install Meshtastic Python | `pip install meshtastic` on Pi | `meshtastic --info` returns device info |
| Send/receive test | Python script sends and receives text | Bidirectional message confirmed on 2+ nodes |
| MQTT setup | Install mosquitto, configure Meshtastic MQTT | Messages visible on MQTT topic |

**PoC Milestone P0**: "Hello World" message sent from Python script to mesh network and received on another node.

**Gap Analysis**:
- No MeshAdv-Mini hardware in hand yet? Order from Etsy or build from schematic
- meshtasticd may have GPIO conflicts if other HATs are used simultaneously
- Pi Zero 2 W may have limited resources for full bridge daemon

---

### Phase 1: SMS Bridge (Week 3-4)

**Goal**: Receive SMS, validate sender, forward to mesh

| Task | Description | Go/No-Go Criteria |
|------|-------------|-------------------|
| GSM modem setup | Connect USB LTE modem, configure gammu-smsd | `gammu identify` succeeds, SMS send/receive works |
| SMS-to-mesh script | Python: gammu callback -> meshtastic send | SMS received on phone -> appears on mesh |
| Mesh-to-SMS script | Meshtastic receive -> gammu send | Mesh message with "SMS:" prefix -> delivered to phone |
| Phone allowlist | Configurable authorized number list | Unauthorized numbers rejected, logged |
| Rate limiting | Max 10 messages/min, 100/hour | Flood test rejected after threshold |

**PoC Milestone P1**: End-to-end SMS <-> mesh messaging with basic access control.

**Go/No-Go Decision Point**: Is SMS latency acceptable? (Expected: 5-15 seconds end-to-end.) Is GSM modem reliable in target deployment location?

**Gap Analysis**:
- Cell coverage at deployment location (rural Maine may have limited LTE)
- SIM card plan must support incoming SMS
- gammu-smsd reliability over weeks of continuous operation
- GPIO pin conflicts between MeshAdv-Mini and any LTE HAT (use USB modem instead)

---

### Phase 2: Email Bridge with GPG (Week 5-8)

**Goal**: Receive GPG-signed email, verify, decrypt, forward to mesh

| Task | Description | Go/No-Go Criteria |
|------|-------------|-------------------|
| GPG keyring setup | Generate gateway key, import community keys | `gpg --list-keys` shows all community members |
| IMAP poller | Python IMAP client polls for new email | New emails detected within 60 seconds |
| GPG verification | python-gnupg verifies signature on incoming mail | Signed emails accepted, unsigned rejected |
| GPG decryption | Decrypt encrypted email body | Encrypted email decrypted to plaintext |
| Message compression | zlib compress email body for mesh | Average 40-60% size reduction |
| Chunking protocol | Fragment messages >200 bytes | Multi-chunk messages reassembled correctly |
| Mesh injection | Forward processed email text to mesh | Email body appears on mesh devices |
| Outbound email | Mesh message -> GPG sign -> SMTP send | Mesh users can send email via gateway |

**PoC Milestone P2**: GPG-signed email sent to gateway address -> verified -> decrypted -> appears on mesh.

**Go/No-Go Decision Point**: Is chunking reliable enough for multi-packet messages? What is the failure rate for 3+ chunk messages? Is GPG key management feasible for community members with varying technical skill?

**Gap Analysis**:
- Email provider may rate-limit IMAP polling
- GPG key management UX is challenging for non-technical users
- Chunking protocol needs extensive testing (packet loss, ordering, timeouts)
- No existing open-source chunking library for Meshtastic -- must be custom
- meshmail (Kotlin) could be referenced but not directly reused (different language)
- Email size variance is enormous -- need hard limits and user guidance

---

### Phase 3: MeshCore Interoperability (Week 9-10)

**Goal**: Bridge Meshtastic mesh to any MeshCore nodes in the community

| Task | Description | Go/No-Go Criteria |
|------|-------------|-------------------|
| AMMB deployment | Install Akita Meshtastic-MeshCore Bridge | AMMB health endpoint returns OK |
| Companion radio setup | Flash MeshCore companion firmware on spare ESP32 | meshcore_py connects and queries device |
| Bidirectional relay | Messages flow Meshtastic <-> MeshCore | Text message traverses both networks |
| REST API integration | AMMB API accessible from bridge daemon | `/api/status` returns metrics |

**PoC Milestone P3**: Message sent from Meshtastic node appears on MeshCore node and vice versa.

**Go/No-Go Decision Point**: Does the community actually have MeshCore nodes? If not, defer this phase entirely. AMMB adds complexity and another failure point.

**Gap Analysis**:
- Requires a dedicated MeshCore companion radio (ESP32 + SX1262)
- AMMB is actively maintained but relatively new (93 commits)
- MeshCore protocol is less mature than Meshtastic
- Potential message format translation issues between ecosystems
- MeshCore max text (160 bytes) is more restrictive than Meshtastic (233 bytes)

---

### Phase 4: Production Hardening (Week 11-14)

**Goal**: Reliable, monitored, maintainable deployment

| Task | Description | Go/No-Go Criteria |
|------|-------------|-------------------|
| systemd services | Bridge daemon, gammu-smsd, meshtasticd as services | Auto-start on boot, auto-restart on crash |
| Logging & audit | Structured logging with rotation | 30 days log retention, searchable |
| Monitoring | Prometheus metrics + alerting | Alert on bridge down, modem failure, disk full |
| Encrypted filesystem | LUKS on SD card data partition | Device theft doesn't expose keys/messages |
| Remote management | SSH + WireGuard VPN | Secure remote access for maintenance |
| Documentation | Ops runbook, community onboarding guide | New member can send first GPG email within 30 min |
| Failover testing | Kill each component, verify recovery | All services recover within 5 minutes |
| Load testing | Sustained 1 msg/min for 24 hours | Zero dropped messages |

**PoC Milestone P4**: 72-hour unattended operation with zero message loss.

**Gap Analysis**:
- SD card reliability for 24/7 operation (consider USB SSD boot)
- Power failure recovery (UPS recommended for critical deployments)
- Antenna weatherproofing for outdoor deployment
- Community adoption requires training and documentation
- Ongoing SIM card cost and management

---

### Phase 5: Advanced Features (Backlog)

| Feature | Priority | Complexity | Dependencies |
|---------|----------|------------|-------------|
| Web dashboard for bridge status | Medium | Medium | Flask/FastAPI |
| Matrix bridge integration | Low | Low | MMRelay exists |
| Multi-gateway coordination | Medium | High | MQTT, leader election |
| Voice-to-text transcription | Low | High | Whisper model |
| Emergency broadcast system | High | Medium | Priority queuing |
| Mesh-based key distribution | Low | High | Custom protocol |
| Satellite backhaul (Starlink) | Medium | Low | Ethernet to Pi |
| LoRa signal mapping tool | Medium | Medium | GPS + RSSI logging |

---

## Appendix A: Key URLs

| Resource | URL |
|----------|-----|
| MeshAdv-Mini Repo | https://github.com/chrismyers2000/MeshAdv-Mini |
| MeshAdv-Mini Config Tool | https://github.com/chrismyers2000/Meshtasticd-Configuration-Tool |
| MeshAdv-Mini Etsy | https://frequencylabs.etsy.com |
| MeshAdv Pi Hat (1W version) | https://github.com/chrismyers2000/MeshAdv-Pi-Hat |
| Meshtastic Python API | https://python.meshtastic.org/ |
| Meshtastic Python GitHub | https://github.com/meshtastic/python |
| Meshtastic Encryption Docs | https://meshtastic.org/docs/overview/encryption/ |
| Meshtastic Encryption Limitations | https://meshtastic.org/docs/about/overview/encryption/limitations/ |
| Meshtastic MQTT Docs | https://meshtastic.org/docs/software/integrations/mqtt/ |
| Meshtastic Client API | https://meshtastic.org/docs/development/device/client-api/ |
| Meshtastic Linux-Native Hardware | https://meshtastic.org/docs/hardware/devices/linux-native-hardware/ |
| MeshCore Firmware | https://github.com/meshcore-dev/MeshCore |
| MeshCore Python (meshcore_py) | https://github.com/meshcore-dev/meshcore_py |
| MeshCore Companion Protocol | https://github.com/meshcore-dev/MeshCore/wiki/Companion-Radio-Protocol |
| MeshCore Pi (Python impl) | https://github.com/brianwiddas/meshcore-pi |
| MeshCore CLI | https://pypi.org/project/meshcore-cli/ |
| AMMB (Meshtastic-MeshCore Bridge) | https://github.com/AkitaEngineering/Akita-Meshtastic-Meshcore-Bridge |
| MMRelay (Matrix Bridge) | https://github.com/geoffwhittington/meshtastic-matrix-relay |
| Signal Bridge | https://github.com/ccwod/meshtastic-signal-bridge |
| Telegram Gateway | https://github.com/tb0hdan/meshtastic-telegram-gateway |
| IRC Gateway | https://github.com/AkitaEngineering/Akita-Meshtastic-IRC-Gateway |
| meshtastic-bridge (encrypted MQTT) | https://github.com/geoffwhittington/meshtastic-bridge |
| meshtastic-bridge (Prometheus/APRS) | https://github.com/jaredquinn/meshtastic-bridge |
| meshmail (email over mesh) | https://github.com/mertrois/meshmail |
| Bitchat Bridge | https://github.com/GigaProjects/meshtastic-bitchat-bridge |
| sms2mqtt | https://github.com/Domochip/sms2mqtt |
| sms-server (Rust) | https://github.com/morgverd/sms-server |
| smsgateway-gammu | https://pypi.org/project/smsgateway-gammu/ |
| python-gnupg | https://gnupg.readthedocs.io/ |
| gpgmailencrypt | https://pypi.org/project/gpgmailencrypt/ |
| envelope (email+GPG) | https://github.com/CZ-NIC/envelope |
| Waveshare SIM7600G-H HAT | https://www.waveshare.com/sim7600g-h-4g-hat.htm |
| Gammu (GSM toolkit) | https://wammu.eu/gammu/ |
| Gammu Phone Compatibility | https://wammu.eu/phones/ |

## Appendix B: Message Size Budget

```
LoRa Max Packet:              256 bytes
Meshtastic Header Overhead:    23 bytes
Available Payload:            233 bytes
Chunk Header (custom):         10 bytes
Usable Payload per Chunk:     223 bytes
Safety Margin (-10%):         200 bytes (recommended)

Typical SMS (160 chars):      160 bytes  -> 1 chunk
Short email (subject only):    50 bytes  -> 1 chunk
Medium email (2 paragraphs):  500 bytes  -> 3 chunks (compressed)
Long email (full body):      2000 bytes  -> 10+ chunks (compressed)

Maximum recommended:          2000 bytes pre-compression (~10 chunks)
Hard limit:                   5000 bytes pre-compression (~25 chunks)
```

## Appendix C: Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Cell coverage insufficient at gateway location | Medium | High | Survey coverage before deployment; consider satellite backhaul |
| MeshAdv-Mini out of stock | Low | Medium | Alternative: MeshAdv Pi Hat (1W) or DIY from schematic |
| GPG adoption barrier for community | High | Medium | Provide turnkey key generation scripts; host key signing events |
| Multi-chunk message reliability | Medium | High | Implement robust ACK/retry; limit to 5 chunks initially |
| SD card failure on gateway Pi | Medium | High | Use USB SSD boot; daily backup to remote |
| gammu-smsd daemon instability | Low | Medium | systemd watchdog + auto-restart; fallback to sms2mqtt |
| Meshtastic/MeshCore API breaking changes | Low | Medium | Pin library versions; test before updating |
| Gateway physical security | Medium | High | LUKS encryption; remote wipe; tamper detection |
| Airtime congestion from bridge traffic | Medium | Medium | Rate limiting; priority queuing; off-peak scheduling |
| Regulatory (ISM band compliance) | Low | High | Stay within FCC Part 15 limits; +22dBm is compliant for 915 MHz |
