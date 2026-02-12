# LA-Mesh Hardware Inventory

**Last Updated**: 2026-02-11
**Status**: Planning / Pre-Procurement

---

## Inventory Register

### Infrastructure Nodes (Tier 1)

| ID | Device | Firmware | Role | Location | Status | Serial | MAC | PSK Channel | Notes |
|----|--------|----------|------|----------|--------|--------|-----|-------------|-------|
| GW-01 | MeshAdv-Mini + Pi 4 | meshtasticd | ROUTER_CLIENT | TBD - Campus | **Not purchased** | -- | -- | LA-Mesh | Gateway/bridge node |
| RTR-01 | Station G2 | Meshtastic | ROUTER | TBD - Campus rooftop | **Not purchased** | -- | -- | LA-Mesh | Primary backbone router |
| RTR-02 | Station G2 | Meshtastic | ROUTER | TBD - Downtown L-A | **Not purchased** | -- | -- | LA-Mesh | Downtown coverage |
| EVAL-MC | Station G2 | MeshCore | simple_repeater | TBD - Campus | **Not purchased** | -- | -- | N/A | MeshCore evaluation |

### User Devices (Tier 2)

| ID | Device | Firmware | Role | Assigned To | Status | Serial | MAC | Notes |
|----|--------|----------|------|-------------|--------|--------|-----|-------|
| MOB-01 | T-Deck Plus | Meshtastic | CLIENT | TBD | **Not purchased** | -- | -- | Community loaner |
| MOB-02 | T-Deck Plus | Meshtastic | CLIENT | TBD | **Not purchased** | -- | -- | Community loaner |
| MOB-03 | T-Deck Plus | Meshtastic | CLIENT | TBD | **Not purchased** | -- | -- | Community loaner |
| MOB-E01 | T-Deck Pro (e-ink) | Meshtastic | CLIENT | TBD | **Not purchased** | -- | -- | Low-power field use |
| MOB-E02 | T-Deck Pro (e-ink) | Meshtastic | CLIENT | TBD | **Not purchased** | -- | -- | Low-power field use |

### SDR / Lab Equipment

| ID | Device | Firmware | Purpose | Status | Serial | Notes |
|----|--------|----------|---------|--------|--------|-------|
| SDR-01 | HackRF H4M + PortaPack | Mayhem | RF education, spectrum analysis | **Not purchased** | -- | Requires tethered GNU Radio for LoRa decode |

---

## Firmware Version Tracking

| Device Class | Current Target | Min Required | CVE Status |
|--------------|---------------|--------------|------------|
| Meshtastic (all) | v2.7.x (latest stable) | v2.7.15 | CVE-2025-52464 patched |
| MeshCore (eval) | v1.12.0 | v1.12.0 | No known CVEs |
| PortaPack Mayhem | Latest release | -- | N/A |

**Policy**: No device may be deployed with firmware below the minimum required version. Check for updates weekly (automated via [firmware-check.yml](../.github/workflows/firmware-check.yml)).

---

## Antenna Inventory

| ID | Type | Gain | Connector | Assigned To | Status |
|----|------|------|-----------|-------------|--------|
| ANT-01 | 6 dBi omnidirectional (915 MHz) | 6 dBi | SMA-M | RTR-01 | **Not purchased** |
| ANT-02 | 6 dBi omnidirectional (915 MHz) | 6 dBi | SMA-M | RTR-02 | **Not purchased** |
| ANT-03 | 3 dBi omnidirectional (915 MHz) | 3 dBi | SMA-M | GW-01 | **Not purchased** |
| ANT-STK-01..05 | Stock antenna (per device) | 2 dBi | SMA-M | MOB devices | Included with device |

---

## Enclosure Inventory

| ID | Type | IP Rating | Fits | Assigned To | Status |
|----|------|-----------|------|-------------|--------|
| ENC-01 | Weatherproof project box | IP65+ | Station G2 + antenna feedthrough | RTR-01 | **Not purchased** |
| ENC-02 | Weatherproof project box | IP65+ | Station G2 + antenna feedthrough | RTR-02 | **Not purchased** |

---

## Power Infrastructure

| ID | Type | Capacity | Output | Assigned To | Status |
|----|------|----------|--------|-------------|--------|
| PWR-01 | UPS (mini) | 10,000+ mAh | 5V USB-C | GW-01 (Pi) | **Not purchased** |
| PWR-02 | Battery backup | 10,000+ mAh | 5V USB-C | RTR-01 | **Not purchased** |
| PWR-03 | Solar panel + charge controller | 10-20W | 5V USB-C | RTR-02 | **Not purchased** |
| PWR-STK-01..05 | Device internal battery | Per device | -- | MOB devices | Included with device |

---

## Check-Out / Assignment Log

| Date | Device ID | Assigned To | Purpose | Expected Return | Returned |
|------|-----------|-------------|---------|-----------------|----------|
| -- | -- | -- | -- | -- | -- |

---

## Maintenance Log

| Date | Device ID | Issue | Action Taken | By |
|------|-----------|-------|--------------|----|
| -- | -- | -- | -- | -- |
