# Troubleshooting Guide

Common issues and solutions for LA-Mesh devices and network.

---

## Device Issues

### Device won't power on

| Check | Action |
|-------|--------|
| Battery dead | Charge for at least 30 minutes via USB-C |
| Stuck state | Hold power button for 10+ seconds to force restart |
| Hardware failure | Try a different USB cable, check for physical damage |

### Device not detected on USB

| Check | Action |
|-------|--------|
| Cable is charge-only | Use a data-capable USB-C cable |
| Wrong driver | ESP32-S3 uses built-in USB, CP2102/CH340 for older chips |
| Port in use | Close other serial monitors, check `ls /dev/ttyUSB* /dev/ttyACM*` |
| Bootloader mode needed | Hold BOOT, press RESET, release BOOT |

### Screen frozen or unresponsive

1. Press RESET button (if available)
2. Hold power button 10+ seconds
3. If persistent: reflash firmware

---

## Network Issues

### Can't see other nodes

| Check | Action |
|-------|--------|
| Wrong channel PSK | Verify PSK matches: `meshtastic --info` |
| Wrong region | Must be set to `US`: `meshtastic --set lora.region US` |
| Wrong modem preset | Must match network: `meshtastic --set lora.modem_preset LONG_FAST` |
| Out of range | Move closer to a known node, check antenna |
| Antenna disconnected | Verify antenna is firmly connected to SMA port |

### Messages not delivering

| Check | Action |
|-------|--------|
| Hop limit too low | Check: `meshtastic --info` -- should be 5 for LA-Mesh |
| Airtime exhausted | Wait a few minutes (device enforces duty cycle limits) |
| Channel congestion | Too many nodes transmitting; reduce message frequency |
| Device role wrong | ROUTER nodes should have `rebroadcast_mode: ALL` |

### Poor signal quality (low SNR)

| Action | Expected Improvement |
|--------|---------------------|
| Move to open area | +10-20 dB |
| Raise antenna height | +3-6 dB per doubling of height |
| Use external antenna | +3-10 dB over stock whip |
| Reduce distance | +6 dB per halving of distance |
| Clear obstructions | Varies (trees: -3 to -10 dB, buildings: -10 to -30 dB) |

---

## Firmware Issues

### Flash fails

| Error | Solution |
|-------|---------|
| "Failed to connect" | Enter bootloader mode (BOOT + RESET) |
| "Invalid head of packet" | Erase flash first: `esptool.py --port /dev/ttyUSB0 erase_flash` |
| "Timed out" | Try lower baud rate (115200 instead of 921600) |
| Permission denied | Add user to dialout group: `sudo usermod -aG dialout $USER` (re-login) |

### Device stuck in boot loop

1. Enter bootloader mode (BOOT + RESET)
2. Erase flash: `esptool.py --port /dev/ttyUSB0 erase_flash`
3. Re-flash firmware
4. Re-apply configuration profile

### Config lost after firmware update

Some firmware updates reset configuration. Always back up first:
```bash
./tools/configure/backup-config.sh /dev/ttyUSB0
```

Restore after update:
```bash
meshtastic --configure configs/backups/latest.yaml
```

---

## Bridge Issues

### SMS bridge not sending

| Check | Action |
|-------|--------|
| Twilio credentials | Verify in `.env` file |
| MQTT connection | Check: `systemctl status mosquitto` |
| Bridge running | Check: `systemctl status lamesh-sms-bridge` |
| Log errors | View: `journalctl -u lamesh-sms-bridge -f` |
| Phone format | Must be E.164: `+12075551234` |

### MQTT not receiving mesh messages

| Check | Action |
|-------|--------|
| meshtasticd running | Check: `systemctl status meshtasticd` |
| MQTT enabled on device | Verify: `meshtastic --info` (MQTT section) |
| Topic mismatch | Default: `msh/US/2/json/LongFast/+` |
| Mosquitto running | Check: `systemctl status mosquitto` |

### Email bridge not sending

| Check | Action |
|-------|--------|
| SMTP credentials | Verify in `.env` file |
| TLS enabled | Most SMTP servers require TLS on port 587 |
| From address verified | SendGrid/others require verified sender |
| Domain allowlist | Check `ALLOWED_DOMAINS` in `.env` |

---

## Getting Help

1. Check this troubleshooting guide
2. Check [Meshtastic documentation](https://meshtastic.org/docs/)
3. Ask at a community meetup
4. Open an issue: https://github.com/Jesssullivan/LA-Mesh/issues
