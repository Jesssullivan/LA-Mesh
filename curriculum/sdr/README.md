# Level 4: Software-Defined Radio and LoRa Analysis

**Audience**: Technically curious participants, students, amateur radio operators
**Time**: 3 hours (lab format)
**Prerequisites**: Mesh Basics (Level 1-2), Security (Level 3)

---

## Learning Objectives

By the end of this module, participants will be able to:

1. Explain what software-defined radio (SDR) is and how it differs from traditional radio
2. Use an SDR to observe the 915 MHz ISM band
3. Identify LoRa transmissions visually on a waterfall display
4. Understand FCC Part 15 rules for 915 MHz ISM
5. Set up GNU Radio with gr-lora_sdr for LoRa signal analysis (advanced)

---

## Required Equipment

| Item | Purpose | Approx. Cost |
|------|---------|-------------|
| HackRF H4M + PortaPack | Transmit/receive SDR with portable display | $200 |
| RTL-SDR Blog V4 | Receive-only SDR (lower cost option) | $35 |
| 915 MHz antenna | Matched antenna for ISM band | $15-25 |
| Laptop with GNU Radio | Signal processing software | -- |
| Meshtastic device | Generate known LoRa signals | Already have |

---

## Module Structure

### Part 1: What Is Software-Defined Radio? (30 min)

**Traditional radio**: Hardware determines what you can receive. An FM radio can only do FM. A walkie-talkie can only do its protocol.

**Software-defined radio**: Hardware captures raw radio waves. Software decides what to do with them. One device can "be" an FM radio, a weather satellite receiver, an aircraft tracker, or a LoRa analyzer.

**SDR components**:
```
Antenna → SDR Hardware → Computer → Software → You
          (digitizer)    (processing)
```

**Our SDR options**:

| Device | TX | RX | Bandwidth | Frequency | Use |
|--------|----|----|-----------|-----------|-----|
| HackRF H4M | Yes | Yes | 20 MHz | 1 MHz - 6 GHz | Full analysis |
| RTL-SDR V4 | No | Yes | 2.4 MHz | 24 MHz - 1.7 GHz | Receive only |
| PortaPack | -- | -- | -- | -- | Standalone UI for HackRF |

**Important**: The HackRF can transmit. Transmitting on frequencies you're not authorized to use is illegal. At 915 MHz ISM, transmission is allowed under FCC Part 15 rules.

### Part 2: FCC Part 15 -- Know the Rules (15 min)

**915 MHz ISM Band Rules (US)**:
- **Frequency**: 902-928 MHz (ISM band)
- **Max conducted power**: 30 dBm (1 Watt)
- **Max EIRP**: 36 dBm (4 Watts) with directional antenna
- **Modulation**: Frequency hopping or digital (LoRa qualifies)
- **License**: None required (Part 15 unlicensed)
- **Interference**: Must accept interference, must not cause harmful interference

**What you CAN do**:
- Operate Meshtastic devices at legal power levels
- Receive and analyze any signal (receive-only is always legal)
- Transmit on 915 MHz ISM within power limits

**What you CANNOT do**:
- Exceed power limits
- Jam or intentionally interfere with other signals
- Transmit on frequencies outside your authorization
- Decrypt/intercept communications you're not authorized to receive (ECPA applies)

### Part 3: Hands-On -- Observing the 915 MHz Band (45 min)

**Setup with RTL-SDR (receive-only)**:

```bash
# Enter Nix devshell (provides rtl-sdr tools)
nix develop

# Verify RTL-SDR is connected
rtl_test -t

# Launch GQRX or SDR++ for visual spectrum
# Center frequency: 915 MHz
# Sample rate: 2.4 MHz
# Gain: Auto or 40 dB
```

**Setup with HackRF + PortaPack**:

1. Power on PortaPack with Mayhem firmware
2. Navigate to: Receive → Spectrum
3. Set center frequency: 915 MHz
4. Set bandwidth: 5 MHz
5. Observe the waterfall display

**What to look for**:

```
Frequency (MHz) →
912   913   914   915   916   917   918
 |     |     |     |     |     |     |
 .     .     .     .     .     .     .    ← noise floor
 .     .     .  ▓▓▓▓▓▓▓  .     .     .    ← LoRa chirp!
 .     .     .     .     .     .     .
 .     .  ▓▓▓▓▓▓▓  .     .     .     .    ← another transmission
```

