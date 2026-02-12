# ADR-002: MeshCore Evaluation Scope

**Status**: Proposed
**Date**: 2026-02-11
**Depends on**: [ADR-001](adr-001-firmware-choice.md)

## Context

ADR-001 selected Meshtastic as the primary firmware. A single MeshCore evaluation node was approved to assess MeshCore's directed routing and room server capabilities.

## Decision

Deploy one Station G2 running MeshCore `simple_repeater` firmware as EVAL-MC. Evaluation runs for 4 weeks (Weeks 4-8) with a structured assessment framework.

### Evaluation Criteria

| Criterion | Metric | Pass Threshold |
|-----------|--------|----------------|
| Firmware stability | Uptime % over 4 weeks | >95% |
| Routing efficiency | Airtime vs Meshtastic for same message volume | >20% reduction |
| Room server reliability | Message delivery rate | >98% |
| Companion app UX | User satisfaction (informal survey) | Positive from 3+ testers |
| AMMB bridge viability | Cross-protocol message delivery | Functional basic relay |

### Evaluation Outputs

1. `firmware/meshcore/evaluation-report.md` -- technical findings
2. Updated ADR-001 with evaluation data
3. Recommendation: expand MeshCore, maintain status quo, or abandon

## Consequences

- One Station G2 allocated to MeshCore (not available for Meshtastic backbone)
- MeshCore evaluation does not affect primary network operation
- If MeshCore evaluation is positive, consider dual-network expansion in Phase 2
