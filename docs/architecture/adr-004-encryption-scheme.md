# ADR-004: Encryption Scheme

**Status**: Proposed
**Date**: 2026-02-11

## Context

LA-Mesh requires encryption to protect community communications. Meshtastic provides two encryption layers: channel encryption (AES-256-CTR with PSK) and direct message encryption (X25519 PKC + AES-256-CCM).

## Decision

### Channel Encryption

All LA-Mesh channels use custom 32-byte (256-bit) PSKs generated with `openssl rand -base64 32`. The default Meshtastic PSK (`AQ==`) is never used.

Three channels configured:
1. **LA-Mesh** (Primary, index 0): All community members
2. **LA-Admin** (Secondary, index 1): Network operators only
3. **LA-Emergency** (Secondary, index 2): Emergency broadcast, all devices

Each channel has a unique PSK.

### PKC for Direct Messages

Public Key Cryptography is enabled on all devices (default in v2.7.15+). This provides end-to-end encryption for direct messages that even other channel members cannot read.

### Key Management

| Aspect | Policy |
|--------|--------|
| PSK generation | `openssl rand -base64 32` on air-gapped device |
| PSK distribution | In-person only, never digital |
| PSK rotation | Quarterly, or immediately on suspected compromise |
| PSK storage | Never in git, never in plaintext on shared systems |
| New member onboarding | Receive PSK at community meetup |
| Key custodian | Designated network operator(s) |

### Firmware Requirement

All devices must run Meshtastic v2.7.15+ due to CVE-2025-52464 (duplicate cryptographic keys from vendor image cloning).

## Consequences

- PSK distribution requires in-person contact (limits remote onboarding)
- Quarterly rotation requires touching all devices (or remote admin capability)
- Separate PSKs per channel means operators manage 3+ keys
- PKC provides strong DM security but requires firmware v2.7.15+
- See [Security Curriculum](../../curriculum/security/README.md) for educational materials