**LoRa chirp characteristics**:
- Wide bandwidth (125 kHz or 250 kHz)
- Distinctive upward "chirp" sweep visible on waterfall
- Duration depends on spreading factor (SF7 = short, SF12 = long)
- Our LONG_FAST preset: 250 kHz bandwidth, SF11

**Exercise**:
1. Have one person send a Meshtastic message
2. Observe the transmission on the SDR waterfall
3. Note: start time, duration, bandwidth, frequency
4. Correlate with the Meshtastic node list (which node transmitted?)

### Part 4: LoRa Signal Anatomy (30 min)

**LoRa modulation explained**:

LoRa uses Chirp Spread Spectrum (CSS):
- A "chirp" is a signal that sweeps from low to high frequency
- Data is encoded in the timing of chirp start positions
- Spreading Factor (SF) controls chirp length and range:

| SF | Chirps/symbol | Sensitivity | Airtime | Range |
|----|---------------|-------------|---------|-------|
| 7 | 128 | -124 dBm | Shortest | ~3 km |
| 8 | 256 | -127 dBm | | ~5 km |
| 9 | 512 | -130 dBm | | ~8 km |
| 10 | 1024 | -133 dBm | | ~12 km |
| **11** | **2048** | **-137 dBm** | | **~20 km** |
| 12 | 4096 | -140 dBm | Longest | ~40 km |

**Packet structure** (simplified):
```
[Preamble] [Sync Word] [Header] [Payload (encrypted)] [CRC]
   8+       2 symbols    varies    your message          2 bytes
```

**Demo**: If using GNU Radio, show the raw IQ capture of a LoRa packet and identify the preamble chirps.

### Part 5: GNU Radio + gr-lora_sdr (Advanced, 45 min)

**Important**: The HackRF PortaPack does NOT natively decode LoRa. For actual LoRa demodulation, you need a computer running GNU Radio with the gr-lora_sdr module.

**Setup** (on laptop with GNU Radio):

```bash
# gr-lora_sdr installation (from source)
git clone https://github.com/tapparelj/gr-lora_sdr
cd gr-lora_sdr
mkdir build && cd build
cmake ..
make -j$(nproc)
sudo make install
```

**Basic receive flowgraph**:
```
RTL-SDR Source → Low Pass Filter → gr-lora Demodulator → File Sink
(915 MHz)        (250 kHz)         (SF11, BW250k)        (raw bytes)
```

**What you can observe**:
- Packet timing and structure
- Preamble detection
- Header decoding (if not encrypted)
- Encrypted payload (appears as random bytes)
- CRC validation

**What you CANNOT do**:
- Decrypt messages without the PSK (AES-256)
- This is by design -- encryption works

**Exercise** (if GNU Radio available):
1. Capture a known LoRa transmission to file
2. Open in GNU Radio with gr-lora_sdr
3. Identify the packet structure
4. Observe that the payload is encrypted (random-looking bytes)

### Part 6: Practical RF Troubleshooting (15 min)

**Using SDR to debug mesh network issues**:

| Problem | SDR Can Help? | How |
|---------|--------------|-----|
| Weak signal between nodes | Yes | Measure actual signal strength at receiver |
| Interference on 915 MHz | Yes | Identify other transmitters on the band |
| Antenna problems | Yes | Compare signal with known-good antenna |
| Node not transmitting | Yes | Verify RF output exists |
| Encryption issues | No | Encrypted payload looks the same whether working or broken |

**Quick spectrum scan for interference**:
```bash
# Record 10 seconds of spectrum at 915 MHz
rtl_power -f 900M:930M:100k -g 40 -i 10 -e 10s scan.csv

# Visualize with heatmap.py (rtl-sdr tools)
python3 heatmap.py scan.csv scan.png
```

---

## Instructor Notes

### Safety Reminders
- HackRF can transmit -- ensure students understand FCC rules before handling
- Keep TX power at minimum for demos
- Only transmit on 915 MHz ISM band
- Receive-only SDRs (RTL-SDR) are always safe

### Equipment Handling
- HackRF is static-sensitive -- use anti-static precautions
- Always connect antenna before powering on (transmitting without antenna can damage HackRF)
- PortaPack battery should be charged before session

### Alternative if No SDR Available
- Use WebSDR (websdr.org) to demonstrate SDR concepts remotely
- Show pre-recorded waterfall captures of LoRa signals
- Focus on theory and Meshtastic CLI tools for RF diagnostics
