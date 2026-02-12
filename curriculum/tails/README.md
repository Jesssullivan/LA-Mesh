# Level 5: TAILS OS and Secure Communications

**Audience**: Advanced participants interested in maximum operational security
**Time**: 3 hours (lab format)
**Prerequisites**: Mesh Basics (Level 1-2), Security (Level 3)

---

## Learning Objectives

By the end of this module, participants will be able to:

1. Explain what TAILS OS is and why it exists
2. Boot TAILS from a USB drive
3. Understand the relationship between mesh networks and internet anonymity tools
4. Combine air-gapped mesh communication with TAILS for layered security
5. Make informed decisions about operational security trade-offs

---

## Important Disclaimer

This curriculum is for **educational purposes** in the context of:
- Journalism source protection
- Human rights documentation in hostile environments
- Disaster communications when infrastructure is compromised
- Academic study of privacy-preserving technologies

Understanding security tools helps communities make informed decisions about when and how to protect their communications.

---

## Module Structure

### Part 1: Why TAILS? (30 min)

**The Amnesic Incognito Live System**:
- **Amnesic**: Forgets everything when you shut down
- **Incognito**: Routes all traffic through Tor
- **Live System**: Boots from USB, doesn't touch your hard drive

**Use cases**:
- Journalists protecting sources in hostile regions
- Activists in countries with internet surveillance
- Whistleblowers communicating securely
- Anyone needing temporary, untraceable computing

**How it works**:
```
USB Drive → Boot TAILS → All traffic → Tor Network → Internet
                ↓                         ↓
          RAM only                   3 relay hops
          (no disk writes)           (IP hidden)
                ↓
          Shutdown = everything gone
```

**Key properties**:
- No persistent storage by default (optional encrypted persistence)
- All network traffic forced through Tor (IP address hidden)
- Leaves no trace on the host computer
- Built on Debian Linux with hardened security defaults

### Part 2: TAILS + Mesh Networks (25 min)

**Why combine TAILS with mesh?**

| Scenario | Mesh Alone | Internet Alone | Mesh + TAILS |
|----------|-----------|---------------|-------------|
| Cell towers down | Works | Fails | Works (mesh) |
| Internet surveilled | N/A | Vulnerable | Protected (Tor) |
| Need anonymity | Limited | Via Tor | Both layers |
| Air-gapped comms | Works | Impossible | Works (mesh) |

**Architecture for maximum security**:
```
                    ┌─────────────────┐
                    │   TAILS on USB  │
                    │  (Tor for web)  │
                    └────────┬────────┘
                             │ USB
                    ┌────────┴────────┐
                    │  Laptop (host)  │
                    │  (no disk use)  │
                    └────────┬────────┘
                             │ Bluetooth/USB
                    ┌────────┴────────┐
                    │  T-Deck / Phone │
                    │  (mesh comms)   │
                    └────────┬────────┘
                             │ LoRa 915 MHz
                    ┌────────┴────────┐
                    │   LA-Mesh       │
                    │   Network       │
                    └─────────────────┘
```

**Separation of concerns**:
- TAILS handles internet anonymity (when internet is available)
- Mesh handles local communication (when internet is unavailable)
- Neither depends on the other -- they complement

**Important**: Mesh communications are encrypted but not anonymous. LoRa transmissions can be direction-found. TAILS provides anonymity for internet traffic, not radio traffic.

### Part 3: Hands-On -- Booting TAILS (45 min)

**Materials needed**:
- USB drive (8GB+) with TAILS pre-installed
- Laptop that supports USB boot
- Internet connection (for Tor demo)

**Steps**:

1. **Download TAILS** (done beforehand):
   - https://tails.net/install/
   - Verify the download signature

2. **Create bootable USB**:
   ```bash
   # On Linux
   sudo dd if=tails-amd64-*.img of=/dev/sdX bs=16M status=progress

   # Or use balenaEtcher (GUI)
   ```

3. **Boot from USB**:
   - Insert USB, restart laptop
   - Enter BIOS/boot menu (usually F2, F12, or DEL)
   - Select USB drive
   - TAILS welcome screen appears

