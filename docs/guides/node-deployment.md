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
meshtastic --port /dev/ttyUSB0 --set-owner "RTR-01-Bates"
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
