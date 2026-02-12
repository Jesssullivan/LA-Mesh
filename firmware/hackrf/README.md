# HackRF H4M / PortaPack Firmware

The HackRF H4M with PortaPack uses **Mayhem firmware** for RF analysis and
spectrum monitoring. It does **not** participate in the mesh network -- it is a
receive-only education tool.

---

## Firmware: PortaPack Mayhem

Mayhem is the community firmware for PortaPack devices. It provides:

- Spectrum analyzer (view LoRa 915 MHz band activity)
- Signal recording and playback
- Protocol decoders
- Frequency scanner

### Download

1. Go to https://github.com/portapack-mayhem/mayhem-firmware/releases
2. Download the latest `.tar` or `.ppfw.tar` release
3. Extract to get the firmware files

### SD Card Preparation

The HackRF H4M loads firmware from a micro SD card.

```bash
# Format SD card as FAT32
# WARNING: This erases the SD card!
sudo mkfs.vfat -F 32 /dev/sdX1

# Mount
sudo mount /dev/sdX1 /mnt/sdcard

# Copy firmware files
cp -r mayhem-firmware/* /mnt/sdcard/

# Unmount
sudo umount /mnt/sdcard
```

Or use the preparation script:

```bash
just hackrf-prepare-sd /dev/sdX1 mayhem-firmware.tar
```

### Update Procedure

1. Download latest Mayhem release
2. Extract firmware files
3. Copy to SD card (replace existing files)
4. Insert SD card into HackRF H4M
5. Power on -- new firmware loads automatically

### Custom Apps and Presets

You can add custom frequency presets for LA-Mesh monitoring:

```
FREQMAN/
  la-mesh-915.txt    # LoRa ISM band frequencies
  ism-band.txt       # Full ISM 902-928 MHz band
```

Frequency preset file format:
```
f=915000000,d=LoRa Ch1 915.0MHz
f=906250000,d=LoRa Ch2 906.25MHz
```

---

## Usage in LA-Mesh

### Spectrum Analysis

Use the spectrum analyzer to observe LoRa activity:

1. Open `Spectrum` app on PortaPack
2. Set center frequency: 915 MHz
3. Set bandwidth: 26 MHz (covers 902-928 MHz ISM band)
4. Observe transmissions from mesh devices

### RF Education (Curriculum Level 4)

The HackRF is used in the curriculum for:

- Understanding RF propagation
- Visualizing LoRa modulation (chirp spread spectrum)
- Measuring signal strength and link quality
- Antenna comparison testing

### Important Restrictions

- **Never transmit** on mesh frequencies with the HackRF
- The HackRF is for **receive-only observation** in LA-Mesh context
- ISM band regulations still apply to any transmissions
- The HackRF does not have mesh encryption keys and cannot decrypt traffic
