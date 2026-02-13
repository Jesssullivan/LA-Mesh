# Node Deployment Guide

**Applies to**: Fixed infrastructure nodes (Station G2 routers, gateway)
**See also**: [Site Survey Checklist](../../hardware/deployment/site-survey-checklist.md)

---

## Overview

Deploying a fixed mesh node involves five phases:
1. Site survey and approval
2. Hardware preparation
3. Physical installation
4. Configuration and verification
5. Monitoring and maintenance

---

## Phase 1: Site Survey

Complete the [Site Survey Checklist](../../hardware/deployment/site-survey-checklist.md) for each location.

**Key criteria**:
- Clear line-of-sight to at least one other mesh node
- Secure mounting point with physical access for maintenance
- Power source (mains preferred, solar for remote sites)
- Permission from property owner/manager
- FAA check if near Auburn-Lewiston Airport (LEW)

---

## Phase 2: Hardware Preparation

### Assemble Enclosure (Indoor)

1. Drill cable gland holes in enclosure bottom
2. Install SMA bulkhead feedthrough for antenna
3. Install USB-C cable gland for power
4. Place desiccant packets inside
5. Apply dielectric grease to SMA connections
6. Mount device inside enclosure (Velcro, standoffs, or zip ties)
7. Route cables and connect
8. Close enclosure and verify seal

### Configure Device

```bash
# Apply router profile
./tools/configure/apply-profile.sh station-g2-router /dev/ttyUSB0

# Apply channel configuration
export LAMESH_PSK_PRIMARY="<base64-psk>"
export LAMESH_PSK_ADMIN="<base64-psk>"
export LAMESH_PSK_EMERGENCY="<base64-psk>"
./tools/configure/apply-channels.sh /dev/ttyUSB0

# Set fixed position (from GPS or site survey)
meshtastic --port /dev/ttyUSB0 --setlat 44.1003 --setlon -70.2148 --setalt 60

# Set node name
meshtastic --port /dev/ttyUSB0 --set-owner "LA-Mesh RTR-01"
meshtastic --port /dev/ttyUSB0 --set-owner-short "R01"

# Verify
meshtastic --port /dev/ttyUSB0 --info
```

### Test Before Deployment

- Send a message from this device
- Verify it's received by at least one other node
- Check battery level and charging
- Confirm GPS position is correct (if applicable)

---

## Phase 3: Physical Installation

### Bring the [Installation Toolkit](../../hardware/deployment/installation-toolkit.md)

### Steps

1. **Mount antenna** at highest accessible point
   - Use pole mount, wall mount, or existing antenna mast
   - Ensure antenna is vertical (for omnidirectional)
   - Tighten SMA to 8 in-lb (finger tight + 1/4 turn with wrench)

2. **Mount enclosure** below antenna
   - Cable glands facing DOWN
   - Protected from direct rain if possible (under eave)
   - Accessible for maintenance

3. **Route cables**
   - Coax from antenna to enclosure SMA feedthrough
   - Form drip loop before entering enclosure
   - Power cable from source to enclosure

4. **Connect power**
   - Verify voltage before connecting (5V USB-C)
   - Secure cable connections
   - Solar: panel → charge controller → battery → device

5. **Seal everything**
   - Apply silicone around all cable glands
   - Check enclosure gasket is seated
   - Cable tie loose cables

6. **Power on and verify**

---

## Phase 4: Verification

### Immediate Checks (at site)

```bash
# From another device or via meshtastic CLI
meshtastic --nodes                    # Verify node appears in list
meshtastic --traceroute '!<node-id>'  # Verify routing works
meshtastic --sendtext "RTR-01 deployment test"
```

### Remote Checks (from base)

- Verify node appears on MQTT broker (if gateway is operational)
- Check telemetry: battery level, voltage, airtime
- Send message from base to deployed node and back
- Record RSSI/SNR for the link

### Document Results

Update `hardware/inventory.md`:
- Set status to "Deployed"
- Record serial number, MAC address
- Record GPS coordinates
- Record installation date
- Note any issues

---

## Phase 5: Monitoring

### Ongoing Monitoring

- Check node status daily (via node-status.py or MQTT)
- Watch battery telemetry on solar-powered nodes
- Investigate if node goes offline for >2 hours

### Maintenance Schedule

| Interval | Task |
|----------|------|
| Monthly | Check battery health via telemetry |
| Quarterly | Physical inspection, replace desiccant, check connections |
| Biannually | Clean solar panel, tighten mounting hardware |
| Annually | Full inspection, firmware update, replace weathering components |
| As needed | Firmware updates (security patches) |

### Emergency Maintenance

