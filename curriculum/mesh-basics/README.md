# Level 1-2: Mesh Networking Basics

**Audience**: Complete beginners, community members, students
**Time**: 2-3 hours (workshop format)
**Prerequisites**: None

---

## Learning Objectives

By the end of this module, participants will be able to:

1. Explain what LoRa and mesh networking are in plain terms
2. Power on and navigate a T-Deck device
3. Send and receive text messages on the LA-Mesh network
4. Understand channels, PSKs, and basic encryption concepts
5. Read the node list and interpret signal quality (SNR/RSSI)

---

## Module Structure

### Part 1: What Is a Mesh Network? (30 min)

**Concepts covered**:
- Traditional networks: cell towers, WiFi routers, internet backbone
- Single point of failure problem
- Mesh networking: every device is a relay
- Why mesh matters: disasters, remote areas, community resilience

**Key analogy**: Think of mesh networking like a bucket brigade. Each person passes the bucket to the next -- if one person steps away, the chain re-routes around them. No fire truck (cell tower) needed.

**Discussion prompts**:
- What happens to your phone when a cell tower goes down?
- How did communities communicate before cell phones?
- What natural disasters has Maine experienced that disrupted communications?

### Part 2: What Is LoRa? (20 min)

**Concepts covered**:
- Radio frequency basics: signals travel through air
- LoRa = Long Range, low power radio
- 915 MHz ISM band (license-free in the US)
- Trade-off: long range but low data rate (text only, no voice/video)
- Range: 1-20+ km depending on terrain and antenna

**Key specs (simplified)**:

| What | Value | Plain English |
|------|-------|--------------|
| Frequency | 915 MHz | UHF radio band, passes through some obstacles |
| Range | 1-20 km | Across town, or further with good antenna placement |
| Speed | ~0.7 kbps | About 1 text message per second |
| Power | Days on battery | T-Deck lasts 1-3 days on a charge |
| License | None needed | FCC Part 15 -- free to use |

**Demo**: Show LoRa signal on spectrum analyzer (if HackRF available) or waterfall diagram.

### Part 3: Hands-On -- Your First Message (45 min)

**Materials needed**:
- One T-Deck device per participant (or pair)
- Devices pre-configured with LA-Mesh channel

**Steps**:

1. **Power on**: Hold power button for 3 seconds
2. **Home screen**: Identify the node list, channel indicator, battery level
3. **Send a message**:
   - Navigate to the message screen
   - Type a short message using the keyboard
   - Press Send
   - Watch it appear on other devices
4. **Check the node list**:
   - How many nodes do you see?
   - What does the signal strength number mean?
   - Find the SNR (Signal-to-Noise Ratio) -- higher is better

**Exercise**: Pair up. Walk to opposite sides of the building. Send messages. Note the SNR value. Then go outside and increase distance. At what point does the signal degrade?

### Part 4: How Mesh Routing Works (20 min)

**Concepts covered**:
- Flooding: every node rebroadcasts every message
- Hop limit: messages don't travel forever (default: 3 hops)
- Device roles:
  - **ROUTER**: Always rebroadcasts (infrastructure nodes on rooftops)
  - **CLIENT**: Rebroadcasts sometimes (your handheld device)
  - **CLIENT_MUTE**: Never rebroadcasts (saves battery, listens only)
- Why we don't all use ROUTER: airtime congestion

**Visualization**:
```
You ──(hop 1)──→ Router A ──(hop 2)──→ Router B ──(hop 3)──→ Friend
                                                              (3 hops!)
```

**Exercise**: Use the traceroute feature to see the path your message takes:
```
meshtastic --traceroute '!<node-id>'
```

### Part 5: Channels and Encryption (20 min)

**Concepts covered**:
- Channels are like radio stations -- everyone on the same channel can hear each other
- PSK (Pre-Shared Key): the password that encrypts your channel
- Why default PSK is bad: `AQ==` is publicly known, anyone can listen
- LA-Mesh uses custom 32-byte PSK distributed in-person only
- Direct messages use additional PKC (Public Key Cryptography)

**Key rules**:
1. Never share the PSK digitally (no text, email, or chat)
2. PSK is rotated quarterly
3. Default PSK (`AQ==`) is NEVER used on LA-Mesh

**Exercise**: Explain to a partner (in your own words) why the PSK should only be shared in person.

### Part 6: Wrap-Up and Q&A (15 min)

**Review quiz** (informal, group discussion):
1. What does LoRa stand for?
2. How many hops can a message take on our network?
3. Why do we use a custom PSK instead of the default?
4. What's the difference between a ROUTER and a CLIENT?
5. Can mesh networks carry voice calls? (No -- text only)

**Take-home resources**:
- LA-Mesh getting started guide: `docs/guides/getting-started.md`
- Meshtastic documentation: https://meshtastic.org/docs/
- LA-Mesh website: transscendsurvival.org/LA-Mesh/

---

## Instructor Notes

### Setup Checklist (Before Workshop)

- [ ] Charge all T-Deck devices to >80%
- [ ] Verify all devices on LA-Mesh channel with correct PSK
- [ ] Verify firmware is v2.6.11+ (CVE-2025-52464)
- [ ] Test message delivery between all devices
- [ ] Prepare spectrum analyzer demo (optional)
- [ ] Print handouts with device diagram and key controls

### Common Questions

**Q: Can I use my phone instead of a T-Deck?**
A: Yes! Install the Meshtastic app (Android/iOS) and pair via Bluetooth. But dedicated devices work without a phone.

**Q: Can the government listen to our messages?**
A: With the default PSK, yes. With our custom 32-byte PSK, messages are encrypted with AES-256. Without the key, messages are unreadable. However, the radio signals themselves are visible -- someone can tell you're transmitting, but not what you're saying.

**Q: What about MeshCore?**
A: MeshCore is a different firmware with some advantages at scale. LA-Mesh uses Meshtastic as our primary platform, but we're evaluating MeshCore on a test node. The two systems cannot talk to each other directly.

**Q: How far can these really reach?**
A: In Southern Maine, with our Station G2 routers on rooftops, expect 5-15 km urban and up to 25 km line-of-sight. Through buildings, 1-3 km is typical. The mesh routing extends effective range by hopping through relay nodes.
