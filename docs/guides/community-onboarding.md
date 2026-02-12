# Community Onboarding Guide

Welcome to LA-Mesh! This guide walks you through joining the community mesh network in the Lewiston-Auburn area.

---

## What You Need

### Option A: Dedicated Device (Recommended)

Purchase a T-Deck Plus (~$82) or T-Deck Pro e-ink (~$111). These are standalone mesh radios with keyboards and screens -- no phone needed.

### Option B: Phone + Bluetooth Device

Any Meshtastic-compatible device (~$25-80) paired with the Meshtastic app on your phone:
- **Android**: [Meshtastic app](https://play.google.com/store/apps/details?id=com.geeksville.mesh)
- **iOS**: [Meshtastic app](https://apps.apple.com/app/meshtastic/id1586432531)

---

## Getting Connected

### Step 1: Get Your Device Configured

Attend a community meetup where an LA-Mesh operator will:
1. Flash the latest firmware (v2.6.11+ required)
2. Apply the appropriate device profile
3. Set the LA-Mesh channel PSK (encryption key)
4. Verify your device can communicate with the network

**Why in-person?** The encryption key (PSK) is only shared face-to-face for security. We never send it digitally.

### Step 2: Learn the Basics

At the meetup, you'll learn:
- How to send and receive messages
- How to read the node list
- What the signal quality numbers mean
- Basic mesh etiquette

See [Mesh Basics Curriculum](../../curriculum/mesh-basics/README.md) for the full workshop.

### Step 3: Stay Connected

- Keep your device charged and powered on when you're in the Lewiston-Auburn area
- Your device automatically relays messages for other users (mesh networking!)
- Check for firmware updates at community meetups

---

## Mesh Etiquette

1. **Keep messages concise** -- LoRa is low bandwidth (~1 text message per second)
2. **Don't spam** -- excessive messages use airtime that everyone shares
3. **Emergency channel is for emergencies only** -- false alarms erode trust
4. **Report issues** -- coverage gaps, connectivity problems, suspicious activity
5. **Attend meetups** -- for PSK rotations and firmware updates
6. **Share knowledge** -- help newcomers get set up

---

## Frequently Asked Questions

**Q: Can people read my messages?**
A: Channel messages are encrypted (AES-256) -- only LA-Mesh members with the PSK can read them. For private conversations, use Direct Messages, which have additional end-to-end encryption that even other LA-Mesh members can't read.

**Q: Can I see my location on the network?**
A: If GPS is enabled, your position is shared with other mesh users. You can disable GPS in your device settings if you prefer not to share location.

**Q: How far does the signal reach?**
A: Typically 1-5 km in urban areas, up to 20+ km with line-of-sight to a router. Your messages can "hop" through other devices to reach further.

**Q: Does it use the internet?**
A: No! The mesh operates entirely on LoRa radio. No WiFi, no cell service, no internet needed. The gateway bridge provides optional SMS/email connectivity.

**Q: What happens if a tower node goes down?**
A: The mesh re-routes around it. With multiple routers, the network is resilient to individual node failures.

**Q: Can I use this for voice calls?**
A: No. LoRa is text-only due to low bandwidth. Think of it like texting, not calling.

**Q: How do I get firmware updates?**
A: At community meetups, or by following the guide in `docs/guides/firmware-flashing.md`.

---

## Community Meetups

- **Location**: TBD (Bates College campus area)
- **Frequency**: Monthly (more often during setup phase)
- **Purpose**: New member onboarding, PSK rotation, firmware updates, coverage reports, planning

---

## Want to Help?

- **Host a node**: If you have a high location (rooftop, hilltop), we may be able to place a relay node
- **Volunteer**: Help at meetups, assist with installations, contribute to documentation
- **Spread the word**: Tell neighbors, friends, community organizations
- See [CONTRIBUTING.md](../../CONTRIBUTING.md) for technical contributions