4. **First boot configuration**:
   - Language and keyboard
   - Optional: additional settings (admin password, persistent storage)
   - Click "Start TAILS"

5. **Verify Tor connection**:
   - Tor Browser opens automatically
   - Visit https://check.torproject.org to confirm
   - Note: initial connection takes 30-60 seconds

**Exercise**: Browse to a website through Tor. Note how your IP appears to be from a different country.

### Part 4: Operational Security Principles (30 min)

**The security mindset**:

Security is about **layers**. No single tool provides complete protection. The goal is to make surveillance costly and impractical, not impossible.

**Layers for LA-Mesh communications**:

| Layer | Tool | Protects Against |
|-------|------|-----------------|
| 1 | LoRa mesh | No internet dependency |
| 2 | AES-256 channel encryption | Passive RF eavesdropping |
| 3 | X25519 PKC (DMs) | Other mesh users reading DMs |
| 4 | TAILS + Tor (web) | IP/location tracking online |
| 5 | Physical security | Device theft, shoulder surfing |

**Common mistakes**:
1. **Using the default PSK**: Publicly known, zero security
2. **Sharing PSK digitally**: Creates a record that can be subpoenaed
3. **Leaving GPS enabled**: Broadcasts your exact location to the mesh
4. **Not updating firmware**: CVE-2025-52464 -- duplicate keys from cloned images
5. **Trusting one tool completely**: No single tool is a silver bullet

**Metadata awareness**:
Even with encryption, metadata reveals information:
- When you transmit (timing)
- How often you transmit (pattern of life)
- Where you transmit from (RF direction-finding)
- Who you communicate with (if DM patterns are observed)

**Exercise**: Group discussion -- for a given scenario (journalist protecting a source, disaster relief coordinator, community organizer), identify which layers are most important and which metadata risks matter.

### Part 5: Practical Scenarios (30 min)

**Scenario 1: Post-Disaster Communication**
- Cell towers down, internet out
- Need to coordinate shelters, supplies, medical aid
- **Tools**: Mesh network (primary), TAILS unnecessary (no internet)
- **Priority**: Message delivery, not anonymity

**Scenario 2: Secure Source Communication**
- Journalist receiving sensitive information
- Source needs anonymity
- **Tools**: Air-gapped mesh for local handoff, TAILS for online research
- **Priority**: Source protection, metadata minimization

**Scenario 3: Community Organizing**
- Planning community event with security concerns
- Need both local coordination and web presence
- **Tools**: Mesh for local comms (no internet trail), TAILS for web tasks
- **Priority**: Compartmentalization of digital and RF activity

**Group exercise**: Each group picks a scenario and designs a communication plan using the tools covered in the curriculum.

### Part 6: Limitations and Honest Assessment (15 min)

**What these tools DON'T protect against**:
- Physical surveillance (someone watching you use the device)
- Compromised devices (malware on the TAILS USB or Meshtastic device)
- Social engineering (someone tricking you into revealing the PSK)
- Legal compulsion (court orders, subpoenas)
- A determined nation-state adversary with unlimited resources

**Honest assessment of mesh security**:
- LoRa signals can be detected and direction-found
- Mesh node IDs are visible to other mesh users
- Position broadcasts reveal your location (disable if needed)
- Channel encryption is group-shared -- any member can read all messages
- PKC for DMs is strong but only as good as the firmware (CVE-2025-52464)

**The goal is proportional security**: Use tools appropriate to your actual threat model. Most LA-Mesh users need basic encryption and don't face state-level adversaries. But understanding the full spectrum empowers better decisions.

---

## Instructor Notes

### Setup Requirements
- Pre-prepared TAILS USB drives (test boot before workshop)
- Laptops that support USB boot (verify BIOS settings)
- Internet connection for Tor demonstration
- Meshtastic devices for mesh + TAILS integration demo

### Sensitive Topics
- This module touches on surveillance and civil liberties
- Frame all discussions in terms of legitimate use cases
- Emphasize legal compliance (FCC rules, ECPA, local laws)
- Encourage critical thinking about trade-offs, not paranoia

### Assessment
- No formal grading -- this is community education
- Success = participants can articulate when and why to use each tool
- Encourage ongoing discussion in LA-Mesh community meetings
