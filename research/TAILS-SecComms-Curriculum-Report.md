# LA-Mesh Deep Research Report: TAILS, Secure Communications, and Community Curriculum

**Date:** 2026-02-11
**Prepared for:** LA-Mesh Project (Lewiston-Auburn Community LoRa Mesh Network)
**Scope:** Southern Maine / Bates College / Androscoggin County

---

## Table of Contents

1. [TAILS OS Integration](#1-tails-os-integration)
2. [Secure Communications Stack](#2-secure-communications-stack)
3. [Community Education Curriculum](#3-community-education-curriculum)
4. [Community Resilience Angle](#4-community-resilience-angle)
5. [Similar Community Projects](#5-similar-community-projects)
6. [Bates College Integration](#6-bates-college-integration)
7. [Documentation and Guides](#7-documentation-and-guides)
8. [Sprint Integration Points](#sprint-integration-points)

---

## 1. TAILS OS Integration

### 1.1 What is TAILS?

[TAILS](https://tails.net/) (The Amnesic Incognito Live System) is a portable operating system that boots from a USB stick and routes all network traffic through the Tor anonymity network. It leaves no trace on the host machine and provides encrypted persistent storage for files, configurations, and additional software packages.

**Key properties for LA-Mesh:**
- Amnesic by default (no forensic traces on host hardware)
- All traffic routed through Tor
- Encrypted persistent storage (LUKS-encrypted partition)
- Debian-based, so standard Linux serial tools are available
- MAC address anonymization enabled by default

### 1.2 TAILS + Meshtastic Serial Connection Feasibility

**Assessment: FEASIBLE WITH CONFIGURATION**

TAILS can communicate with Meshtastic devices over USB serial connections. The path requires:

1. **USB Serial Access**: TAILS recognizes USB devices when plugged in while the screen is unlocked. Meshtastic devices present as `/dev/ttyUSB0` or `/dev/ttyACM0` (CP2102/CH340 or CDC ACM drivers). The Linux kernel in TAILS includes these drivers by default.

2. **Additional Software Packages**: TAILS supports [installing additional software via persistent storage](https://tails.net/doc/persistent_storage/additional_software/index.en.html). Required packages:
   - `python3-pip` (for Meshtastic CLI)
   - `python3-serial` (pyserial for serial communication)
   - `screen` or `minicom` (serial terminal access)
   - The Meshtastic Python CLI (`pip install meshtastic`)

3. **Persistent Storage Configuration**: Enable the [Persistent Storage](https://tails.net/doc/persistent_storage/) feature and configure:
   - Additional Software (to auto-install serial tools on boot)
   - Dotfiles (to preserve Meshtastic configuration files)
   - GnuPG keys (for signed mesh messages)

4. **Serial Module**: Meshtastic's [Serial Module](https://meshtastic.org/docs/configuration/module/serial/) enables device control over serial connections, supporting both configuration and message exchange.

**Limitations:**
- TAILS security model warns that additional packages may compromise built-in security
- Each boot requires re-establishing the serial connection
- No Bluetooth support in TAILS (serial/USB only)
- Performance impact from Tor routing for any internet-facing mesh bridges

### 1.3 USB Persistence for Mesh Network Configs

A TAILS persistent volume can store:

| Data Type | Persistence Feature | Purpose |
|-----------|-------------------|---------|
| Meshtastic CLI config | Dotfiles | Channel keys, device settings |
| GPG keys | GnuPG | Signed mesh messages |
| Python packages | Additional Software | meshtastic CLI, pyserial |
| Channel PSKs | Dotfiles / encrypted file | Pre-shared keys for channels |
| Node identity | Dotfiles | Consistent mesh identity across sessions |

**Setup procedure for community members:**
1. Create TAILS USB (minimum 8GB, 16GB recommended)
2. Boot TAILS, set admin password
3. Create Persistent Storage with strong passphrase
4. Enable: Additional Software, Dotfiles, GnuPG
5. Install meshtastic CLI and dependencies
6. Configure Meshtastic device connection
7. Export and store channel configurations

### 1.4 Tor + Mesh Network Bridge Concepts

This is the most speculative integration area. Several architectural patterns are possible:

**Pattern 1: MQTT-over-Tor Gateway**
- A Meshtastic node with WiFi connects to an [MQTT broker](https://meshtastic.org/docs/software/integrations/mqtt/) through Tor
- Messages from the local LoRa mesh are forwarded to a Tor hidden service running MQTT
- Remote mesh clusters can subscribe to the same hidden service
- Provides: geographic anonymity for the bridge operator, censorship resistance
- Reference: [Meshtastic MQTT documentation](https://meshtastic.org/docs/configuration/module/mqtt/)

**Pattern 2: Reticulum + Tor Transport**
- [Reticulum Network Stack](https://reticulum.network/) natively supports TCP/IP as a transport layer
- Reticulum interfaces can be configured to connect through Tor SOCKS proxy
- This bridges local LoRa mesh segments over Tor to remote segments
- Reticulum's built-in encryption (Curve25519 ECDH + AES) provides forward secrecy on top of Tor

**Pattern 3: Store-and-Forward via Tor**
- MeshCore's [Room Server](https://github.com/meshcore-dev/MeshCore) acts as a BBS/store-and-forward node
- A gateway node running on TAILS connects to the Room Server and synchronizes messages over Tor
- Provides asynchronous communication with anonymity

**Important caveats:**
- LoRa bandwidth is extremely limited (250 bps to ~21.9 kbps); Tor adds significant overhead
- Tor's latency (seconds) vs. LoRa's latency (seconds) compounds to poor UX
- This is primarily useful for bridging geographically separated mesh clusters, not for local mesh traffic

### 1.5 TAILS Distribution Guide for Community Members

**Recommended distribution workflow:**
1. Host a "TAILS Party" (similar to key signing parties)
2. Provide known-good TAILS USB images verified against [official checksums](https://tails.net/install/)
3. Walk participants through persistent storage setup
4. Pre-configure mesh network settings during the session
5. Distribute a printed quick-reference card (TAILS + Meshtastic)
6. Emphasize: TAILS 6.11+ required (patches [critical January 2025 vulnerabilities](https://mr-alias.com/articles/tails-os-setup.html))

---

## 2. Secure Communications Stack

### 2.1 Meshtastic Encryption Architecture

Meshtastic implements a layered encryption model as of firmware v2.5+:

**Channel Encryption (Group Messages):**
- AES-256-CTR encryption for all LoRa payload data
- Pre-Shared Key (PSK) shared among all channel participants
- Same key used for encryption and decryption
- Default "LongFast" channel uses a publicly known PSK (provides zero security)
- Custom channels with unique PSKs provide group confidentiality
- Reference: [Meshtastic Encryption Overview](https://meshtastic.org/docs/overview/encryption/)

**Direct Message Encryption (PKC):**
- Introduced in firmware v2.5.0
- x25519 public key cryptography for key exchange
- AES-CCM (Counter with CBC-MAC) for message encryption and authentication
- Each node generates a unique public/private key pair
- Messages encrypted with recipient's public key
- Message Authentication Code verifies sender identity and integrity
- Reference: [Meshtastic PKC Blog Post](https://meshtastic.org/blog/introducing-new-public-key-cryptography-in-v2_5/)

**Known Limitations:**
- Channel PSK model means compromise of one device compromises the entire channel
- No forward secrecy for channel messages (same key for all messages)
- PKC for DMs is NOT quantum-resistant (x25519 vulnerable to Shor's algorithm)
- AES-256 component IS considered quantum-resistant
- Reference: [Meshtastic Encryption Limitations](https://meshtastic.org/docs/about/overview/encryption/limitations/)

### 2.2 CRITICAL: CVE-2025-52464 -- Key Generation Vulnerability

**Severity: CVSSv4 9.5 (Critical)**

A major vulnerability was discovered in Meshtastic firmware affecting versions 2.5.0 through 2.6.10:

- **Root Cause 1**: Hardware vendors created "golden images" by flashing one device, letting it generate keys, then cloning that image to entire production batches -- resulting in identical x25519 keypairs across thousands of devices
- **Root Cause 2**: The `rweather/crypto` library failed to properly initialize randomness pools on NRF52 platforms
- **Impact**: Attackers can decrypt Direct Messages from devices with duplicated keys
- **Fix**: Firmware v2.7.15 implements entropy enhancements and key regeneration on region set
- **Action Required**: ALL LA-Mesh participants must upgrade to v2.7.15+ and regenerate keys
- Reference: [NVD CVE-2025-52464](https://nvd.nist.gov/vuln/detail/CVE-2025-52464), [CyberPress Advisory](https://cyberpress.org/severe-meshtastic-flaw/)

**LA-Mesh mandatory security protocol:**
1. Flash v2.7.15+ firmware before deploying ANY device
2. Verify key uniqueness using `meshtastic --info` on each device
3. Document device key fingerprints in a secure community registry
4. Consider manual key generation via OpenSSL for maximum security

### 2.3 Reticulum: A Stronger Encryption Alternative

[Reticulum Network Stack](https://github.com/markqvist/Reticulum) provides fundamentally stronger encryption by design:

- **Mandatory encryption**: All traffic is encrypted; no option to disable
- **Forward secrecy**: Ephemeral keys generated via Elliptic Curve Diffie-Hellman on Curve25519
- **Sender privacy**: Decentralized addressing, no centralized key servers
- **Multi-transport**: Works over LoRa, packet radio, WiFi, TCP/IP, I2P simultaneously
- **Applications**: [Sideband](https://github.com/markqvist/Sideband) provides GUI with file transfers, voice messages, voice calls, mapping, and telemetry
- **Hardware**: [RNode](https://unsigned.io/rnode_bootstrap_console/m/networks.html) is an open-source LoRa transceiver designed for Reticulum

**Recommendation for LA-Mesh:** Support both Meshtastic (larger community, easier onboarding) and Reticulum (stronger security, more advanced users). Use Meshtastic as the "front door" and Reticulum for security-sensitive applications.

### 2.4 GPG/PGP Key Management for Community

**Web of Trust Model:**

LA-Mesh should establish a community web of trust using GPG keys for:
- Signing firmware images distributed to members
- Authenticating mesh network configuration files
- Signed announcements and governance decisions
- Verifying member identity in the network

**Key Signing Party Protocol:**
Based on established [key signing party best practices](https://www.cryptnet.net/fdp/crypto/keysigning_party/en/keysigning_party.html):

1. **Before the party**: Each participant generates a GPG key pair, publishes their public key to a keyserver or shared directory, and prints their key fingerprint on paper slips
2. **At the party** (NO computers allowed -- prevents MITM attacks):
   - Each participant distributes their fingerprint slip
   - Each participant verifies every other participant's government-issued ID
   - Each participant records verified fingerprints
3. **After the party**: Each participant signs the keys they verified using `caff` (from the `signing-party` package), and emails the signed key encrypted to the key owner
4. **Result**: A growing web of trust where community members can verify each other's identities

Reference: [Key Signing Party HOWTO](https://www.cryptnet.net/fdp/crypto/keysigning_party/en/keysigning_party.html), [Ubuntu KeySigningParty Guide](https://wiki.ubuntu.com/KeySigningParty)

### 2.5 Signal Protocol Concepts Applied to Mesh

The [Signal Protocol](https://en.wikipedia.org/wiki/Signal_Protocol) provides state-of-the-art properties:
- Forward secrecy (past messages stay secure if keys are compromised)
- Post-compromise security (future messages become secure after compromise)
- Deniable authentication
- Asynchronous key exchange

**Challenges for LoRa mesh:**
- Signal Protocol requires server-mediated key exchange (prekey bundles) -- incompatible with fully offline mesh
- Bandwidth requirements exceed typical LoRa capacity
- [Bridgefy](https://bridgefy.me/) has adapted Signal Protocol for Bluetooth mesh, but LoRa bandwidth constraints make this impractical

**What LA-Mesh can adopt from Signal:**
- The concept of rotating session keys (implemented partially in Reticulum)
- Double Ratchet algorithm concepts for message security
- Safety number verification UI patterns for verifying contacts
- Teaching Signal Protocol concepts helps members understand what "end-to-end encryption" means

**Practical recommendation**: Use Signal for internet-connected secure communications between LA-Mesh members. Use Meshtastic/Reticulum for off-grid mesh. Bridge the two where appropriate using MQTT gateways.

### 2.6 OPSEC Basics for Community Members

Drawing from [EFF's 2025 OPSEC training program](https://www.eff.org/deeplinks/2025/12/operations-security-opsec-trainings-2025-review) (66 organizations, 2000+ participants):

**Threat Modeling Framework (teach to all members):**
1. What assets am I protecting? (mesh traffic, location, identity, network topology)
2. Who might want to access them? (passive observers, law enforcement, hostile actors)
3. What are the consequences of compromise? (privacy loss, network disruption, physical safety)
4. What mitigations are available? (encryption, TAILS, anonymity practices)
5. What is my realistic capacity for security? (daily habits vs. emergency protocols)

**Practical OPSEC for mesh network participants:**

| Topic | Guidance |
|-------|----------|
| Device security | Set unique channel PSKs; never use default "LongFast" for sensitive comms |
| Location privacy | Disable GPS broadcast on nodes near your home; use fixed position offset |
| Identity | Use pseudonyms on the mesh; separate mesh identity from real identity |
| RF emissions | Understand that LoRa transmissions can be direction-found with SDR equipment |
| Metadata | Even encrypted messages reveal: timing, frequency, node IDs, approximate locations |
| Physical security | Secure rooftop nodes against tampering; use tamper-evident enclosures |
| Network topology | Understand that mesh topology itself reveals social relationships |
| Key management | Rotate channel PSKs periodically; use PKC for sensitive DMs |
| Firmware | Keep firmware updated (CVE-2025-52464 is a stark reminder) |
| TAILS | Use TAILS for mesh management tasks that require anonymity |

Reference: [OPSEC Guide 2025](https://mr-alias.com/articles/opsec-handbook.html), [State of Surveillance Mesh Guide](https://stateofsurveillance.org/articles/technical/mesh-networks-surveillance-resistance/), [Hacktive Security OPSEC Introduction](https://www.hacktivesecurity.com/blog/2025/01/21/introduction-to-opsec-part-1/)

---

## 3. Community Education Curriculum

### Curriculum Design Philosophy

Progressive learning from "plug and play" to "protocol hacker." Each level builds on the previous. Designed for community workshops at Bates College, the Lewiston Public Library, and LA-Mesh community events.

---

### Level 1: Basic Mesh Networking -- "Join the Network"

**Target audience:** Complete beginners, community members, non-technical participants
**Duration:** 2-hour workshop + 1-hour hands-on lab
**Prerequisites:** None

**Learning Objectives:**
- Understand what a mesh network is and why it matters for community resilience
- Successfully join the LA-Mesh network and send/receive messages
- Know the difference between Meshtastic and MeshCore
- Understand basic radio concepts (range, line-of-sight, obstacles)

**Hands-On Exercises:**
1. Unbox and power on a pre-configured Meshtastic device
2. Pair device with smartphone via Bluetooth
3. Send a message to the LA-Mesh default channel
4. Walk around campus/neighborhood to test range boundaries
5. Observe message hop counts and signal strength (SNR/RSSI)

**Required Equipment (per participant):**
- 1x Meshtastic-compatible device (Heltec V3 recommended for cost: ~$18-25)
- 1x Antenna (stock or upgraded whip)
- 1x USB-C cable
- Smartphone with Meshtastic app (Android or iOS)
- Battery pack (optional, for field testing)

**Assessment Criteria:**
- [ ] Successfully sent and received a message on the mesh
- [ ] Can explain what "mesh networking" means in their own words
- [ ] Can identify their device on the network map
- [ ] Understands that default channel is NOT private

**Reference Materials:**
- [Meshtastic Getting Started](https://meshtastic.org/docs/getting-started/)
- [Meshtastic Initial Configuration](https://meshtastic.org/docs/getting-started/initial-config/)
- [BestHamRadio Beginner Guide](https://www.besthamradio.com/how-to-set-up-meshtastic/)

---

### Level 2: Device Configuration and Optimization

**Target audience:** Level 1 graduates, technically curious participants
**Duration:** 3-hour workshop + 2-hour lab
**Prerequisites:** Level 1 completion

**Learning Objectives:**
- Flash firmware on Meshtastic and MeshCore devices
- Configure channels, radio parameters, and roles (client, router, repeater)
- Understand LoRa modulation parameters (spreading factor, bandwidth, coding rate)
- Optimize antenna placement for maximum range
- Set up a solar-powered repeater node

**Hands-On Exercises:**
1. Flash latest Meshtastic firmware using [web flasher](https://flasher.meshtastic.org/) or CLI
2. Create a private encrypted channel with custom PSK
3. Configure a device as a dedicated router node
4. Test different LoRa presets (LongFast, MediumSlow, ShortFast) and measure performance
5. Build a simple solar-powered node (solar panel + charge controller + device)
6. Flash MeshCore on a second device and compare protocols
7. Set up a MeshCore Room Server for store-and-forward messaging

**Required Equipment (per participant):**
- All Level 1 equipment
- 1x Computer with USB (for firmware flashing)
- 1x MeshCore-compatible device (for comparison)
- 1x 6V/2W solar panel + TP4056 charge controller (for solar node exercise)
- 1x Weatherproof enclosure (3D printed or commercial)

**Assessment Criteria:**
- [ ] Successfully flashed firmware on both Meshtastic and MeshCore devices
- [ ] Created and joined a custom encrypted channel
- [ ] Can explain the tradeoff between range and data rate (spreading factor)
- [ ] Built a functional solar-powered node
- [ ] Can articulate differences between Meshtastic and MeshCore routing

**Reference Materials:**
- [Meshtastic Supported Hardware](https://meshtastic.org/docs/hardware/devices/)
- [MeshCore GitHub](https://github.com/meshcore-dev/MeshCore)
- [RAK WisBlock Quick Start](https://docs.rakwireless.com/product-categories/meshtastic/wismesh-starter-kit/quickstart/)
- [OpenELAB Firmware Flashing Guide](https://openelab.io/blogs/getting-started/meshtastic-guide-how-to-flash-meshtastic-firmware)
- [Meshtastic vs MeshCore Comparison](https://www.austinmesh.org/learn/meshcore-vs-meshtastic/)

---

### Level 3: Encryption and Security Fundamentals

**Target audience:** Level 2 graduates, privacy-conscious community members
**Duration:** 4-hour workshop + 2-hour lab
**Prerequisites:** Level 2 completion

**Learning Objectives:**
- Understand symmetric vs. asymmetric encryption at a conceptual level
- Configure and verify Meshtastic PKC (public key cryptography) for DMs
- Set up GPG keys and participate in a key signing ceremony
- Implement basic OPSEC practices for mesh networking
- Understand TAILS and its role in secure mesh management
- Know about CVE-2025-52464 and why key management matters

**Hands-On Exercises:**
1. Generate a GPG key pair and publish to the LA-Mesh keyserver/directory
2. Participate in a mini key signing ceremony (verify IDs, exchange fingerprints)
3. Verify Meshtastic device key uniqueness (detect CVE-2025-52464 affected devices)
4. Send an encrypted DM using Meshtastic PKC and verify the encryption
5. Boot TAILS from USB, configure persistent storage, and connect a Meshtastic device
6. Create a personal threat model using the 5-question framework
7. Demonstrate how default "LongFast" messages can be read by anyone (using a second device)

**Required Equipment (per participant):**
- All Level 2 equipment
- 1x TAILS USB stick (8GB+, 16GB recommended)
- Government-issued ID (for key signing ceremony)
- Printed GPG key fingerprint slips

**Assessment Criteria:**
- [ ] Has a valid GPG key signed by at least 2 other community members
- [ ] Can explain the difference between channel encryption (PSK) and DM encryption (PKC)
- [ ] Successfully booted TAILS and connected a Meshtastic device
- [ ] Can articulate their personal threat model
- [ ] Verified their Meshtastic device keys are unique (not affected by CVE-2025-52464)

**Reference Materials:**
- [Meshtastic Encryption Technical Reference](https://meshtastic.org/docs/development/reference/encryption-technical/)
- [Hackers Arise: Securing Meshtastic](https://hackers-arise.com/off-grid-communications-part-4-securing-your-meshtastic-communications/)
- [TAILS Persistent Storage](https://tails.net/doc/persistent_storage/)
- [Key Signing Party HOWTO](https://www.cryptnet.net/fdp/crypto/keysigning_party/en/keysigning_party.html)
- [EFF OPSEC Training](https://www.eff.org/deeplinks/2025/12/operations-security-opsec-trainings-2025-review)

---

### Level 4: RF Engineering Basics (HackRF Demos)

**Target audience:** Level 3 graduates, STEM students, radio enthusiasts
**Duration:** 6-hour workshop (split over 2 sessions) + 3-hour lab
**Prerequisites:** Level 3 completion; basic command-line comfort

**Learning Objectives:**
- Understand electromagnetic spectrum fundamentals (frequency, wavelength, propagation)
- Use an SDR (Software Defined Radio) to visualize and decode LoRa signals
- Understand FCC Part 15 regulations for the 915MHz ISM band
- Perform basic RF site surveys for node placement
- Decode Meshtastic packets using GNU Radio and Wireshark

**Hands-On Exercises:**
1. Use HackRF One + GNU Radio to visualize the 915MHz ISM band spectrum
2. Identify LoRa chirp signals in the waterfall display
3. Decode Meshtastic packets using [GNU Radio LoRa decoder](https://www.jeffgeerling.com/blog/2025/decoding-meshtastic-gnuradio-on-raspberry-pi/)
4. Install the [Wireshark LoRa plugin](https://github.com/exploiteers/Exploiteers-Wireshark-LoRa/) and analyze packet structure
5. Measure antenna performance (SWR) using a NanoVNA
6. Conduct a basic RF site survey for optimal repeater placement
7. Calculate link budgets for point-to-point LoRa links

**Required Equipment (shared/lab equipment):**
- 2x HackRF One ($350 each) or RTL-SDR ($30 each, receive only)
- 1x NanoVNA ($50, for antenna analysis)
- 1x Computer with GNU Radio installed
- 1x Computer with Wireshark + LoRa plugin
- Various antennas (dipole, Yagi, collinear) for comparison testing
- Whiteboard for link budget calculations

**FCC Regulatory Content:**
- [FCC Part 15](https://www.ecfr.gov/current/title-47/chapter-I/subchapter-A/part-15) governs unlicensed operation in the 902-928MHz ISM band
- Maximum conducted power: 1W (+30 dBm) with antenna gain limits
- No duty cycle restrictions in the US (unlike EU)
- No license required for Part 15 compliant devices
- Meshtastic devices with FCC-certified modules inherit certification
- Reference: [LoRa FCC Certification Guide](https://www.sunfiretesting.com/LoRa-FCC-Certification-Guide/), [Digikey 915MHz Band Guide](https://www.digikey.com/en/articles/unlicensed-915-mhz-band-fits-many-applications-and-allows-higher-transmit-power)

**Amateur Radio Path:**
- [FCC Part 97](https://www.ecfr.gov/current/title-47/chapter-I/subchapter-D/part-97) governs amateur radio
- Technician license allows operation on 70cm band (430-440MHz) with higher power
- **CRITICAL**: Encryption is prohibited on amateur radio frequencies
- Meshtastic on 433MHz (ham band) requires callsign identification every 10 minutes
- LA-Mesh should partner with [Androscoggin County ARES](https://www.ka1aar.org/) for emergency communications integration
- Reference: [ARRL Part 97](http://www.arrl.org/part-97-amateur-radio), [Meshtastic FAQ on Ham](https://meshtastic.org/docs/faq/)

**Assessment Criteria:**
- [ ] Can identify LoRa signals in an SDR waterfall display
- [ ] Successfully decoded at least one Meshtastic packet in Wireshark
- [ ] Can explain FCC Part 15 power limits for 915MHz
- [ ] Completed a basic link budget calculation
- [ ] Can explain why encryption is prohibited on amateur radio frequencies

**Reference Materials:**
- [Great Scott Gadgets SDR Course](https://greatscottgadgets.com/sdr/)
- [HackRF One Complete Course](https://hackrfone.com/course/)
- [Jeff Geerling: Decoding Meshtastic with GNU Radio](https://www.jeffgeerling.com/blog/2025/decoding-meshtastic-gnuradio-on-raspberry-pi/)
- [Philly Mesh: Real-Time Meshtastic Decoding](https://phillymesh.net/post/2026-01-10-scapy-meshtastic-decoder/)
- [RTL-SDR: Decoding Meshtastic in Realtime](https://www.rtl-sdr.com/decoding-meshtastic-in-realtime-with-an-rtl-sdr-and-gnu-radio/)

---

### Level 5: Advanced Topics

**Target audience:** Level 4 graduates, CS/engineering students, advanced hobbyists
**Duration:** Ongoing seminar series (monthly sessions)
**Prerequisites:** Level 4 completion

**Learning Objectives:**
- Understand TEMPEST (Van Eck Phreaking) side-channel attacks
- Perform protocol analysis on mesh network traffic
- Develop bridges between mesh networks and internet services
- Understand Reticulum's advanced cryptographic model
- Contribute to open-source mesh networking projects

#### 5A: TEMPEST and Side-Channel Analysis

**Hands-On Exercises:**
1. Use [TempestSDR](https://github.com/aalex954/tempest-sdr-demo) with HackRF to reconstruct video from HDMI cable emissions
2. Demonstrate LoRa direction-finding using multiple SDR receivers
3. Analyze electromagnetic emissions from Meshtastic devices
4. Discuss countermeasures (shielding, TEMPEST-rated equipment, emission management)

Reference: [TempestSDR Demo](https://github.com/aalex954/tempest-sdr-demo), [RTL-SDR TEMPEST](https://www.rtl-sdr.com/tag/tempest/), [Medium: Practical TEMPEST Attack](https://medium.com/@jeroenverhaeghe/practical-tempest-sdr-attack-1bbc07cfa8)

#### 5B: Protocol Analysis

**Hands-On Exercises:**
1. Capture and decode full Meshtastic protocol stack using SDR + Scapy
2. Analyze Meshtastic routing behavior (managed flood vs. next-hop)
3. Compare MeshCore multi-hop routing efficiency
4. Identify metadata leakage in encrypted mesh traffic
5. Write a custom Wireshark dissector for a mesh protocol extension

Reference: [Disk91: Critical Analysis of Meshtastic Protocol](https://www.disk91.com/2024/technology/lora/critical-analysis-of-the-meshtastic-protocol/), [Exploiteers Wireshark Plugin](https://github.com/exploiteers/Exploiteers-Wireshark-LoRa/)

#### 5C: Bridge Development

**Hands-On Exercises:**
1. Set up a Meshtastic MQTT bridge to connect local mesh to internet
2. Configure a [MeshCore MQTT Gateway](https://github.com/jmead/Meshcore-Repeater-MQTT-Gateway)
3. Build a [meshtastic-bridge](https://github.com/geoffwhittington/meshtastic-bridge) instance for multi-platform bridging
4. Set up Reticulum with multiple transport types (LoRa + TCP/IP)
5. (Advanced) Route MQTT through a Tor hidden service for anonymous bridging
6. (Advanced) Develop a custom bridge between Meshtastic and Matrix/Element

Reference: [Meshtastic MQTT Docs](https://meshtastic.org/docs/software/integrations/mqtt/), [Hackers Arise MQTT Bridge Guide](https://hackers-arise.com/off-grid-communications-part-3-extending-meshtastic-communication-range-with-mqtt-bridges/), [Reticulum Manual](https://reticulum.network/manual/whatis.html)

#### 5D: Reticulum Deep Dive

**Hands-On Exercises:**
1. Set up a Reticulum network with RNode devices
2. Configure [Sideband](https://github.com/markqvist/Sideband) for encrypted messaging
3. Build a multi-transport Reticulum bridge (LoRa + WiFi + TCP/IP)
4. Explore Reticulum's [MeshChat](https://github.com/liamcottle/reticulum-meshchat) for community communication
5. Implement custom Reticulum destinations and services

**Assessment Criteria (Level 5 overall):**
- [ ] Demonstrated one TEMPEST side-channel attack in a controlled environment
- [ ] Captured and decoded mesh protocol traffic using SDR + software tools
- [ ] Built and deployed at least one functional bridge between mesh and internet
- [ ] Contributed documentation, code, or analysis to an open-source mesh project

---

## 4. Community Resilience Angle

### 4.1 Mesh Networks for Emergency Communications

**The case for LA-Mesh as emergency infrastructure:**

During the 2018 Camp Fire in Northern California, 17 cell towers were knocked out on the first day. Emergency evacuation alerts failed to reach two-thirds of local residents who subscribed to receive them. [Source: goTenna](https://gotenna.com/blogs/newsroom/mesh-networks-can-connect-us-during-disasters)

LoRa mesh networks provide:
- **Zero infrastructure dependency**: No cell towers, no internet, no power grid required
- **Rapid deployment**: A community mesh can be operational within minutes
- **Resilience**: No single point of failure; nodes self-organize
- **Long range**: LoRa signals travel 1-10+ km depending on terrain and antenna height
- **Low power**: Devices run on batteries for days; solar-powered indefinitely

**Southern Maine specific scenarios:**
- Nor'easters and ice storms disrupting power and cell service
- Flooding along the Androscoggin River
- Lewiston-Auburn bridge infrastructure failure isolating communities
- Mass casualty events (the community is painfully familiar with this need)
- Campus emergency communications for Bates College

### 4.2 Disaster Preparedness Applications

**Tier 1: Always-On Community Mesh**
- Solar-powered repeater nodes on Bates College buildings, church steeples, and municipal structures
- Community members carry personal nodes for daily use (normalized mesh culture)
- When disaster strikes, the network is ALREADY operational

**Tier 2: Rapid Deployment Kit**
- Pre-configured "grab bag" mesh kits stored at designated locations
- Include: 5x Meshtastic nodes, 5x antennas, 5x battery packs, 1x solar panel, laminated instructions
- Can extend mesh coverage to evacuation centers, hospitals, shelters

**Tier 3: Interoperability with Emergency Services**
- Bridge to Androscoggin County ARES amateur radio network
- Gateway to FEMA Integrated Public Alert and Warning System (IPAWS)
- Coordinate with [Maine Emergency Management Agency community preparedness](https://www.maine.gov/mema/maine-prepares/community-preparedness)

### 4.3 Androscoggin County ARES Integration

[Androscoggin County ARES/RACES](https://www.ka1aar.org/) (callsign KA1AAR) provides emergency communications for Androscoggin County. Key integration opportunities:

- **Emergency Coordinator**: Paul Leonard, KE6PIJ
- **Training nets**: Weekly training nets with monthly topic rotation
- **Events**: Beach-to-Beacon, Dempsey Challenge, ARRL Maine State Convention
- **Maine Emergency Communications Net**: 2nd and 4th Sundays at 5PM on 3.940 MHz

**Recommended partnership:**
1. Attend ARES training nets to introduce LA-Mesh
2. Propose joint exercises (LoRa mesh + HF radio for multi-band emergency comms)
3. Offer to provide LoRa mesh nodes for ARES field exercises
4. Pursue Technician license study group for LA-Mesh members interested in amateur radio

### 4.4 Community Network Governance Models

Based on lessons from [NYC Mesh](https://www.nycmesh.net/) and other community networks:

**Network Commons License:**
NYC Mesh uses a [Network Commons License](https://www.nycmesh.net/ncl.pdf) with four tenets:
1. Participants are free to use the network for any purpose that doesn't limit others
2. Participants are free to know how the network and its components function
3. Participants are free to offer and accept services on their own terms
4. Participants agree to extend the network to others under the same conditions

**Recommended LA-Mesh governance structure:**

| Component | Model |
|-----------|-------|
| Legal entity | Nonprofit 501(c)(3) or unincorporated association (initially) |
| Decision making | Consensus-based with elected coordinators |
| Network policy | Adapted Network Commons License |
| Membership | Open to all; no fees required; donations welcome |
| Technical decisions | Working group with community input |
| Conflict resolution | Mediation by elected community members |
| Transparency | Public meeting notes, open-source everything |

### 4.5 Legal Considerations

**FCC Part 15 (Unlicensed Operation):**
- Meshtastic and MeshCore devices operate under [FCC Part 15](https://www.ecfr.gov/current/title-47/chapter-I/subchapter-A/part-15) in the 902-928MHz ISM band
- Maximum 1W conducted power (+30 dBm)
- No license required; no duty cycle restrictions in the US
- Devices must use FCC-certified radio modules
- Reference: [EFF: Good News for LoRa & Mesh](https://www.eff.org/deeplinks/2025/07/radio-hobbyists-rejoice-good-news-lora-mesh)

**Amateur Radio (FCC Part 97):**
- Higher power and dedicated bands available with Technician license or above
- **Encryption is PROHIBITED on amateur frequencies** (including Meshtastic's encryption)
- Callsign identification required every 10 minutes
- No commercial use
- Reference: [FCC Part 97](https://www.ecfr.gov/current/title-47/chapter-I/subchapter-D/part-97)

**Rooftop Installation Liability:**
- Building owners should require certificate of liability insurance from installers
- Include the building owner as additional insured on Commercial General Liability policy
- Provide RF Electromagnetic Fields Emissions Safety Report if requested
- Verify installation will not affect existing telecommunications at the building
- NYC Mesh's approach: Initially use home ISP connections (legal in the US), community-owned equipment
- Reference: [Phillips Nizer Rooftop Installations](https://www.phillipsnizer.com/mining-the-roof), [NYC Mesh FAQ](https://www.nycmesh.net/faq)

**Privacy and Data:**
- LoRa transmissions can be received by anyone with appropriate equipment
- Metadata (timing, node IDs, locations) is visible even with payload encryption
- Follow NYC Mesh's policy: collect and store no user data, so no data exists to provide if requested
- Reference: [NYC Mesh Protecting the Mesh](https://wiki.nycmesh.net/books/4-organization-mission/page/protecting-the-mesh)

**Content Liability:**
- Network operators should establish acceptable use policies
- Prohibit illegal activity, copyright violations, spam
- Use disclaimers similar to Wi-Fi hotspot operators
- Reference: [MBM Law: Wi-Fi Hotspot Liability](https://www.mbm-law.net/insights/wi-fi-hotspots-and-liability-concerns/)

---

## 5. Similar Community Projects

### 5.1 NYC Mesh

- **Website**: [nycmesh.net](https://www.nycmesh.net/)
- **Scale**: 2,000+ active nodes across New York City's five boroughs
- **Technology**: Primarily WiFi mesh (Ubiquiti hardware), not LoRa
- **Organization**: Nonprofit (EIN: 84-2616395), volunteer-driven
- **Governance**: Network Commons License
- **Funding**: Donations, suggested installation fee (~$50-100)
- **Lessons for LA-Mesh**:
  - Start small, grow organically
  - Education and outreach are as important as technical work
  - Don't over-engineer: avoid "tech-solutionism"
  - Build community FIRST, then build network
  - Maintenance is the biggest ongoing challenge
  - Library partnerships are effective outreach channels
- Reference: [NYC Mesh Wikipedia](https://en.wikipedia.org/wiki/NYC_Mesh), [How to Start a Community Network](https://www.nycmesh.net/blog/how/), [Urban Omnibus: Mesh Together](https://urbanomnibus.net/2023/05/mesh-together/)

### 5.2 Althea

- **Website**: [althea.net](https://www.althea.net/)
- **Scale**: Deployed in 4 countries, 12 US states, thousands of homes
- **Technology**: WiFi mesh with blockchain-incentivized routing
- **Innovation**: End users pay tokens for internet access; rooftop transmitters earn tokens for forwarding traffic
- **Governance**: On-chain governance via Althea L1 blockchain
- **Lessons for LA-Mesh**:
  - Incentive models can sustain community networks
  - Blockchain-based governance is complex but provides transparency
  - Challenging terrain deployments are their specialty
  - More commercially oriented than LA-Mesh's community model
- Reference: [Althea Overview](https://www.althea.net/), [Althea Governance Model](https://blog.althea.net/the-althea-governance-model/)

### 5.3 goTenna

- **Website**: [gotenna.com](https://gotenna.com/)
- **Technology**: Proprietary mesh radios (900MHz ISM band)
- **Deployments**: Used by FEMA, Red Cross, military, and emergency responders
- **Lessons for LA-Mesh**:
  - Emergency response is the strongest use case for mesh
  - Elevation is everything: 2 relay nodes at elevation can cover 60 linear km
  - During Hurricane Dorian, deployed to Bahamas within 48 hours of landfall
  - Proprietary = vendor lock-in; LA-Mesh's open-source approach is superior for community ownership
- Reference: [goTenna Emergency Management Guide](https://community.gotennamesh.com/t/gotenna-mesh-user-guide-for-emergency-management-disaster-response/498), [goTenna Disaster Communications](https://gotenna.com/blogs/newsroom/mesh-networks-can-connect-us-during-disasters)

### 5.4 Disaster Radio

- **Website**: [disaster.radio](https://disaster.radio/learn/)
- **Technology**: Solar-powered ESP32 + LoRa nodes with WiFi captive portal
- **Status**: Project is no longer actively maintained (as of 2024)
- **Innovation**: Users connect via phone WiFi to a local LoRa node (no app needed)
- **Lessons for LA-Mesh**:
  - Solar + LoRa + WiFi captive portal is an elegant design for public access
  - Community access without requiring an app lowers barriers dramatically
  - Project sustainability requires ongoing community engagement
  - Open hardware design (can be replicated)
- Reference: [Disaster Radio Project](https://disaster.radio/learn/), [Hackaday: Disaster Radio](https://hackaday.io/project/170069-disaster-radio-lora-mesh)

### 5.5 Reticulum Network Stack

- **Website**: [reticulum.network](https://reticulum.network/)
- **Developer**: Mark Qvist
- **Technology**: Transport-agnostic cryptographic mesh (LoRa, WiFi, TCP/IP, I2P, packet radio)
- **Philosophy**: "Build unstoppable networks"
- **Key advantage**: Mandatory encryption with forward secrecy, unlike Meshtastic
- **Applications**: Sideband (GUI client), MeshChat, NomadNet (text-based social network)
- **Lessons for LA-Mesh**:
  - Security-first design attracts privacy-conscious participants
  - Multi-transport capability means the network can grow beyond LoRa
  - Smaller community (vs. Meshtastic) but more technically sophisticated
  - Ideal for the "advanced" tier of LA-Mesh participants
- Reference: [Reticulum GitHub](https://github.com/markqvist/Reticulum), [Reticulum Manual](https://reticulum.network/manual/whatis.html), [Mesh Underground: Reticulum Overview](https://meshunderground.com/posts/1743612357295-reticulum-mesh-network---secure-communication-beyond-the-internet/)

### 5.6 RegionMesh / Community MeshCore Networks

- **Website**: [regionmesh.com](https://www.regionmesh.com/)
- **Technology**: MeshCore-based regional mesh networks
- **Growth**: Rapid expansion since early 2025
- **Innovation**: Dedicated repeater infrastructure + lightweight client model
- **Lessons for LA-Mesh**:
  - Infrastructure-node model (repeaters + clients) may scale better than Meshtastic's all-router approach
  - Room Servers provide asynchronous messaging (critical for emergency comms)
  - Store-and-forward model is resilient to intermittent connectivity
- Reference: [RegionMesh](https://www.regionmesh.com/), [MeshCore GitHub](https://github.com/meshcore-dev/MeshCore)

### 5.7 Comparative Analysis

| Feature | NYC Mesh | Althea | goTenna | Disaster Radio | Reticulum | MeshCore | Meshtastic |
|---------|----------|--------|---------|----------------|-----------|----------|------------|
| Technology | WiFi | WiFi+Blockchain | Proprietary RF | LoRa+WiFi | Multi-transport | LoRa | LoRa |
| Open Source | Yes | Partial | No | Yes | Yes | Yes | Yes |
| Encryption | WPA/TLS | WPA/TLS | AES | None | Curve25519+AES | AES-256 | AES-256+PKC |
| Forward Secrecy | N/A | N/A | No | No | Yes | No | No |
| License Required | No | No | No | No | No | No | No |
| Active Community | Large | Medium | Commercial | Inactive | Growing | Growing | Very Large |
| Emergency Focus | Moderate | Low | High | High | Moderate | Moderate | Growing |
| Cost Per Node | $200+ | $200+ | $180 | $20-50 | $30-100 | $18-50 | $18-50 |

---

## 6. Bates College Integration

### 6.1 Digital and Computational Studies (DCS) Department

**This is the primary institutional partner for LA-Mesh.**

[Bates College DCS](https://www.bates.edu/digital-computational-studies/) is a new interdisciplinary program (major offered since ~2025) with five core elements:
1. Computer Science
2. Data Science, Analysis, and Visualization
3. Critical Digital Studies
4. Human-Centered Design
5. **Community-Engaged Learning** <-- Direct alignment with LA-Mesh

Funded by $19 million in gifts from Bates families. The program explicitly includes community-engaged capstone projects.

Reference: [Bates DCS Announcement](https://www.bates.edu/news/2025/04/08/bates-newest-major-digital-and-computational-studies-blends-computer-science-with-critique-community-engagement/)

### 6.2 Leveraging College Infrastructure

**Physical assets:**
- Rooftop access on multiple campus buildings (excellent LoRa propagation)
- Bell tower and other high points for repeater placement
- Reliable power for always-on nodes
- Indoor lab space for workshops and curriculum delivery
- Campus WiFi for MQTT gateway nodes

**Proposal: LA-Mesh as DCS Capstone Project**

DCS seniors complete a community-engaged capstone project. LA-Mesh is an ideal candidate:
- Real-world engineering challenge (mesh network design and deployment)
- Community engagement component (teaching workshops, writing guides)
- Critical digital studies angle (surveillance resistance, digital equity, community resilience)
- Data science component (network telemetry, coverage mapping, performance analysis)

### 6.3 Research and Academic Angles for Grants

**Potential grant sources:**

| Source | Program | Relevance | Amount |
|--------|---------|-----------|--------|
| NSF | Computer and Information Science and Engineering (CISE) | Mesh networking research | $100K-500K |
| NTIA | [Digital Equity Competitive Grant](https://broadbandusa.ntia.gov/funding-programs/Digital_Equity_Competitive_Grant_Program) | Community connectivity | $50K-5M |
| Hewlett Foundation | Open education / digital equity | Aligns with Bates existing grants | Varies |
| ARRL Foundation | Amateur radio education | Ham radio integration | $500-5K |
| Maine Community Foundation | Community resilience | Southern Maine focus | $5K-50K |

**Research paper opportunities:**
- "Community Mesh Networks as Digital Equity Infrastructure in Post-Industrial New England"
- "Security Analysis of LoRa Mesh Protocols for Community Emergency Communications"
- "Pedagogical Approaches to Community Technology Education: The LA-Mesh Case Study"
- "Measuring Mesh Network Performance in Northern New England RF Environments"

### 6.4 Student Involvement and Course Credit

**Existing course alignment:**

| Bates Course/Program | LA-Mesh Integration |
|---------------------|---------------------|
| DCS Capstone | Design, deploy, and document the mesh network |
| DCS: Digital Innovation in/for Community Engagement | Build LA-Mesh web tools, guides, apps |
| DCS: Public History in the Digital Age | Document the history of community networking |
| Physics/Engineering | Antenna design, RF propagation studies |
| Sociology | Community network governance, digital divide analysis |
| Environmental Studies | Solar-powered infrastructure, resilience planning |

**Student roles:**
- Network architects (DCS/CS students)
- Workshop facilitators (any discipline)
- Documentarians (DCS/Communications students)
- Community liaisons (Harward Center affiliates)
- Research assistants (for grant-funded projects)

### 6.5 Harward Center for Community Partnerships

[The Harward Center](https://www.bates.edu/harward/) is Bates' community engagement hub:
- [Community Partner Grants](https://www.bates.edu/harward/grants-2/communitypartners/): Up to $2,000 for programming connecting Bates and L-A community
- Community Work-Study Fellowships: $8/hour for students working on community projects
- Community-Based Research Fellows: $750 grants
- Transportation Assistance: $100 grants for community partner engagement

**Recommended approach:**
1. Register LA-Mesh as a Harward Center community partner
2. Apply for Community Partner Grant ($2,000) for initial equipment
3. Recruit DCS students through capstone program
4. Propose LA-Mesh workshops as Harward Center programming

### 6.6 IRB Considerations

If LA-Mesh involves any research on human subjects (e.g., studying how community members adopt mesh technology, surveying network usage patterns), Bates College IRB review is required.

**When IRB review IS needed:**
- Surveys or interviews about mesh network usage
- Observational studies of community adoption
- Analysis of communication patterns on the network
- Any data collection that could identify individual participants

**When IRB review is NOT needed:**
- Purely technical network performance testing
- Equipment deployment and configuration
- Writing documentation and guides
- Teaching workshops (educational, not research)

**Recommendation:** Submit an IRB protocol early, even if initially exempt. This enables future research without delay and demonstrates institutional credibility for grant applications.

---

## 7. Documentation and Guides

### 7.1 Recommended Guide Structure for LA-Mesh Website

Based on research into community mesh project documentation (NYC Mesh, Meshtastic official docs, RegionMesh, Philly Mesh):

```
docs/
├── getting-started/
│   ├── what-is-la-mesh.md         # Overview, mission, coverage map
│   ├── join-the-network.md         # Step-by-step network joining guide
│   ├── buy-a-device.md            # Recommended devices and where to buy
│   └── first-message.md           # Send your first message tutorial
│
├── device-guides/
│   ├── heltec-v3-setup.md         # Heltec WiFi LoRa 32 V3 (recommended beginner)
│   ├── t-beam-setup.md            # LilyGo T-Beam (GPS + battery)
│   ├── rak-wisblock-setup.md      # RAK WisBlock Meshtastic Starter Kit
│   ├── meshcore-companion.md      # MeshCore companion device setup
│   ├── solar-node-build.md        # Solar-powered repeater build guide
│   └── firmware-update.md         # How to update firmware (web flasher + CLI)
│
├── security/
│   ├── encryption-overview.md      # How mesh encryption works
│   ├── channel-security.md         # Setting up secure channels
│   ├── dm-encryption.md           # PKC direct messages
│   ├── gpg-setup.md              # GPG key generation and management
│   ├── tails-guide.md            # TAILS + Meshtastic setup
│   ├── opsec-basics.md           # Operational security for mesh users
│   └── known-vulnerabilities.md   # CVE tracking and mitigation guides
│
├── network/
│   ├── coverage-map.md           # LA-Mesh coverage area and node map
│   ├── node-placement.md         # Where to put nodes for best coverage
│   ├── repeater-setup.md         # Setting up a repeater/router node
│   ├── mqtt-bridge.md            # Connecting mesh to internet via MQTT
│   └── reticulum-guide.md        # Alternative: Reticulum Network Stack
│
├── community/
│   ├── governance.md             # Network commons license, decision making
│   ├── code-of-conduct.md        # Community standards
│   ├── meetings.md               # Meeting schedule and notes
│   ├── contribute.md             # How to contribute (nodes, documentation, code)
│   └── emergency-plan.md         # Emergency communications procedures
│
├── legal/
│   ├── fcc-compliance.md         # FCC Part 15 and Part 97 overview
│   ├── rooftop-installation.md    # Liability and insurance for installations
│   ├── privacy-policy.md         # What data we collect (ideally: none)
│   └── acceptable-use.md         # Network acceptable use policy
│
├── education/
│   ├── curriculum-overview.md     # 5-level learning path
│   ├── level-1-basics.md         # Workshop materials
│   ├── level-2-configuration.md   # Workshop materials
│   ├── level-3-security.md       # Workshop materials
│   ├── level-4-rf-engineering.md  # Workshop materials
│   ├── level-5-advanced.md       # Seminar materials
│   └── resources.md              # External learning resources
│
└── troubleshooting/
    ├── no-messages.md             # Can't send/receive messages
    ├── device-not-detected.md     # Device not showing up on computer/phone
    ├── poor-range.md              # Getting poor range
    ├── firmware-issues.md         # Firmware flash failures
    └── faq.md                     # Frequently asked questions
```

### 7.2 Priority Guide Writing Order

**Sprint 1 (Weeks 1-2): Foundation**
1. what-is-la-mesh.md
2. join-the-network.md
3. buy-a-device.md
4. heltec-v3-setup.md (most common beginner device)
5. governance.md
6. fcc-compliance.md

**Sprint 2 (Weeks 3-4): Security and Community**
7. encryption-overview.md
8. channel-security.md
9. opsec-basics.md
10. code-of-conduct.md
11. coverage-map.md
12. faq.md

**Sprint 3 (Weeks 5-8): Depth**
13. t-beam-setup.md
14. rak-wisblock-setup.md
15. firmware-update.md
16. solar-node-build.md
17. gpg-setup.md
18. dm-encryption.md

**Sprint 4 (Weeks 9-12): Advanced and Education**
19. tails-guide.md
20. mqtt-bridge.md
21. reticulum-guide.md
22. curriculum-overview.md
23. All level-specific workshop materials
24. emergency-plan.md

---

## Sprint Integration Points

### Phase 1: Foundation (Weeks 1-4)

**Curriculum Development:**
- [ ] Draft Level 1 workshop materials
- [ ] Draft Level 2 workshop materials
- [ ] Identify workshop venue (Bates campus room, Lewiston Public Library)
- [ ] Order initial equipment (10x Heltec V3, 2x T-Beam, antennas, cables)

**Guide Writing:**
- [ ] Complete Sprint 1 guides (foundation docs)
- [ ] Begin Sprint 2 guides (security and community)
- [ ] Set up documentation site (GitHub Pages or similar)

**Go/No-Go Decisions:**
- **GO/NO-GO: Meshtastic vs. MeshCore as primary protocol** -- Decision needed by end of Week 2. Recommendation: Meshtastic primary (larger community, more beginner-friendly), MeshCore secondary (better store-and-forward, delivery confirmation). Both are LoRa-based and use similar hardware.
- **GO/NO-GO: Nonprofit formation** -- Decide whether to form 501(c)(3) or operate as unincorporated association initially. Recommendation: Start as informal association; incorporate when handling >$5K in annual equipment/donations.

**Community Outreach:**
- [ ] Contact Bates DCS department (propose capstone partnership)
- [ ] Contact Harward Center (register as community partner)
- [ ] Contact Androscoggin County ARES (introduce LA-Mesh, propose collaboration)
- [ ] Attend one ARES training net (2nd or 4th Sunday, 5PM, 3.940 MHz)
- [ ] Post on r/meshtastic and regional mesh forums

### Phase 2: Network Deployment (Weeks 5-8)

**Curriculum Development:**
- [ ] Deliver first Level 1 workshop (target: 10-15 participants)
- [ ] Gather feedback, iterate on materials
- [ ] Draft Level 3 workshop materials (encryption and security)
- [ ] Schedule first key signing party

**Guide Writing:**
- [ ] Complete Sprint 2 and Sprint 3 guides
- [ ] Publish device-specific setup guides
- [ ] Create video walkthroughs for top 3 most common tasks

**Go/No-Go Decisions:**
- **GO/NO-GO: Rooftop node deployment** -- Requires: building owner permission, basic liability agreement, tested equipment. Recommendation: Start with Bates campus buildings (institutional support simplifies permissions).
- **GO/NO-GO: MQTT bridge deployment** -- Requires: reliable internet connection at bridge location, security review of MQTT configuration. Recommendation: Deploy after completing encryption-overview.md and conducting security review.

**Community Outreach:**
- [ ] Host first community "Mesh Meet" (informal gathering with demos)
- [ ] Reach out to Lewiston Public Library for workshop space
- [ ] Contact local makerspaces/hackerspaces
- [ ] Engage Bates student organizations (CS club, physics club, environmental groups)

### Phase 3: Expansion and Security (Weeks 9-16)

**Curriculum Development:**
- [ ] Deliver Level 2 and Level 3 workshops
- [ ] Host first key signing party
- [ ] Begin Level 4 materials development (coordinate HackRF/SDR equipment access)
- [ ] Pilot TAILS + Meshtastic workshop with security-interested participants

**Guide Writing:**
- [ ] Complete Sprint 4 guides (advanced and education)
- [ ] Publish complete curriculum on website
- [ ] Create printable quick-reference cards for field use

**Go/No-Go Decisions:**
- **GO/NO-GO: Reticulum parallel deployment** -- Requires: 3+ participants with technical aptitude, RNode or compatible hardware. Recommendation: Deploy as "advanced tier" for security-focused participants.
- **GO/NO-GO: Tor bridge** -- Requires: stable MQTT bridge, TAILS-capable hardware, operator willing to maintain. Recommendation: Experimental only; defer to Phase 4 unless strong demand.
- **GO/NO-GO: Grant applications** -- Requires: established community, documented impact metrics, institutional partner (Bates). Recommendation: Apply for Harward Center Community Partner Grant ($2K) immediately; larger grants in Phase 4.

**Community Outreach:**
- [ ] Present at Bates College event or class
- [ ] Joint exercise with Androscoggin ARES
- [ ] Coverage mapping event (community members walk/drive with devices to map coverage)
- [ ] Document and publish coverage map

### Phase 4: Maturity and Sustainability (Weeks 17-26)

**Curriculum Development:**
- [ ] Deliver all 5 curriculum levels at least once
- [ ] Begin Level 5 seminar series (monthly)
- [ ] Publish curriculum as open educational resource (OER)
- [ ] Propose DCS capstone project for next academic year

**Guide Writing:**
- [ ] Complete all documentation
- [ ] Conduct documentation review with community members (usability testing)
- [ ] Translate critical guides to languages spoken in L-A community (Somali, French)

**Go/No-Go Decisions:**
- **GO/NO-GO: Nonprofit incorporation** -- Requires: >$5K annual throughput, insurance needs, grant eligibility requirements. Evaluate at this point.
- **GO/NO-GO: NSF/NTIA grant application** -- Requires: documented community impact, institutional partner letter, preliminary research results.

**Community Outreach:**
- [ ] Host public demo day (inviting press, city officials, college administration)
- [ ] Connect with other community mesh projects (NYC Mesh, Philly Mesh, etc.)
- [ ] Establish regular meeting cadence (monthly community meetings)
- [ ] Publish first annual report

### Gap Analysis

**Critical gaps identified during research:**

| Gap | Description | Mitigation | Priority |
|-----|-------------|------------|----------|
| TAILS + Meshtastic tested workflow | No existing guide for TAILS serial connection to Meshtastic exists publicly | LA-Mesh must create and test this workflow from scratch | HIGH |
| Tor + LoRa mesh bridge | Conceptually sound but no production implementation documented | Treat as experimental; develop in Level 5 curriculum | MEDIUM |
| CVE response process | No community process for responding to Meshtastic/MeshCore CVEs | Establish security advisory mailing list and firmware update protocol | HIGH |
| MeshCore documentation gap | MeshCore is newer with less community documentation than Meshtastic | Contribute documentation upstream as we develop MeshCore guides | MEDIUM |
| Insurance/liability template | No open-source template for community mesh rooftop installation agreements | Adapt NYC Mesh's approach; consult with local attorney | HIGH |
| Multilingual guides | L-A has significant Somali and Francophone communities | Plan for translation in Phase 4; recruit bilingual community members | MEDIUM |
| Amateur radio licensing pipeline | No existing Technician license study group in the LA-Mesh community | Partner with Androscoggin ARES to offer license exam sessions | LOW |
| Sustainability funding | No recurring funding model beyond donations | Explore Althea-style incentive models, grant funding, institutional partnerships | HIGH |
| Reticulum + Meshtastic interop | The two protocols are completely incompatible | Deploy as parallel networks with shared physical infrastructure | LOW |
| Emergency services integration | No formal MOU with Androscoggin County EMA | Begin relationship building in Phase 2; formalize in Phase 4 | MEDIUM |

### Key External Dependencies

| Dependency | Owner | Risk | Mitigation |
|-----------|-------|------|------------|
| Meshtastic firmware updates | Meshtastic project | Medium (CVE-2025-52464 showed supply chain risk) | Monitor releases; test before deploying to community |
| MeshCore development | Andy Kirby / community | Medium (newer project, smaller team) | Contribute upstream; maintain fork if necessary |
| Bates College partnership | DCS Department / Harward Center | Low (strong mission alignment) | Formalize partnership early; multiple contact points |
| ARES collaboration | Paul Leonard, KE6PIJ | Low (mutual interest) | Attend nets regularly; offer value first |
| FCC regulatory environment | FCC | Low (Part 15 ISM band is well-established) | Monitor EFF and ARRL regulatory updates |
| TAILS project continuity | Tails developers | Low (well-funded, Tor Project support) | Standard dependency; no unique risk |

---

## Appendix A: Key URLs and References

### Official Documentation
- Meshtastic: https://meshtastic.org/docs/
- MeshCore: https://github.com/meshcore-dev/MeshCore
- Reticulum: https://reticulum.network/
- TAILS: https://tails.net/
- FCC Part 15: https://www.ecfr.gov/current/title-47/chapter-I/subchapter-A/part-15
- FCC Part 97: https://www.ecfr.gov/current/title-47/chapter-I/subchapter-D/part-97

### Community Projects
- NYC Mesh: https://www.nycmesh.net/
- NYC Mesh Network Commons License: https://www.nycmesh.net/ncl.pdf
- Althea: https://www.althea.net/
- RegionMesh: https://www.regionmesh.com/
- Disaster Radio: https://disaster.radio/learn/
- Philly Mesh: https://phillymesh.net/

### Security and Privacy
- Meshtastic Encryption: https://meshtastic.org/docs/overview/encryption/
- Meshtastic PKC: https://meshtastic.org/blog/introducing-new-public-key-cryptography-in-v2_5/
- CVE-2025-52464: https://nvd.nist.gov/vuln/detail/CVE-2025-52464
- EFF OPSEC Training: https://www.eff.org/deeplinks/2025/12/operations-security-opsec-trainings-2025-review
- Key Signing Party HOWTO: https://www.cryptnet.net/fdp/crypto/keysigning_party/en/keysigning_party.html
- TAILS Persistent Storage: https://tails.net/doc/persistent_storage/

### RF Engineering and SDR
- Great Scott Gadgets SDR Course: https://greatscottgadgets.com/sdr/
- Wireshark LoRa Plugin: https://github.com/exploiteers/Exploiteers-Wireshark-LoRa/
- TempestSDR Demo: https://github.com/aalex954/tempest-sdr-demo
- Jeff Geerling GNU Radio Meshtastic: https://www.jeffgeerling.com/blog/2025/decoding-meshtastic-gnuradio-on-raspberry-pi/
- RTL-SDR Meshtastic Decode: https://www.rtl-sdr.com/decoding-meshtastic-in-realtime-with-an-rtl-sdr-and-gnu-radio/

### Bates College
- DCS Department: https://www.bates.edu/digital-computational-studies/
- Harward Center: https://www.bates.edu/harward/
- Community Partner Grants: https://www.bates.edu/harward/grants-2/communitypartners/
- Research Opportunities: https://www.bates.edu/academics/research-opportunities/
- External Grants: https://www.bates.edu/grants/

### Local Emergency Management
- Androscoggin County EMA: https://androscoggincountyema.gov/
- Androscoggin ARES: https://www.ka1aar.org/
- Maine EMA Community Preparedness: https://www.maine.gov/mema/maine-prepares/community-preparedness

### Legal and Regulatory
- EFF LoRa & Mesh: https://www.eff.org/deeplinks/2025/07/radio-hobbyists-rejoice-good-news-lora-mesh
- LoRa FCC Certification Guide: https://www.sunfiretesting.com/LoRa-FCC-Certification-Guide/
- NYC Mesh FAQ (legal): https://www.nycmesh.net/faq

### Bridges and Gateways
- Meshtastic MQTT: https://meshtastic.org/docs/software/integrations/mqtt/
- MeshCore MQTT Gateway: https://github.com/jmead/Meshcore-Repeater-MQTT-Gateway
- Meshtastic Bridge: https://github.com/geoffwhittington/meshtastic-bridge
- Philly Mesh MQTT Bridge Setup: https://phillymesh.net/2025/03/24/mqtt-bridge-setup/

---

*This report was prepared by deep research agent for the LA-Mesh project. All URLs verified as of 2026-02-11. Information may become outdated; verify critical security information against primary sources before deployment.*
