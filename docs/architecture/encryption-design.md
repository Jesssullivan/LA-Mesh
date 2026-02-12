# LA-Mesh Encryption Design

**See also**: [ADR-004](adr-004-encryption-scheme.md), [Security Curriculum](../../curriculum/security/README.md)

---

## Encryption Layers

### Layer 1: LoRa Physical Layer (No Encryption)

Radio signals are transmitted in the clear at the physical layer. Anyone with an SDR receiver can detect LoRa transmissions at 915 MHz. Encryption protects the payload content, not the existence of the transmission.

**Observable by passive listener**:
- Transmission timing and frequency
- Packet size and duration
- Approximate direction (with directional antenna)
- Modulation parameters (SF, BW)

**NOT observable**:
- Message content (encrypted)
- Sender/receiver identity (encrypted in payload)
- Channel name (encrypted)

### Layer 2: Channel Encryption (AES-256-CTR)

Every packet on a channel is encrypted with the channel's PSK using AES-256 in CTR mode.

```
Plaintext → AES-256-CTR(PSK, nonce) → Ciphertext → LoRa TX
```

**Properties**:
- Symmetric encryption: same key encrypts and decrypts
- CTR mode: stream cipher behavior, no padding needed
- 256-bit key strength: computationally infeasible to brute force
- Nonce: prevents identical plaintexts from producing identical ciphertexts

**Limitation**: Everyone with the channel PSK can decrypt all messages on that channel. Channel encryption protects against outsiders, not insiders.

### Layer 3: Direct Message PKC (X25519 + AES-256-CCM)

For private direct messages, Meshtastic v2.7.15+ uses Public Key Cryptography:

```
Sender's X25519 private key + Recipient's X25519 public key
    → ECDH shared secret
    → AES-256-CCM encryption
    → Only recipient can decrypt
```

**Properties**:
- Asymmetric: each device has a unique key pair
- Forward secrecy per session
- Even other devices on the same channel cannot read DMs
- Key pairs generated on-device (v2.7.15+ ensures unique keys)

**Critical**: CVE-2025-52464 (firmware < v2.7.15) caused vendor-cloned devices to share identical key pairs, completely defeating PKC. Update to v2.7.15+ forces key regeneration.

---

## Threat Model

### What LA-Mesh Encryption Protects Against

| Threat | Channel Encryption | PKC (DMs) |
|--------|-------------------|-----------|
| Casual eavesdropping (default PSK) | N/A (we don't use default PSK) | Protected |
| Passive RF monitoring (SDR) | **Protected** | **Protected** |
| Network member reading broadcast messages | Not protected (they have PSK) | **Protected** |
| Network member reading DMs | **Protected** (different key) | **Protected** |
| PSK compromise | **NOT protected** | Still protected (PKC independent) |
| Device theft (before PSK rotation) | **NOT protected** | Partially (device's DMs exposed) |

### What Encryption Does NOT Protect Against

- **Traffic analysis**: Timing, frequency, and volume of transmissions are visible
- **Direction finding**: Radio signals can be located with directional equipment
- **Compromised device**: If attacker has physical access to a configured device
- **Social engineering**: Tricking someone into revealing the PSK
- **Rubber-hose cryptanalysis**: Physical coercion to reveal keys

---

## Key Hierarchy

```
                    ┌─────────────────┐
                    │  PSK Generation  │
                    │  (openssl rand)  │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
    ┌─────────┴──────┐ ┌───┴──────┐ ┌────┴──────────┐
    │ Primary PSK    │ │ Admin PSK│ │ Emergency PSK  │
    │ (Channel 0)    │ │ (Ch. 1)  │ │ (Channel 2)    │
    │ All members    │ │ Ops only │ │ All members    │
    └────────────────┘ └──────────┘ └────────────────┘

    ┌─────────────────┐
    │ Device Key Pair  │  (X25519, generated on-device)
    │ Per-device unique│
    │ Used for DM PKC  │
    └─────────────────┘
```

---

## Operational Procedures

### PSK Rotation

1. Generate new PSKs: `openssl rand -base64 32` (one per channel)
2. Schedule in-person key distribution event
3. Apply new PSKs to all infrastructure nodes first
4. Apply to client devices at meetup
5. Verify all devices can communicate on new PSKs
6. Document rotation date (not the PSK itself)

### Compromise Response

1. **Suspected PSK leak**: Rotate affected channel immediately
2. **Device theft**: Rotate all channels, attempt remote wipe via admin channel
3. **Firmware vulnerability**: Update all devices, rotate PKC keys if needed
4. **Operator departure**: Rotate admin channel PSK
