# ADR-003: Network Topology Design

**Status**: Proposed
**Date**: 2026-02-11

## Context

LA-Mesh needs a network topology that provides coverage across the Bates College campus and the Lewiston-Auburn downtown corridor (~5 km span). The topology must be resilient to single-node failures and support future expansion.

## Decision

**Hub-and-spoke with mesh redundancy**: Two elevated Station G2 routers form the backbone, with a gateway node providing internet bridge services. Mobile T-Deck clients connect through the nearest router.

### Topology

- **RTR-01** (Campus): Bates College rooftop, highest available building. Primary backbone.
- **RTR-02** (Downtown): Elevated site in downtown Lewiston-Auburn. Secondary backbone.
- **GW-01** (Gateway): Indoor at campus, wired power + internet. MQTT/SMS/email bridge.
- **MOB-01..N** (Clients): T-Deck devices carried by community members.

### Why This Topology

| Alternative | Rejected Because |
|-------------|-----------------|
| Single router | Single point of failure, limited coverage |
| Flat mesh (all CLIENT) | Airtime congestion, unreliable routing |
| Many small relays | Higher cost, more maintenance, power challenges |
| **Two routers + gateway** | **Best cost/coverage/resilience balance** |

### Hop Limit

Set to 5 (up from default 3) to ensure campus-to-downtown coverage via multi-hop paths.

## Consequences

- Two Station G2 units required for backbone (additional cost)
- Rooftop access needed at two locations
- Gateway node requires reliable internet connection
- Coverage gaps between routers may exist until Phase 2 expansion
- See [Network Topology](network-topology.md) for detailed design
