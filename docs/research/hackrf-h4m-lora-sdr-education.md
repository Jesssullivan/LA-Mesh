# HackRF H4M PortaPack + LoRa SDR Education Deep Dive

**LA-Mesh Project -- Bates College**
**Research Date:** 2026-02-11
**Status:** Comprehensive Research Report

---

## Table of Contents

1. [HackRF One + H4M PortaPack](#1-hackrf-one--h4m-portapack)
2. [LoRa Protocol Analysis with HackRF](#2-lora-protocol-analysis-with-hackrf)
3. [TEMPEST/RF Security Education](#3-tempestrf-security-education)
4. [dBm Calculations Coursework](#4-dbm-calculations-coursework)
5. [LoRa Packet Debugging](#5-lora-packet-debugging)
6. [Curriculum Design](#6-curriculum-design)
7. [Firmware Management](#7-firmware-management)
8. [Sprint Integration Points](#sprint-integration-points)

---

## 1. HackRF One + H4M PortaPack

### 1.1 Hardware Overview

The HackRF One is an open-source SDR platform operating from 1 MHz to 6 GHz, with both TX and RX capability, 8-bit ADC, up to 20 MHz bandwidth, and USB 2.0 connectivity. The PortaPack H4M is the latest generation accessory that adds a touchscreen, controls, battery, and onboard processing for standalone portable operation.

**H4M Key Specifications:**
- 3.2" TFT matte display (reduced glare, better outdoor visibility)
- USB-C port (faster charging vs H2's micro-USB)
- Sliding power switch (eliminates phantom battery drain of H2)
- Real-time battery percentage, voltage, current draw display
- GPIO expansion header for add-on modules (GPS, sensors)
- Combined encoder and 4-way button for navigation
- Streamlined, compact form factor

**H4M vs H2 vs H1 Comparison:**

| Feature | H1 | H2 | H4M |
|---------|----|----|-----|
| Battery | None (external power) | Internal Li-Ion | Internal Li-Ion + smart management |
| Display | Basic | Glossy TFT | Matte TFT (outdoor-friendly) |
| USB | Micro-USB | Micro-USB | USB-C |
| Power switch | None | Toggle | Sliding (full disconnect) |
| Battery info | N/A | Limited | Full telemetry in firmware |
| Audio | No speaker | Speaker header | Speaker header |
| GPIO | None | Limited | Expansion header |

**References:**
- [RTL-SDR H4M Review](https://www.rtl-sdr.com/a-review-of-the-new-hackrf-portapack-h4m/)
- [SDR Store H4M vs H2 Comparison](https://www.sdrstore.eu/portapack-h4m-vs-h2-comparison/)
- [Mobile Hacker H4M Guide](https://www.mobile-hacker.com/2025/05/19/hackrf-portapack-h4m-with-mayhem-firmware-a-powerful-handheld-sdr-toolkit/)

### 1.2 Firmware Options

#### Mayhem Firmware (Recommended)

**Repository:** https://github.com/portapack-mayhem/mayhem-firmware

Mayhem is the dominant community firmware for PortaPack devices. It supports H1, H2, and H4M hardware. As of 2026-02-10, nightly releases are actively published.

**Key Applications (categorized):**

| Category | Applications |
|----------|-------------|
| **Receive** | ADS-B, AFSK, AIS, Analog TV, APRS, Audio, BLE, ERT, Morse, NOAA APT, POCSAG, Radiosonde, SSTV, TPMS, Weather, WeFax |
| **Transmit** | APRS, BLE, GPS Sim, Jammer, Morse, OOK, POCSAG, Spectrum Painter, SSTV |
| **Analysis** | Looking Glass (spectrum), Level (signal strength), Detector (wideband), gfxEQ |
| **Capture/Replay** | Raw IQ capture, signal replay |
| **Utilities** | Scanner, Flash Utility, WAV Viewer, Hopper (frequency hopping) |
| **Flipper** | FlipperTX (.sub file replay -- bridging Flipper Zero community) |

**Critical Gap: No native LoRa app exists in Mayhem.** Feature requests have been open since 2021:
- [Issue #400](https://github.com/portapack-mayhem/mayhem-firmware/issues/400) -- Original LoRa/Meshtastic receiver request (open, 42 comments, 45 thumbs-up)
- [Issue #2400](https://github.com/portapack-mayhem/mayhem-firmware/issues/2400) -- Meshtastic 915MHz capability (closed as duplicate of #400)
- [Issue #2171](https://github.com/portapack-mayhem/mayhem-firmware/issues/2171) -- Meshtastic integration request

The core challenge is implementing CSS (Chirp Spread Spectrum) demodulation on the PortaPack's embedded processor. No developer has committed to this work.

#### Original HackRF Firmware

The stock Great Scott Gadgets firmware provides basic SDR functionality when used with a computer. It does not include PortaPack UI features and is primarily useful for `hackrf_sweep`, `hackrf_transfer`, and other command-line tools.

**Repository:** https://github.com/greatscottgadgets/hackrf

#### Mayhem Hub (Web Interface)

**URL:** https://hackrf.app/

Web-based interface for firmware management, supporting WebUSB Serial for browser-based flashing. Supports stable, nightly, and custom firmware versions.

### 1.3 Keeping Firmware Up to Date

**Method 1: On-Device Flash Utility (Easiest)**
1. Download `.ppfw.tar` from [Mayhem Releases](https://github.com/portapack-mayhem/mayhem-firmware/releases)
2. Copy to SD card root
3. Use Flash Utility app in Utilities menu
4. The `.ppfw.tar` format updates firmware AND external apps together

**Method 2: hackrf.app Website**
1. Connect device via USB to WebUSB-capable browser
2. Navigate to https://hackrf.app/
3. Select firmware version (stable/nightly/custom)
4. Device auto-reboots after flashing

**Method 3: hackrf_spiflash CLI**
```bash
# Linux
hackrf_spiflash -w portapack-h1_h2-mayhem.bin

# macOS (install via brew first)
brew install hackrf
hackrf_spiflash -w portapack-h1_h2-mayhem.bin
```

**Important:** SD card content (maps, external apps `.ppma` files) must version-match the firmware. Use a 16GB+ card.

**References:**
- [Firmware Update Wiki](https://github.com/portapack-mayhem/mayhem-firmware/wiki/Update-firmware)
- [Mayhem Releases](https://github.com/portapack-mayhem/mayhem-firmware/releases)

---

## 2. LoRa Protocol Analysis with HackRF

### 2.1 Can HackRF Decode LoRa?

**Yes, but not natively on the PortaPack.** HackRF can capture raw IQ data at 915 MHz, and computer-side software (GNU Radio + gr-lora modules) can demodulate and decode the Chirp Spread Spectrum (CSS) signals. This is the primary workflow:

```
[LoRa TX] ---> [HackRF One (IQ capture)] ---> [Computer (GNU Radio + gr-lora)]
                                                        |
                                              [Decoded packets / Waterfall display]
```

LoRa uses CSS modulation where data is encoded in frequency chirps that sweep across the bandwidth. Higher spreading factors use longer chirps (more chips per symbol), trading data rate for sensitivity and range.

### 2.2 GNU Radio LoRa Decoder Projects

There are three major gr-lora implementations:

#### gr-lora_sdr (EPFL -- Recommended)

**Repository:** https://github.com/tapparelj/gr-lora_sdr
**Institution:** EPFL Telecommunication Circuits Laboratory
**License:** GPL-3.0

This is the most complete and academically rigorous implementation. It provides a **full LoRa transceiver** (both TX and RX) in GNU Radio.

**Supported Parameters:**
- Spreading Factors: SF5-SF12 (SF5-6 incompatible with SX126x chips)
- Coding Rates: 0-4
- Header Modes: Implicit and explicit
- Payload: 1-255 bytes
- CRC verification, soft-decision decoding
- Low datarate optimization mode

**Receiver chain:** Packet synchronization -> STO/CFO estimation/correction -> Demodulation -> Gray demapping -> Deinterleaving -> Hamming decoding -> Dewhitening -> CRC verification

**Installation (Conda -- easiest):**
```bash
conda install -c tapparelj -c conda-forge gnuradio-lora_sdr
```

**Installation (from source):**
```bash
# Prerequisites: GNU Radio 3.10, Python 3, CMake, libvolk, Boost, gcc >9.3.0, pybind11
git clone https://github.com/tapparelj/gr-lora_sdr.git
cd gr-lora_sdr
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local
make -j$(nproc)
sudo make install
sudo ldconfig
```

**Tested hardware:** USRP, RFM95, SX1276, SX1262. HackRF One is compatible via SoapySDR.

#### rpp0/gr-lora

**Repository:** https://github.com/rpp0/gr-lora

The original community LoRa decoder for GNU Radio. Receive-only. HackRF One is a tested receiver. For HackRF and USRP, frequency offset correction is usually not needed (unlike cheap RTL-SDR dongles).

**Installation:**
```bash
git clone https://github.com/rpp0/gr-lora.git
mkdir build && cd build
cmake ../
make && sudo make install
```

Docker option available: `cd docker/ && ./docker_run_grlora.sh`

**Output:** Decoded messages printed to console or forwarded to UDP port 40868.

#### jkadbear/gr-lora

**Repository:** https://github.com/jkadbear/gr-lora

Fork focused on collision decoding -- useful for dense mesh network analysis where multiple LoRa transmitters may overlap.

### 2.3 Meshtastic SDR Decode Project

**Repository:** https://gitlab.com/crankylinuxuser/meshtastic_sdr
**Author:** Josh Conway

This project builds on gr-lora_sdr to provide a full Meshtastic transceiver stack (both RX and TX) for SDR. It works with any SDR supported by SoapySDR, including HackRF.

**Setup (based on Jeff Geerling's documented procedure):**
```bash
# Install core dependencies
sudo apt install -y gnuradio cmake hackrf libhackrf-dev soapysdr-module-hackrf
pip3 install meshtastic

# Install gr-lora_sdr (see above)

# Clone Meshtastic_SDR
git clone https://gitlab.com/crankylinuxuser/meshtastic_sdr.git

# Load GRC flowgraph for visualization
gnuradio-companion meshtastic_sdr/rx_flowgraph.grc
```

**Meshtastic US LongFast channel:** 906.875 MHz center frequency, sync word 0x2B.

**Known issues (as of 2025):**
- RX Python decode script sometimes produces garbled output
- NumPy version compatibility issues (may need `pip install numpy==1.26.4`)
- Library path issues with CMAKE_INSTALL_PREFIX

**References:**
- [Jeff Geerling: Decoding Meshtastic with GNU Radio](https://www.jeffgeerling.com/blog/2025/decoding-meshtastic-gnuradio-on-raspberry-pi/)
- [RTL-SDR: Decoding Meshtastic in Realtime](https://www.rtl-sdr.com/decoding-meshtastic-in-realtime-with-an-rtl-sdr-and-gnu-radio/)
- [Hackaday: Decoding Meshtastic with GNU Radio](https://hackaday.com/2024/06/26/decoding-meshtastic-with-gnu-radio/)
- [RTL-SDR: Transmitting and Receiving Meshtastic with SDR](https://www.rtl-sdr.com/transmitting-and-receiving-meshtastic-with-sdr/)

### 2.4 Waterfall Visualization of LoRa Chirps

LoRa chirps are visually distinctive on a waterfall display -- they appear as diagonal lines sweeping from low to high frequency (up-chirps) or high to low (down-chirps). The preamble consists of repeated up-chirps, followed by sync down-chirps, then data chirps.

**Tools for waterfall visualization:**

| Tool | Platform | Notes |
|------|----------|-------|
| GNU Radio QT GUI Waterfall Sink | Linux/Mac | Best for real-time LoRa analysis |
| SDR++ | Cross-platform | General SDR receiver with waterfall |
| GQRX | Linux/Mac | Easy to use, good for initial exploration |
| PortaPack Looking Glass | Standalone | Built into Mayhem firmware, wideband only |
| SDR# | Windows | Popular, HackRF via Zadig drivers |

**GNU Radio Waterfall Setup:**
1. Create flowgraph with HackRF source block (via SoapySDR or OsmoSDR)
2. Set center frequency to 906.875 MHz (US LongFast)
3. Set sample rate to 250 kHz or higher
4. Add QT GUI Waterfall Sink
5. Add Rational Resampler to narrow bandwidth if needed
6. Observe diagonal chirp patterns when Meshtastic devices transmit

### 2.5 Spectrum Analysis of 915 MHz ISM Band

**hackrf_sweep** is the primary tool for wideband spectrum analysis:

```bash
# Scan the US 915MHz ISM band (902-928 MHz)
hackrf_sweep -f 900:930 -w 100000 -l 32 -g 32

# Parameters:
# -f: frequency range in MHz
# -w: FFT bin width in Hz
# -l: LNA gain (0-40 dB)
# -g: VGA gain (0-62 dB)
```

hackrf_sweep can scan up to 8 GHz/second, making full 0-6 GHz sweeps possible in under a second.

**GUI spectrum analyzer tools:**

| Tool | URL | Notes |
|------|-----|-------|
| QSpectrumAnalyzer | https://github.com/xmikos/qspectrumanalyzer | PyQtGraph GUI for hackrf_sweep |
| hackrf-spectrum-analyzer | https://github.com/pavsa/hackrf-spectrum-analyzer | Java-based, Windows-friendly |
| PortaPack Looking Glass | Built-in | Standalone spectrum display on device |
| PortaPack Level | Built-in | Signal strength measurement |
| PortaPack Detector | Built-in | Wideband signal detector with RSSI history |

**References:**
- [HackRF Tools Documentation](https://hackrf.readthedocs.io/en/latest/hackrf_tools.html)
- [0xStubs: HackRF as Spectrum Analyzer](https://0xstubs.org/using-the-hackrf-one-as-a-wideband-spectrum-analyzer/)
- [SDR Store: H4M Spectrum Analyzer Guide](https://www.sdrstore.eu/hackrf-h4m-portable-spectrum-analyzer/)

---

## 3. TEMPEST/RF Security Education

### 3.1 What is TEMPEST?

TEMPEST (Telecommunications Electronics Material Protected from Emanating Spurious Transmissions) refers to techniques for eavesdropping on electronic equipment via unintentional electromagnetic emissions. Also known as Van Eck phreaking, it exploits the fact that electronic devices, particularly display cables and monitors, emit RF radiation that can be captured and reconstructed.

### 3.2 TempestSDR Software

**Repository:** https://github.com/martinmarinov/TempestSDR

TempestSDR is an open-source tool for remote video eavesdropping using SDR. It consists of:
- C library for signal processing
- Plugins for various SDR front-ends (HackRF, RTL-SDR, Airspy, SDRplay)
- Java-based GUI
- Cross-platform operation

**How it works:** Raster video is transmitted one line of pixels at a time as a varying current, generating electromagnetic waves. TempestSDR maps received field strength to grayscale shades in real-time, reconstructing the original video signal.

### 3.3 Educational TEMPEST Demonstration with HackRF

**Demo Repository:** https://github.com/aalex954/tempest-sdr-demo

**Hardware Required:**
- HackRF One (produces better results than RTL-SDR due to higher sample rates)
- Directional antenna (log-periodic or Yagi recommended)
- Target: computer with HDMI display (HDMI 1.2 cables emit strongly)

**Step-by-Step Procedure:**

1. **Connect HackRF** via USB, verify driver installation
2. **Wideband scan** (300-800 MHz) to identify display emanation peaks
3. **Launch TempestSDR**, select HackRF as source
4. **Tune to identified frequency** (typically where spikes appear in spectrum)
5. **Set display parameters** (1920x1080 @ 60Hz, or use auto-detect)
6. **Refine signal** using the height/width sliders until monitor content becomes visible
7. **Discuss defenses:** shielded cables, TEMPEST-rated monitors, distance attenuation

**Safety and Legal Notes:**
- This demonstration must be performed on equipment you own or have explicit authorization to test
- The demonstration works best on unshielded HDMI cables at short range (1-5 meters in classroom setting)
- Modern DisplayPort and USB-C with good shielding are much harder to capture
- Use this to teach **defensive** RF security concepts

**References:**
- [TempestSDR GitHub](https://github.com/martinmarinov/TempestSDR)
- [TempestSDR Demo with HackRF](https://github.com/aalex954/tempest-sdr-demo)
- [RTL-SDR: TempestSDR Overview](https://www.rtl-sdr.com/tempestsdr-a-sdr-tool-for-eavesdropping-on-computer-screens-via-unintentionally-radiated-rf/)
- [Raymond EMC: TEMPEST Security](https://raymondemc.com/news/tempest-and-tempestsdr-securing-information-and-privacy/)
- [Practical TEMPEST SDR Attack Guide](https://medium.com/@jeroenverhaeghe/practical-tempest-sdr-attack-1bbc07cfa8)
- [TEMPEST with DVB-T Stick Tutorial](https://ivanorsolic.github.io/post/tempest/)

### 3.4 Additional RF Security Demonstrations

| Demo | Concept | Tools | Difficulty |
|------|---------|-------|------------|
| TEMPEST screen capture | EM emanation reconstruction | TempestSDR + HackRF | Medium |
| Unintentional emission scanning | Finding RF leakage from devices | hackrf_sweep + QSpectrumAnalyzer | Easy |
| Replay attacks (OOK) | Signal capture and retransmission | PortaPack Capture/Replay | Easy |
| ADS-B monitoring | Aircraft tracking via 1090 MHz | PortaPack ADS-B app | Easy |
| POCSAG pager decoding | Unencrypted pager message capture | PortaPack POCSAG RX | Easy |
| Bluetooth LE sniffing | BLE advertisement capture | PortaPack BLE RX | Medium |

---

## 4. dBm Calculations Coursework

### 4.1 Core RF Engineering Formulas

#### Free Space Path Loss (FSPL)

The Friis free-space path loss equation:

```
FSPL(dB) = 20*log10(d) + 20*log10(f) + 20*log10(4*pi/c)

Simplified:
FSPL(dB) = 20*log10(d_km) + 20*log10(f_MHz) + 32.44
```

Where:
- `d_km` = distance in kilometers
- `f_MHz` = frequency in MHz
- `c` = speed of light (3 x 10^8 m/s)

**Example at 915 MHz:**
```
FSPL at 1 km = 20*log10(1) + 20*log10(915) + 32.44
             = 0 + 59.23 + 32.44
             = 91.67 dB

FSPL at 5 km = 20*log10(5) + 20*log10(915) + 32.44
             = 13.98 + 59.23 + 32.44
             = 105.65 dB

FSPL at 10 km = 20*log10(10) + 20*log10(915) + 32.44
              = 20 + 59.23 + 32.44
              = 111.67 dB
```

#### Link Budget

```
Link Budget (dB) = Tx_power(dBm) + Tx_antenna_gain(dBi) + Rx_antenna_gain(dBi)
                   - Path_loss(dB) - Cable_losses(dB) - Misc_losses(dB)

Link Margin = Link_Budget - Rx_sensitivity(dBm)
```

**If Link Margin > 0 dB, the link works.**

#### Receiver Sensitivity

```
Rx_sensitivity(dBm) = -174 + 10*log10(BW) + NF + SNR_required

Where:
- -174 dBm/Hz = thermal noise floor at room temperature
- BW = bandwidth in Hz
- NF = noise figure in dB (typically 6 dB for LoRa)
- SNR_required = minimum SNR for demodulation (varies by SF)
```

### 4.2 LoRa Receiver Sensitivity Table

Based on the Semtech SX1276 datasheet specifications:

| Spreading Factor | Required SNR (dB) | Sensitivity @ 125kHz (dBm) | Sensitivity @ 250kHz (dBm) | Sensitivity @ 500kHz (dBm) |
|:-:|:-:|:-:|:-:|:-:|
| SF7 | -7.5 | -123 | -120 | -117 |
| SF8 | -10 | -126 | -123 | -120 |
| SF9 | -12.5 | -129 | -126 | -123 |
| SF10 | -15 | -132 | -129 | -126 |
| SF11 | -17.5 | -134.5 | -131.5 | -128.5 |
| SF12 | -20 | -137 | -134 | -131 |

**Key insight:** Each step in SF adds approximately 2.5-3 dB of sensitivity but halves the data rate.

### 4.3 LoRa Data Rate vs Spreading Factor

| SF | Bit Rate (125kHz) | Bit Rate (250kHz) | Bit Rate (500kHz) | Time on Air (10 bytes) |
|:-:|:-:|:-:|:-:|:-:|
| SF7 | 5,470 bps | 10,940 bps | 21,880 bps | ~36 ms |
| SF8 | 3,125 bps | 6,250 bps | 12,500 bps | ~62 ms |
| SF9 | 1,760 bps | 3,520 bps | 7,040 bps | ~113 ms |
| SF10 | 980 bps | 1,960 bps | 3,920 bps | ~206 ms |
| SF11 | 440 bps | 880 bps | 1,760 bps | ~413 ms |
| SF12 | 250 bps | 500 bps | 1,000 bps | ~827 ms |

### 4.4 Complete LoRa Link Budget Example

**Scenario:** Meshtastic node on Bates College campus to downtown Lewiston

```
Parameters:
- Tx Power: +20 dBm (100 mW, Meshtastic default for US)
- Tx Antenna Gain: +3 dBi (small whip antenna)
- Rx Antenna Gain: +3 dBi
- Cable/connector losses: 1 dB each side
- Frequency: 906.875 MHz (US LongFast)
- Distance: 3 km
- Spreading Factor: SF11 (Meshtastic LongFast default)
- Bandwidth: 250 kHz

Step 1: Calculate FSPL
  FSPL = 20*log10(3) + 20*log10(906.875) + 32.44
       = 9.54 + 59.15 + 32.44
       = 101.13 dB (free space)

Step 2: Add urban penalty (+20 dB typical for urban)
  Effective path loss = 101.13 + 20 = 121.13 dB

Step 3: Calculate received power
  Rx_power = 20 + 3 + 3 - 121.13 - 1 - 1 = -97.13 dBm

Step 4: Compare to sensitivity
  SF11 @ 250kHz sensitivity = -131.5 dBm
  Link Margin = -97.13 - (-131.5) = 34.37 dB

Result: Link works with 34.37 dB margin (excellent)
```

### 4.5 Practical Exercises with HackRF

**Exercise 1: Measure Actual Signal Levels**
```bash
# Use HackRF to capture IQ data at 906.875 MHz
hackrf_transfer -r capture.raw -f 906875000 -s 2000000 -l 32 -g 32 -n 20000000

# Analyze power levels in GNU Radio or Python
# Note: HackRF is not calibrated, but relative measurements are useful
```

**Exercise 2: Band Survey**
```bash
# Sweep 902-928 MHz ISM band
hackrf_sweep -f 902:928 -w 50000 -l 32 -g 32 -N 100 > sweep_data.csv

# Plot in QSpectrumAnalyzer or Python/matplotlib
```

**Exercise 3: Verify Inverse Square Law**
- Place Meshtastic node at known distances (10m, 20m, 50m, 100m)
- Record RSSI at each distance using both Meshtastic client and HackRF
- Plot power vs distance, verify 20*log10(d) relationship
- Compare to theoretical FSPL

**Exercise 4: Antenna Comparison**
- Measure received power from same source with different antennas
- Stock whip vs directional Yagi
- Calculate effective antenna gain difference

**References:**
- [LoRa Documentation](https://lora.readthedocs.io/en/latest/)
- [The Things Network: Estimating Service Radius](https://www.thethingsnetwork.org/community/oxford/post/estimating-the-service-radius)
- [LoRaWAN Link Budget Calculator](https://www.rfwireless-world.com/terminology/lorawan-link-budget)
- [LoRa Calculator](https://waycalculator.com/tool/LoRa-Calculator.php)
- [Campbell Scientific: Link Budget App Note](https://s.campbellsci.com/documents/us/technical-papers/link-budget.pdf)
- [Semtech SX1276 Datasheet](https://cdn-shop.adafruit.com/product-files/3179/sx1276_77_78_79.pdf)
- [Free Space Path Loss Calculator](https://www.everythingrf.com/rf-calculators/free-space-path-loss-calculator)

---

## 5. LoRa Packet Debugging

### 5.1 Meshtastic Packet Structure

Meshtastic packets consist of four layers:

```
+------------------------------------------+
| Layer 1: LoRa PHY                        |
| - Preamble (8+ symbols)                  |
| - Sync Word (0x2B for Meshtastic)        |
| - LoRa Header (SF, CR, payload length)   |
+------------------------------------------+
| Layer 2: MeshPacket (unencrypted header)  |
| - Source ID (32-bit, from BLE address)    |
| - Destination ID (32-bit)                |
| - Packet ID (32-bit random)              |
| - Channel (8-bit, XOR of name + key)     |
| - Flags/Hop count                        |
+------------------------------------------+
| Layer 3: MeshPayload (encrypted)         |
| - AES-256-CTR encrypted                  |
| - Packet ID used as nonce                |
| - Port number for application routing    |
+------------------------------------------+
| Layer 4: Application Data (protobuf)     |
| - Text messages                          |
| - Node info                              |
| - Position (GPS)                         |
| - Telemetry                              |
+------------------------------------------+
| LoRa CRC (optional)                      |
+------------------------------------------+
```

**Default US LongFast Configuration:**
- Frequency: 906.875 MHz
- Spreading Factor: SF11
- Bandwidth: 250 kHz
- Coding Rate: CR4/5
- Tx Power: +20 dBm (max +30 dBm allowed by FCC)
- Sync Word: 0x2B

**Security Notes (from disk91.com analysis):**
- No message authentication/signing -- identity spoofing possible
- No replay protection in default configuration
- Channel encoding leaks PSK information via XOR
- No CRC to verify proper decryption
- Most networks run unencrypted (default "AQ==" key for LongFast)

**References:**
- [Meshtastic Protobuf Definitions](https://github.com/meshtastic/protobufs/blob/master/meshtastic/mesh.proto)
- [MeshPacket Structure (DeepWiki)](https://deepwiki.com/meshtastic/protobufs/2.1-meshpacket-structure)
- [Critical Analysis of Meshtastic Protocol](https://www.disk91.com/2024/technology/lora/critical-analysis-of-the-meshtastic-protocol/)
- [Meshtastic Mesh Algorithm](https://meshtastic.org/docs/overview/mesh-algo/)

### 5.2 MeshCore Packet Structure

MeshCore is a separate mesh protocol (not Meshtastic) with a different packet layout:

```
+------------------------------------------+
| Header (8 bytes)                         |
| - Packet ID (4 bytes)                    |
| - Source Address (2 bytes)               |
| - Destination Address (2 bytes)          |
| - Hop Count (1 byte)                     |
| - Flags (1 byte)                         |
+------------------------------------------+
| Payload (max 237 bytes)                  |
| - Message Type (1 byte)                  |
| - Encrypted Data (max 236 bytes)         |
+------------------------------------------+
| Checksum (2 bytes, CRC16)                |
+------------------------------------------+
```

**MeshCore Analysis Tools:**
- [MeshCore Packet Knife](https://jkingsman.github.io/meshcore-packet-knife/) -- Online decoder/analyzer with brute-force key recovery
- [meshcore-decoder (Python)](https://pypi.org/project/meshcoredecoder/) -- Python library for packet decoding
- [meshcore-decoder (TypeScript)](https://github.com/michaelhart/meshcore-decoder) -- TypeScript library with WASM crypto
- [MeshExplorer](https://github.com/ajvpot/meshexplorer) -- Real-time map and packet analysis for both MeshCore and Meshtastic

### 5.3 Capture and Decode Tools

#### GNU Radio + gr-lora_sdr (Primary Method)

This is the most reliable method for capturing raw LoRa frames from the air:

```bash
# 1. Install gr-lora_sdr (see Section 2.2)

# 2. Use the Meshtastic_SDR project for full decode chain
git clone https://gitlab.com/crankylinuxuser/meshtastic_sdr.git

# 3. Run the RX flowgraph
python3 meshtastic_sdr/lora_rx.py

# 4. Decoded packets output via ZMQ for further processing
```

#### Wireshark with Meshtastic Dissector

**Plugin:** https://github.com/exploiteers/Exploiteers-Wireshark-LoRa/

**Installation:**
1. Copy `meshtastic/` directory to Wireshark plugins folder:
   - Linux: `~/.config/wireshark/plugins/meshtastic/`
   - Mac: `/Users/USERNAME/.config/wireshark/plugins/meshtastic/`
   - Windows: `C:\Users\USERNAME\AppData\Roaming\Wireshark\plugins\meshtastic\`
2. In Wireshark: Edit > Preferences > Protocols > ProtoBuf
3. Add `plugins/meshtastic/protobufs/` directory, check "Load all files"
4. Edit > Preferences > Protocols > Meshtastic -- enter channel key (base64)

**Default keys:**
- LongFast: `AQ==`
- DEFCONnect: `OEu8wB3AItGBvza4YSHh+5a3LlW/dCJ+nWr7SNZMsaE=`

#### Scapy Meshtastic Decoder (Philly Mesh Project)

**Repository:** https://github.com/calefrey/scapy-meshtastic

This 2026 project provides:
- Custom Scapy dissector layers for all Meshtastic packet layers
- Real-time Wireshark streaming via pcap stdin
- SQLite storage for network analytics
- Integration with Malla for MQTT collection

Uses a CatWAN USB Stick (RP2040 + RFM95W) for hardware capture, but the software layers can work with any packet source.

#### Universal Radio Hacker (URH)

**Repository:** https://github.com/jbruns/urh

URH covers the complete wireless protocol investigation workflow:
- Signal capture from HackRF
- Demodulation of raw signals
- Bitstream decoding
- Differential analysis
- Protocol fuzzing and simulation

**Note:** URH does not have native CSS/LoRa demodulation, but it can visualize captured IQ data and is useful for analyzing non-LoRa signals in the ISM band (like OOK garage remotes, weather sensors, etc.).

#### Inspectrum

**Repository:** https://github.com/miek/inspectrum

Signal visualization tool for analyzing captured IQ files. Useful for:
- Examining modulation characteristics
- Measuring symbol rates
- Identifying signal types
- Post-capture analysis of recorded signals

#### SigDigger

**Repository:** https://github.com/BatchDrake/SigDigger

Qt-based digital signal analyzer using its own DSP library (sigutils) rather than GNU Radio. Supports SoapySDR devices including HackRF. Good for:
- Real-time FSK, PSK, ASK demodulation
- Analog video decoding
- Bursty signal analysis
- Plugin extensibility

**References:**
- [PentHertz: Testing LoRa with SDR](https://penthertz.com/blog/testing-LoRa-with-SDR-and-handy-tools.html)
- [Exploiteers Wireshark Plugin](https://hackerpager.net/wireshark-plugin/)
- [SigDigger Homepage](https://batchdrake.github.io/SigDigger/)
- [Philly Mesh: Real-Time Meshtastic Decoding](https://phillymesh.net/post/2026-01-10-scapy-meshtastic-decoder/)

### 5.4 Identifying Interference, Collisions, and Retransmissions

**Interference Detection:**
- Use hackrf_sweep to survey the 902-928 MHz band for non-LoRa signals
- Look for persistent signals that overlap with LoRa channels
- Common interferers: WiFi (if misconfigured), industrial sensors, baby monitors, weather stations

**Collision Identification:**
- Overlapping chirps on waterfall display (two diagonal lines at same time)
- CRC failures in decoded packets
- jkadbear/gr-lora provides collision decoding capabilities

**Retransmission Analysis:**
- Duplicate Packet IDs with incremented hop counts
- Meshtastic uses flood routing -- expect to see same packet from multiple nodes
- High retransmission rates indicate poor link quality or congestion

---

## 6. Curriculum Design

### 6.1 Recommended Course Structure: RF/LoRa Engineering with HackRF

**Duration:** 10-12 weeks
**Prerequisites:** Basic physics (waves), basic programming (Python), comfortable with Linux command line
**Hardware per student/pair:** HackRF One + H4M PortaPack, Meshtastic node (T-Beam or RAK), laptop with Linux

#### Week 1-2: Foundations of RF and SDR

**Lecture Topics:**
- Electromagnetic spectrum, wavelength, frequency
- What is Software Defined Radio?
- HackRF One hardware overview
- PortaPack H4M firmware (Mayhem) basics

**Lab 1: First Contact**
- Flash latest Mayhem firmware
- Explore PortaPack apps (Scanner, Looking Glass, Detector)
- Receive FM radio
- Perform wideband spectrum sweep with hackrf_sweep

**Lab 2: The Decibel**
- dB, dBm, dBi definitions and conversions
- Power ratios: +3 dB = 2x power, +10 dB = 10x power
- Measure signal levels with PortaPack Level app
- Practice calculations

**Reference Course:** [Great Scott Gadgets: SDR with HackRF](https://greatscottgadgets.com/sdr/) (Lessons 1-3)

#### Week 3-4: Digital Signal Processing Basics

**Lecture Topics:**
- Sampling theorem and Nyquist frequency
- Complex numbers and IQ data
- FFT and waterfall displays
- Filters (low-pass, band-pass, high-pass)

**Lab 3: GNU Radio Introduction**
- Install GNU Radio Companion
- Build simple FM receiver flowgraph
- Understand sample rates, decimation, data types

**Lab 4: Signal Analysis**
- Capture IQ data with HackRF
- Analyze in GNU Radio (FFT, waterfall, time domain)
- Identify modulation types visually (AM, FM, OOK, FSK)

**Reference Course:** [Great Scott Gadgets: SDR with HackRF](https://greatscottgadgets.com/sdr/) (Lessons 4-7)

#### Week 5-6: LoRa Physical Layer

**Lecture Topics:**
- Chirp Spread Spectrum (CSS) modulation
- Spreading factors, bandwidth, coding rate
- LoRa sensitivity vs data rate tradeoffs
- LoRa packet structure (PHY layer)

**Lab 5: Visualizing LoRa**
- Set up GNU Radio to receive 906.875 MHz
- Observe LoRa chirps on waterfall display
- Identify preamble, sync word, data portion
- Compare SF7 vs SF12 visually (chirp duration)

**Lab 6: LoRa Decode**
- Install gr-lora_sdr
- Decode LoRa packets from a test transmitter
- Examine raw decoded bytes
- Vary SF and observe effect on decode success/range

#### Week 7-8: Link Budget and RF Engineering

**Lecture Topics:**
- Friis transmission equation
- Free space path loss
- Antenna gain and radiation patterns
- Link margin and fade margin
- Real-world propagation (urban, suburban, rural)

**Lab 7: Link Budget Calculations**
- Calculate theoretical range for LA-Mesh nodes
- Use LoRa calculators to verify
- Design link budget for campus-to-downtown path

**Lab 8: Field Measurements**
- Place Meshtastic nodes at increasing distances
- Record RSSI and SNR at each point
- Plot measured vs theoretical path loss
- Identify obstructions and multipath effects
- Compare antenna types

#### Week 9-10: Mesh Networking and Protocol Analysis

**Lecture Topics:**
- Meshtastic protocol deep dive (4-layer structure)
- MeshCore protocol comparison
- Encryption: AES-256-CTR, key management
- Routing: flood routing vs directed routing
- Duty cycle and channel access

**Lab 9: Packet Capture and Analysis**
- Set up Wireshark with Meshtastic dissector
- Capture and decode Meshtastic packets
- Identify different message types (text, position, telemetry)
- Analyze routing behavior (hop counts, retransmissions)

**Lab 10: Mesh Network Debugging**
- Deploy 5+ node mesh on campus
- Use HackRF to monitor all channels simultaneously
- Identify collision events
- Measure network throughput and latency
- Optimize node placement based on RF analysis

#### Week 11-12: RF Security and Capstone

**Lecture Topics:**
- TEMPEST and electromagnetic emanations
- RF security vulnerabilities in IoT
- LoRaWAN vs Meshtastic security models
- Defensive RF engineering
- FCC regulations and responsible research

**Lab 11: TEMPEST Demonstration**
- Set up TempestSDR with HackRF
- Demonstrate screen capture from HDMI emanations
- Discuss shielding and countermeasures
- Explore LoRa protocol security weaknesses

**Lab 12: Capstone Project**
- Students design, analyze, and deploy a mesh network segment
- Full link budget documentation
- RF coverage mapping
- Protocol analysis report
- Presentation of findings

### 6.2 Safety Considerations and FCC Compliance

**FCC Part 15 Rules (47 CFR 15):**

- HackRF One is sold as **test equipment** and is exempt from equipment authorization
- However, **transmissions must comply with Part 15** power limits unless under amateur radio license
- 915 MHz ISM band (902-928 MHz): Part 15.247 allows up to 1 watt (30 dBm) with antenna gain restrictions
- **Educational institution provision** (15.221): AM transmissions originating on campus have slightly relaxed field strength limits at the campus perimeter
- **General rules** (15.5): Devices may not cause harmful interference and must accept any interference received

**Practical Guidelines for Lab TX:**
1. Use minimum necessary power for the exercise
2. Keep transmissions short (duty cycle awareness)
3. Use dummy loads for high-power testing when possible
4. Document all intentional transmissions
5. Amateur radio license holders in class can operate under Part 97 with more flexibility
6. Consider obtaining a club amateur radio callsign for the project

**References:**
- [ARRL: FCC Part 15](https://www.arrl.org/part-15-radio-frequency-devices)
- [eCFR: 47 CFR Part 15](https://www.ecfr.gov/current/title-47/chapter-I/subchapter-A/part-15)
- [Great Scott Gadgets: SDR Lesson 8 (FCC/Regulatory)](https://greatscottgadgets.com/sdr/8/)

### 6.3 Reference Courses and Materials

| Resource | URL | Notes |
|----------|-----|-------|
| Great Scott Gadgets SDR Course | https://greatscottgadgets.com/sdr/ | Free, CC-BY, 11 lessons |
| Tonex SDR Training with HackRF | https://www.tonex.com/training-courses/sdr-training-with-hackrf-advanced-software-defined-radio-training/ | 3-day commercial course |
| HackRF One PortaPack Course (Udemy) | https://www.udemy.com/course/hackrf-one-portapack/ | Paid, PortaPack-specific |
| SDR for Ethical Hackers (Udemy) | https://www.udemy.com/course/software-defined-radio-3/ | Security-focused |
| PentHertz SDR Hacking Academy | https://hackademy.penthertz.com/course/introduction-to-rf-hacking-with-sdr | Offensive security focused |
| HackRF + GNU Radio for Comm Theory (Paper) | https://www.researchgate.net/publication/335179428 | Academic implementation |
| EPFL LoRa PHY Resource Page | https://www.epfl.ch/labs/tcl/resources-and-sw/lora-phy/ | Academic LoRa reference |

---

## 7. Firmware Management

### 7.1 Building PortaPack Mayhem from Source

#### Docker Method (Recommended)

```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/portapack-mayhem/mayhem-firmware.git
cd mayhem-firmware

# Build Docker image
docker build -t portapack-dev -f dockerfile-nogit .

# For ARM systems (Apple Silicon Macs):
docker build --platform linux/amd64 -t portapack-dev -f dockerfile-nogit .

# Compile firmware
docker run -it --rm -v ${PWD}:/havoc portapack-dev

# With parallel compilation:
docker run -it --rm -v ${PWD}:/havoc portapack-dev make -j$(nproc)

# Output: build/firmware/
#   - *.bin (firmware only)
#   - *.ppfw.tar (firmware + external apps)
```

#### Native Linux Build

```bash
# Install dependencies (Debian/Ubuntu)
sudo apt-get update
sudo apt-get install -y git tar wget cmake python3 bzip2 lz4 curl \
    hackrf python3-distutils python3-setuptools
pip install pyyaml

# Install ARM toolchain (version 9.2.1 REQUIRED)
# CRITICAL: Newer toolchain versions produce oversized firmware
sudo mkdir -p /opt/build && cd /opt/build
sudo wget -O gcc-arm-none-eabi.tar.bz2 \
    "https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2019q4/gcc-arm-none-eabi-9-2019-q4-major-x86_64-linux.tar.bz2"
sudo mkdir armbin
sudo tar --strip=1 -xjvf gcc-arm-none-eabi.tar.bz2 -C armbin
export PATH=/opt/build/armbin/bin:$PATH

# Build
cd /path/to/mayhem-firmware
mkdir build && cd build
cmake ..
make -j$(nproc)

# Flash
hackrf_spiflash -w build/firmware/portapack-h1_h2-mayhem.bin
```

**Critical notes:**
- ARM toolchain version 9.2.1 is required -- newer versions produce firmware that exceeds flash memory
- On Windows, configure `git config --global core.autocrlf false` before cloning
- Always initialize submodules with `--recurse-submodules`

### 7.2 External Apps (.ppma)

External apps are stored on the SD card in the `APPS/` folder. They must version-match the running firmware.

Some apps are moving from internal (compiled into firmware) to external to save flash ROM space. Check the [Mayhem Wiki Applications page](https://github.com/portapack-mayhem/mayhem-firmware/wiki/Applications) for current status.

### 7.3 Custom App Development

The Mayhem firmware is C++ based, targeting the LPC43xx ARM Cortex-M4 processor. Custom apps can:
- Access the full HackRF radio frontend
- Use the PortaPack display, buttons, and encoder
- Process signals in real-time on the embedded processor

**Development resources:**
- [Mayhem GitHub Wiki](https://github.com/portapack-mayhem/mayhem-firmware/wiki)
- Study existing apps in `firmware/application/apps/` directory
- External app examples in `firmware/application/external/` directory
- Pull requests welcome -- the project actively accepts contributions

**Potential LA-Mesh contribution:** A LoRa spectrum monitor app for PortaPack would be a significant contribution. Even without full CSS demodulation, a 915 MHz band monitor with chirp detection would be valuable. See [Issue #400](https://github.com/portapack-mayhem/mayhem-firmware/issues/400) for community discussion.

### 7.4 Integration with Computer-Based SDR Tools

The HackRF can operate in two modes:

**Standalone mode** (with PortaPack):
- Mayhem firmware provides all UI and processing
- No computer needed
- Limited by embedded processor capabilities

**Tethered mode** (with computer):
- HackRF acts as USB SDR peripheral
- Full power of GNU Radio, SDR++, GQRX, etc.
- Required for LoRa decoding (CSS demodulation too complex for PortaPack)
- Can capture IQ data on PortaPack SD card, then process on computer later

**SDR++ Setup:**
```bash
# Install SDR++ (supports HackRF natively)
# Available as AppImage on Linux, or build from source
# https://github.com/AlexandreRouma/SDRPlusPlus

# Launch and select HackRF as source
# Tune to 906.875 MHz for Meshtastic LongFast
# Set bandwidth to 250-500 kHz
# Enable waterfall display
```

**GQRX Setup:**
```bash
# Install
sudo apt install gqrx-sdr

# Launch
gqrx

# Select "HackRF One" as device
# Set frequency, gain, and FFT parameters
```

---

## Sprint Integration Points

### Phase 1: Hardware Setup and Firmware (Week 1-2)

**Deliverables:**
- [ ] All H4M PortaPacks flashed with latest stable Mayhem firmware
- [ ] SD cards prepared with matching content (16GB+ each)
- [ ] Firmware update procedure documented and tested
- [ ] PortaPack basic operation verified (Scanner, Looking Glass, Detector apps)
- [ ] hackrf_sweep verified working in tethered mode on lab computers

**Go/No-Go Criteria:**
- All devices boot and display Mayhem UI
- FM radio reception confirmed on each unit
- hackrf_sweep produces valid spectrum data
- SD card apps load correctly

**Procedure:**
1. Download latest stable release from https://github.com/portapack-mayhem/mayhem-firmware/releases
2. Flash each unit using Flash Utility (SD card method)
3. Extract SD card content package to each card
4. Verify operation with FM radio test
5. Test tethered mode with `hackrf_info` command on computer

### Phase 2: Software Environment Setup (Week 2-3)

**Deliverables:**
- [ ] Lab computers configured with GNU Radio 3.10+
- [ ] gr-lora_sdr installed and tested (Conda method recommended)
- [ ] Meshtastic_SDR project cloned and operational
- [ ] SDR++ or GQRX installed for waterfall visualization
- [ ] QSpectrumAnalyzer installed for spectrum analysis
- [ ] Wireshark + Meshtastic dissector installed
- [ ] Python environment: meshtastic, scapy, numpy, matplotlib

**Go/No-Go Criteria:**
- gr-lora_sdr example scripts run without errors
- GNU Radio flowgraph displays waterfall at 906.875 MHz
- Wireshark loads Meshtastic dissector plugin
- At least one LoRa packet successfully decoded from a test transmission

**Known Issues to Prepare For:**
- NumPy version conflicts (may need 1.26.4)
- CMAKE_INSTALL_PREFIX path issues with gr-lora_sdr
- HackRF USB permission issues on Linux (udev rules needed)
- GNU Radio Python binding issues on some distributions

### Phase 3: LoRa Analysis Capability (Week 3-5)

**Deliverables:**
- [ ] Students can visualize LoRa chirps on waterfall display
- [ ] Packet decode pipeline working (HackRF -> GNU Radio -> decoded bytes)
- [ ] Meshtastic packet structure understood and documented
- [ ] Link budget calculations validated against field measurements
- [ ] hackrf_sweep band survey of local 902-928 MHz environment completed

**Go/No-Go Criteria:**
- Waterfall shows clear chirp patterns from Meshtastic transmissions
- At least unencrypted packet headers decodable
- RSSI measurements within 10 dB of theoretical predictions
- Band survey identifies all active signals in ISM band

### Phase 4: Protocol Deep Dive and Security (Week 6-8)

**Deliverables:**
- [ ] Full Meshtastic packet decode (including encrypted payload with known key)
- [ ] MeshCore packet analysis capability
- [ ] TEMPEST demonstration operational
- [ ] Interference and collision detection demonstrated
- [ ] RF security lab exercises completed

**Go/No-Go Criteria:**
- Can decode Meshtastic text messages from RF capture
- TempestSDR displays readable text from test monitor
- Students can identify collision events on waterfall

### Phase 5: Field Deployment and Capstone (Week 9-12)

**Deliverables:**
- [ ] Multi-node mesh deployed across campus/Lewiston
- [ ] RF coverage map generated from HackRF measurements
- [ ] Complete link budget documentation for each link
- [ ] Network performance analysis (throughput, latency, reliability)
- [ ] Student capstone presentations

**Go/No-Go Criteria:**
- Mesh network provides coverage to target areas
- HackRF analysis identifies and helps resolve at least one real network issue
- Students can independently perform RF analysis with HackRF

### Gap Analysis

| Gap | Severity | Mitigation |
|-----|----------|------------|
| **No native LoRa app in Mayhem firmware** | Medium | Use tethered mode with GNU Radio for LoRa decode; PortaPack useful for spectrum analysis and other RF exercises |
| **Meshtastic_SDR decode script unreliable** | Medium | Use Wireshark + dissector plugin as alternative decode path; Philly Mesh Scapy decoder as backup |
| **HackRF not calibrated for absolute dBm** | Low | Use for relative measurements; compare against Meshtastic node RSSI readings for calibration reference |
| **CSS demodulation complexity** | Medium | gr-lora_sdr handles this; ensure correct installation is a priority |
| **MeshCore SDR decode not yet available** | Medium | Use MeshCore Packet Knife for analysis of captured packets; focus curriculum on Meshtastic SDR decode |
| **Student Linux proficiency varies** | Medium | Provide pre-configured VMs or Docker containers; allocate extra time for setup |
| **FCC compliance for TX exercises** | Low | Stay within Part 15 limits; use Meshtastic nodes (already FCC-compliant devices) for TX; HackRF TX only with dummy load or minimal power |
| **TempestSDR Java dependency issues** | Low | Test full setup before class; have backup pre-recorded demo |
| **ARM toolchain version sensitivity for firmware builds** | Low | Use Docker build method to avoid toolchain issues |

### Equipment Checklist Per Student Station

| Item | Quantity | Purpose |
|------|----------|---------|
| HackRF One + H4M PortaPack | 1 | SDR analysis platform |
| Meshtastic node (T-Beam/RAK) | 1 | LoRa mesh network node |
| 915 MHz antenna (SMA) | 2 | For HackRF and Meshtastic |
| USB-C cable | 1 | HackRF to computer |
| MicroSD card (16GB+) | 1 | PortaPack storage |
| Laptop (Linux) | 1 | GNU Radio, analysis tools |
| SMA adapter/pigtail | 1 | Antenna flexibility |
| Optional: directional antenna | 1 per 2-3 students | For TEMPEST demo and field work |

### Recommended Software Stack

```
# Core tools (install order)
1. GNU Radio 3.10+
2. gr-lora_sdr (via Conda or source)
3. Meshtastic_SDR (from GitLab)
4. SDR++ or GQRX
5. QSpectrumAnalyzer
6. Wireshark + Meshtastic dissector
7. Universal Radio Hacker (URH)
8. SigDigger
9. Inspectrum
10. TempestSDR
11. Python: meshtastic, scapy, numpy, matplotlib, protobuf

# PortaPack firmware
- Mayhem (latest stable from GitHub releases)
- SD card content package (matching version)
```

---

## Appendix A: Key URLs and Repositories

### Firmware and Hardware
- Mayhem Firmware: https://github.com/portapack-mayhem/mayhem-firmware
- Mayhem Releases: https://github.com/portapack-mayhem/mayhem-firmware/releases
- Mayhem Wiki: https://github.com/portapack-mayhem/mayhem-firmware/wiki
- Mayhem Hub (Web Flash): https://hackrf.app/
- HackRF Official: https://github.com/greatscottgadgets/hackrf
- HackRF Docs: https://hackrf.readthedocs.io/

### LoRa SDR Tools
- gr-lora_sdr (EPFL): https://github.com/tapparelj/gr-lora_sdr
- gr-lora (rpp0): https://github.com/rpp0/gr-lora
- gr-lora (jkadbear, collision): https://github.com/jkadbear/gr-lora
- gr-lorawan (EPFL MAC layer): https://github.com/tapparelj/gr-lorawan
- Meshtastic_SDR: https://gitlab.com/crankylinuxuser/meshtastic_sdr
- EPFL LoRa PHY Page: https://www.epfl.ch/labs/tcl/resources-and-sw/lora-phy/

### Packet Analysis
- Exploiteers Wireshark LoRa Plugin: https://github.com/exploiteers/Exploiteers-Wireshark-LoRa/
- HackerPager Wireshark Plugin: https://hackerpager.net/wireshark-plugin/
- Scapy Meshtastic Decoder: https://github.com/calefrey/scapy-meshtastic
- MeshCore Packet Knife: https://jkingsman.github.io/meshcore-packet-knife/
- MeshCore Decoder (Python): https://pypi.org/project/meshcoredecoder/
- MeshCore Decoder (TypeScript): https://github.com/michaelhart/meshcore-decoder
- MeshExplorer: https://github.com/ajvpot/meshexplorer
- Meshtastic Protobufs: https://github.com/meshtastic/protobufs

### Signal Analysis Tools
- Universal Radio Hacker: https://github.com/jbruns/urh
- Inspectrum: https://github.com/miek/inspectrum
- SigDigger: https://github.com/BatchDrake/SigDigger
- QSpectrumAnalyzer: https://github.com/xmikos/qspectrumanalyzer
- hackrf-spectrum-analyzer: https://github.com/pavsa/hackrf-spectrum-analyzer
- SDR++: https://github.com/AlexandreRouma/SDRPlusPlus
- PentHertz LoRa Craft: https://github.com/PentHertz/LoRa_Craft

### RF Security / TEMPEST
- TempestSDR: https://github.com/martinmarinov/TempestSDR
- TempestSDR HackRF Demo: https://github.com/aalex954/tempest-sdr-demo
- RFSec-ToolKit: https://github.com/cn0xroot/RFSec-ToolKit

### Education and Courses
- Great Scott Gadgets SDR Course: https://greatscottgadgets.com/sdr/
- PentHertz LoRa Testing Guide: https://penthertz.com/blog/testing-LoRa-with-SDR-and-handy-tools.html
- Jeff Geerling Meshtastic Decode: https://www.jeffgeerling.com/blog/2025/decoding-meshtastic-gnuradio-on-raspberry-pi/
- LoRa Docs: https://lora.readthedocs.io/en/latest/
- Semtech SX1276 Datasheet: https://cdn-shop.adafruit.com/product-files/3179/sx1276_77_78_79.pdf
- RevSpace LoRa Decoding Wiki: https://revspace.nl/DecodingLora

### Protocol References
- Meshtastic Protocol Docs: https://meshtastic.org/docs/overview/mesh-algo/
- MeshCore Protocol: https://github.com/meshcore-dev/MeshCore
- MeshCore Protocol Explained: https://www.localmesh.nl/en/meshcore-protocol-explained/
- Critical Meshtastic Analysis: https://www.disk91.com/2024/technology/lora/critical-analysis-of-the-meshtastic-protocol/
- Philly Mesh Decoder Blog: https://phillymesh.net/post/2026-01-10-scapy-meshtastic-decoder/

### Academic Papers
- Decoding LoRa: Realizing a Modern LPWAN with SDR: https://pubs.gnuradio.org/index.php/grcon/article/download/8/7/
- Multi-Channel LoRa Decoder: https://www.robyns.me/docs/robyns2018lora.pdf
- Open-Source LoRa PHY on GNU Radio: https://arxiv.org/pdf/2002.08208
- LoRa Frame Analysis with GNU Radio and SDR: https://www.researchgate.net/publication/349662163
- GNU Radio Conference 2024 LoRa Implementation: https://events.gnuradio.org/event/24/contributions/641/

---

## Appendix B: Quick Reference Card

### HackRF CLI Commands

```bash
# Device info
hackrf_info

# Wideband spectrum sweep (902-928 MHz LoRa band)
hackrf_sweep -f 902:928 -w 50000 -l 32 -g 32

# Capture IQ data at Meshtastic LongFast frequency
hackrf_transfer -r capture.raw -f 906875000 -s 2000000 -l 32 -g 32

# Flash firmware
hackrf_spiflash -w firmware.bin

# Transmit IQ data (CAUTION: verify FCC compliance)
hackrf_transfer -t signal.raw -f 906875000 -s 2000000
```

### Meshtastic US Channel Frequencies (LongFast)

| Channel | Frequency (MHz) | Notes |
|---------|-----------------|-------|
| 0 | 903.08 | |
| 1 | 905.24 | |
| 2 | 906.875 | **Default LongFast** |
| 3 | 907.50 | |
| ... | ... | 902-928 MHz range |

### Key dBm Reference Points

| Power Level | dBm | Watts |
|------------|-----|-------|
| Max Meshtastic US TX | +30 | 1 W |
| Default Meshtastic TX | +20 | 100 mW |
| Typical WiFi router | +20 | 100 mW |
| Bluetooth Class 1 | +4 | 2.5 mW |
| LoRa SF12 sensitivity | -137 | 0.02 fW |
| Thermal noise floor | -174 | per Hz |
