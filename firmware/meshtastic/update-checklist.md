# Meshtastic Firmware Update Checklist

Use this checklist when updating firmware on LA-Mesh devices.

---

## Pre-Update

- [ ] Check current firmware version: `meshtastic --info | grep Firmware`
- [ ] Check latest release: https://meshtastic.org/downloads
- [ ] Read release notes for breaking changes
- [ ] Verify minimum version requirement (v2.6.11+ for CVE-2025-52464)
- [ ] **Back up device config**: `./tools/configure/backup-config.sh /dev/ttyUSB0`

## Download

- [ ] Download correct firmware binary for device type:
  - Station G2: `firmware-esp32s3-*.bin`
  - T-Deck Plus: `firmware-tdeck-*.bin`
  - T-Deck Pro e-ink: `firmware-tdeck-pro-*.bin`
- [ ] Verify download (check SHA256 if provided)

## Flash

- [ ] Connect device via USB
- [ ] Enter bootloader mode if needed (BOOT + RESET)
- [ ] Flash: `./tools/flash/flash-meshtastic.sh firmware.bin /dev/ttyUSB0`
- [ ] Wait for "Flash complete!" message
- [ ] Do NOT disconnect during flash

## Post-Update

- [ ] Wait for device to reboot (~10 seconds)
- [ ] Verify new firmware version: `meshtastic --info | grep Firmware`
- [ ] Verify configuration was preserved: `meshtastic --info`
- [ ] If config was lost, restore from backup: `meshtastic --configure configs/backups/latest.yaml`
- [ ] Re-apply channel PSK if needed (firmware update may reset channels)
- [ ] Test message sending/receiving
- [ ] Update `hardware/inventory.md` with new firmware version

## Test on Evaluation Node First

For non-critical updates:
1. Update EVAL-MC or a spare device first
2. Run for 24 hours
3. If stable, proceed with infrastructure nodes (RTR-01, RTR-02)
4. Then update client devices (MOB-01..N)

For security patches (CVEs):
1. Update all infrastructure nodes immediately
2. Update client devices at next meetup or sooner if critical

## Rollback

If the update causes issues:
1. Re-flash with the previous firmware version
2. Restore config from backup
3. Report the issue: https://github.com/meshtastic/firmware/issues
