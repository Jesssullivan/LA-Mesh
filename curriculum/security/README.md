# Level 3: Mesh Network Security

**Audience**: Participants who completed Level 1-2, network operators, security-conscious users
**Time**: 2 hours (workshop format)
**Prerequisites**: Mesh Basics (Level 1-2)

---

## Learning Objectives

By the end of this module, participants will be able to:

1. Generate and manage secure PSK keys
2. Enable and verify PKC (Public Key Cryptography) for direct messages
3. Explain the CVE-2025-52464 vulnerability and its implications
4. Perform a basic threat model for a community mesh network
5. Follow operational security practices for key distribution

---

## Module Structure

### Part 1: Encryption Layers in Meshtastic (25 min)

**Layer 1 -- LoRa Physical Layer**:
- Radio signals are visible to anyone with an SDR receiver
- Signal characteristics (frequency, timing, packet size) are observable
- Encryption protects content, not the fact that you're transmitting

**Layer 2 -- Channel Encryption (AES-256-CTR)**:
- Every message on a channel is encrypted with the channel PSK
- All devices sharing the PSK can decrypt all channel messages
- CTR mode: stream cipher behavior, no padding oracle attacks
- Limitation: anyone with the PSK can read everything on that channel

**Layer 3 -- Direct Message PKC (X25519 + AES-256-CCM)**:
- Optional end-to-end encryption for DMs
- Each device generates an X25519 key pair
- ECDH key exchange creates a shared secret per pair
- Even other devices with the channel PSK cannot read your DMs

```
Channel Message: ────[AES-256-CTR]───→ All devices with PSK can read
Direct Message:  ────[X25519+AES-CCM]─→ Only recipient can read
```

**Exercise**: Check your device's public key:
```bash
meshtastic --info  # Look for "Public Key" in output
```

### Part 2: PSK Management (25 min)

**Generating a Secure PSK**:
```bash
# Generate a cryptographically secure 32-byte PSK
openssl rand -base64 32
# Example output: K7xR2p4mN8vQwY3jH6fL0tBuI9sDcE5gA1rO7kZ4hXs=
```

**PSK Strength Comparison**:
| PSK | Bits | Security |
|-----|------|----------|
| `AQ==` (default) | 8 | **NONE** -- publicly known |
| Short passphrase | ~40-60 | Weak -- brute-forceable |
| 16-byte random | 128 | Good |
| **32-byte random** | **256** | **Strong -- LA-Mesh standard** |

**Distribution Rules**:
1. Generate PSK on an air-gapped device or trusted machine
2. Distribute ONLY in person, face-to-face
3. Never send via text, email, Signal, or any digital channel
4. Write on paper, show screen, or use QR code in-person
5. Destroy paper copies after devices are configured
6. Rotate quarterly or immediately on suspected compromise

**Exercise**: Generate a PSK, configure it on your device, verify another device can receive your messages.

```bash
# Generate
openssl rand -base64 32

# Apply to device
meshtastic --ch-set psk "<your-base64-psk>" --ch-index 0

# Verify
meshtastic --info
```

### Part 3: CVE-2025-52464 Case Study (20 min)

**The vulnerability**:
- **CVSSv4 score**: 9.5 (Critical)
- **Discovery**: Early 2025
- **Issue**: Some device vendors cloned firmware images without regenerating cryptographic keys
- **Impact**: Multiple devices shared identical key pairs, undermining PKC encryption
- **Affected**: Firmware versions before v2.6.11

**What went wrong**:
1. Vendor creates a firmware image on one device
2. Vendor clones that image to hundreds/thousands of devices
3. All cloned devices share the same private key
4. PKC "encryption" is meaningless -- everyone has the same key

**Lesson**: Supply chain security matters. Even strong cryptography fails if keys aren't unique.

**Fix**: Firmware v2.6.11+ forces key regeneration on first boot after update.

**LA-Mesh policy**: No device may be deployed with firmware below v2.6.11.

**Exercise**: Check your device firmware version:
```bash
meshtastic --info | grep "Firmware"
```

### Part 4: Threat Modeling for Mesh Networks (30 min)

**What is threat modeling?**
Identifying: Who might want to attack us? What can they do? How do we defend?

**Threat actors for a community mesh**:

| Actor | Capability | Motivation | Likelihood |
|-------|-----------|------------|------------|
| Curious neighbor | SDR receiver, basic skills | Eavesdropping | Medium |
| Local law enforcement | Professional RF equipment, legal authority | Surveillance | Low-Medium |
| Sophisticated adversary | Full SDR suite, traffic analysis, nation-state tools | Targeted surveillance | Very Low |
| Prankster/troll | Meshtastic device, default channel knowledge | Disruption | Medium |

**Attack surfaces**:

1. **Passive RF monitoring**: Detecting that mesh traffic exists
   - **Defense**: Impossible to prevent (radio waves are public). Encryption protects content.

2. **PSK compromise**: Attacker obtains channel PSK
   - **Defense**: In-person distribution only, quarterly rotation, compartmentalized channels

3. **Rogue node injection**: Attacker joins with a valid PSK
   - **Defense**: PKC for sensitive DMs, node list monitoring, community vetting

4. **Traffic analysis**: Counting packets, timing, identifying active nodes
   - **Defense**: Limited -- LoRa transmissions are observable. Position sharing can be disabled.

5. **Physical device theft**: Attacker obtains a configured device
   - **Defense**: Device PIN/lock, remote admin to wipe PSK, PSK rotation after theft

**Group exercise**: Draw a threat model for LA-Mesh. Identify the three most likely threats and propose defenses.

### Part 5: Operational Security Practices (20 min)

**For all users**:
- Enable PKC for direct messages
- Use a device PIN/screen lock
- Don't share screenshots of your node info publicly
- Be aware that your position is broadcast if GPS is enabled
- Disable GPS position sharing if operational security requires it

**For network operators**:
- Use the LA-Admin channel (separate PSK) for operator communications
- Monitor node list for unknown devices
- Keep firmware updated (weekly checks via automated workflow)
- Maintain offline backup of all device configs
- Document PSK rotation schedule

**For key custodians**:
- Generate PSKs on air-gapped devices
- Use separate PSKs for each channel
- Maintain a secure log of PSK rotation dates (not the PSKs themselves)
- Have a PSK emergency rotation procedure

**Exercise**: Enable PKC on your device and send an encrypted DM to another participant:
```bash
# PKC is enabled by default on v2.6.11+
# Send a DM (encrypted end-to-end)
meshtastic --sendtext "Secret message" --dest '!<node-id>'
```

---

## Instructor Notes

### Materials Needed
- Pre-configured T-Deck devices (v2.6.11+)
- Whiteboard for threat modeling exercise
- Printed handout with CLI commands
- Air-gapped laptop for PSK generation demo

### Key Takeaways to Reinforce
1. Encryption is only as strong as key management
2. Channel encryption protects from outsiders; PKC protects from insiders
3. Supply chain attacks (CVE-2025-52464) bypass even strong crypto
4. Threat modeling is a practice, not a one-time exercise
