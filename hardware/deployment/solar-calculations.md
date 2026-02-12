# Solar Power Calculations for LA-Mesh Nodes

**Location**: Lewiston-Auburn, Maine (44.1°N, 70.2°W)
**Purpose**: Size solar systems for always-on outdoor mesh nodes

---

## Solar Resource in Southern Maine

### Monthly Peak Sun Hours (PSH)

| Month | PSH/day | Notes |
|-------|---------|-------|
| January | 2.5 | Shortest days, snow cover |
| February | 3.3 | Increasing daylight, snow reflection helps |
| March | 4.1 | Spring equinox approaches |
| April | 4.8 | Good solar, occasional clouds |
| May | 5.3 | Near peak |
| June | 5.6 | Peak month |
| July | 5.5 | Near peak |
| August | 5.0 | Still strong |
| September | 4.2 | Declining |
| October | 3.2 | Fall foliage, lower angle |
| November | 2.4 | Low sun angle |
| December | 2.1 | Winter minimum |
| **Annual Avg** | **3.9** | |
| **Winter Avg** | **2.5** | **Design for this** |

Source: NREL NSRDB data for central Maine.

---

## Device Power Requirements

### Station G2 (Router Mode)

| Parameter | Value |
|-----------|-------|
| Active TX (30 dBm) | ~600 mA @ 5V = 3.0W |
| Active RX | ~80 mA @ 5V = 0.4W |
| Average (10% TX duty) | ~130 mA @ 5V = 0.65W |
| Daily consumption | 0.65W × 24h = **15.6 Wh/day** |

### T-Deck Plus (Client Mode, Power Saving)

| Parameter | Value |
|-----------|-------|
| Active (screen on, TX) | ~350 mA @ 5V = 1.75W |
| Idle (screen off, RX) | ~50 mA @ 5V = 0.25W |
| Light sleep | ~15 mA @ 5V = 0.075W |
| Average (typical use) | ~60 mA @ 5V = 0.3W |
| Daily consumption | 0.3W × 24h = **7.2 Wh/day** |

### Raspberry Pi 4 + MeshAdv-Mini (Gateway)

| Parameter | Value |
|-----------|-------|
| Pi 4 idle | ~3.0W |
| Pi 4 active | ~5.0W |
| MeshAdv-Mini | ~0.5W |
| Average | ~4.0W |
| Daily consumption | 4.0W × 24h = **96 Wh/day** |

**Note**: The Pi gateway should be powered from mains with UPS backup, not solar. Solar is only practical for Station G2 and small relay nodes.

---

## Solar Sizing for Station G2 Router

### Design Parameters

- Daily consumption: 15.6 Wh
- Autonomy days (cloudy weather buffer): 3 days
- System voltage: 5V (USB)
- Panel efficiency loss: 20% (angle, dirt, temperature)
- Battery charge/discharge efficiency: 85%
- Design PSH: 2.5 (worst-case winter)

### Battery Sizing

```
Required capacity = Daily consumption × Autonomy days / Discharge efficiency
                  = 15.6 Wh × 3 / 0.85
                  = 55 Wh

At 5V:  55 Wh / 5V = 11,000 mAh
At 3.7V (LiPo native): 55 Wh / 3.7V = 14,865 mAh

Recommendation: 20,000 mAh USB power bank (provides ~74 Wh usable)
This gives ~4.7 days of autonomy without solar.
```

### Solar Panel Sizing

```
Required panel output = Daily consumption / (PSH × Panel efficiency)
                      = 15.6 Wh / (2.5h × 0.80)
                      = 7.8W

Recommendation: 10W panel (provides margin)
```

### Recommended Kit for Station G2

| Component | Specification | Est. Cost |
|-----------|--------------|-----------|
| Solar panel | 10W, 5V USB output | $20-25 |
| Charge controller | MPPT, USB-C in/out | $15 |
| Battery | 20,000 mAh USB power bank | $25-30 |
| Cables | USB-C, outdoor-rated | $5-10 |
| **Total** | | **$65-80** |

---

## Winter Considerations (Maine-Specific)

### Temperature Effects on Batteries

| Temperature | LiPo Capacity | Effect |
|-------------|---------------|--------|
| 25°C (77°F) | 100% | Optimal |
| 0°C (32°F) | ~80% | Mild winter |
| -10°C (14°F) | ~60% | Typical Maine winter |
| -20°C (-4°F) | ~40% | Extreme cold snap |
| -30°C (-22°F) | ~20% | Rare but possible |

**Mitigation**:
- Use insulated enclosure with thermal mass
- Place battery inside weatherproof box (not exposed to wind)
- Consider battery heater pad for extreme cold installations
- LiFePO4 batteries tolerate cold better than LiPo (but heavier)

### Snow and Ice on Solar Panels

- Mount panel at 45-60° angle (steeper = snow slides off)
- Consider panel heater for critical nodes
- Clear panels after heavy snow if accessible
- Snow reflection (albedo) can actually increase output on clear days

### Shorter Winter Days

- 2.5 PSH in December vs 5.6 in June
- Battery must bridge 15.5 hours of darkness in December
- With 20,000 mAh battery: 15.5h × 130mA = 2,015 mAh used overnight (well within capacity)

---

## Monitoring Solar Performance

Track via mesh telemetry:
```bash
# Check battery voltage from mesh
meshtastic --nodes  # Battery percentage visible in node list

# Set telemetry broadcast interval
meshtastic --set telemetry.device_update_interval 900  # Every 15 minutes
```

Alert if battery drops below 20% -- may indicate panel obstruction or failure.
