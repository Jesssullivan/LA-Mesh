# Security Comparison: Meshtastic vs MeshCore

This document provides a neutral, fact-based comparison of the encryption and
security models in Meshtastic and MeshCore firmware. Both are open-source LoRa
mesh networking stacks with different design tradeoffs. This analysis is intended
to help LA-Mesh operators make informed decisions about which firmware to deploy
for each use case.

> **Disclaimer**: Security is a moving target. Both projects are under active
> development. Verify claims against current source code before making deployment
> decisions. Last reviewed against Meshtastic v2.6.x and MeshCore as of early 2025.

---

## Encryption at a Glance

| Property | Meshtastic | MeshCore |
|----------|-----------|----------|
| **Channel encryption** | AES-256-CTR | AES-128-ECB |
| **Direct message encryption** | X25519 key exchange + AES-256-CCM (PKC) | Ed25519 + ECDH + AES-128-ECB |
| **Key size** | 256-bit | 128-bit |
| **Mode of operation** | CTR (stream cipher mode) | ECB (electronic codebook) |
| **Authentication** | CCM (authenticated encryption for DMs) | HMAC-SHA256 (2-byte truncated) |
| **Forward secrecy** | No | No |
| **Key revocation** | No formal mechanism | No formal mechanism |

---

## Channel Encryption

### Meshtastic: AES-256-CTR

Meshtastic encrypts channel traffic using AES-256 in Counter (CTR) mode. Each
packet uses a unique nonce derived from the packet ID and sender node number,
ensuring that identical plaintext messages produce different ciphertext.

- **Key derivation**: Channel PSK is hashed to produce a 256-bit key
- **Nonce construction**: Packet ID (4 bytes) + sender node (4 bytes) + zero-padded
- **Plaintext patterns**: Not preserved in ciphertext (CTR mode is a stream cipher)

### MeshCore: AES-128-ECB

MeshCore encrypts messages using AES-128 in Electronic Codebook (ECB) mode. ECB
encrypts each 16-byte block independently with the same key.

- **Key size**: 128-bit (half the key space of Meshtastic)
- **No IV/nonce**: Each block is encrypted identically
- **Plaintext patterns**: Identical plaintext blocks produce identical ciphertext
  blocks. This is the well-known "ECB penguin" problem -- structural patterns in
  the plaintext are visible in the ciphertext. For short text messages this is
  less impactful than for images, but repeated message prefixes or fixed-format
  data may reveal patterns.

### Practical Implications

For text messaging over LoRa, the practical impact of ECB vs CTR depends on
usage patterns:

- **Short unique messages** (typical mesh chat): ECB weakness is minimal since
  messages rarely span multiple identical blocks
- **Repeated/templated messages** (automated alerts, status reports): ECB may
  reveal that the same message was sent repeatedly
- **Traffic analysis**: Both protocols expose packet timing and size. Neither
  provides traffic flow confidentiality.

---

## Direct Message (DM) Encryption

### Meshtastic: Public Key Cryptography (PKC)

Meshtastic v2.5+ supports end-to-end encrypted direct messages using:

1. **X25519** Diffie-Hellman key exchange (Curve25519)
2. **AES-256-CCM** authenticated encryption
3. Key pairs are generated per-device at first boot
4. Trust-on-first-use (TOFU) model -- no certificate authority

DMs are encrypted such that only the sender and recipient can decrypt them. Other
mesh nodes relay the ciphertext but cannot read it. The CCM mode provides both
confidentiality and integrity (authenticated encryption).

### MeshCore: Ed25519 + ECDH + AES-128-ECB

MeshCore DMs use:

1. **Ed25519** signing keys (also used for ECDH key agreement)
2. **ECDH** shared secret derivation
3. **AES-128-ECB** encryption of the shared-secret-derived message

The DM key exchange is sound (Ed25519/ECDH), but the resulting message is
encrypted with AES-128-ECB, carrying the same ECB limitations.

---

## Message Authentication

### Meshtastic

- Channel messages: No per-message authentication (anyone with the PSK can forge)
- DMs: AES-256-CCM provides authenticated encryption (forgery is detected)

### MeshCore

- Messages include an **HMAC-SHA256 tag truncated to 2 bytes** (16 bits)
- With only 65,536 possible values, an attacker can forge a valid tag with
  probability 1/65,536 per attempt -- feasible for a motivated attacker sending
  many packets
