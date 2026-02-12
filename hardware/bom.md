# LA-Mesh Bill of Materials

**Last Updated**: 2026-02-11
**Currency**: USD
**Status**: Planning estimates -- prices verified as of Feb 2026

---

## Phase 1: Core Network (Weeks 1-4)

### Required Hardware

| Qty | Item | Unit Cost | Total | Vendor | Notes |
|-----|------|-----------|-------|--------|-------|
| 2 | Station G2 (915 MHz) | $109 | $218 | [Tindie](https://www.tindie.com/products/neilhao/meshtastic-mesh-device-station-g2/) / [Unit Engineering](https://shop.uniteng.com/) | Frequently OOS -- order early |
| 3 | T-Deck Plus (with case) | $82 | $246 | AliExpress / LilyGo official | 2.8" IPS LCD, M5Stack Launcher capable |
| 2 | T-Deck Pro e-ink | $111 | $222 | AliExpress / LilyGo official | 3.1" e-paper, aggressive power saving |
| 1 | MeshAdv-Mini Pi HAT | $40-60 | $50 | MeshAdv / Tindie | Custom PCB with E22-900M22S (SX1262) |
| 1 | Raspberry Pi 4 (4GB) | $55 | $55 | Approved resellers | For gateway/bridge |
| 1 | Pi 4 power supply (official) | $8 | $8 | Pi Foundation | 5.1V 3A USB-C |
| 1 | microSD card (64GB) | $10 | $10 | Amazon | For Pi OS |
| | | | **$809** | | |

### Antennas

| Qty | Item | Unit Cost | Total | Vendor | Notes |
|-----|------|-----------|-------|--------|-------|
| 2 | 6 dBi 915 MHz omnidirectional | $25 | $50 | Amazon / Rokland | For Station G2 routers |
| 1 | 3 dBi 915 MHz omnidirectional | $15 | $15 | Amazon | For gateway |
| 2 | SMA male-to-N-type pigtail | $8 | $16 | Amazon | If using N-type outdoor antenna |
| | | | **$81** | | |

### Enclosures and Mounting

| Qty | Item | Unit Cost | Total | Vendor | Notes |
|-----|------|-----------|-------|--------|-------|
| 2 | IP65 weatherproof box (150x100x70mm) | $15 | $30 | Amazon | For outdoor Station G2 |
| 2 | Cable gland (SMA feedthrough) | $5 | $10 | Amazon | Waterproof antenna passthrough |
| 2 | Pole/mast mounting bracket | $12 | $24 | Amazon | For elevated antenna placement |
| 1 | Indoor Pi enclosure | $10 | $10 | Amazon | For gateway Pi |
| | | | **$74** | | |

### Power

| Qty | Item | Unit Cost | Total | Vendor | Notes |
|-----|------|-----------|-------|--------|-------|
| 1 | UPS HAT for Pi 4 | $25 | $25 | Amazon / Waveshare | Battery backup for gateway |
| 2 | 10,000 mAh USB-C power bank | $20 | $40 | Amazon | Battery backup for routers |
| 2 | USB-C cable (2m) | $5 | $10 | Amazon | For router power |
| | | | **$75** | | |

### Cables and Accessories

| Qty | Item | Unit Cost | Total | Vendor | Notes |
|-----|------|-----------|-------|--------|-------|
| 5 | USB-C data cable (1m) | $5 | $25 | Amazon | For flashing/config |
| 1 | USB-to-UART adapter (CP2102) | $8 | $8 | Amazon | Backup serial interface |
| | | | **$33** | | |

### Phase 1 Total

| Category | Cost |
|----------|------|
| Hardware | $809 |
| Antennas | $81 |
| Enclosures | $74 |
| Power | $75 |
| Cables | $33 |
| **Phase 1 Total** | **$1,072** |

---

## Phase 2: Expansion (Weeks 5-6)

| Qty | Item | Unit Cost | Total | Notes |
|-----|------|-----------|-------|-------|
| 1 | Station G2 (MeshCore eval) | $109 | $109 | For EVAL-MC node |
| 1 | Solar panel (10W, 5V USB) | $25 | $25 | For RTR-02 outdoor |
| 1 | Solar charge controller | $15 | $15 | MPPT USB-C output |
| 1 | 20,000 mAh battery | $30 | $30 | Solar buffer for outdoor node |
| 3 | Additional T-Deck Plus | $82 | $246 | Community loaner devices |
| | | | **$425** | |

---

## Phase 3: SDR Education Lab (Weeks 7-8)

| Qty | Item | Unit Cost | Total | Notes |
|-----|------|-----------|-------|-------|
| 1 | HackRF One H4M + PortaPack | $200 | $200 | SDR education platform |
| 1 | 915 MHz bandpass filter | $30 | $30 | Clean up SDR reception |
| 1 | SMA antenna set (wideband) | $20 | $20 | For SDR experiments |
| 1 | RTL-SDR Blog V4 | $35 | $35 | Lower-cost receive-only SDR |
| | | | **$285** | |

---

## Full Project Budget Summary

| Phase | Cost | Timeline |
|-------|------|----------|
| Phase 1: Core Network | $1,072 | Weeks 1-4 |
| Phase 2: Expansion | $425 | Weeks 5-6 |
| Phase 3: SDR Lab | $285 | Weeks 7-8 |
| **Total** | **$1,782** | |

### Contingency

| Item | Estimate |
|------|----------|
| Shipping costs | $50-100 |
| Replacement/spare parts | $100 |
| Unforeseen accessories | $50 |
| **Contingency Total** | **$200-250** |

### Grand Total (with contingency): ~$2,000

---

## Vendor Notes

### Station G2 Procurement

- **Primary**: [Unit Engineering shop](https://shop.uniteng.com/) or [Tindie](https://www.tindie.com/products/neilhao/meshtastic-mesh-device-station-g2/)
- **Stock**: Frequently out of stock. Lead time can be 2-4 weeks.
- **Alternative**: If G2 unavailable, Heltec V3 + external PA is a fallback (~$45 + $40 PA) but lower performance
- **Bulk pricing**: Contact Neil Hao directly for 3+ units

### T-Deck Procurement

- **Primary**: AliExpress (LilyGo official store) or [LilyGo website](https://www.lilygo.cc/)
- **Lead time**: 2-3 weeks from China, faster from US warehouses when available
- **T-Deck Plus vs Pro**: Plus ($77-82) for daily use, Pro e-ink ($92-111) for extended field ops
- **Case**: Order with case option if available, otherwise 3D print

### MeshAdv-Mini

- **Source**: MeshAdv community / Tindie
- **Lead time**: Small-batch production, may be 2-4 weeks
- **Alternative**: DIY with Ebyte E22-900M22S module + custom carrier board

### Funding Sources

| Source | Amount | Application |
|--------|--------|-------------|
| Bates Harward Center | $500-2,000 | Community engagement grant |
| Maine Community Foundation | $5,000-50,000 | Technology access grant |
| Self-funded / donations | Variable | Community contributions |
| Bates STEM department | In-kind | Lab space, mentorship |