If a node goes offline:
1. Check MQTT/telemetry for last known status
2. Check battery level (may be drained)
3. Attempt remote admin reset: `meshtastic --dest '!<node-id>' --reboot`
4. If unresponsive, schedule site visit
5. Bring replacement device and full installation toolkit

---

## Node Naming Convention

Each device on the LA-Mesh network uses a consistent owner name so nodes are
easily identifiable in node lists, message headers, and on-screen displays.

| Role | Owner Name Pattern | Short Name | Example |
|------|-------------------|------------|---------|
| Router (fixed relay) | `LA-Mesh RTR-NN` | `RNN` | `LA-Mesh RTR-01` / `R01` |
| Client (T-Deck) | `LA-Mesh USR-NN` | `UNN` | `LA-Mesh USR-01` / `U01` |
| Gateway (MeshAdv) | `LA-Mesh GW-NN` | `GNN` | `LA-Mesh GW-01` / `G01` |

Set the owner name after provisioning:

```bash
meshtastic --port /dev/ttyACM0 --set-owner "LA-Mesh RTR-01" --set-owner-short "R01"
```

The base profile sets `owner: "LA-Mesh"` and `owner_short: "LAM"` as defaults.
Individual node identity is applied per the table above after flashing.

### Boot Logo Note

Custom boot logos in Meshtastic v2.7.x are compiled into the firmware binary
(`icon.xbm` referenced from `Screen.cpp`). Changing the logo requires building
custom firmware, which is out of scope for standard deployments. The
`--set-owner` name is the primary visible branding mechanism -- it appears on
all node lists, message headers, and the device's own screen after boot.

---

## Station G2 Hardware Notes

The B&Q Consulting Station G2 is an ESP32-S3 board with 16MB flash, native USB,
and a SX1262 LoRa radio with PA/LNA. It has several quirks that affect
provisioning and management.

### USB Interface

The Station G2 uses **native ESP32-S3 USB CDC** (appears as `/dev/ttyACM0`),
not a CH340/CP2102 UART bridge. This means:

- **No DTR/RTS auto-reset** -- esptool cannot automatically enter bootloader
  mode. You must manually hold the BOOT button.
- **USB disconnects on reboot** -- the port disappears when the device reboots
  (e.g., after region or role changes) and re-enumerates after ~10-15 seconds.
- **esptool `--before no_reset`** -- required after the first `erase_flash`
  to prevent esptool from trying (and failing) to toggle DTR/RTS.

### Entering Bootloader Mode

1. **Unplug** the USB cable
2. **Hold** the button labeled "loop" (closest to the USB-C port)
3. **Plug in** the USB cable while holding the button
4. **Continue holding** for 2 seconds after plugging in, then release
5. The device should enumerate as `303a:1001` on USB (check with `lsusb`)

### Flash Procedure (16MB)

The Station G2 uses a 16MB flash layout with three partitions that must all be
written for a clean install:

| Partition | Offset | File | Size |
|-----------|--------|------|------|
| Bootloader + App | `0x0` | `firmware-station-g2-*.bin` | ~2.1 MB |
| BLE OTA | `0x650000` | `bleota-s3.bin` | ~495 KB |
| LittleFS | `0xc90000` | `littlefs-station-g2-*.bin` | ~3.4 MB |

**Important**: Always erase flash before a full install. Without erasing, the
old bootloader/partition table persists and the device boots the old firmware.

```bash
# Full install sequence (device must be in bootloader mode)
esptool --chip esp32s3 --port /dev/ttyACM0 --baud 921600 erase_flash
esptool --chip esp32s3 --port /dev/ttyACM0 --baud 921600 --before no_reset \
    write_flash 0x0 firmware-station-g2-*.bin
esptool --chip esp32s3 --port /dev/ttyACM0 --baud 921600 --before no_reset \
    write_flash 0x650000 bleota-s3.bin
esptool --chip esp32s3 --port /dev/ttyACM0 --baud 921600 --before no_reset \
    write_flash 0xc90000 littlefs-station-g2-*.bin
```

### ROUTER Mode and USB Serial

**Known issue** (GitHub [#4206](https://github.com/meshtastic/firmware/issues/4206)):
when set to ROUTER role, the ESP32-S3 enters light sleep and the native USB CDC
serial does not always recover. The port appears in `/dev/` but returns no data.

**Workaround for initial provisioning**: apply all configuration settings
*before* changing the device role to ROUTER. Set the role as the very last step.
Once in ROUTER mode, manage the device via:

- **Admin channel** from another mesh node
- **Web flasher** at `https://flasher.meshtastic.org` (WebSerial)
- **Factory reset** by re-entering bootloader mode and erasing flash

### Alternative to ROUTER Role

If you need USB serial access for ongoing management, use `ROUTER_CLIENT` role
instead. It provides the same relay functionality but keeps the display and
serial active (at the cost of slightly higher power consumption).