- The full SHA256 is computed but only 2 bytes are transmitted (bandwidth
  optimization for LoRa's low data rate)

---

## Key Management

### Key Generation

| Aspect | Meshtastic | MeshCore |
|--------|-----------|----------|
| Channel keys | User-set PSK (shared at meetups) | Admin-set password |
| DM keys | Auto-generated X25519 at first boot | Auto-generated Ed25519 at first boot |
| Key storage | Plaintext in ESP32 NVS | Plaintext in ESP32 NVS |
| Key rotation | Manual PSK rotation at meetups | Manual password change |

### Key Storage Security

Both Meshtastic and MeshCore store encryption keys in the ESP32's Non-Volatile
Storage (NVS) partition **in plaintext**. This means:

- **Physical access to the device = access to all keys**
- Reading NVS is possible with esptool.py or JTAG
- ESP32-S3 supports XTS-AES-256 flash encryption, but **neither firmware enables
  it by default**
- Enabling flash encryption is a one-way operation on ESP32 (eFuse)

### Key Revocation

Neither protocol has a formal key revocation mechanism:

- **Meshtastic**: If a device is lost/stolen, rotate the channel PSK. All devices
  must be updated.
- **MeshCore**: If a device is compromised, its Ed25519 identity cannot be
  invalidated. Other nodes have no way to know the key is compromised.

---

## Forward Secrecy

**Neither Meshtastic nor MeshCore provides forward secrecy.**

This means:

- If a long-term key is compromised, **all historical messages** encrypted with
  that key can be decrypted
- An adversary who records encrypted traffic and later obtains the key can decrypt
  all captured messages
- This is a fundamental limitation of both protocols, driven by LoRa's extreme
  bandwidth constraints making ephemeral key exchange impractical

---

## Routing and Relay Security

### Meshtastic

- All roles (ROUTER, CLIENT, ROUTER_CLIENT) can relay messages
- A compromised ROUTER can see encrypted traffic it relays (but cannot decrypt
  without the PSK)
- **CLIENT_HIDDEN**: Does not appear in node lists, does not broadcast NodeInfo,
  minimal RF footprint. Useful for privacy-conscious users.
- **CLIENT_MUTE**: Appears in node lists but does not rebroadcast others' messages

### MeshCore

- **Clients never repeat**: A compromised client device cannot become an adversary
  relay node. This is a structural security advantage.
- **Repeaters/room servers are trust-critical**: These nodes see all traffic they
  relay. Default passwords on room servers ("password", "hello") are a deployment
  risk.
- Hybrid routing (flood + directed) with per-hop acknowledgment

---

## Threat Model Analysis

### Casual Eavesdropper (no special equipment)

| Threat | Meshtastic | MeshCore |
|--------|-----------|----------|
| Read channel messages | Cannot (AES-256) | Cannot (AES-128) |
| Read DMs | Cannot (PKC) | Cannot (ECDH) |
| See who is transmitting | Can (RF metadata) | Can (RF metadata) |
| See message timing/size | Can | Can |

Both protocols adequately protect against casual eavesdropping.

### Stolen/Lost Device

| Threat | Meshtastic | MeshCore |
|--------|-----------|----------|
| Extract channel PSK | Yes (plaintext NVS) | Yes (plaintext NVS) |
| Extract DM keys | Yes (plaintext NVS) | Yes (plaintext NVS) |
| Decrypt historical traffic | Yes (no PFS) | Yes (no PFS) |
| Impersonate the device | Yes | Yes |
| Revoke compromised identity | No (rotate PSK) | No (no mechanism) |
| Become adverse relay | Yes (all roles relay) | No (clients can't repeat) |

MeshCore's "clients never repeat" design limits the blast radius of a compromised
client device -- it cannot be used to manipulate routing or selectively drop
messages for other nodes. However, the lack of any key revocation mechanism is a
more significant operational concern.

### Resourced Adversary (recording traffic, capable of cryptanalysis)

| Threat | Meshtastic | MeshCore |
|--------|-----------|----------|
| Brute-force channel key | 2^256 (infeasible) | 2^128 (infeasible today) |
| Detect repeated messages | No (CTR mode) | Yes (ECB mode) |
| Forge message authentication | Requires PSK | ~1/65,536 per attempt |
| Direction-finding / locate nodes | Yes (RF) | Yes (RF) |
| Decrypt with captured key | All historical traffic | All historical traffic |

---

## Operational Considerations for LA-Mesh

### Factors Favoring Meshtastic

- Stronger channel encryption (AES-256-CTR vs AES-128-ECB)
- Authenticated DM encryption (AES-256-CCM)
- CLIENT_HIDDEN role for minimal RF footprint
- Larger ecosystem, more devices, better documentation
- MQTT bridge support for gateway integration
- Active CVE tracking and security updates

### Factors Favoring MeshCore

- Clients cannot become adverse relays (structural security)
- Room server architecture for group messaging
- Simpler protocol (smaller attack surface in some respects)
- Active development with ChaChaPoly AEAD upgrade planned (not yet shipped)

### Neither Protocol Provides

- Forward secrecy
- Key revocation
- Hardware-backed key storage (ESP32 eFuses not used)
- Protection against RF direction-finding
- Traffic flow confidentiality

---

## References

- Meshtastic encryption documentation: https://meshtastic.org/docs/overview/encryption/
- MeshCore source code: https://github.com/rocketgithub/meshcore-firmware
- ESP32-S3 flash encryption: https://docs.espressif.com/projects/esp-idf/en/latest/esp32s3/security/flash-encryption.html
- CVE-2025-52464: Duplicate crypto keys from vendor image cloning
- "ECB penguin" visualization: https://blog.filippo.io/the-ecb-penguin/
