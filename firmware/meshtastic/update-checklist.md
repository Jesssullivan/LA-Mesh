# Meshtastic Firmware Update Checklist

Use this checklist when updating firmware on LA-Mesh devices.

---

## Pre-Update

- [ ] Check current firmware version: `meshtastic --info | grep Firmware`
- [ ] Check pinned version: `just firmware-versions`
- [ ] Check for upstream updates: `just firmware-check`
- [ ] Read release notes for breaking changes
- [ ] Verify minimum version requirement (v2.6.11+ for CVE-2025-52464)
- [ ] **Back up device config**: `just configure-backup /dev/ttyUSB0`

## Download

- [ ] Fetch firmware for your device:
  ```bash
  # Download all device firmware
  just fetch-firmware

  # Or specific device
  just fetch-firmware station-g2

  # Or specific version
  just fetch-firmware --version 2.7.0
  ```
- [ ] Firmware is automatically verified against `firmware/manifest.json` SHA256 hashes
- [ ] If updating to a new version, update the manifest first:
  ```bash
  ./tools/flash/update-manifest.sh --version 2.7.0
  ```

## Flash

- [ ] Connect device via USB
- [ ] Enter bootloader mode if needed (BOOT + RESET)
- [ ] Flash using one-command provisioning:
  ```bash
  just provision station-g2 /dev/ttyUSB0
  ```
  Or manual flash:
  ```bash
  just flash-meshtastic firmware/.cache/firmware-station-g2-2.6.11.bin /dev/ttyUSB0
  ```
- [ ] Wait for "Flash complete!" message
- [ ] Do NOT disconnect during flash

## Post-Update

- [ ] Wait for device to reboot (~10 seconds)
- [ ] Verify new firmware version: `meshtastic --info | grep Firmware`
- [ ] Verify configuration was preserved: `meshtastic --info`
- [ ] If config was lost, restore from backup: `meshtastic --configure configs/backups/latest.yaml`
- [ ] Re-apply channel PSK if needed (firmware update may reset channels):
  ```bash
  just configure-channels /dev/ttyUSB0
  ```
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
1. Re-flash with the previous firmware version:
   ```bash
   just fetch-firmware --version <previous-version>
   just provision <device> /dev/ttyUSB0
   ```
2. Restore config from backup
3. Report the issue: https://github.com/meshtastic/firmware/issues

## Updating the Manifest

When a new Meshtastic version is released:

```bash
# Check what's available
just firmware-check

# Update manifest to new version (downloads, hashes, updates manifest.json)
./tools/flash/update-manifest.sh --version X.Y.Z

# Review changes
git diff firmware/manifest.json

# Commit
git add firmware/manifest.json
git commit -m "firmware: update Meshtastic to vX.Y.Z"
```
