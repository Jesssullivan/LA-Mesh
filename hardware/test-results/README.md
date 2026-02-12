# Test Results

This directory stores RF test data, bench testing results, and field measurements.

## File Naming Convention

```
{test-type}-{date}.csv
```

Examples:
- `baseline-20260215.csv` -- Initial bench test measurements
- `range-test-20260220-143022.csv` -- Automated range test output
- `field-test-bates-campus-20260301.csv` -- Field test at specific location
- `antenna-comparison-20260215.csv` -- Antenna A/B testing
- `battery-life-20260215.csv` -- Battery drain measurements

## CSV Schemas

### Range Test (from range-test.sh)

```csv
msg_num,timestamp_utc,test_id,message
1,2026-02-20T14:30:22Z,RT-20260220-143022,RANGE_TEST RT-20260220-143022 1/10 ...
```

### Baseline Measurements (manual)

```csv
device,distance_m,rssi_dbm,snr_db,delivered,antenna,location,notes
G2-01,100,-75,12.5,yes,stock_whip,indoor,"Same floor"
```

### Battery Life (manual)

```csv
device,role,gps,ble,screen,start_time,pct_50_time,pct_20_time,dead_time,hours_total
T-Deck Plus,CLIENT,on,on,auto,2026-02-15T10:00:00Z,...,...,...,18.5
```

## Subdirectories

- `meshcore-eval/` -- MeshCore evaluation test data (when available)
