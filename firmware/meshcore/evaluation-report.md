# MeshCore Evaluation Report

**Device**: EVAL-MC (Station G2 running MeshCore simple_repeater)
**Firmware**: MeshCore v1.12.0
**Evaluation Period**: Week 4-8 (TBD start date)
**Status**: Template -- fill in during evaluation

---

## Evaluation Criteria

### 1. Firmware Stability

| Metric | Target | Actual | Pass? |
|--------|--------|--------|-------|
| Uptime over 4 weeks | >95% | | |
| Unexpected reboots | <3 total | | |
| Memory leaks observed | None | | |
| Flash process reliability | 100% success | | |

**Notes**: ___________________

### 2. Routing Efficiency

| Metric | Target | Actual | Pass? |
|--------|--------|--------|-------|
| Airtime reduction vs Meshtastic (same msg volume) | >20% | | |
| Path discovery time | <30 seconds | | |
| Directed routing success rate | >90% | | |
| Message delivery rate (peer-to-peer) | >98% | | |

**Test methodology**: Send N identical messages through both MeshCore and Meshtastic networks, measure total airtime and delivery rate.

**Notes**: ___________________

### 3. Room Server Functionality

| Metric | Target | Actual | Pass? |
|--------|--------|--------|-------|
| Message store-and-forward | Functional | | |
| Message retrieval latency | <10 seconds | | |
| Storage capacity | >1000 messages | | |
| Multi-client access | 3+ clients simultaneously | | |

**Notes**: ___________________

### 4. Companion App UX

| Metric | Target | Actual | Pass? |
|--------|--------|--------|-------|
| Android app stability | No crashes in 1 week | | |
| iOS app stability | No crashes in 1 week | | |
| BLE connection reliability | >95% success rate | | |
| User satisfaction (informal, N=3+) | Positive | | |

**Notes**: ___________________

### 5. AMMB Bridge Viability

| Metric | Target | Actual | Pass? |
|--------|--------|--------|-------|
| Cross-protocol message delivery | Functional basic relay | | |
| Setup complexity | <2 hours | | |
| Reliability over 1 week | >90% delivery | | |
| Latency (Meshtastic → MeshCore) | <60 seconds | | |

**Notes**: ___________________

---

## Findings Summary

### Strengths Observed

1. ___________________
2. ___________________
3. ___________________

### Weaknesses Observed

1. ___________________
2. ___________________
3. ___________________

### Comparison with Meshtastic

| Aspect | Meshtastic | MeshCore | Winner |
|--------|-----------|----------|--------|
| Stability | | | |
| Routing efficiency | | | |
| Encryption | AES-256-CTR | AES-128-ECB | Meshtastic |
| App ecosystem | | | |
| MQTT bridge | Native | Third-party | Meshtastic |
| Documentation | | | |
| Community support | | | |

---

## Recommendation

- [ ] **Expand MeshCore**: Deploy additional MeshCore nodes alongside Meshtastic
- [ ] **Maintain status quo**: Keep single evaluation node, revisit in 3 months
- [ ] **Abandon MeshCore**: Consolidate all devices on Meshtastic
- [ ] **Dual-network**: Run parallel Meshtastic and MeshCore networks

**Rationale**: ___________________

**Update ADR-001**: ___________________

---

## Raw Data

Test data files stored in `hardware/test-results/meshcore-eval/`:
- `routing-comparison.csv`
- `airtime-measurements.csv`
- `delivery-rates.csv`
- `app-stability-log.md`
