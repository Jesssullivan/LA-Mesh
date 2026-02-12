# LA-Mesh Target Device Hardware Deep Dive

**Date:** 2026-02-11
**Scope:** G2 Base Station, T-Deck Pro (e-ink), T-Deck Plus (full-featured), firmware interop, RF design, procurement
**Region:** Southern Maine (Lewiston-Auburn area, Bates College)

---

## Table of Contents

1. [G2 Base Station](#1-g2-base-station)
2. [LilyGo T-Deck Pro (E-Ink)](#2-lilygo-t-deck-pro-e-ink)
3. [LilyGo T-Deck Plus (Full-Featured)](#3-lilygo-t-deck-plus-full-featured)
4. [Dual MeshCore/Meshtastic Firmware](#4-dual-meshcoremeshtastic-firmware)
5. [Antenna and RF Design](#5-antenna-and-rf-design)
6. [Link Budget and Range Modeling for Southern Maine](#6-link-budget-and-range-modeling-for-southern-maine)
7. [Bulk Procurement](#7-bulk-procurement)
8. [Sprint Integration Points](#8-sprint-integration-points)

---

## 1. G2 Base Station

### 1.1 Identity

The "G2 base station" refers to the **Station G2** designed by Neil Hao at B&Q Consulting / Unit Engineering. This is NOT a Heltec V3 or LILYGO T-Beam -- it is a purpose-built, high-performance LoRa base station specifically designed for relay/backbone duty. It is the most powerful consumer-grade Meshtastic device available.

- **Manufacturer:** B&Q Consulting (Unit Engineering)
- **Product Page:** https://wiki.uniteng.com/en/meshtastic/station-g2
- **Tindie Store:** https://www.tindie.com/products/neilhao/meshtastic-mesh-device-station-g2/
- **Official Store:** https://shop.uniteng.com/product/meshtastic-mesh-device-station-edition/

### 1.2 Full Hardware Specifications

| Component | Specification |
|-----------|--------------|
| **MCU** | ESP32-S3 WROOM-1 (dual-core LX7, 240 MHz) |
| **Flash/PSRAM** | 16 MB Flash, 8 MB PSRAM |
| **WiFi** | 802.11 b/g/n (2.4 GHz) |
| **Bluetooth** | 5.0 LE |
| **LoRa Transceiver** | Semtech SX1262 |
| **Frequency Reference** | 32 MHz TCXO (+/-1.5 ppm) |
| **Power Amplifier** | 35 dBm (3.16 W) at P1dB compression point |
| **Max RF Output** | 36.5 dBm (4.46 W) @ US915; 37 dBm (5 W) @ EU868 |
| **LNA** | Dedicated ultra-low noise figure LNA (Gain: 18.5 dB typical, Noise Figure: 1.8 dB typical) |
| **Frequency Range** | 864 - 928 MHz |
| **Default TX Power** | 30 dBm (for license-free ISM band) |
| **Antenna Connector** | Rugged SMA socket (female) |
| **Display** | 1.3-inch OLED |
| **GPS** | Optional via GROVE GPS socket |
| **Expansion** | GROVE I2C socket, SparkFun QWIIC socket, IO Extension socket |
| **Power Input - USB** | USB-C with PD Protocol (negotiates 15V) |
| **Power Input - DC** | 1x5P pitch=1.5mm socket (9V-19V DC external) |
| **User Interface** | 1x user button, OLED status display |

### 1.3 What Makes It Special

The Station G2 is not just another ESP32+SX1262 board. Its distinguishing features:

1. **Dedicated PA chain:** The 35 dBm power amplifier is external to the SX1262 (which maxes at 22 dBm natively). This gives 5+ watts ERP with a decent antenna.
2. **Dedicated LNA:** The ultra-low noise figure (1.8 dB) LNA improves receive sensitivity by approximately 4 dB over standard designs. This means the G2 can hear weaker signals that other nodes miss.
3. **Fast-transient DC-DC converter:** Purpose-designed power regulation for clean RF performance.
4. **Rugged SMA connector:** Unlike U.FL/IPEX connectors on most dev boards, the SMA is field-serviceable and mechanically robust.

### 1.4 FCC / Legal Power Considerations

Under **FCC Part 15.247** for the 902-928 MHz ISM band:

| Parameter | Limit |
|-----------|-------|
| **Max conducted power** | 1 W (30 dBm) for digitally modulated systems |
| **Max EIRP** | 4 W (36 dBm) with directional antennas (antenna gain minus 6 dBi is subtracted from allowed EIRP) |
| **Frequency hopping** | Required if < 50 hopping channels, max 1 W; >= 50 channels allows up to 1 W conducted |
| **Dwell time** | 400 ms max per channel (LoRaWAN spec) |

**Critical note for LA-Mesh:** The Station G2 defaults to **30 dBm** output power, which is the legal limit for conducted power. The maximum hardware capability of 36.5 dBm (4.46 W) exceeds FCC limits for unlicensed operation. **Do NOT set TX power above 30 dBm unless operating under an amateur radio license on appropriate frequencies.** With a 6 dBi omnidirectional antenna at 30 dBm conducted, EIRP is 36 dBm -- right at the legal limit.

**Recommended legal configuration:**
- TX Power: 30 dBm (default)
- Antenna gain: up to 6 dBi omnidirectional (yields 36 dBm EIRP, legal max)
- With higher-gain antennas (10+ dBi), reduce TX power accordingly

### 1.5 Power and Solar Options

The Station G2 requires more power than typical Meshtastic nodes due to the high-power PA:

| Power Method | Details |
|-------------|---------|
| **USB-C PD** | Requires USB Power Delivery (15V negotiation). Standard 5V USB will NOT work. Need a PD-capable charger/battery bank (15W minimum). |
| **12V DC input** | 9V-19V via the 5-pin side connector. Ideal for solar setups. |
| **12V Battery Dock** | Optional accessory from B&Q Consulting for field deployment. |
| **Solar recommendation** | 20W+ solar panel with 12V MPPT charge controller and 12V LiFePO4 battery (12Ah+ for multi-day autonomy). The 12V DC input is far simpler for solar than USB PD. |

**Community build reference:** The Philly Mesh Station G2 rooftop installation used a Rokland 5.8 dBi outdoor antenna, antenna mount bracket, SMA-to-N adapter, and Anker 20W USB-C PD charger. Source: https://phillymesh.net/2025/03/24/station-g2-node-installation/

### 1.6 Weatherproofing / Enclosure Options

The Station G2 does NOT come in a weatherproof enclosure. For outdoor/rooftop deployment:

| Option | Description | Price Range |
|--------|-------------|-------------|
| **RAK WisMesh Unify Enclosure** | IP65-rated, fits various boards, optional solar panel | $25-50 |
| **Generic IP67 ABS box** | Amazon/eBay, drill holes for SMA and power cable glands | $10-20 |
| **Atlavox Beacon** | Purpose-built solar Meshtastic node, IP67, CNC aluminum, integrated mounting | $150-250 |
| **District47 Solar Node** | 18,000 mAh battery, IP67, designed for low-sun areas | $200+ |
| **DIY enclosure** | Polycase or Hammond ABS box with cable glands, silicone sealant | $15-30 |

**Recommended approach for Bates tower deployment:** Use a generic IP67 ABS enclosure (150x200x100mm minimum), two cable glands (one for SMA antenna feedthrough, one for 12V solar power), and mount using U-bolts or hose clamps to a pole or railing.

### 1.7 MeshCore Support

The Station G2 is **confirmed supported** by MeshCore firmware. It is listed in the MeshCore FAQ supported devices and is available in the MeshCore web flasher at https://flasher.meshcore.co.uk/. Both Meshtastic and MeshCore can be flashed to this device.

---

## 2. LilyGo T-Deck Pro (E-Ink)

### 2.1 Overview

The T-Deck Pro is the newest member of the T-Deck family, replacing the IPS LCD with a 3.1-inch e-paper display for dramatically improved battery life and sunlight readability. It is the ideal portable communicator for field use.

- **Official Store:** https://lilygo.cc/products/t-deck-pro-meshtastic
- **CNX Software Review:** https://www.cnx-software.com/2025/04/03/lilygo-t-deck-pro-esp32-s3-lora-messenger-e-paper-touch-display-keyboard-and-4g-lte-or-audio-codec-option/

### 2.2 Full Hardware Specifications

| Component | Specification |
|-----------|--------------|
| **MCU** | ESP32-S3FN16R8 (dual-core LX7, up to 240 MHz) |
| **Flash** | 16 MB SPI Flash |
| **PSRAM** | 8 MB |
| **WiFi** | 802.11 b/g/n (2.4 GHz) |
| **Bluetooth** | 5.0 LE |
| **LoRa Transceiver** | Semtech SX1262 |
| **LoRa TX Power** | Up to +22 dBm |
| **LoRa Frequencies** | 433 / 868 / 915 / 920 MHz (variant-dependent) |
| **Antenna (default)** | Integrated PCB antenna |
| **Antenna (optional)** | External antenna variant available (SMA or U.FL) |
| **Display** | 3.1-inch e-paper (GDEQ031T10), 320x240 resolution |
| **Touch** | CST328 capacitive touchscreen overlay on e-paper |
| **Display Refresh** | Full: 3s, Fast: 1s, Partial: 0.5s |
| **GPS** | u-blox MIA-M10Q GNSS module |
| **IMU** | Bosch BHI260AP self-learning AI smart sensor with integrated IMU |
| **Light Sensor** | Lite-on LTR-553ALS |
| **Keyboard** | Physical BlackBerry-style QWERTY, managed by secondary ESP32-C3 |
| **Audio** | Speaker, microphone, 3.5mm headphone jack |
| **Expansion** | Qwiic function module interface |
| **Storage** | MicroSD card slot |
| **Battery** | 1,400 mAh integrated LiPo |
| **Charging** | TP4065B via USB Type-C |
| **PMU** | Dedicated power management unit |
| **Dimensions** | 120 x 66 x 13.5 mm |
| **Variants** | PCM5102A Audio Codec version; A7682E 4G LTE version |

### 2.3 Two Hardware Variants

| Variant | Feature | Price (LilyGo official) |
|---------|---------|------------------------|
| **PCM5102A (Voice)** | High-quality audio codec for voice applications | $92.35 (915MHz) / $101.04 (915MHz + ext antenna) |
| **A7682E (4G)** | Simcom 4G LTE modem for cellular fallback | $102.91 (915MHz) / $110.85 (915MHz + ext antenna) |

**Note:** The 4G and Audio versions are mutually exclusive -- you cannot have both.

### 2.4 E-Ink Display Characteristics

The e-paper display is a major differentiator:
- **Sunlight readable:** Perfect for outdoor field use in Maine
- **Zero power to maintain image:** Display retains content with no power draw
- **Partial refresh at 0.5s:** Usable for messaging UI without full-screen redraws
- **Resolution:** 320x240 at 3.1 inches provides good text clarity
- **Limitation:** Not suitable for fast-updating content (maps scrolling, animations)

### 2.5 Battery Life

Community reports indicate the T-Deck Pro with its 1,400 mAh battery achieves comparable runtime to the T-Deck Plus (2,000 mAh) thanks to the e-ink display:

- **Active use (messaging, GPS on):** 8-12 hours estimated
- **Standby with GPS off:** Multiple days
- **Key factor:** GPS is enabled by default and is the primary power consumer. Disabling GPS dramatically extends battery life.

Source: Community reports on Reddit and LilyGo product reviews.

### 2.6 Firmware Support Status (CRITICAL)

**Meshtastic:**
- As of late 2025/early 2026, Meshtastic support for the T-Deck Pro has been achieved. The BaseUI version of Meshtastic works on the T-Deck Pro.
- Reddit thread "T-Deck Pro now works!" confirmed BaseUI Meshtastic running on the device.
- Earlier in 2025, the Pro was NOT supported. This is a recent development.
- Firmware filename: `firmware-t-deck-pro-X.X.X.xxxxxxx.bin`
- **Status: WORKING but relatively new. May have rough edges.**

**MeshCore:**
- The MeshCore FAQ lists "Lilygo T-Deck" in supported devices.
- The Aurora firmware (https://forge.hackers.town/Wrewdison/Aurora) provides a MeshCore implementation specifically for the T-Deck family.
- **T-Deck Pro e-ink-specific MeshCore support should be verified before bulk purchase.**

### 2.7 Recommendation for LA-Mesh

The T-Deck Pro is an excellent choice for **field operators** who need:
- All-day battery life
- Sunlight-readable display for outdoor use
- Compact, pocketable form factor
- Standalone operation without smartphone

**Buy the 915MHz external antenna variant** ($101-111 depending on variant) for better range. The internal PCB antenna is a compromise.

**Preferred variant for LA-Mesh:** PCM5102A (Voice) at $101.04 with external antenna. The 4G modem is unnecessary for a mesh network and adds cost/complexity.

---

## 3. LilyGo T-Deck Plus (Full-Featured)

### 3.1 Overview

The T-Deck Plus is the "full-featured" color-display member of the family. It has a 2.8-inch IPS LCD, GPS, larger battery, and the most mature firmware support of any T-Deck variant. This is the device most LA-Mesh members will recognize as the "BlackBerry-style Meshtastic communicator."

- **Official Store:** https://lilygo.cc/products/t-deck-plus-meshtastic
- **Amazon:** https://www.amazon.com/LILYGO-ESP32-S3-LORA-89-2-8-inch-Development/dp/B0FBGX1VP5

### 3.2 Full Hardware Specifications

| Component | Specification |
|-----------|--------------|
| **MCU** | ESP32-S3FN16R8 (dual-core LX7, up to 240 MHz) |
| **Flash** | 16 MB |
| **PSRAM** | 8 MB |
| **WiFi** | 802.11 b/g/n (2.4 GHz) |
| **Bluetooth** | 5.0 LE |
| **LoRa Transceiver** | Semtech SX1262 |
| **LoRa TX Power** | Up to +22 dBm |
| **LoRa Frequencies** | 433 / 868 / 915 / 920 MHz (variant-dependent) |
| **Antenna** | Internal PCB antenna (standard) or external SMA (variant) |
| **Display** | 2.8-inch IPS LCD (ST7789), 320x240 pixels, touch-enabled |
| **GPS** | u-blox module (integrated in Plus variant) |
| **Keyboard** | Physical BlackBerry-style QWERTY with backlight (ALT+B toggle) |
| **Trackball** | Integrated navigation trackball |
| **Audio** | Microphone, speaker |
| **Storage** | MicroSD card slot (max 32 GB) |
| **Battery** | 2,000 mAh integrated LiPo |
| **Charging** | USB Type-C |
| **Case** | ABS shell included |

### 3.3 Pricing

| Variant | Price (LilyGo Official) |
|---------|------------------------|
| 915MHz standard (PCB antenna) | $77.16 |
| 915MHz with external antenna | $82.11 |

Also available from:
- **Amazon (US warehouse):** ~$80-90 depending on variant
- **AliExpress:** Similar pricing, longer shipping
- **Rokland:** ~$85-95, US-based shipping
- **eBay:** Variable, often marked up $10-20

### 3.4 Display and Usability

- **2.8-inch IPS LCD:** Full color, good viewing angles, fast refresh
- **320x240 resolution:** Adequate for messaging, basic map display
- **Touchscreen:** Functional but the 240 MHz ESP32-S3 can feel sluggish with complex UI elements
- **Keyboard backlight:** Toggleable, useful for nighttime operation
- **Trackball:** Helps with menu navigation when touch is imprecise

**Known limitations:**
- No IP rating (not water/dust resistant)
- Map tile rendering is slow due to processor constraints
- 240 MHz processor struggles with demanding UI operations
- Battery life: 8-9 hours with active smartphone app usage

### 3.5 Firmware Support

**Meshtastic:** Fully supported, mature. Multiple UI options:
- Standard Meshtastic UI
- MUI (Meshtastic UI) -- enhanced interface
- FancyUI -- community-developed rich interface

**MeshCore:** Supported via:
- Standard MeshCore companion firmware
- Aurora firmware (community MeshCore implementation for T-Deck)
- Ripple Radios T-Deck Ultra firmware

**Multi-boot capability:** See Section 4 below.

### 3.6 Comparison: T-Deck Plus vs T-Deck Pro

| Feature | T-Deck Plus | T-Deck Pro |
|---------|-------------|------------|
| **Display** | 2.8" IPS LCD (color, fast) | 3.1" E-Paper (B&W, sunlight-readable) |
| **Battery** | 2,000 mAh | 1,400 mAh |
| **Effective battery life** | ~8-9 hours active | ~8-12 hours active (e-ink savings) |
| **GPS** | Yes (built-in) | Yes (u-blox MIA-M10Q) |
| **Sunlight readability** | Poor (LCD wash-out) | Excellent |
| **Night use** | Good (backlit LCD) | Requires frontlight/external light |
| **Firmware maturity** | Excellent (longest support) | Good (recently added, improving) |
| **4G option** | No | Yes (A7682E variant) |
| **Audio codec** | Basic speaker/mic | PCM5102A option for high-quality audio |
| **IMU** | No | Yes (Bosch BHI260AP) |
| **Dimensions** | Slightly thicker | 120x66x13.5mm (slimmer) |
| **Price (915MHz, ext ant)** | $82.11 | $101.04 - $110.85 |
| **Multi-boot (SD card)** | Proven (M5Stack Launcher) | Not confirmed |

---

## 4. Dual MeshCore/Meshtastic Firmware

### 4.1 Firmware Switching -- Not Dual-Boot (Usually)

There is **no true dual-boot partition scheme** that runs both MeshCore and Meshtastic simultaneously or switches between them at the bootloader level on standard ESP32 devices. However, there are multiple approaches to switch:

### 4.2 Method 1: M5Stack Launcher (T-Deck Plus -- RECOMMENDED)

The **M5Stack Launcher** enables SD-card-based multi-firmware selection on the T-Deck Plus:

1. Flash the M5Stack Launcher bootloader to the device
2. Place firmware .bin files on a 32 GB (max) microSD card
3. On power-up, select which firmware to boot from the SD card menu

**Supported firmwares via launcher:**
- Meshtastic (standard UI)
- Meshtastic with FancyUI
- MeshCore / Ripple Radios T-Deck Ultra
- Aurora MeshCore

**Setup guide:** https://www.om7tek.com/2025/how-to-use-the-m5stack-launcher-on-the-t-deck-plus-with-sd-card/

**SD card requirement:** SanDisk Extreme PRO 32 GB recommended. T-Deck cannot read cards > 32 GB.

**This is the best solution for LA-Mesh members who want both MeshCore and Meshtastic on a single device.**

### 4.3 Method 2: Web Flasher Re-flash

For devices without SD card multi-boot (including the Station G2):

**Meshtastic flasher:** https://flasher.meshtastic.org/
**MeshCore flasher:** https://flasher.meshcore.co.uk/

Both use Web Serial (Chrome/Edge browser + USB cable). The process takes 1-3 minutes:
1. Connect device via USB
2. Open flasher in Chrome
3. Select device model and firmware version
4. Flash (optionally with "Full Erase" to clear settings)

**Important:** ESP32 devices are "virtually impossible to brick" -- the built-in bootloader always remains accessible.

### 4.4 Method 3: OTA Updates

- **ESP32 devices:** OTA via WiFi using the built-in web interface. Connect to the device's WiFi AP, navigate to the config page, upload new firmware.
- **nRF52 devices:** OTA via Bluetooth using the nRF Connect app.

### 4.5 Method 4: Meshtastic BLE Flasher

A community tool (https://github.com/liamcottle/meshtastic-flasher-ble) allows flashing Meshtastic firmware over Bluetooth from a web browser -- no USB cable needed.

### 4.6 Firmware Strategy for LA-Mesh

| Device Role | Recommended Firmware | Switching Method |
|------------|---------------------|-----------------|
| **G2 Base Station (backbone relay)** | Meshtastic (primary) or MeshCore Repeater | Web flasher re-flash as needed |
| **T-Deck Plus (member handset)** | M5Stack Launcher with both | SD card boot selection |
| **T-Deck Pro (field operator)** | Meshtastic BaseUI (primary) | Web flasher re-flash |

---

## 5. Antenna and RF Design

### 5.1 Antenna Options by Deployment Type

#### Base Station / Tower (Station G2)

| Antenna | Gain | Type | Connector | Price | Notes |
|---------|------|------|-----------|-------|-------|
| **Rokland 5.8 dBi Outdoor Omni** | 5.8 dBi | Omnidirectional, outdoor-rated | N-Female | ~$25-35 | Most popular Meshtastic outdoor antenna. Good balance of gain and coverage. |
| **Meshnology 10 dBi Outdoor Omni** | 10 dBi | Omnidirectional, fiberglass | N-Female | ~$35-50 | Higher gain, narrower vertical beamwidth. Best for flat terrain, high-mount sites. |
| **RAK WisMesh Blade** | 5-6 dBi | Omnidirectional, fiberglass | N-Female | ~$30-40 | Purpose-built for Meshtastic, good quality. |
| **ALFA Network AYA-9012 Yagi** | 12 dBi | Directional | N-Female | ~$40-60 | Point-to-point links. 30-40 degree beamwidth. |
| **Tesswave 14 dBi Yagi** | 14 dBi | Directional | N-Female | ~$60-80 | Long-range point-to-point. Must reduce TX power to stay legal. |
| **Tesswave 16 dBi Yagi** | 16 dBi | Directional | N-Female | ~$80-100 | Maximum range. TX power must be reduced to 20 dBm for legal EIRP. |

**Adapters needed:** SMA-Male to N-Female adapter for connecting Station G2 (SMA) to outdoor antennas (typically N-type). Keep adapter count minimal -- each connection adds ~0.5 dB loss.

#### Portable Devices (T-Deck Plus/Pro)

| Antenna | Gain | Type | Price | Notes |
|---------|------|------|-------|-------|
| **Stock PCB antenna** | ~1-2 dBi | Internal, omnidirectional | Included | Adequate for close-range urban use. |
| **Nagoya NA-771 (915 MHz)** | ~3 dBi | Whip, SMA-Male | ~$10-15 | Classic upgrade. Requires external antenna variant. |
| **Signal Stuff Signal Stick** | ~3 dBi | Flexible whip | ~$20 | Well-regarded in Meshtastic community. |
| **MESHTAC Gooseneck** | 4 dBi | Flexible tactical | ~$15-20 | Bendable, good for body-worn setups. |
| **Meshnology 3 dBi stub** | 3 dBi | Short whip, SMA-Male | ~$8-12 | Compact upgrade for T-Deck. |

### 5.2 Coax and Feedline

For tower/rooftop installations, feedline loss matters:

| Cable Type | Loss @ 915 MHz (per 10 ft) | Recommendation |
|-----------|---------------------------|----------------|
| **RG-174** | ~2.5 dB | Avoid for runs > 3 ft |
| **RG-58** | ~1.5 dB | Acceptable for < 10 ft |
| **LMR-195** | ~1.2 dB | Good for 10-20 ft runs |
| **LMR-240** | ~0.9 dB | Better for 15-30 ft runs |
| **LMR-400** | ~0.5 dB | Best for 20-50 ft runs. Heavy, less flexible. |

**Rule of thumb:** Keep cable runs as short as possible. Mount the Station G2 near the antenna (in a weatherproof box) and run only power cable the long distance.

### 5.3 Polarization

All station antennas should use **vertical polarization** for consistency across the mesh. Meshtastic LoRa uses vertically polarized signals by convention. Mixing polarizations (e.g., horizontal yagi to vertical omni) incurs a 20+ dB cross-polarization loss.

---

## 6. Link Budget and Range Modeling for Southern Maine

### 6.1 Terrain Profile: Lewiston-Auburn Area

- **Average elevation:** 282 ft (Lewiston), 190 ft (Auburn)
- **Terrain:** Rolling hills, moderate forest cover (mixed deciduous/conifer), river valleys (Androscoggin River)
- **Building density:** Suburban/small city, mix of residential and light commercial
- **Seasonal factor:** Deciduous leaf cover (June-October) adds 3-8 dB foliage loss; bare trees (November-May) improve propagation

### 6.2 Link Budget Calculation

#### Station G2 to Station G2 (Base-to-Base)

```
TX Power (conducted):           +30 dBm (1 W, legal max)
TX feedline loss:               -1.0 dB (short LMR-240 run)
TX antenna gain:                +5.8 dBi (Rokland omni)
------
EIRP:                           +34.8 dBm

Free Space Path Loss @ 10 km:  -100.7 dB (FSPL at 915 MHz)
Additional terrain/foliage:     -15 to -30 dB (varies by obstruction)
------
Signal at RX antenna:           -80.9 to -95.9 dBm

RX antenna gain:                +5.8 dBi
RX feedline loss:               -1.0 dB
RX sensitivity (LongFast):     -136.5 dBm (SX1262 with LNA)
------
Link margin:                    +45.4 to +60.4 dB
```

**Interpretation:** Base-to-base links have 45-60 dB of margin at 10 km. This is excellent. Even with heavy forest and hills, Station G2 to Station G2 links should be reliable at 5-15+ km in southern Maine terrain.

#### Station G2 to T-Deck Plus (Base-to-Handheld)

```
TX Power (G2):                  +30 dBm
TX antenna gain:                +5.8 dBi (outdoor omni)
TX feedline loss:               -1.0 dB
EIRP:                           +34.8 dBm

FSPL @ 5 km:                   -94.7 dB
Terrain/foliage/body loss:     -20 to -35 dB
------
Signal at T-Deck:              -79.9 to -94.9 dBm

T-Deck antenna gain:           +1 dBi (PCB) to +3 dBi (external whip)
T-Deck RX sensitivity:         -134 dBm (SX1262 without external LNA)
------
Link margin:                   +40.1 to +58.1 dB
```

**Interpretation:** Base-to-handheld at 5 km has 40-58 dB margin. Usable in most conditions. Dense forest and buildings will reduce this. Handhelds with external antennas gain 2-4 dB.

### 6.3 Meshtastic Preset Link Budgets

| Preset | Link Budget | Data Rate | Use Case |
|--------|------------|-----------|----------|
| **Short Range / Turbo** | 140 dB | Fastest | Testing, same-room |
| **Short Range / Fast** | 146 dB | Fast | Campus, events |
| **Medium Range / Fast** | 150 dB | Moderate | Urban mesh |
| **Long Range / Fast** | 153 dB | Default | General use (RECOMMENDED) |
| **Long Range / Moderate** | 156 dB | Slower | Extended range |
| **Long Range / Slow** | 158.5 dB | Slowest | Maximum range |
| **Very Long Range / Slow** | 160+ dB | Very slow | Extreme range |

**Recommendation for LA-Mesh:** Start with **Long Range / Fast** (default). Switch to **Long Range / Moderate** if coverage is insufficient. Avoid Slow presets unless needed for specific long links -- they reduce network throughput significantly.

### 6.4 Estimated Coverage Ranges for LA-Mesh

| Scenario | Estimated Range |
|----------|----------------|
| G2 tower (30m height) to G2 tower (30m height), LOS | 15-50+ km |
| G2 tower (30m height) to G2 tower, obstructed (hills/forest) | 5-15 km |
| G2 tower to T-Deck handheld, suburban | 3-8 km |
| G2 tower to T-Deck handheld, dense forest | 1-3 km |
| T-Deck to T-Deck, suburban ground level | 0.5-2 km |
| T-Deck to T-Deck, open field/water | 2-5 km |

### 6.5 Bates College Tower Deployment Considerations

The Bates College campus in Lewiston sits at approximately 280 ft elevation. Key considerations:

1. **Height advantage:** Even a modest 30-50 ft tower or rooftop mount at Bates would provide excellent coverage over the Lewiston-Auburn metro area and into surrounding communities.
2. **Line of sight:** From Bates elevation, there is reasonable LOS to much of Lewiston and Auburn. The Androscoggin River valley may create RF shadows.
3. **WRBC radio station:** Bates has existing radio infrastructure (WRBC 91.5 FM, broadcasting from 31 Frye Street). This suggests institutional familiarity with antenna installations and potentially existing tower/roof access.
4. **Power availability:** A rooftop or tower installation at an educational institution will likely have reliable AC power, eliminating the need for solar in the primary site. Use a 12V power supply for the Station G2.
5. **Antenna recommendation:** A 5.8 dBi omnidirectional antenna mounted as high as possible. Consider a secondary directional (yagi) pointed toward the most distant desired coverage area.
6. **Redundancy:** Deploy two Station G2 units -- one primary, one backup. Or one Meshtastic, one MeshCore, for protocol diversity.

---

## 7. Bulk Procurement

### 7.1 Device Pricing Summary

| Device | Unit Price | External Antenna Variant | Best Source |
|--------|-----------|-------------------------|-------------|
| **Station G2** | $109 | SMA included (stock antenna included) | Tindie / B&Q Shop |
| **T-Deck Plus** (915MHz) | $77-82 | $82.11 (ext ant) | LilyGo Official / Amazon |
| **T-Deck Pro** (915MHz, Audio) | $92-101 | $101.04 (ext ant) | LilyGo Official / Amazon |
| **T-Deck Pro** (915MHz, 4G) | $103-111 | $110.85 (ext ant) | LilyGo Official |
| **Nano G2 Ultra** (portable alt) | $85-90 | N/A (internal antenna) | Tindie / B&Q Shop |
| **RAK WisMesh Pocket V2** (alt) | $99 | External LoRa ant included | RAK Store / Rokland |
| **RAK WisMesh Repeater Mini** | ~$99-149 | Included, IP67 solar | RAK Store / Rokland |

### 7.2 Vendors and Lead Times

| Vendor | Location | Lead Time | Bulk Discount | Notes |
|--------|----------|-----------|---------------|-------|
| **Rokland** (store.rokland.com) | USA | 3-7 days | Yes -- contact via live chat for QTY pricing | First authorized Meshtastic marketplace. Best US source. |
| **LilyGo Official** (lilygo.cc) | China (ships worldwide) | 7-21 days | 10% off codes periodically (e.g., code "LILYGO") | Direct from manufacturer. Cheapest per-unit. |
| **LilyGo AliExpress** | China | 14-30 days | AliExpress bulk pricing tiers | Sometimes cheaper than official store. |
| **Amazon** | USA | 1-3 days | No bulk discount | Fast shipping, easy returns, slightly higher price. |
| **B&Q Consulting / Tindie** | China | 14-30 days (or longer) | Not specified | **WARNING: US shipping currently impacted by customs delays. Station G2 frequently out of stock.** |
| **RAK Wireless** (store.rakwireless.com) | China/USA | 5-14 days | Contact for enterprise pricing | Professional-grade, well-documented. |
| **eBay** | Various | Variable | No | Markup common. Verify seller reputation. |

### 7.3 Station G2 Availability Warning

The Station G2 has **chronic stock issues**:
- Sold out on Tindie as of September 2025
- US shipping suspended by B&Q Consulting due to high rates of random US Customs inspections (packages delayed 1-4 weeks)
- eBay listings exist but at significant markup ($130-160+)

**Mitigation:**
1. Sign up for Tindie restock notifications immediately
2. Contact B&Q Consulting directly about bulk/community orders
3. Consider the **Nano G2 Ultra** ($85-90) as a smaller-form-factor alternative with similar PA/LNA (but uses nRF52840 MCU, not ESP32-S3)
4. For pure relay/repeater duty, the **RAK WisMesh Repeater** (IP67, solar-ready) is an alternative, though at lower TX power

### 7.4 Recommended LA-Mesh Procurement Plan

For a community of ~20 members with 3 relay sites:

| Item | Quantity | Unit Cost | Total | Source |
|------|----------|-----------|-------|--------|
| Station G2 (915MHz) | 4 (3 relay + 1 spare) | $109 | $436 | Tindie/B&Q (when in stock) |
| T-Deck Plus (915MHz, ext ant) | 15 | $82 | $1,230 | LilyGo Official or Rokland |
| T-Deck Pro (915MHz, Audio, ext ant) | 5 | $101 | $505 | LilyGo Official |
| Rokland 5.8 dBi outdoor omni antenna | 4 | $30 | $120 | Rokland |
| SMA-to-N adapters | 8 | $5 | $40 | Amazon |
| IP67 ABS enclosures (relay sites) | 4 | $15 | $60 | Amazon |
| Cable glands (pack of 10) | 2 | $10 | $20 | Amazon |
| LMR-240 cable (10 ft, N-to-SMA) | 4 | $20 | $80 | Rokland / Amazon |
| 20W solar panel (12V) | 3 | $30 | $90 | Amazon |
| 12V LiFePO4 battery (12Ah) | 3 | $50 | $150 | Amazon |
| 12V MPPT charge controller | 3 | $20 | $60 | Amazon |
| SanDisk 32GB microSD (for M5 Launcher) | 15 | $8 | $120 | Amazon |
| Meshnology 3dBi stub antennas (T-Deck) | 20 | $10 | $200 | Amazon |
| **TOTAL** | | | **$3,111** | |

Add ~15% for shipping, taxes, and contingency: **~$3,580 total estimated budget**

---

## 8. Sprint Integration Points

### 8.1 Hardware Procurement Timeline

| Week | Action | Dependencies | Status |
|------|--------|-------------|--------|
| Week 1 | Sign up for Station G2 restock notifications on Tindie | None | **GO** |
| Week 1 | Contact Rokland live chat for bulk pricing on T-Deck Plus (qty 15) | None | **GO** |
| Week 1 | Order T-Deck Pro samples (2x Audio variant, 915MHz, ext ant) for testing | Budget approval | **GO** |
| Week 2 | Validate T-Deck Pro Meshtastic BaseUI functionality | Sample in hand | **PENDING** |
| Week 2 | Validate T-Deck Pro MeshCore (Aurora) functionality | Sample in hand | **PENDING** |
| Week 2 | Order bulk T-Deck Plus units from LilyGo or Rokland | Budget approval + Rokland quote | **PENDING** |
| Week 3 | Order Station G2 units (when available) | Stock availability | **RISK: Stock constraint** |
| Week 3 | Order all antenna/enclosure/solar components from Amazon/Rokland | Budget approval | **GO** |
| Week 4 | Begin firmware flashing and configuration of received devices | Devices in hand | **PENDING** |

### 8.2 Firmware Flashing Procedures

#### Station G2 Flash Procedure (Meshtastic)
1. Connect Station G2 via USB-C (PD not required for flashing, standard USB works)
2. Open https://flasher.meshtastic.org/ in Chrome
3. Select device: "Station G2"
4. Select firmware version (latest stable)
5. Click "Full Erase and Install" for first flash, or "Update" for subsequent
6. Configure via Meshtastic app (Android/iOS) over Bluetooth or via web interface over WiFi

#### Station G2 Flash Procedure (MeshCore)
1. Connect via USB-C
2. Open https://flasher.meshcore.co.uk/ in Chrome
3. Select device: "Station G2"
4. Select firmware type: "Repeater" (for relay duty) or "Companion" (for BLE app use)
5. Flash

#### T-Deck Plus Multi-Boot Setup
1. Flash M5Stack Launcher: https://bmorcelli.github.io/Launcher/
2. Format 32GB microSD as FAT32
3. Download firmware binaries:
   - Meshtastic: from https://flasher.meshtastic.org/ (download .bin, don't flash)
   - MeshCore/Ripple: from https://flasher.meshcore.co.uk/ or Ripple Radios
4. Place .bin files on SD card root
5. Insert SD card, power on
6. Select firmware from Launcher menu

#### T-Deck Pro Flash Procedure
1. Power off device
2. Hold middle trackball button + connect USB-C
3. Release after 2-3 seconds (enters bootloader mode -- screen will be black)
4. Open https://flasher.meshtastic.org/ in Chrome
5. Select device: "T-Deck Pro"
6. Flash

### 8.3 Go/No-Go Decision Matrix

| Decision Point | Criteria | Current Assessment |
|----------------|----------|-------------------|
| **Station G2 procurement** | In stock at $109, ships to US | **NO-GO currently.** Out of stock; US shipping suspended. Monitor Tindie weekly. Fallback: RAK WisMesh Repeater for relay duty. |
| **T-Deck Plus for member handsets** | Available, firmware mature, price < $85 | **GO.** Widely available. Proven device. |
| **T-Deck Pro for field operators** | Meshtastic working, MeshCore working, battery life verified | **CONDITIONAL GO.** Meshtastic BaseUI confirmed working. MeshCore on e-ink needs hands-on verification. Order 2 samples first. |
| **M5Stack Launcher multi-boot** | Reliable switching, both firmwares stable | **GO.** Community-proven on T-Deck Plus. |
| **Solar relay sites** | Station G2 + solar + enclosure validated | **PENDING.** Needs Station G2 availability. Begin enclosure and solar component ordering now. |
| **Bates College tower site** | Physical access, power, antenna mounting approved | **PENDING.** Requires institutional coordination. Begin conversations with Bates facilities/IT. |

### 8.4 Gap Analysis

| Gap | Severity | Mitigation |
|-----|----------|------------|
| **Station G2 availability** | HIGH | Monitor restocking. Have Nano G2 Ultra or RAK WisMesh Repeater as backup. Consider eBay at markup for initial units. |
| **T-Deck Pro MeshCore validation** | MEDIUM | Order 2 samples immediately. Test Aurora firmware and standard MeshCore. If MeshCore doesn't work on Pro, use Pro for Meshtastic-only and T-Deck Plus for dual-firmware members. |
| **T-Deck Pro firmware maturity** | MEDIUM | BaseUI is new. Expect bugs. Have Meshtastic standard firmware as fallback. Community is actively developing. |
| **Station G2 USB PD power for solar** | MEDIUM | Use 12V DC input (not USB-C) for all solar installations. This simplifies the power chain and avoids PD negotiation issues. |
| **FCC compliance at high power** | LOW | Default 30 dBm is legal. Document policy: no TX power above 30 dBm without amateur license. |
| **Antenna impedance matching** | LOW | All recommended antennas are 50-ohm, matched to SX1262 design. Verify VSWR < 1.5:1 with NanoVNA if available. |
| **Seasonal propagation variation** | LOW | Maine leaf-on (summer) reduces range by 3-8 dB vs. leaf-off (winter). Plan relay spacing for summer worst-case. |
| **Customs delays for China-sourced devices** | MEDIUM | Prefer Rokland (US-based) or Amazon (US warehouse) over direct China orders for time-sensitive procurement. |

### 8.5 Alternative Devices to Consider

If Station G2 remains unavailable, these devices can fill the base station role:

| Device | TX Power | LNA | Price | Pros | Cons |
|--------|----------|-----|-------|------|------|
| **Heltec WiFi LoRa 32 V4** | 22 dBm | No dedicated LNA | ~$20 | Cheap, widely available | Low power, no PA, poor stock antenna |
| **LILYGO T-Beam Supreme** | 22 dBm | No dedicated LNA | ~$40-50 | GPS built-in, 18650 battery holder | No external PA, limited relay capability |
| **RAK WisMesh Repeater** | Standard (nRF52840) | No | ~$99-149 | IP67, solar-ready, zero maintenance | Lower TX power, nRF52 (not ESP32) |
| **RAK13302 1W PA Module** | 30 dBm (1W) | Integrated filter | ~$30 (module) | Adds 1W capability to any WisBlock | Requires WisBlock base, assembly needed |
| **Nano G2 Ultra** | 22 dBm (nRF52840 native) | Optimized RF frontend | ~$85-90 | Excellent portable node, wideband antenna | Not as powerful as Station G2 for relay duty |

### 8.6 Immediate Next Steps

1. **Order T-Deck Pro samples** (2x PCM5102A, 915MHz, external antenna) from Amazon for fastest delivery (~$100 each, 2-day shipping)
2. **Contact Rokland** via live chat for T-Deck Plus bulk pricing (qty 15-20)
3. **Set Tindie alerts** for Station G2 restock
4. **Order one RAK WisMesh Repeater** as Station G2 alternative evaluation
5. **Begin Bates College coordination** for tower/rooftop access
6. **Purchase a NanoVNA** (~$50) for antenna testing and VSWR verification
7. **Create firmware SD cards** -- prepare 32GB microSD cards with M5Stack Launcher + both firmware binaries

---

## Appendix A: Key URLs

| Resource | URL |
|----------|-----|
| Station G2 Wiki | https://wiki.uniteng.com/en/meshtastic/station-g2 |
| Station G2 on Tindie | https://www.tindie.com/products/neilhao/meshtastic-mesh-device-station-g2/ |
| Station G2 Meshtastic Docs | https://meshtastic.org/docs/hardware/devices/b-and-q-consulting/station-series/ |
| T-Deck Pro (LilyGo) | https://lilygo.cc/products/t-deck-pro-meshtastic |
| T-Deck Plus (LilyGo) | https://lilygo.cc/products/t-deck-plus-meshtastic |
| T-Deck Meshtastic Docs | https://meshtastic.org/docs/hardware/devices/lilygo/tdeck/ |
| MeshCore GitHub | https://github.com/meshcore-dev/MeshCore |
| MeshCore Web Flasher | https://flasher.meshcore.co.uk/ |
| Meshtastic Web Flasher | https://flasher.meshtastic.org/ |
| M5Stack Launcher Guide | https://www.om7tek.com/2025/how-to-use-the-m5stack-launcher-on-the-t-deck-plus-with-sd-card/ |
| Aurora MeshCore (T-Deck) | https://forge.hackers.town/Wrewdison/Aurora |
| Meshtastic Antenna Guide | https://meshtastic.org/docs/hardware/antennas/lora-antenna/ |
| Range Optimization Guide | https://meshunderground.com/posts/maximize-meshtastic-range-tips-and-deep-dive/ |
| FCC 47 CFR 15.247 | https://www.ecfr.gov/current/title-47/chapter-I/subchapter-A/part-15/subpart-C/subject-group-ECFR2f2e5828339709e/section-15.247 |
| Rokland (US retailer) | https://store.rokland.com/pages/meshtastic-hardware-rak-lilygo |
| RAK Wireless Meshtastic | https://store.rakwireless.com/collections/meshtastic |
| NH Meshtastic Device Guide | https://nhmesh.com/blog/meshtastic-latest-devices |
| MaineMesh (existing Maine project) | https://github.com/JFRHorton/MaineMesh |
| Lewiston Topographic Map | https://en-us.topographic-map.com/map-29gt/Lewiston/ |
| Philly Mesh G2 Install | https://phillymesh.net/2025/03/24/station-g2-node-installation/ |

## Appendix B: Comparison of All Target Devices

| Feature | Station G2 | T-Deck Plus | T-Deck Pro |
|---------|-----------|-------------|------------|
| **Role** | Base/Relay | Member Handset | Field Operator |
| **MCU** | ESP32-S3 | ESP32-S3 | ESP32-S3 |
| **LoRa** | SX1262 + 35dBm PA + LNA | SX1262 (22 dBm native) | SX1262 (22 dBm native) |
| **Max TX** | 36.5 dBm (4.46 W) | 22 dBm (158 mW) | 22 dBm (158 mW) |
| **RX Sensitivity** | Enhanced (LNA: 18.5dB gain, 1.8dB NF) | Standard SX1262 | Standard SX1262 |
| **Display** | 1.3" OLED | 2.8" IPS LCD color | 3.1" E-Paper touch |
| **Keyboard** | None | QWERTY + trackball | QWERTY + touch |
| **GPS** | Optional (GROVE socket) | Yes (integrated) | Yes (u-blox MIA-M10Q) |
| **Battery** | None (external power) | 2,000 mAh | 1,400 mAh |
| **Antenna** | SMA (rugged) | PCB or external (variant) | PCB or external (variant) |
| **Weatherproof** | No (needs enclosure) | No | No |
| **Meshtastic** | Yes (stable) | Yes (mature) | Yes (BaseUI, recent) |
| **MeshCore** | Yes (confirmed) | Yes (confirmed, Aurora) | Needs verification |
| **Multi-boot** | No (reflash only) | Yes (M5Stack Launcher) | Not confirmed |
| **Price** | $109 | $77-82 | $92-111 |
| **Availability** | POOR (frequently OOS) | GOOD | GOOD |
