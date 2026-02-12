# Weatherproofing Guide for Outdoor Mesh Nodes

**Climate**: Southern Maine (USDA Zone 5b)
**Temperature range**: -29°C to 38°C (-20°F to 100°F)
**Precipitation**: Rain, snow, ice, fog -- significant year-round

---

## Enclosure Requirements

### Minimum Specifications

| Requirement | Rating | Rationale |
|-------------|--------|-----------|
| **IP rating** | IP65 minimum | Dust-tight + water jet protection |
| **UV resistance** | UV-stabilized ABS or polycarbonate | Outdoor sun exposure degrades plastics |
| **Temperature** | -40°C to +85°C operating | Exceeds Maine extremes |
| **Size** | 150×100×70mm minimum | Fits Station G2 + cable glands |
| **Color** | Light gray or white | Reflects heat, reduces internal temperature |

### Recommended Enclosures

| Option | IP | Material | Size | Est. Cost |
|--------|-----|----------|------|-----------|
| Polycase WC-22 | IP65 | Polycarbonate | 158×90×60mm | $12 |
| Hammond 1554J | IP66 | ABS | 160×90×60mm | $15 |
| Bud Industries PN-1332 | IP65 | ABS | 150×100×70mm | $10 |
| Generic project box | IP65 | ABS | 158×90×60mm | $8 |

---

## Sealing and Cable Management

### Cable Glands

Every cable penetration must be sealed:

| Penetration | Gland Size | Cable |
|-------------|-----------|-------|
| USB-C power | M16 or PG9 | USB-C cable |
| SMA antenna | SMA bulkhead feedthrough | N/A (integrated seal) |
| GPS antenna (if external) | SMA bulkhead | GPS cable |

**Installation**:
1. Drill hole to match gland size
2. Deburr hole edges
3. Thread gland from outside, nut from inside
4. Route cable through gland
5. Tighten compression ring until cable is snug
6. Apply silicone sealant around gland exterior

### SMA Antenna Feedthrough

1. Drill 6.5mm hole in enclosure wall
2. Install SMA bulkhead adapter (gasket outward)
3. Tighten lock washer and nut from inside
4. Apply marine-grade silicone around exterior gasket
5. Connect internal SMA pigtail to device

### Silicone Sealant

Use **marine-grade** or **outdoor-rated** clear silicone:
- Apply around all cable glands after installation
- Seal any drill holes or modifications
- Apply thin bead around enclosure lid gasket
- Allow 24h cure time before deployment

---

## Condensation Management

Sealed enclosures trap moisture that causes corrosion and shorts.

### Prevention Methods

1. **Desiccant packs**: Place 2-3 silica gel packets inside enclosure
   - Replace every 6 months or when indicator changes color
   - Rechargeable desiccant packs preferred (bake at 120°C to regenerate)

2. **Conformal coating**: Spray circuit boards with conformal coating
   - Protects against moisture and salt air
   - Use MG Chemicals 419D or similar
   - Do NOT coat antenna connector or USB port

3. **Ventilation (if temperature cycling is severe)**:
   - Install IP68 breather vent (Gore-Tex membrane)
   - Equalizes pressure without admitting water
   - Recommended for locations with extreme temperature swings

---

## Mounting Methods

### Pole Mount (Preferred for Rooftop)

| Component | Purpose |
|-----------|---------|
| Stainless steel U-bolts (2) | Attach enclosure bracket to pole |
| Aluminum L-bracket | Mount enclosure to pole via U-bolts |
| Stainless hardware | Corrosion resistance (salt air) |

**Steps**:
1. Attach L-bracket to enclosure with bolts through mounting ears
2. Position bracket on pole at desired height
3. Secure with U-bolts, tighten evenly
4. Ensure enclosure cable glands face downward (drip loops)

### Wall Mount

| Component | Purpose |
|-----------|---------|
| Tapcon concrete screws (4) | Mount to brick/concrete |
| Stainless steel screws (4) | Mount to wood |
| Silicone pad | Between enclosure and wall (vibration dampening) |

### J-Pole Antenna Mount

For elevated antenna with enclosure below:
1. Mount J-pole or collinear antenna at top of mast
2. Run coax cable down to enclosure
3. Enter enclosure through SMA bulkhead feedthrough
4. Ensure drip loop in coax before enclosure entry

---

## Cable Routing

**Critical rule**: All cables must enter from the **bottom** of the enclosure.

```
  ┌─────────────────┐
  │    Antenna       │  ← Top: antenna mounted above
  │       │          │
  │  ┌────┴────┐     │
  │  │ Device  │     │
  │  └────┬────┘     │
  │       │          │
  │  ─────┴─────     │  ← Bottom: cable glands here
  └─────────────────┘
       │     │
    USB-C   SMA pigtail to antenna
```

This prevents water from running down cables into the enclosure.

**Drip loops**: Form a U-shape in cables before they enter glands. Water follows gravity and drips off the loop bottom instead of entering the enclosure.

---

## Seasonal Maintenance Schedule

| Season | Tasks |
|--------|-------|
| **Spring** (April) | Inspect enclosures for winter damage, replace desiccant, check cable glands, clean solar panels |
| **Summer** (July) | Check internal temperature (should stay below 50°C), verify ventilation |
| **Fall** (October) | Pre-winter check, tighten all fasteners, verify battery health, clear debris from antenna |
| **Winter** (January) | Remote monitoring only (check battery telemetry), clear snow from solar panel if accessible |
