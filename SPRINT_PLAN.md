# LA-Mesh 8-Week Integration Sprint Plan

**Project**: LA-Mesh -- Community LoRa Mesh Network for Lewiston-Auburn / Southern Maine
**Repository**: github.com/Jesssullivan/LA-Mesh
**Start Date**: TBD (Week 0 = this planning document)
**Scope**: Full deployment from empty repo to operational community mesh network

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Device Fleet Reference](#device-fleet-reference)
3. [Cross-Cutting Concerns](#cross-cutting-concerns)
4. [Hardware Procurement Timeline](#hardware-procurement-timeline)
5. [Regulatory Checklist](#regulatory-checklist)
6. [Week 1: Foundation and Scaffold](#week-1-foundation--scaffold)
7. [Week 2: Firmware and Device Bring-Up](#week-2-firmware--device-bring-up)
8. [Week 3: Network Architecture and Deployment](#week-3-network-architecture--deployment)
9. [Week 4: Bridge and Gateway Development](#week-4-bridge--gateway-development)
10. [Week 5: Security and Encryption](#week-5-security--encryption)
11. [Week 6: SDR and RF Education](#week-6-sdr--rf-education)
12. [Week 7: Documentation and Community](#week-7-documentation--community)
13. [Week 8: Integration Testing and Launch Prep](#week-8-integration-testing--launch-prep)
14. [Risk Register](#risk-register)
15. [Decision Log Template](#decision-log-template)

---

## Executive Summary

LA-Mesh builds a community LoRa mesh network covering the Lewiston-Auburn area and Bates College campus. The project spans hardware deployment, firmware engineering, bridge/gateway software development, security infrastructure, RF education curriculum, and community outreach. This plan sequences 8 weeks of parallel agent work with explicit decision gates, dependency tracking, and human approval checkpoints.

### Critical Architectural Decision (Week 1 Blocker)

**Meshtastic vs. MeshCore**: These two firmware ecosystems do NOT interoperate on the same LoRa mesh. A device running Meshtastic cannot relay or decode MeshCore packets, and vice versa. The project must decide:

| Option | Pros | Cons |
|--------|------|------|
| **A: Meshtastic-primary** | Mature ecosystem, web flasher, MQTT bridge, large community, well-documented API | Less flexible routing, no native dual-protocol |
| **B: MeshCore-primary** | Newer routing algorithms, Aurora firmware for T-Deck, room servers | Smaller community, fewer integrations, client apps are freemium |
| **C: Dual-network** | Covers both ecosystems, research value | Double the hardware, double the complexity, confusing for community users |

**Recommendation**: Option A (Meshtastic-primary) with a single MeshCore evaluation node for research. Meshtastic's ecosystem maturity, MQTT bridge support, and community size make it the pragmatic choice for a community deployment. MeshCore can be evaluated in parallel without blocking the main network.

> **USER DECISION REQUIRED**: Confirm primary firmware choice before Week 2 begins.

---

## Device Fleet Reference

| Device | Role | Firmware | Quantity (Est.) | Unit Cost (Est.) | Notes |
|--------|------|----------|-----------------|-------------------|-------|
| **G2 Base Station** (Heltec/RAK-based) | Fixed relay/router nodes | Meshtastic (router mode) | 4-8 | $30-50 | Rooftop/tower deployment, weatherproof enclosure needed |
| **T-Deck Pro (Full)** | Mobile client, field ops | Meshtastic (client mode) | 2-4 | $80-120 | Full keyboard, color display, GPS |
| **T-Deck Pro (E-Ink)** | Low-power mobile client | Meshtastic (client mode) | 2-3 | $80-120 | Battery-optimized, sunlight-readable |
| **HackRF H4M PortaPack** | SDR education/analysis | Mayhem/H4M firmware | 1-2 | $200-350 | NOT a mesh participant; RF analysis and education tool |
| **MeshAdv-Mini** | Compact relay/sensor node | Meshtastic (router-client) | 3-6 | $20-40 | Small form factor, battery or solar powered |
| **MQTT Gateway Node** | Internet bridge | Meshtastic (client+WiFi) | 1-2 | $30-50 | RAK WisMesh WiFi Gateway or Heltec WiFi LoRa 32 |

### Total Estimated Hardware Budget: $800 - $2,500 (depending on quantities)

---

## Cross-Cutting Concerns

These span all 8 weeks and should be tracked continuously.

### Security (Weeks 1-8)

- All configuration files containing keys or PSKs are git-excluded (enforced by pre-commit hook)
- GPG signing for all mesh-to-external-world messages
- Channel encryption keys rotated on a documented schedule
- TAILS compatibility tested for all bridge interactions
- No plaintext credentials in any committed artifact
- Threat model document maintained and updated each sprint

### Documentation (Weeks 1-8)

- GitHub Pages site updated with each sprint's deliverables
- Every device gets a dedicated setup guide
- Architecture decision records (ADRs) for all major choices
- All agent outputs reviewed by human before publication
- Bilingual consideration: Lewiston has a significant Francophone community (Somali, French)

### Testing (Weeks 2-8)

- Each firmware flash verified with basic connectivity test
- Range tests documented with GPS coordinates, signal strength, and environmental conditions
- Bridge integrations tested end-to-end before declaring complete
- Integration test suite grows each week
- Regression: re-run previous week's tests to catch breakage

### Community Engagement (Weeks 3-8)

- Bates College partnership coordination (facilities access, student involvement)
- L-A community outreach timeline aligned with network readiness
- No public launch until Week 8 go/no-go passes

---

## Hardware Procurement Timeline

Hardware lead times are a critical-path risk. Order early.

| Item | Order By | Expected Arrival | Needed By | Vendor Options |
|------|----------|-----------------|-----------|----------------|
| G2 Base Stations (x4 minimum) | **Week 0 (NOW)** | Week 1-2 | Week 2 | Rokland, RAKwireless, Heltec |
| T-Deck Pro Full (x2) | **Week 0 (NOW)** | Week 1-2 | Week 2 | LILYGO official store, AliExpress |
| T-Deck Pro E-Ink (x2) | **Week 0 (NOW)** | Week 2-3 | Week 3 | LILYGO official store |
| MeshAdv-Mini (x4) | **Week 0 (NOW)** | Week 1-2 | Week 3 | Varies by vendor |
| HackRF H4M PortaPack (x1) | Week 1 | Week 3-4 | Week 6 | Great Scott Gadgets, Amazon |
| MQTT Gateway (x1) | Week 1 | Week 2-3 | Week 4 | Rokland (WisMesh WiFi Gateway) |
| Weatherproof enclosures (x4-8) | Week 1 | Week 2-3 | Week 3 | Amazon, Polycase |
| Antennas (tuned 915MHz, x8+) | **Week 0 (NOW)** | Week 1-2 | Week 2 | Rokland, Signalstuff |
| Solar panels + batteries (x2-4) | Week 2 | Week 3-4 | Week 3 | Amazon, Voltaic Systems |
| Coax/pigtails/adapters | Week 1 | Week 1-2 | Week 2 | Amazon, DX Engineering |

> **USER DECISION REQUIRED (Week 0)**: Confirm device quantities, approve budget, and place initial orders. Hardware lead time from AliExpress/LILYGO can be 2-4 weeks. Rokland and Amazon are faster (2-7 days domestic).

---

## Regulatory Checklist

### FCC Compliance (Mandatory -- USA)

| Requirement | Status | Notes |
|-------------|--------|-------|
| **Part 15.247**: 915 MHz ISM band, spread spectrum | Must verify | Meshtastic uses LoRa (CSS modulation) in 902-928 MHz ISM band. Max 1W (30 dBm) conducted power with antenna gain considered |
| **Part 15.247 antenna integral rule** | Must verify | If using aftermarket antennas, total EIRP must stay within limits |
| **No encryption restrictions on Part 15** | OK | Part 15 devices may use encryption; no restriction |
| **Station identification** | Not required | Part 15 devices exempt from callsign requirements |
| **Part 97 (Amateur)** | Optional | If any operators are licensed hams, they could use higher power on 33cm band, but this creates encryption restrictions (Part 97 prohibits obscured meaning) |
| **Building permits for rooftop antennas** | Must check | Lewiston/Auburn building codes, Bates College facilities approval |
| **FAA notification** | Likely not needed | Only if antenna structure exceeds 200 feet AGL or is near an airport. Check proximity to Auburn-Lewiston Municipal Airport (LEW) |

### Key Regulatory Decisions

> **USER DECISION REQUIRED**:
> 1. Will any nodes operate under Part 97 (amateur radio)? This prohibits encryption and requires licensed operators.
> 2. Confirm all operations will be Part 15 (ISM band, no license required, encryption permitted).
> 3. Check proximity of planned node sites to Auburn-Lewiston Municipal Airport (LEW) -- FAA Form 7460-1 may be needed if within certain distances/heights.

### FCC Power Budget Worksheet

```
Max conducted power (Part 15.247): +30 dBm (1 Watt)
Typical Meshtastic TX power setting:  +22 dBm (default) to +30 dBm (max)
Cable/connector loss (typ):           -1 to -3 dB
Antenna gain (stock whip):            +2 to +3 dBi
Antenna gain (directional):           +6 to +12 dBi

EIRP = TX power - cable loss + antenna gain
Must not exceed +36 dBm EIRP (4W) for point-to-multipoint
Must not exceed +30 dBm conducted in all cases

Example: +22 dBm TX - 1 dB cable + 6 dBi antenna = +27 dBm EIRP (OK)
Example: +30 dBm TX - 1 dB cable + 9 dBi antenna = +38 dBm EIRP (VIOLATION)
```

---

## Week 1: Foundation and Scaffold

**Theme**: Repository infrastructure, build system, documentation skeleton, and procurement verification

**Duration**: 5-7 days
**Prerequisites**: Hardware orders placed (Week 0), firmware choice confirmed

### Parallel Agent Tasks (5 agents)

#### Agent 1-1: Repository Structure and Build System

**Objective**: Create the complete repository scaffold with Bazel, Nix, and Justfile build system.

**Input Requirements**:
- Confirmed repo name and GitHub org (Jesssullivan/LA-Mesh)
- Target languages/tools: Python (bridges), Shell (scripts), Markdown (docs), potentially Go or Rust (tooling)
- Nix flake for reproducible dev environment

**Work Items**:
1. Create directory structure:
   ```
   LA-Mesh/
   ├── BUILD.bazel              # Root Bazel build
   ├── WORKSPACE.bazel          # Bazel workspace
   ├── MODULE.bazel             # Bzlmod configuration
   ├── flake.nix                # Nix flake for dev shell
   ├── flake.lock
   ├── justfile                 # Task runner
   ├── pyproject.toml           # Python project config (uv)
   ├── .github/
   │   ├── workflows/
   │   │   ├── ci.yml           # Main CI pipeline
   │   │   ├── pages.yml        # GitHub Pages deploy
   │   │   └── firmware-check.yml  # Firmware version tracking
   │   └── ISSUE_TEMPLATE/
   │       ├── device-issue.yml
   │       ├── network-issue.yml
   │       └── feature-request.yml
   ├── docs/                    # GitHub Pages source
   │   ├── _config.yml          # Jekyll config
   │   ├── index.md
   │   ├── devices/
   │   ├── guides/
   │   ├── architecture/
   │   └── curriculum/
   ├── firmware/
   │   ├── meshtastic/          # Firmware configs per device
   │   ├── meshcore/            # MeshCore evaluation configs
   │   └── hackrf/              # PortaPack firmware notes
   ├── configs/
   │   ├── channels/            # Channel definitions (no keys)
   │   ├── device-profiles/     # Per-device-type configs
   │   └── network/             # Network topology configs
   ├── bridges/
   │   ├── sms/                 # SMS bridge code
   │   ├── email/               # Email/GPG bridge code
   │   └── mqtt/                # MQTT bridge configs
   ├── tools/
   │   ├── flash/               # Firmware flashing scripts
   │   ├── test/                # Network testing tools
   │   └── monitor/             # Network monitoring
   ├── curriculum/
   │   ├── sdr/                 # HackRF/SDR labs
   │   ├── tails/               # TAILS integration guides
   │   ├── mesh-basics/         # Mesh networking fundamentals
   │   └── security/            # Encryption/OPSEC curriculum
   └── hardware/
       ├── enclosures/          # 3D print files, BOMs
       ├── antennas/            # Antenna specs and calculations
       └── power/               # Solar/battery configurations
   ```

2. Nix flake providing: Python 3.12+, meshtastic CLI, esptool, platformio, hackrf-tools, gnuradio (optional), just, bazel
3. Justfile with recipes: `flash`, `test`, `docs-serve`, `docs-build`, `lint`, `fmt`, `clean`
4. Bazel BUILD files for Python bridge code
5. GitHub Actions CI: lint, build docs, run tests
6. GitHub Actions Pages: deploy from `docs/` on push to main

**Output Artifacts**:
- Complete directory tree committed to `main`
- Working `nix develop` shell
- Working `just --list` showing all recipes
- CI pipeline passing (green)
- GitHub Pages deploying (even if just skeleton)

**Estimated Effort**: 4-6 hours agent time

---

#### Agent 1-2: GitHub Pages Documentation Skeleton

**Objective**: Build the GitHub Pages site structure with navigation, theming, and placeholder content for all planned documentation.

**Input Requirements**:
- Site theme preference (recommended: Just the Docs, or Minimal Mistakes)
- Custom domain decision (e.g., mesh.lewiston-auburn.org or similar)
- Logo/branding assets (if any)

**Work Items**:
1. Jekyll site configuration with chosen theme
2. Navigation structure matching the full 8-week deliverable plan
3. Landing page with project overview, map placeholder, and "get involved" CTA
4. Device pages (one per device type, placeholder content)
5. Architecture overview page with placeholder diagrams
6. Curriculum index page
7. Contributing guide
8. Community page with contact info, meeting schedule placeholder
9. RSS/Atom feed for updates
10. SEO metadata and Open Graph tags

**Output Artifacts**:
- Deployed GitHub Pages site with full navigation
- All placeholder pages with "Coming in Week N" notes
- Local preview working via `just docs-serve`
- Responsive on mobile (community members will access on phones)

**Estimated Effort**: 3-4 hours agent time

---

#### Agent 1-3: Protocol Research Consolidation

**Objective**: Produce a comprehensive technical reference document comparing Meshtastic and MeshCore protocols, informing the firmware decision.

**Input Requirements**:
- Current Meshtastic stable version (check github.com/meshtastic/firmware/releases)
- Current MeshCore stable version (check github.com/meshcore-dev/MeshCore/releases)
- Device compatibility matrix for both firmwares

**Work Items**:
1. Protocol comparison document:
   - Modulation parameters (SF, BW, CR for each preset)
   - Channel capacity and duty cycle limits
   - Routing algorithms (Meshtastic flooding vs. MeshCore managed routing)
   - Encryption schemes (AES-256 in Meshtastic, MeshCore's approach)
   - Maximum message size and fragmentation
   - Hop count limits
   - Power consumption profiles per device type
2. Device compatibility matrix:
   - Which devices support which firmware
   - Known issues per device/firmware combination
   - T-Deck Pro status in both ecosystems (this is immature -- document gaps)
3. Bridge/integration comparison:
   - Meshtastic MQTT vs. MeshCore room servers
   - API availability (Meshtastic Python API, MeshCore CLI)
   - Third-party tool ecosystem
4. Recommendation document with pros/cons for LA-Mesh specifically

**Output Artifacts**:
- `docs/architecture/protocol-comparison.md`
- `docs/architecture/device-compatibility.md`
- `docs/architecture/adr-001-firmware-choice.md` (Architecture Decision Record)

**Estimated Effort**: 3-5 hours agent time (heavy research)

---

#### Agent 1-4: Device Inventory and Procurement Tracker

**Objective**: Create a living inventory system and verify all hardware orders are placed and tracked.

**Input Requirements**:
- Confirmed device list and quantities from user
- Budget approval
- Shipping addresses (Bates College facilities? Personal address?)

**Work Items**:
1. Hardware inventory spreadsheet/document:
   - Device ID, type, serial number, firmware version, assigned role, physical location
   - Procurement status: ordered/shipped/received/configured/deployed
   - Cost tracking
2. Antenna inventory with specifications:
   - Type (whip, Yagi, collinear, etc.)
   - Gain (dBi)
   - Connector type (SMA, U.FL, etc.)
   - Assigned to which device
3. Enclosure and mounting hardware list
4. Power supply inventory (batteries, solar panels, USB adapters)
5. Cable and adapter inventory
6. Tracking document with order numbers, expected delivery dates
7. Receiving checklist (what to verify when hardware arrives)

**Output Artifacts**:
- `hardware/inventory.md` (or CSV/JSON for programmatic access)
- `hardware/procurement-tracker.md`
- `hardware/receiving-checklist.md`
- `hardware/bom.md` (Bill of Materials with costs)

**Estimated Effort**: 2-3 hours agent time

---

#### Agent 1-5: CI/CD Pipeline and Quality Gates

**Objective**: Establish automated quality enforcement for the repository.

**Input Requirements**:
- GitHub repository settings access (branch protection, Pages, Actions)
- Desired branch strategy (recommend: main + feature branches, or three-tier sid/dev/main)

**Work Items**:
1. GitHub Actions workflows:
   - `ci.yml`: Lint markdown, validate YAML/JSON configs, check links in docs, Python linting (ruff), shell linting (shellcheck)
   - `pages.yml`: Build and deploy Jekyll site on push to main
   - `firmware-check.yml`: Weekly cron job checking meshtastic/firmware releases for updates
   - `security-scan.yml`: Check for committed secrets (gitleaks or similar)
2. Branch protection rules (documented, user applies):
   - Require CI pass before merge
   - Require at least 1 review for PRs to main
   - No force push to main
3. Issue templates for common workflows
4. PR template with checklist
5. CODEOWNERS file
6. Dependabot or Renovate config for dependency updates

**Output Artifacts**:
- All workflow files in `.github/workflows/`
- `.github/PULL_REQUEST_TEMPLATE.md`
- `.github/ISSUE_TEMPLATE/*.yml`
- `.github/CODEOWNERS`
- `docs/contributing.md` with branch/PR workflow

**Estimated Effort**: 2-3 hours agent time

---

### Sequential Dependencies

```
Week 0 (Pre-sprint):
  [USER] Place hardware orders
  [USER] Confirm firmware choice (Meshtastic vs MeshCore vs Dual)
  [USER] Confirm budget
      |
      v
Week 1 agents run in parallel:
  Agent 1-1 (Repo Structure) ──┐
  Agent 1-2 (Pages Skeleton) ──┤── All independent, can run simultaneously
  Agent 1-3 (Protocol Research)┤
  Agent 1-4 (Inventory)        │
  Agent 1-5 (CI/CD)  ──────────┘
      |
      v
  [USER REVIEW] Review all Week 1 outputs
  [USER DECISION] Finalize firmware choice based on Agent 1-3 research
      |
      v
  Week 2 begins
```

### Go/No-Go Criteria for Week 2

| Criterion | Required? | Verification |
|-----------|-----------|-------------|
| Repository structure committed and CI passing | **Yes** | Green CI badge |
| GitHub Pages deployed with skeleton | **Yes** | Site accessible at URL |
| Protocol research document reviewed by user | **Yes** | ADR-001 has "Accepted" status |
| At least 2 G2 devices ordered/in-transit | **Yes** | Procurement tracker shows status |
| At least 1 T-Deck Pro ordered/in-transit | **Yes** | Procurement tracker shows status |
| Nix flake builds successfully | **Yes** | `nix develop` enters shell |
| Budget approved | **Yes** | User confirmation |

### Gap Analysis Directives

Research agents should investigate during Week 1:

1. **T-Deck Pro firmware maturity**: Is the Meshtastic firmware for T-Deck Pro stable enough for deployment, or is it still experimental? Check GitHub issues, Reddit reports.
2. **MeshAdv-Mini availability**: Confirm this device exists and is purchasable. Identify the exact product (manufacturer, model number, LoRa chip).
3. **Lewiston-Auburn terrain analysis**: Elevation data, building heights, tree cover density. Identify potential high-point locations for relay nodes.
4. **Bates College facilities**: Which buildings/towers could host nodes? Who is the facilities contact? Are there existing antenna mounts?
5. **Local RF environment**: Any known interference sources in 902-928 MHz band near planned node sites?
6. **Auburn-Lewiston Airport proximity**: Calculate distances from planned node sites to LEW airport. Determine if FAA notification is needed.

### User Decision Points

| Decision | Deadline | Impact if Delayed |
|----------|----------|-------------------|
| Primary firmware (Meshtastic vs MeshCore) | End of Week 1 | Blocks all Week 2 work |
| Device quantities and budget | Start of Week 1 | Delays procurement, cascading delay |
| GitHub Pages domain (custom vs github.io) | Week 1 | Minor, can change later |
| Branch strategy (simple vs three-tier) | Week 1 | Minor, establishes convention early |
| Bates College contact initiated | Week 1 | Blocks Week 3 deployment planning |

---

## Week 2: Firmware and Device Bring-Up

**Theme**: Flash firmware on all received devices, establish baseline configurations, initial bench testing

**Duration**: 5-7 days
**Prerequisites**: Week 1 complete, at least some hardware received, firmware choice confirmed

### Parallel Agent Tasks (5 agents)

#### Agent 2-1: Meshtastic Firmware Flashing Automation

**Objective**: Create reproducible firmware flashing scripts for every device type in the fleet.

**Input Requirements**:
- Confirmed Meshtastic firmware version (from Week 1 research)
- Device types and their ESP32/nRF chip variants
- USB serial port detection method per OS

**Work Items**:
1. Flashing script per device type:
   - `tools/flash/flash-g2.sh` -- G2 base station flashing
   - `tools/flash/flash-tdeck-pro.sh` -- T-Deck Pro (both variants)
   - `tools/flash/flash-meshadv-mini.sh` -- MeshAdv-Mini
   - `tools/flash/flash-gateway.sh` -- MQTT gateway node
2. Each script:
   - Downloads correct firmware binary (version-pinned)
   - Verifies SHA256 checksum
   - Detects serial port automatically
   - Flashes via esptool or appropriate method
   - Verifies flash success
   - Outputs device info (node ID, hardware model)
3. Justfile recipes: `just flash-g2`, `just flash-tdeck`, etc.
4. Nix shell includes all flash dependencies
5. Troubleshooting guide for common flash failures

**Output Artifacts**:
- `tools/flash/*.sh` scripts
- `firmware/meshtastic/checksums.txt`
- `docs/guides/flashing.md`
- Updated justfile with flash recipes

**Estimated Effort**: 3-4 hours agent time

---

#### Agent 2-2: Device Configuration Profiles

**Objective**: Create and document Meshtastic configuration profiles for each device role.

**Input Requirements**:
- Network region (US 915 MHz)
- Channel plan decision (how many channels, naming convention)
- Device role assignments (router, client, router-client)

**Work Items**:
1. Configuration profiles (Meshtastic CLI YAML or JSON):
   - **Router profile** (G2 base stations): Router mode, max TX power, fixed position, no GPS needed, channel config
   - **Client profile** (T-Deck Pro): Client mode, GPS enabled, default TX power, display settings
   - **Router-Client profile** (MeshAdv-Mini): Hybrid mode, moderate TX power, battery optimization
   - **Gateway profile** (MQTT bridge): Client mode, WiFi enabled, MQTT config template
2. Channel configuration:
   - Primary channel (community mesh, default encryption)
   - Admin channel (network management, separate PSK)
   - Emergency channel (high-priority, minimal encryption for interop)
3. Configuration application script:
   - `tools/configure/apply-profile.sh <device-port> <profile-name>`
   - Uses `meshtastic` CLI to apply settings
   - Verifies configuration was applied correctly
4. Configuration backup/export script
5. Factory reset script

**Output Artifacts**:
- `configs/device-profiles/router.yaml`
- `configs/device-profiles/client.yaml`
- `configs/device-profiles/router-client.yaml`
- `configs/device-profiles/gateway.yaml`
- `configs/channels/channel-plan.yaml` (no PSK values -- those stay in .env)
- `tools/configure/apply-profile.sh`
- `tools/configure/backup-config.sh`
- `tools/configure/factory-reset.sh`
- `docs/guides/device-configuration.md`

**Estimated Effort**: 4-5 hours agent time

---

#### Agent 2-3: MeshCore Evaluation (Single Device)

**Objective**: Flash MeshCore (Aurora) on one T-Deck device for evaluation purposes; document findings.

**Input Requirements**:
- One spare T-Deck device designated for MeshCore testing
- Aurora firmware source (github.com/wrewditech/Aurora or similar)
- MeshCore firmware for companion room server (if testing)

**Work Items**:
1. Flash Aurora/MeshCore firmware on evaluation device
2. Document the flash process step-by-step
3. Compare UI/UX with Meshtastic on same hardware
4. Test basic messaging (MeshCore-to-MeshCore if two devices available)
5. Test room server functionality (if applicable)
6. Document API/CLI access methods
7. Evaluate: "Could MeshCore serve any role in the LA-Mesh network?"
8. Write evaluation report with recommendation

**Output Artifacts**:
- `firmware/meshcore/evaluation-report.md`
- `firmware/meshcore/flash-instructions.md`
- `docs/architecture/adr-002-meshcore-evaluation.md`
- Screenshots/photos of MeshCore on T-Deck

**Estimated Effort**: 3-4 hours agent time (requires physical device)

---

#### Agent 2-4: Bench Testing and Baseline Measurements

**Objective**: Establish baseline RF performance for each device type before deployment.

**Input Requirements**:
- At least 2 flashed and configured devices
- Testing location (indoor bench, outdoor line-of-sight)
- Meshtastic CLI or app for reading signal metrics

**Work Items**:
1. Bench test protocol document:
   - Indoor range test (same room, adjacent rooms, through floors)
   - Outdoor line-of-sight range test
   - Metrics to record: RSSI, SNR, packet delivery ratio, latency, hop count
   - Standardized test message format
2. Per-device-type baseline measurements:
   - G2 with stock antenna
   - G2 with upgraded antenna
   - T-Deck Pro with stock antenna
   - MeshAdv-Mini with stock antenna
3. Antenna comparison tests:
   - Stock whip vs. aftermarket
   - dBi gain validation (does real-world match spec?)
4. Battery life baseline:
   - Each device type, continuous receive, GPS on/off
   - Estimated operational time per charge
5. Test data recording template (CSV or JSON)
6. Create `tools/test/range-test.sh` that automates sending test messages and recording metrics

**Output Artifacts**:
- `docs/guides/bench-testing-protocol.md`
- `hardware/test-results/baseline-measurements.csv`
- `hardware/test-results/antenna-comparison.csv`
- `hardware/test-results/battery-life.csv`
- `tools/test/range-test.sh`
- Photos/maps of test locations

**Estimated Effort**: 4-6 hours (requires physical testing)

---

#### Agent 2-5: Development Environment Validation

**Objective**: Verify that the Nix dev shell, Bazel build, and all tooling work end-to-end on at least two platforms.

**Input Requirements**:
- Target platforms: Linux (primary), macOS (secondary)
- Nix flake from Week 1

**Work Items**:
1. Test `nix develop` on Linux -- verify all tools available:
   - meshtastic CLI
   - esptool
   - python3 with meshtastic library
   - hackrf_tools (for Week 6)
   - just
   - bazel (or bazelisk)
   - jekyll (for docs)
   - shellcheck
   - ruff (Python linter)
2. Test `nix develop` on macOS (if available)
3. Test Justfile recipes all work:
   - `just lint`
   - `just fmt`
   - `just docs-serve`
   - `just docs-build`
   - `just flash-*` (dry run mode if no device connected)
4. Test Bazel build:
   - Python targets build
   - Test targets run
5. Document any platform-specific quirks
6. Create `DEVELOPING.md` with setup instructions

**Output Artifacts**:
- `docs/guides/developing.md`
- Bug fixes to flake.nix if needed
- Bug fixes to justfile if needed
- CI validation that all checks pass

**Estimated Effort**: 2-3 hours agent time

---

### Sequential Dependencies

```
Week 1 Complete
  + Hardware arriving
  + Firmware choice confirmed
      |
      v
Week 2 agents:
  Agent 2-1 (Flash Scripts) ─────────┐
  Agent 2-2 (Config Profiles)────────┤── Can develop in parallel
  Agent 2-3 (MeshCore Eval) ─────────┤   (2-3 needs one dedicated device)
  Agent 2-5 (Dev Env Validation) ────┘
      |
      v
  Agent 2-1 + 2-2 outputs feed into:
  Agent 2-4 (Bench Testing) ──── Requires flashed, configured devices
      |
      v
  [USER REVIEW] Review bench test results
  [USER REVIEW] Review MeshCore evaluation
  [USER DECISION] Confirm channel plan and device roles
      |
      v
  Week 3 begins
```

### Go/No-Go Criteria for Week 3

| Criterion | Required? | Verification |
|-----------|-----------|-------------|
| At least 4 devices flashed and configured | **Yes** | Inventory updated with firmware versions |
| Flash scripts work reproducibly | **Yes** | Two people can flash same device type |
| Configuration profiles applied and verified | **Yes** | `meshtastic --info` shows correct config |
| Bench test baseline recorded | **Yes** | CSV data with RSSI/SNR for each device type |
| Two devices can message each other | **Yes** | Basic point-to-point test passes |
| MeshCore evaluation complete | No (nice to have) | Evaluation report written |
| Dev environment works on primary platform | **Yes** | `nix develop` and `just lint` both work |

### Gap Analysis Directives

1. **T-Deck Pro firmware stability**: Document any crashes, display glitches, or GPS issues during bench testing.
2. **Battery life under realistic conditions**: Stock Meshtastic power settings may drain T-Deck Pro quickly. Research optimal power/sleep settings.
3. **USB serial driver issues**: Some ESP32 devices need CH340/CP2102 drivers. Document which devices need which drivers on which OS.
4. **Meshtastic Python API completeness**: Can the Python API do everything the CLI can? Are there gaps that affect bridge development (Week 4)?
5. **OTA firmware update**: Does Meshtastic support OTA updates for deployed nodes? This affects maintainability of rooftop nodes.

### User Decision Points

| Decision | Deadline | Impact if Delayed |
|----------|----------|-------------------|
| Channel naming and PSK generation | Mid-Week 2 | Blocks configuration profiles |
| Device role assignments (which physical device = which role) | Mid-Week 2 | Blocks deployment planning |
| MeshCore disposition (continue evaluation or abandon) | End of Week 2 | Minor, only affects one device |
| TX power levels per device role | End of Week 2 | Affects range test interpretation |

---

## Week 3: Network Architecture and Deployment

**Theme**: Design the physical network topology, plan fixed node deployments, configure channels and encryption, set up MQTT bridge

**Duration**: 5-7 days
**Prerequisites**: Week 2 complete, bench testing data available, rooftop/tower access conversations started

### Parallel Agent Tasks (5 agents)

#### Agent 3-1: Network Topology Design

**Objective**: Design the physical mesh network topology for the Lewiston-Auburn coverage area.

**Input Requirements**:
- Bench test range data from Week 2
- Map of L-A area with candidate node locations
- Bates College campus map with potential tower/rooftop sites
- Elevation data for the area
- User's priority coverage areas

**Work Items**:
1. Coverage modeling:
   - Identify high-point locations (buildings, towers, hills)
   - Estimate radio range per location using terrain data + bench test results
   - Model coverage with 2-hop, 3-hop, and 4-hop scenarios
   - Identify coverage gaps and dead zones
2. Node placement plan:
   - Primary backbone nodes (G2 on rooftops/towers)
   - Secondary relay nodes (MeshAdv-Mini on street-level or mid-height)
   - Gateway node location (needs reliable WiFi/ethernet)
   - Mobile client expected operating area
3. Network diagram:
   - Physical topology map overlaid on L-A map
   - Logical topology (hop paths, expected routes)
   - Redundancy analysis: what happens when a node goes down?
4. Scalability plan:
   - Phase 1: Core backbone (4-6 nodes)
   - Phase 2: Extended coverage (8-12 nodes)
   - Phase 3: Community growth (12+ nodes, community-contributed)
5. Site survey checklist for each planned location

**Output Artifacts**:
- `docs/architecture/network-topology.md` with maps and diagrams
- `docs/architecture/coverage-model.md`
- `configs/network/topology.yaml` (machine-readable node definitions)
- `hardware/site-surveys/` directory with per-site checklists
- `docs/architecture/adr-003-network-topology.md`

**Estimated Effort**: 5-7 hours agent time

---

#### Agent 3-2: Fixed Node Deployment Planning

**Objective**: Create detailed deployment plans for each fixed (rooftop/tower) node, including mounting, power, and weatherproofing.

**Input Requirements**:
- Node placement plan from Agent 3-1 (or preliminary locations from user)
- Enclosure specifications
- Solar panel and battery specifications
- Mounting hardware options

**Work Items**:
1. Per-site deployment plan:
   - Physical access procedure (keys, ladders, safety)
   - Mounting method (pole mount, wall mount, adhesive, etc.)
   - Antenna selection and orientation (omnidirectional vs. directional)
   - Power source (mains, solar, battery, PoE)
   - Weatherproofing (enclosure, cable glands, silicone sealing)
   - Network cable routing (if using ethernet for gateway)
2. Solar power calculations:
   - Average solar hours for Lewiston, ME (latitude ~44.1N)
   - Panel wattage needed per device type
   - Battery capacity for X days of cloudy weather
   - Charge controller selection
3. Weatherproofing specifications:
   - IP rating requirements (IP65 minimum for outdoor)
   - Temperature range (Maine: -20F to 100F / -29C to 38C)
   - UV protection for enclosures
   - Condensation mitigation (desiccant, ventilation)
4. Installation toolkit checklist
5. Safety considerations (working at height, electrical)

**Output Artifacts**:
- `hardware/deployment/site-plan-template.md`
- `hardware/deployment/solar-calculations.md`
- `hardware/deployment/weatherproofing-guide.md`
- `hardware/deployment/installation-toolkit.md`
- Per-site plans in `hardware/deployment/sites/`
- `docs/guides/node-deployment.md`

**Estimated Effort**: 4-5 hours agent time

---

#### Agent 3-3: Channel and Encryption Configuration

**Objective**: Design and implement the channel structure and encryption scheme for the mesh network.

**Input Requirements**:
- Number of channels needed
- User's security requirements (community vs. private channels)
- PSK management strategy decision

**Work Items**:
1. Channel architecture:
   - Channel 0 (Primary): Community mesh -- open to all LA-Mesh members
   - Channel 1 (Admin): Network management -- restricted to operators
   - Channel 2 (Emergency): High-priority -- minimal overhead
   - Channel 3-7: Available for special purposes (events, classes, experiments)
2. Encryption configuration:
   - Default AES-256 PSK per channel
   - PSK generation procedure (cryptographically random)
   - PSK distribution method (in-person only? QR code? Secure channel?)
   - PSK rotation schedule and procedure
   - Document what encryption does and does NOT protect against
3. Key management:
   - PSK storage: encrypted file in operator's possession, never in git
   - PSK backup procedure
   - Compromise response plan (what to do if a PSK leaks)
   - New member onboarding: how they receive channel keys
4. Configuration scripts that apply channel settings without embedding keys:
   - Script reads PSK from environment variable or stdin
   - Applies channel config via meshtastic CLI
   - Verifies channel config matches expected state

**Output Artifacts**:
- `docs/architecture/channel-plan.md` (no keys, just structure)
- `docs/architecture/encryption-design.md`
- `docs/guides/key-management.md`
- `configs/channels/channel-plan.yaml` (channel names, indices, settings -- NO PSKs)
- `tools/configure/apply-channels.sh`
- `docs/architecture/adr-004-encryption-scheme.md`

**Estimated Effort**: 3-4 hours agent time

---

#### Agent 3-4: MQTT Bridge Setup

**Objective**: Configure and test the MQTT bridge that connects the mesh network to the internet for monitoring, bridging, and data collection.

**Input Requirements**:
- MQTT broker decision (self-hosted Mosquitto? Cloud service? Meshtastic public MQTT?)
- Gateway node hardware (WiFi-enabled device)
- Network/WiFi credentials for gateway location

**Work Items**:
1. MQTT broker setup:
   - Option A: Self-hosted Mosquitto (on a Raspberry Pi, VPS, or existing server)
   - Option B: Meshtastic public MQTT (mqtt.meshtastic.org) -- easier but less control
   - Option C: Cloud MQTT (HiveMQ, CloudMQTT) -- managed, reliable
   - Document pros/cons of each, recommend one
2. Gateway node configuration:
   - WiFi settings
   - MQTT connection settings (broker URL, port, TLS, credentials)
   - Topic structure for LA-Mesh
   - Message filtering (what gets bridged, what stays mesh-only)
3. MQTT topic design:
   - `lamesh/messages/{channel}/{from_node}` -- text messages
   - `lamesh/telemetry/{node_id}` -- device telemetry
   - `lamesh/position/{node_id}` -- GPS positions
   - `lamesh/status/{node_id}` -- online/offline status
4. Basic MQTT consumer scripts:
   - `tools/monitor/mqtt-listener.py` -- subscribe and print all messages
   - `tools/monitor/mqtt-to-csv.py` -- log messages to CSV
   - `tools/monitor/node-status.py` -- track which nodes are online
5. Test MQTT bridge end-to-end:
   - Send message from mesh device
   - Verify it arrives at MQTT broker
   - Send message from MQTT to mesh
   - Verify it arrives on mesh devices

**Output Artifacts**:
- `configs/network/mqtt-broker.yaml` (no credentials)
- `bridges/mqtt/mqtt-listener.py`
- `bridges/mqtt/mqtt-to-csv.py`
- `bridges/mqtt/node-status.py`
- `docs/architecture/mqtt-bridge-design.md`
- `docs/guides/mqtt-setup.md`
- `docs/architecture/adr-005-mqtt-broker.md`

**Estimated Effort**: 4-5 hours agent time

---

#### Agent 3-5: Field Range Testing

**Objective**: Conduct real-world range tests at planned deployment locations to validate the coverage model.

**Input Requirements**:
- At least 2 configured Meshtastic devices
- Transportation to test sites
- GPS-enabled phone or device for recording positions
- Preliminary node locations from Agent 3-1

**Work Items**:
1. Field test protocol:
   - Place transmitter at each planned fixed node location
   - Walk/drive receiver to various distances and directions
   - Record RSSI, SNR, packet delivery at each test point
   - Note terrain, obstructions, elevation changes
   - Test at different times of day (RF environment may vary)
2. Test at minimum 3 planned node sites:
   - Highest priority backbone locations
   - Gateway location
   - One challenging/marginal location
3. Multi-hop test:
   - Place 3 devices in a line, verify multi-hop routing works
   - Measure latency per hop
   - Test with intermediate node at various positions
4. Interference survey:
   - Note any signal degradation near known RF sources
   - Document 915 MHz band noise floor at each site
5. Data analysis and coverage map update

**Output Artifacts**:
- `hardware/test-results/field-test-{site-name}.csv` per site
- `docs/architecture/field-test-report.md`
- Updated coverage model with real-world data
- Go/no-go recommendation per planned node site

**Estimated Effort**: 6-8 hours (physical field work, cannot be fully automated)

---

### Sequential Dependencies

```
Week 2 Complete
  + Devices flashed and configured
  + Bench test data available
      |
      v
  Agent 3-1 (Topology Design) ──────┐
  Agent 3-3 (Channel/Encryption) ───┤── Can start immediately in parallel
  Agent 3-4 (MQTT Bridge) ──────────┘
      |
      v
  Agent 3-1 outputs (planned locations) feed:
  Agent 3-2 (Deployment Planning) ── Needs topology to plan per-site
  Agent 3-5 (Field Testing) ──────── Needs locations to test
      |
      v
  [USER REVIEW] Review topology and field test results
  [USER DECISION] Approve node locations
  [USER DECISION] Approve MQTT broker choice
  [USER ACTION] Initiate access requests for rooftop/tower sites
      |
      v
  Week 4 begins
```

### Go/No-Go Criteria for Week 4

| Criterion | Required? | Verification |
|-----------|-----------|-------------|
| Network topology designed and reviewed | **Yes** | Topology doc with map |
| At least 2 field tests completed | **Yes** | Test data files exist |
| Coverage model validated against field data | **Yes** | Model updated with real measurements |
| Channel plan finalized | **Yes** | Channel plan doc approved |
| MQTT bridge working end-to-end | **Yes** | Message sent from mesh arrives at broker |
| At least 1 rooftop/tower access confirmed | **Yes** | Verbal or written approval |
| Encryption scheme documented | **Yes** | Key management guide complete |

### Gap Analysis Directives

1. **Bates College network policies**: Does Bates allow IoT devices on their WiFi? Is there a guest/IoT VLAN? Firewall rules for MQTT?
2. **Municipal building access**: Are there city-owned buildings in L-A with accessible rooftops? Contact city facilities department.
3. **Meshtastic hop limit implications**: Default 3-hop limit may not cover the entire L-A area. Research increasing to 5-7 hops and the performance implications.
4. **LoRa duty cycle**: US ISM band has no strict duty cycle limit (unlike EU), but Meshtastic has built-in airtime limits. Document how these affect throughput at scale.
5. **Winter weather impact**: Maine winters are harsh. Research LoRa signal propagation in snow/ice conditions. Battery performance at -20F.

### User Decision Points

| Decision | Deadline | Impact if Delayed |
|----------|----------|-------------------|
| Approve node placement locations | End of Week 3 | Blocks physical deployment |
| MQTT broker choice (self-hosted vs. cloud) | Mid-Week 3 | Blocks bridge development |
| Rooftop access requests submitted | Week 3 | Blocks Week 3 field testing at those sites |
| PSK generation and distribution method | End of Week 3 | Blocks community onboarding |
| Solar vs. mains power per site | End of Week 3 | Affects procurement and deployment |

---

## Week 4: Bridge and Gateway Development

**Theme**: Build the SMS and email/GPG bridges, integrate with MQTT, begin MeshAdv-Mini deployment

**Duration**: 5-7 days
**Prerequisites**: MQTT bridge operational, channel encryption configured, at least 4 mesh nodes communicating

### Parallel Agent Tasks (5 agents)

#### Agent 4-1: SMS Bridge Development

**Objective**: Build a working SMS-to-mesh bridge that allows non-mesh users to send/receive messages via SMS.

**Input Requirements**:
- SMS gateway service decision (Twilio, Vonage, or local GSM modem)
- Phone number allocation
- MQTT bridge operational
- Message format design

**Work Items**:
1. SMS bridge architecture:
   - SMS provider receives text from phone
   - Webhook/API forwards to bridge server
   - Bridge server publishes to MQTT
   - MQTT-to-mesh gateway delivers to mesh network
   - Reverse path for mesh-to-SMS
2. Bridge server implementation (`bridges/sms/`):
   - Python (FastAPI or Flask) webhook receiver
   - Message parsing and validation
   - Rate limiting (prevent SMS spam flooding mesh)
   - Message formatting (SMS character limits, mesh payload limits)
   - Bidirectional routing: SMS -> mesh and mesh -> SMS
   - Phone number allowlist/denylist
3. Alternative: Direct serial bridge (no internet):
   - MeshAdv-Mini or similar device with built-in cellular modem
   - If T-Deck Pro has 4G variant (A7682E), explore direct integration
4. Testing:
   - Send SMS -> verify arrives on mesh
   - Send mesh message -> verify arrives as SMS
   - Test edge cases: long messages, special characters, concurrent messages
5. Monitoring and logging:
   - Message delivery confirmation
   - Error alerting
   - Usage metrics

**Output Artifacts**:
- `bridges/sms/server.py` -- SMS bridge server
- `bridges/sms/requirements.txt` or `pyproject.toml` dependency section
- `bridges/sms/config.yaml.template` (no credentials)
- `bridges/sms/tests/` -- unit and integration tests
- `docs/architecture/sms-bridge-design.md`
- `docs/guides/sms-bridge-setup.md`

**Estimated Effort**: 6-8 hours agent time

---

#### Agent 4-2: Email/GPG Bridge Development

**Objective**: Build an email-to-mesh bridge with GPG signature verification for authenticated messages.

**Input Requirements**:
- SMTP/IMAP server access (or decision to use existing email service)
- GPG key management strategy from Week 3
- MQTT bridge operational
- Message format design

**Work Items**:
1. Email bridge architecture:
   - IMAP polling or webhook for incoming email
   - GPG signature verification on incoming messages
   - Message body extraction and truncation for mesh (LoRa payload limits)
   - MQTT publish to mesh
   - Mesh-to-email: GPG-sign outgoing messages
2. GPG integration:
   - Operator GPG keyring management
   - Signature verification pipeline
   - Signed message formatting for mesh display
   - Key exchange workflow for new users
3. Bridge server implementation (`bridges/email/`):
   - Python IMAP client for polling
   - GPG operations via python-gnupg
   - Message formatting (strip HTML, truncate to mesh limits)
   - Sender authentication (verify GPG sig, check allowed senders)
   - Bidirectional: email -> mesh and mesh -> email
4. TAILS compatibility consideration:
   - Can a TAILS user send GPG-signed email that reaches the mesh?
   - Document the workflow: TAILS -> Thunderbird -> GPG sign -> email -> bridge -> mesh
5. Testing:
   - Send signed email -> verify arrives on mesh with "VERIFIED" indicator
   - Send unsigned email -> verify it's flagged or rejected
   - Send mesh message -> verify it arrives as signed email
   - Test with TAILS (Week 5 deep dive, but basic test here)

**Output Artifacts**:
- `bridges/email/server.py` -- Email bridge server
- `bridges/email/gpg_utils.py` -- GPG operations
- `bridges/email/requirements.txt`
- `bridges/email/config.yaml.template`
- `bridges/email/tests/`
- `docs/architecture/email-bridge-design.md`
- `docs/guides/email-bridge-setup.md`
- `docs/guides/gpg-quickstart.md`

**Estimated Effort**: 6-8 hours agent time

---

#### Agent 4-3: MeshAdv-Mini Integration

**Objective**: Deploy and test MeshAdv-Mini devices as compact relay nodes, evaluate any special capabilities.

**Input Requirements**:
- MeshAdv-Mini devices received and identified
- Firmware compatibility confirmed
- Deployment locations for compact relays

**Work Items**:
1. Device characterization:
   - Exact hardware specs (LoRa chip, MCU, antenna, battery)
   - Firmware options and compatibility
   - Power consumption profile
   - Range comparison with G2 base stations
2. Flash and configure for relay role:
   - Apply router-client profile
   - Optimize for battery life if battery-powered
   - Configure appropriate TX power
3. Deployment scenarios:
   - Window-mounted relay (indoor, extending coverage)
   - Temporary event relay (portable, battery-powered)
   - Vehicle-mounted mobile relay
   - Street-level fill-in relay
4. Integration testing:
   - Verify MeshAdv-Mini relays messages correctly
   - Measure latency added per hop through Mini
   - Test recovery after power cycle
   - Test range in realistic deployment positions
5. Create deployment guide specific to MeshAdv-Mini form factor

**Output Artifacts**:
- `firmware/meshtastic/meshadv-mini-notes.md`
- `configs/device-profiles/meshadv-mini-relay.yaml`
- `hardware/deployment/meshadv-mini-deployment-guide.md`
- Test results added to `hardware/test-results/`
- Updated device inventory

**Estimated Effort**: 3-4 hours agent time

---

#### Agent 4-4: Meshtastic Python API Integration Library

**Objective**: Build a reusable Python library that both bridges use for mesh communication.

**Input Requirements**:
- Meshtastic Python API documentation
- MQTT topic design from Week 3
- Message format specifications

**Work Items**:
1. Core library (`bridges/lib/`):
   - `mesh_client.py` -- Connect to mesh via serial or MQTT
   - `message.py` -- Message parsing, formatting, validation
   - `node.py` -- Node information and status tracking
   - `channel.py` -- Channel management utilities
   - `telemetry.py` -- Telemetry data parsing
2. Message format standards:
   - Maximum message length calculation (LoRa payload - overhead)
   - Message truncation with indicator
   - Multi-part message support (for longer content)
   - Message ID tracking for deduplication
3. Error handling:
   - Connection retry with backoff
   - Message delivery confirmation
   - Timeout handling
   - Graceful degradation when mesh is unreachable
4. Monitoring utilities:
   - Network health dashboard data
   - Node uptime tracking
   - Message throughput metrics
   - Signal quality trends
5. Test suite:
   - Unit tests with mocked meshtastic interface
   - Integration test framework (requires real device or emulator)

**Output Artifacts**:
- `bridges/lib/__init__.py`
- `bridges/lib/mesh_client.py`
- `bridges/lib/message.py`
- `bridges/lib/node.py`
- `bridges/lib/channel.py`
- `bridges/lib/telemetry.py`
- `bridges/lib/tests/`
- Bazel BUILD targets for library and tests

**Estimated Effort**: 5-6 hours agent time

---

#### Agent 4-5: Network Monitoring Dashboard

**Objective**: Create a simple monitoring dashboard that shows network health, node status, and message activity.

**Input Requirements**:
- MQTT broker operational
- MQTT topic design from Week 3
- Node inventory from Week 2

**Work Items**:
1. Dashboard design options:
   - Option A: Static page on GitHub Pages (updates via MQTT WebSocket)
   - Option B: Simple Python web app (Flask/FastAPI + HTMX)
   - Option C: Grafana + InfluxDB/Prometheus (heavier, more capable)
   - Recommend Option A for simplicity, with path to Option C
2. Dashboard features:
   - Node status map (online/offline/last-seen)
   - Message activity log (recent messages, redacted content)
   - Signal quality heatmap
   - Network topology visualization
   - Uptime statistics per node
3. MQTT-to-dashboard data pipeline:
   - Subscribe to `lamesh/status/#` and `lamesh/telemetry/#`
   - Process and aggregate data
   - Serve via WebSocket or periodic page update
4. Alerting (basic):
   - Node offline > 1 hour
   - Signal quality degradation
   - Unusual message volume (potential spam/attack)

**Output Artifacts**:
- `tools/monitor/dashboard/` -- dashboard code
- `docs/guides/monitoring.md`
- Dashboard accessible at GitHub Pages URL or local server
- `tools/monitor/alerts.py` -- basic alerting script

**Estimated Effort**: 4-5 hours agent time

---

### Sequential Dependencies

```
Week 3 Complete
  + MQTT operational
  + Channels configured
  + Node locations planned
      |
      v
  Agent 4-4 (Python Library) ────┐
  Agent 4-3 (MeshAdv-Mini) ──────┤── Start immediately, no cross-dependencies
  Agent 4-5 (Dashboard) ─────────┘
      |
      v
  Agent 4-4 (library) outputs feed:
  Agent 4-1 (SMS Bridge) ───── Uses shared library for mesh communication
  Agent 4-2 (Email/GPG Bridge) ── Uses shared library + GPG utilities
      |
      v
  [USER REVIEW] Test SMS bridge with personal phone
  [USER REVIEW] Test email bridge with personal email
  [USER DECISION] SMS service provider selection (budget impact)
  [USER DECISION] Dashboard hosting decision
      |
      v
  Week 5 begins
```

### Go/No-Go Criteria for Week 5

| Criterion | Required? | Verification |
|-----------|-----------|-------------|
| SMS bridge sends and receives messages | **Yes** | Demo with real phone number |
| Email/GPG bridge sends and receives | **Yes** | Demo with real email |
| GPG signature verification works | **Yes** | Signed message shows "VERIFIED" on mesh |
| Python library has passing test suite | **Yes** | `just test` passes |
| MeshAdv-Mini devices operational in mesh | No (can continue in Week 5) | Devices appear in node list |
| Dashboard shows live node status | No (nice to have) | Dashboard page accessible |
| No regressions in mesh connectivity | **Yes** | Nodes still communicating, MQTT still working |

### Gap Analysis Directives

1. **SMS cost modeling**: What is the monthly cost of Twilio/Vonage for expected message volume? Is there a free tier that suffices?
2. **Local GSM modem option**: Could a USB GSM modem with a local SIM card replace cloud SMS? This would be more resilient and private.
3. **LoRa payload size limits**: Exact maximum payload for the chosen Meshtastic preset. This constrains message length for both bridges.
4. **MQTT broker reliability**: If self-hosted, what happens when the broker goes down? Do bridges queue messages?
5. **mesh-api project evaluation**: The mr-tbot/mesh-api project on GitHub already supports Twilio SMS and email. Should we fork/adapt it rather than building from scratch?

### User Decision Points

| Decision | Deadline | Impact if Delayed |
|----------|----------|-------------------|
| SMS provider selection and account setup | Start of Week 4 | Blocks SMS bridge development |
| Email account/server for bridge | Start of Week 4 | Blocks email bridge development |
| Monthly operational budget for SMS/email | Start of Week 4 | Informs architecture decisions |
| Dashboard hosting (GitHub Pages vs. separate) | Mid-Week 4 | Affects dashboard implementation |
| Evaluate vs. build-from-scratch (mesh-api project) | Start of Week 4 | Could save significant development time |

---

## Week 5: Security and Encryption

**Theme**: Harden the entire system -- encryption audit, GPG key infrastructure, TAILS integration, threat modeling

**Duration**: 5-7 days
**Prerequisites**: Bridges working, mesh network operational with encryption, GPG basics from Week 4

### Parallel Agent Tasks (5 agents)

#### Agent 5-1: Security Audit of Mesh Configuration

**Objective**: Comprehensive security review of the entire mesh network configuration.

**Input Requirements**:
- Current device configurations (exported)
- Channel encryption settings
- MQTT broker configuration
- Bridge server configurations
- Network topology

**Work Items**:
1. Threat model document:
   - Asset inventory (what are we protecting?)
   - Threat actors (who might attack? Capabilities?)
   - Attack vectors specific to LoRa mesh:
     * RF eavesdropping (passive intercept of LoRa packets)
     * Replay attacks (re-transmitting captured packets)
     * Node impersonation (fake node joining mesh)
     * Denial of service (jamming 915 MHz band)
     * Physical device compromise (stolen node)
     * MQTT broker compromise
     * Bridge server compromise
   - Risk assessment per threat
   - Mitigations implemented and planned
2. Configuration audit:
   - Verify AES-256 is active on all channels
   - Verify no default/weak PSKs in use
   - Verify admin channel is properly restricted
   - Check for information leakage in telemetry (GPS positions, etc.)
   - Review MQTT TLS configuration
   - Review bridge server authentication
3. Penetration testing (basic):
   - Attempt to join mesh without valid PSK
   - Attempt to decode intercepted packets (with SDR if available)
   - Attempt to send messages via MQTT without authentication
   - Attempt to access bridge server admin functions
4. Remediation plan for any findings
5. Security hardening checklist for operators

**Output Artifacts**:
- `docs/architecture/threat-model.md`
- `docs/architecture/security-audit-report.md`
- `docs/guides/security-hardening-checklist.md`
- `docs/architecture/adr-006-security-posture.md`
- Remediation tickets/issues for any findings

**Estimated Effort**: 5-7 hours agent time

---

#### Agent 5-2: GPG Key Management System

**Objective**: Build a robust GPG key management system for mesh operators and bridge users.

**Input Requirements**:
- Number of initial operators
- Key distribution constraints (in-person only? Internet OK?)
- TAILS compatibility requirements

**Work Items**:
1. GPG infrastructure design:
   - Key hierarchy: Network master key -> Operator subkeys -> User keys
   - Key generation procedures (standardized, documented)
   - Key signing party protocol for in-person verification
   - Key revocation procedures
   - Key expiration policy (recommend 1-year, with renewal)
2. Keyring management:
   - Operator keyring setup script
   - Public key distribution mechanism (keyserver? WKD? Git repo?)
   - Key fingerprint verification procedure
   - Trust model (Web of Trust vs. centralized CA-like)
3. Bridge integration:
   - Update email bridge to use managed keyring
   - Message signing/verification pipeline
   - Key rotation impact on bridges
4. TAILS compatibility:
   - GPG key import/export in TAILS
   - Persistent volume configuration for keys in TAILS
   - Thunderbird + Enigmail/OpenPGP setup in TAILS
5. Documentation for end users:
   - "GPG in 15 minutes" quickstart
   - Key generation guide (with screenshots)
   - Key backup and recovery guide

**Output Artifacts**:
- `tools/gpg/generate-operator-key.sh`
- `tools/gpg/import-public-keys.sh`
- `tools/gpg/verify-keyring.sh`
- `docs/guides/gpg-key-management.md`
- `docs/guides/gpg-quickstart-users.md`
- `curriculum/security/gpg-key-party-protocol.md`

**Estimated Effort**: 4-6 hours agent time

---

#### Agent 5-3: TAILS Integration Testing

**Objective**: Verify and document that all LA-Mesh communication pathways work from a TAILS environment.

**Input Requirements**:
- TAILS USB drive prepared
- Test machine (ideally not the main development machine)
- Working SMS and email bridges

**Work Items**:
1. TAILS environment setup:
   - Document TAILS version tested
   - Persistent volume configuration for GPG keys and Meshtastic configs
   - Tor network considerations for bridge access
2. Test scenarios from TAILS:
   - Send GPG-signed email -> bridge -> mesh (verify delivery)
   - Receive mesh message -> bridge -> email -> TAILS Thunderbird
   - Send SMS via Tor-accessible SMS gateway -> bridge -> mesh
   - Access mesh monitoring dashboard via Tor Browser
   - Direct serial connection to Meshtastic device from TAILS (USB)
3. Tor compatibility assessment:
   - Can MQTT work over Tor? (likely needs .onion address or Tor-friendly broker)
   - Latency impact of Tor on bridge responsiveness
   - IP leakage assessment for bridge services
4. TAILS-specific documentation:
   - Step-by-step setup guide with screenshots
   - Known limitations and workarounds
   - What works, what doesn't, and why
5. Operational security (OPSEC) guidelines:
   - When to use TAILS vs. regular OS
   - What metadata is exposed at each layer
   - Threat model for TAILS + mesh combination

**Output Artifacts**:
- `docs/guides/tails-integration.md`
- `curriculum/security/tails-mesh-guide.md`
- `curriculum/security/opsec-guidelines.md`
- Test results documenting what works/fails
- Screenshots of TAILS workflows

**Estimated Effort**: 5-7 hours (requires physical TAILS testing)

---

#### Agent 5-4: End-to-End Encryption Verification

**Objective**: Verify that encryption is working correctly at every layer of the system.

**Input Requirements**:
- Working mesh network with encryption enabled
- Working bridges
- HackRF or SDR (if available for RF-level analysis)

**Work Items**:
1. Encryption layer inventory:
   - Layer 1: LoRa link-layer (spread spectrum, not true encryption)
   - Layer 2: Meshtastic AES-256 channel encryption
   - Layer 3: GPG message-level encryption (for bridge messages)
   - Layer 4: MQTT TLS (broker connection)
   - Layer 5: HTTPS for web interfaces
2. Per-layer verification:
   - Capture raw LoRa packets (with SDR or packet sniffer) -- verify content is encrypted
   - Verify Meshtastic shows correct encryption indicator
   - Verify GPG signatures validate correctly
   - Verify MQTT connection uses TLS (no plaintext MQTT)
   - Verify dashboard/web interfaces use HTTPS
3. Known weaknesses documentation:
   - Meshtastic node ID is NOT encrypted (visible in packet headers)
   - GPS position may be encrypted but timing analysis could reveal movement
   - Channel membership is inferable from traffic analysis
   - LoRa signal can be direction-found regardless of encryption
   - MQTT broker sees decrypted content (unless using E2E encryption)
4. Recommendations for improvement:
   - Additional encryption layers where warranted
   - Metadata minimization strategies
   - Traffic analysis countermeasures (dummy traffic, etc.)

**Output Artifacts**:
- `docs/architecture/encryption-verification-report.md`
- `docs/architecture/known-security-limitations.md`
- Updated threat model
- Recommendations document

**Estimated Effort**: 4-5 hours agent time

---

#### Agent 5-5: Incident Response Plan

**Objective**: Create procedures for handling security incidents affecting the mesh network.

**Input Requirements**:
- Threat model from Agent 5-1
- Operator contact information
- Escalation procedures

**Work Items**:
1. Incident classification:
   - Level 1: Node malfunction (non-security)
   - Level 2: Suspected eavesdropping
   - Level 3: Node compromise (physical or remote)
   - Level 4: PSK compromise
   - Level 5: Operator key compromise
   - Level 6: Bridge/infrastructure compromise
2. Response procedures per level:
   - Who to notify
   - Immediate containment steps
   - Evidence preservation
   - Recovery procedures
   - Post-incident review
3. PSK rotation procedure (emergency):
   - Generate new PSKs
   - Distribute to all operators
   - Reconfigure all nodes (rolling update procedure)
   - Verify all nodes on new PSK
   - Revoke old PSK
4. Physical device loss/theft procedure:
   - Remote lock-out capability (if any)
   - PSK rotation necessity assessment
   - Device recovery or replacement
5. Communication plan during incidents:
   - Out-of-band communication (phone tree, Signal group)
   - Public communication template (if incident affects community users)

**Output Artifacts**:
- `docs/operations/incident-response-plan.md`
- `docs/operations/psk-rotation-procedure.md`
- `docs/operations/device-loss-procedure.md`
- `docs/operations/operator-contacts.md.template`
- Incident report template

**Estimated Effort**: 3-4 hours agent time

---

### Sequential Dependencies

```
Week 4 Complete
  + Bridges working
  + GPG basics functional
  + Mesh network operational
      |
      v
  All Week 5 agents can start in parallel:
  Agent 5-1 (Security Audit) ────────┐
  Agent 5-2 (GPG Key Management) ────┤
  Agent 5-3 (TAILS Integration) ─────┤── All independent
  Agent 5-4 (E2E Encryption Verify) ─┤
  Agent 5-5 (Incident Response) ─────┘
      |
      v
  Agent 5-1 findings may generate remediation work:
  [REMEDIATION SPRINT] Fix any critical security findings
      |
      v
  [USER REVIEW] Review threat model and accept residual risks
  [USER REVIEW] Review incident response plan
  [USER DECISION] Approve GPG key hierarchy design
  [USER ACTION] Generate operator GPG keys (in-person key signing event)
      |
      v
  Week 6 begins
```

### Go/No-Go Criteria for Week 6

| Criterion | Required? | Verification |
|-----------|-----------|-------------|
| Security audit complete, no critical findings unresolved | **Yes** | Audit report reviewed |
| Threat model documented and accepted | **Yes** | User sign-off |
| AES-256 encryption verified on all channels | **Yes** | Verification report |
| MQTT using TLS | **Yes** | Connection test shows TLS |
| GPG key management procedures documented | **Yes** | Guide complete |
| TAILS integration tested (at least email pathway) | **Yes** | Test results documented |
| Incident response plan reviewed | **Yes** | User has read and accepted |
| No regressions in mesh or bridge functionality | **Yes** | All previous tests still pass |

### Gap Analysis Directives

1. **Meshtastic E2E encryption**: Does Meshtastic support per-message E2E encryption (beyond channel PSK)? If so, how does it interact with bridges?
2. **Physical security for rooftop nodes**: Can someone with physical access extract the PSK from a Meshtastic device? (Answer: likely yes, via serial connection.) What mitigations exist?
3. **MQTT E2E encryption**: Can messages transit the MQTT broker encrypted, with decryption only at endpoints? This would protect against broker compromise.
4. **LoRa signal direction finding**: How easy is it to locate a LoRa transmitter? What countermeasures exist? This matters for protest/activism use cases.
5. **Legal considerations for encryption**: Any Maine or federal laws affecting encrypted mesh communications? (Generally no, but document the analysis.)

### User Decision Points

| Decision | Deadline | Impact if Delayed |
|----------|----------|-------------------|
| Accept residual security risks | End of Week 5 | Blocks community launch |
| GPG key hierarchy approval | Mid-Week 5 | Blocks key generation |
| TAILS compatibility: hard requirement vs. nice-to-have? | Start of Week 5 | Affects development priority |
| Incident response plan approval | End of Week 5 | Blocks operational readiness |
| Operator security clearance (who gets admin access) | End of Week 5 | Blocks key distribution |

---

## Week 6: SDR and RF Education

**Theme**: HackRF PortaPack curriculum development, LoRa protocol analysis, RF education materials

**Duration**: 5-7 days
**Prerequisites**: Network operational, security reviewed, HackRF hardware received

### Parallel Agent Tasks (4 agents)

#### Agent 6-1: HackRF PortaPack Curriculum Development

**Objective**: Create a structured SDR education curriculum using the HackRF H4M PortaPack.

**Input Requirements**:
- HackRF H4M with PortaPack (hardware in hand)
- Current firmware version (Mayhem or H4M-specific)
- Target audience: Bates College students, community members with technical interest
- Prerequisite knowledge level: basic electronics awareness, no RF experience required

**Work Items**:
1. Curriculum structure (6-8 lab modules):
   - **Lab 1: Introduction to Software Defined Radio**
     * What is SDR? Analog vs. digital radio
     * HackRF hardware overview (ADC, DAC, frequency range)
     * PortaPack UI navigation
     * Safety: TX power, legal frequencies, FCC rules
   - **Lab 2: Spectrum Analysis**
     * Using spectrum analyzer mode
     * Identifying signals in the local RF environment
     * Understanding frequency, bandwidth, and power
     * Practical: Find and identify WiFi, FM broadcast, weather radio, LoRa
   - **Lab 3: FM Radio Reception and Transmission**
     * Receive FM broadcast stations
     * Understand modulation (FM vs. AM vs. digital)
     * Micro-power FM transmitter exercise (legal under Part 15)
     * Audio processing basics
   - **Lab 4: LoRa Signal Analysis**
     * LoRa chirp spread spectrum (CSS) modulation explained
     * Capture and visualize LoRa packets from the mesh network
     * Spreading factor, bandwidth, coding rate visualization
     * Packet structure analysis
   - **Lab 5: dBm, Link Budgets, and Antenna Theory**
     * Decibel math: dBm, dBi, dB
     * Link budget calculation for LoRa
     * Antenna patterns: omni vs. directional
     * Practical measurement: compare antenna performance with HackRF
   - **Lab 6: Digital Modes and Protocol Analysis**
     * OOK, FSK, and other common modulations
     * Weather station protocol decode
     * POCSAG pager decode (if applicable locally)
     * Understanding the difference between analysis and interception
   - **Lab 7: TEMPEST Concepts (Demonstration Only)**
     * Electromagnetic emanation basics
     * Historical context (TEMPEST program)
     * Demonstration: receive unintentional emissions from a display
     * Shielding and EMSEC concepts
     * **Ethics discussion: legal and ethical boundaries**
   - **Lab 8: Building a LoRa Transceiver from Scratch** (Advanced)
     * LoRa module + microcontroller
     * Raw packet construction
     * Compare with Meshtastic's implementation
     * Understanding protocol layers

2. Per-lab deliverables:
   - Objectives and prerequisites
   - Background reading
   - Step-by-step procedure
   - Expected results with screenshots/spectrograms
   - Discussion questions
   - Assessment criteria

3. Safety and legal framework:
   - FCC rules summary for each lab activity
   - "Red light / green light" chart: what you can and cannot do
   - Responsible disclosure policy for anything discovered via SDR
   - Explicit warnings about illegal interception (ECPA, wiretapping laws)

**Output Artifacts**:
- `curriculum/sdr/lab-01-intro-to-sdr.md`
- `curriculum/sdr/lab-02-spectrum-analysis.md`
- `curriculum/sdr/lab-03-fm-radio.md`
- `curriculum/sdr/lab-04-lora-analysis.md`
- `curriculum/sdr/lab-05-link-budgets.md`
- `curriculum/sdr/lab-06-digital-modes.md`
- `curriculum/sdr/lab-07-tempest-demo.md`
- `curriculum/sdr/lab-08-lora-from-scratch.md`
- `curriculum/sdr/instructor-guide.md`
- `curriculum/sdr/safety-and-legal.md`
- `curriculum/sdr/syllabus.md`

**Estimated Effort**: 8-10 hours agent time (extensive content creation)

---

#### Agent 6-2: LoRa Protocol Deep Dive Document

**Objective**: Create a comprehensive technical reference on LoRa/LoRaWAN physical and protocol layers, tailored for LA-Mesh operators and students.

**Input Requirements**:
- LoRa modulation parameters used by Meshtastic
- Captured LoRa packets from the operational mesh (if possible)
- Meshtastic protocol buffer definitions

**Work Items**:
1. Physical layer reference:
   - CSS (Chirp Spread Spectrum) modulation explained
   - Spreading Factor (SF7-SF12): tradeoffs of range vs. data rate
   - Bandwidth (125, 250, 500 kHz): channel capacity
   - Coding Rate: error correction overhead
   - Frequency hopping and channel plan
   - Time-on-air calculations
2. Meshtastic protocol layer:
   - Protocol buffer message format
   - Packet structure: header, encrypted payload, CRC
   - Routing algorithm (flooding-based)
   - Hop count and deduplication
   - Node discovery and neighbor tracking
   - Channel multiplexing
3. Performance characterization:
   - Throughput per spreading factor
   - Latency per hop count
   - Duty cycle implications (US ISM band)
   - Collision probability at various network sizes
   - Practical capacity: how many messages per minute?
4. Comparison with LoRaWAN:
   - Meshtastic mesh vs. LoRaWAN star topology
   - When to use which
   - Can they coexist on same frequencies?

**Output Artifacts**:
- `docs/architecture/lora-protocol-reference.md`
- `curriculum/mesh-basics/lora-deep-dive.md`
- `curriculum/mesh-basics/time-on-air-calculator.py`
- Diagrams and visualizations

**Estimated Effort**: 5-6 hours agent time

---

#### Agent 6-3: dBm Calculation Exercises and RF Tools

**Objective**: Create practical RF calculation tools and exercises for education and network planning.

**Input Requirements**:
- Device TX power specifications
- Antenna specifications from inventory
- Planned link distances from network topology

**Work Items**:
1. RF calculation reference sheet:
   - dBm to mW conversion table
   - dBi to linear gain conversion
   - Free space path loss formula
   - Fresnel zone calculations
   - Link budget worksheet
2. Interactive calculation tools:
   - `tools/rf/link-budget-calculator.py` -- CLI tool for link budgets
   - `tools/rf/fresnel-zone-calculator.py` -- Fresnel zone clearance
   - `tools/rf/time-on-air-calculator.py` -- LoRa airtime calculator
   - `tools/rf/eirp-calculator.py` -- Verify FCC compliance
3. Exercise worksheets:
   - Calculate link budget between two planned node sites
   - Determine optimal spreading factor for a given distance
   - Calculate battery life given TX power and duty cycle
   - Determine antenna requirements for a marginal link
   - FCC compliance verification for a given setup
4. Real-world validation:
   - Compare calculated link budgets with field test measurements
   - Document discrepancies and likely causes (terrain, foliage, interference)

**Output Artifacts**:
- `tools/rf/link-budget-calculator.py`
- `tools/rf/fresnel-zone-calculator.py`
- `tools/rf/time-on-air-calculator.py`
- `tools/rf/eirp-calculator.py`
- `curriculum/sdr/rf-calculation-exercises.md`
- `curriculum/sdr/rf-reference-sheet.md`
- `docs/guides/rf-planning-guide.md`

**Estimated Effort**: 4-5 hours agent time

---

#### Agent 6-4: TEMPEST Demonstration Design

**Objective**: Design a safe, legal, educational TEMPEST demonstration using the HackRF PortaPack.

**Input Requirements**:
- HackRF H4M PortaPack (hardware)
- Target display for emanation capture (CRT ideal, LCD works with some setups)
- Understanding of legal boundaries

**Work Items**:
1. TEMPEST background document:
   - Historical overview (NSA TEMPEST program, Van Eck phreaking)
   - Physical principles (electromagnetic emanation from digital circuits)
   - Modern relevance (EMSEC, side-channel attacks)
   - Legal framework: receiving unintentional emanations is generally legal; using them to intercept communications may not be
2. Demonstration design:
   - **Setup**: Controlled environment, own equipment only
   - **Transmitter**: High-contrast pattern displayed on test monitor (black/white stripes)
   - **Receiver**: HackRF + PortaPack in spectrum analyzer or AM demodulation mode
   - **Frequency**: Target the pixel clock frequency of the display
   - **Visualization**: Show correlation between display content and received signal
   - **Distance**: Start close (1 meter), increase to show attenuation
3. Shielding demonstration:
   - Show signal before and after shielding
   - Types of shielding: Faraday cage, conductive film, distance
   - Cost-effectiveness of various countermeasures
4. Safety and ethics:
   - ONLY demonstrate on own equipment
   - Never attempt to capture emanations from others' equipment
   - Discuss legal and ethical implications
   - Guest speaker opportunity: invite infosec professional

**Output Artifacts**:
- `curriculum/sdr/lab-07-tempest-demo.md` (detailed version)
- `curriculum/sdr/tempest-background.md`
- `curriculum/sdr/tempest-setup-guide.md`
- Equipment list and setup diagram
- Expected results with example spectrograms

**Estimated Effort**: 3-4 hours agent time

---

### Sequential Dependencies

```
Week 5 Complete
  + Security audit passed
  + Network operational and secure
  + HackRF hardware available
      |
      v
  All Week 6 agents can run in parallel:
  Agent 6-1 (HackRF Curriculum) ────┐
  Agent 6-2 (LoRa Deep Dive) ───────┤── All independent
  Agent 6-3 (RF Calculators) ────────┤
  Agent 6-4 (TEMPEST Demo) ─────────┘
      |
      v
  [USER REVIEW] Review all curriculum for accuracy
  [USER REVIEW] Test labs with actual HackRF hardware
  [USER DECISION] Finalize curriculum for Bates course offering
      |
      v
  Week 7 begins
```

### Go/No-Go Criteria for Week 7

| Criterion | Required? | Verification |
|-----------|-----------|-------------|
| At least 6 SDR lab modules complete | **Yes** | Lab documents in curriculum/sdr/ |
| Labs tested with real HackRF hardware | **Yes** | User verified each lab works |
| LoRa protocol reference complete | **Yes** | Document reviewed for accuracy |
| RF calculation tools produce correct results | **Yes** | Validated against known values |
| All content reviewed for legal/safety accuracy | **Yes** | User sign-off |
| TEMPEST demo tested safely | No (can demo in Week 8) | Setup guide complete |
| Instructor guide complete | No (nice to have for Week 7) | Document exists |

### Gap Analysis Directives

1. **HackRF + LoRa capture feasibility**: Can the HackRF actually demodulate LoRa CSS signals in real time, or only capture raw I/Q for offline analysis? This affects Lab 4 design.
2. **GNURadio LoRa blocks**: Are there maintained GNURadio blocks for LoRa demodulation? (gr-lora, gr-lora_sdr) Evaluate their current state.
3. **Bates College academic calendar**: When do courses start/end? Can this curriculum slot into an existing course or does it need to be a standalone workshop?
4. **PortaPack Mayhem LoRa capabilities**: Does the latest Mayhem firmware have a LoRa receive/analyze mode, or does LoRa analysis require GNURadio on a laptop?
5. **TEMPEST legal review**: Get a definitive answer on the legality of TEMPEST demonstrations for educational purposes in Maine.

### User Decision Points

| Decision | Deadline | Impact if Delayed |
|----------|----------|-------------------|
| Curriculum depth (workshop vs. semester course) | Start of Week 6 | Affects content volume |
| Target audience prerequisites | Start of Week 6 | Affects content level |
| Bates College partnership status | Week 6 | Affects delivery timeline |
| HackRF firmware version (Mayhem vs. other) | Start of Week 6 | Affects lab procedures |
| TEMPEST demo: include or defer? | Mid-Week 6 | Affects lab count |

---

## Week 7: Documentation and Community

**Theme**: Complete all documentation, build community onboarding materials, prepare outreach

**Duration**: 5-7 days
**Prerequisites**: All technical systems operational, curriculum drafted, security review complete

### Parallel Agent Tasks (5 agents)

#### Agent 7-1: Per-Device Setup Guides

**Objective**: Create comprehensive, beginner-friendly setup guides for every device type in the fleet.

**Input Requirements**:
- Tested firmware flashing procedures from Week 2
- Configuration profiles from Week 2
- Photos of each device type
- Common troubleshooting issues encountered during testing

**Work Items**:
1. Per device, one complete guide:
   - **G2 Base Station Guide**: Unboxing, flashing, configuring as router, antenna attachment, enclosure assembly, deployment
   - **T-Deck Pro (Full) Guide**: Unboxing, flashing, configuration, keyboard shortcuts, GPS usage, battery management
   - **T-Deck Pro (E-Ink) Guide**: Same as above + e-ink-specific UI notes, display refresh behavior
   - **MeshAdv-Mini Guide**: Flashing, configuration, deployment options (window mount, vehicle, portable)
   - **MQTT Gateway Guide**: Flashing, WiFi setup, MQTT configuration, testing
   - **HackRF H4M Guide**: Firmware update, basic usage, safety warnings, pairing with curriculum labs
2. Each guide includes:
   - Bill of materials (what's in the box, what you need additionally)
   - Step-by-step with photos/screenshots
   - Troubleshooting section (top 5 issues)
   - Quick reference card (printable 1-page summary)
   - QR code linking to online version
3. Beginner-friendly language:
   - Define all technical terms on first use
   - Link to glossary
   - "What to do if..." decision tree for common situations
4. Print-ready formatting:
   - Guides should render well as PDF for workshop handouts
   - Include page breaks at logical sections

**Output Artifacts**:
- `docs/devices/g2-base-station.md`
- `docs/devices/tdeck-pro-full.md`
- `docs/devices/tdeck-pro-eink.md`
- `docs/devices/meshadv-mini.md`
- `docs/devices/mqtt-gateway.md`
- `docs/devices/hackrf-h4m.md`
- `docs/devices/glossary.md`
- Quick reference card PDFs (if tooling supports)

**Estimated Effort**: 6-8 hours agent time

---

#### Agent 7-2: GitHub Pages Content Build-Out

**Objective**: Populate the GitHub Pages site with all documentation, guides, and curriculum content from Weeks 1-6.

**Input Requirements**:
- All documentation artifacts from previous weeks
- Site skeleton from Week 1
- Photos, diagrams, and maps

**Work Items**:
1. Content migration and formatting:
   - Move all docs/ content into proper Jekyll structure
   - Ensure consistent formatting, cross-links, and navigation
   - Add breadcrumbs and "next/previous" navigation
   - Add search functionality (lunr.js or similar)
2. Landing page enhancement:
   - Project overview with compelling description
   - Coverage map (even if approximate)
   - "Get Involved" call to action with clear steps
   - Device showcase with photos
   - FAQ section
3. Architecture section:
   - All ADRs indexed and linked
   - Network topology diagram (interactive if possible)
   - Protocol comparison
   - Security overview (public-appropriate)
4. Guides section:
   - All device guides
   - Bridge setup guides
   - Monitoring guide
   - Contributing guide
5. Curriculum section:
   - SDR lab index
   - Mesh basics
   - Security/TAILS guide
   - Prerequisites and schedule
6. Community section:
   - How to join the mesh
   - Meeting schedule (placeholder)
   - Contact information
   - Code of conduct
   - License (recommend MIT or Apache 2.0 for code, CC-BY for docs)

**Output Artifacts**:
- Fully populated GitHub Pages site
- All pages accessible and cross-linked
- Mobile-responsive
- Search functional
- SEO metadata on all pages

**Estimated Effort**: 5-7 hours agent time

---

#### Agent 7-3: Community Onboarding Materials

**Objective**: Create materials for non-technical community members to understand and join the mesh network.

**Input Requirements**:
- Network operational and accepting new members
- Device availability for community members (can they buy their own? Loaner program?)
- Community demographics (Lewiston-Auburn is diverse: Somali, French-speaking, English)

**Work Items**:
1. Community overview document:
   - What is LA-Mesh? (Plain English, no jargon)
   - Why does it exist? (Community resilience, emergency communication, digital equity)
   - Who is it for? (Everyone in L-A area)
   - How do I join? (Step-by-step)
   - What does it cost? ($30-50 for a basic device)
   - Is it legal? (Yes, uses unlicensed ISM band)
   - Is it private? (Explain encryption in simple terms)
2. Device recommendation guide for new members:
   - Budget option: [cheapest compatible device]
   - Recommended option: [best value device]
   - Premium option: [T-Deck Pro for power users]
   - Where to buy (with links)
3. Quick start guide:
   - Buy device
   - Flash firmware (or attend flash party)
   - Configure (or attend config party)
   - Join the mesh
   - Send your first message
4. Community event planning:
   - Flash party: bring your device, we'll flash it
   - Mesh walk: test the network while exploring the neighborhood
   - SDR workshop: learn about radio with HackRF
   - Encryption workshop: learn GPG basics
5. Multilingual consideration:
   - At minimum: English
   - Desirable: French, Somali translations of key documents
   - Community translator outreach plan
6. Flyer/poster design brief:
   - One-page flyer for community boards, coffee shops, library
   - QR code to website
   - Contact information
   - Meeting time/place

**Output Artifacts**:
- `docs/community/what-is-la-mesh.md`
- `docs/community/how-to-join.md`
- `docs/community/device-buying-guide.md`
- `docs/community/quick-start.md`
- `docs/community/events-plan.md`
- `docs/community/code-of-conduct.md`
- `docs/community/flyer-content.md` (content for designer to lay out)
- Translation plan document

**Estimated Effort**: 4-5 hours agent time

---

#### Agent 7-4: Curriculum Finalization and Packaging

**Objective**: Finalize all curriculum materials and package them for delivery.

**Input Requirements**:
- All curriculum drafts from Weeks 5-6
- Instructor feedback (if available)
- Bates College course format requirements (if partnering)

**Work Items**:
1. Curriculum review and polish:
   - Consistency pass across all lab documents
   - Technical accuracy review
   - Grammar and clarity editing
   - Ensure all prerequisites are clearly stated
   - Verify all tools/software referenced are in the Nix flake
2. Syllabus creation:
   - 8-session course outline (one lab per session, 2-3 hours each)
   - Alternative: 2-day intensive workshop format
   - Alternative: Self-paced online format
   - Prerequisites checklist
   - Assessment criteria (if academic credit)
3. Instructor materials:
   - Instructor guide with teaching notes per lab
   - Answer keys for exercises
   - Common student questions and answers
   - Equipment setup checklist per lab
   - Backup plans for when things go wrong
4. Student materials:
   - Student workbook (all labs compiled)
   - Reference card set (key formulas, unit conversions, FCC rules)
   - Resource list (books, websites, communities for further learning)
5. Packaging:
   - All materials accessible via GitHub Pages
   - Downloadable PDF compilation
   - Offline-capable version (for TAILS or air-gapped environments)

**Output Artifacts**:
- Finalized `curriculum/` directory
- `curriculum/syllabus.md`
- `curriculum/instructor-guide.md`
- `curriculum/student-workbook.md` (compiled)
- `curriculum/reference-cards.md`
- `curriculum/resources.md`
- PDF versions (if tooling supports)

**Estimated Effort**: 4-5 hours agent time

---

#### Agent 7-5: Operations Runbook

**Objective**: Create the complete operational documentation for maintaining the mesh network.

**Input Requirements**:
- All infrastructure documentation from previous weeks
- Incident response plan from Week 5
- Monitoring setup from Week 4

**Work Items**:
1. Daily operations:
   - Morning check: verify all nodes online via dashboard
   - Review any alerts
   - Message throughput normal?
2. Weekly operations:
   - Battery status check for solar-powered nodes
   - Firmware update check
   - Review message logs for issues
   - Backup configurations
3. Monthly operations:
   - Physical inspection of outdoor nodes
   - Antenna connections check
   - Enclosure integrity check
   - PSK rotation (if on monthly schedule)
   - Performance trend analysis
4. Incident procedures:
   - Node offline troubleshooting tree
   - Signal quality degradation troubleshooting
   - Bridge service restart procedures
   - MQTT broker restart procedure
   - Emergency PSK rotation
5. Scaling procedures:
   - Adding a new fixed node
   - Onboarding a new community member
   - Adding a new bridge type
   - Expanding coverage area
6. Knowledge transfer:
   - How to train a new operator
   - Minimum knowledge requirements for operators
   - Access control: who has what permissions

**Output Artifacts**:
- `docs/operations/daily-checklist.md`
- `docs/operations/weekly-checklist.md`
- `docs/operations/monthly-checklist.md`
- `docs/operations/troubleshooting-guide.md`
- `docs/operations/scaling-guide.md`
- `docs/operations/operator-onboarding.md`
- `docs/operations/runbook.md` (consolidated)

**Estimated Effort**: 4-5 hours agent time

---

### Sequential Dependencies

```
Week 6 Complete
  + All curriculum drafted
  + All systems operational
  + Security reviewed
      |
      v
  Agent 7-1 (Device Guides) ────────────┐
  Agent 7-3 (Community Onboarding) ──────┤── Can start immediately
  Agent 7-4 (Curriculum Finalization) ───┤
  Agent 7-5 (Operations Runbook) ────────┘
      |
      v
  Agent 7-1, 7-3, 7-4, 7-5 outputs feed:
  Agent 7-2 (GitHub Pages Build-Out) ── Needs all content to build site
      |
      v
  [USER REVIEW] Complete documentation review
  [USER REVIEW] Community materials tone and accuracy
  [USER DECISION] Approve for community distribution
  [USER ACTION] Begin community outreach (posters, social media, etc.)
      |
      v
  Week 8 begins
```

### Go/No-Go Criteria for Week 8

| Criterion | Required? | Verification |
|-----------|-----------|-------------|
| All device setup guides complete and tested | **Yes** | Each guide followed by a second person |
| GitHub Pages site fully populated | **Yes** | All pages render correctly |
| Community onboarding materials reviewed | **Yes** | Non-technical person can follow quick start |
| Curriculum finalized | **Yes** | All labs complete and instructor guide done |
| Operations runbook complete | **Yes** | Operator can use runbook independently |
| Code of conduct published | **Yes** | Linked from main page |
| License chosen and applied | **Yes** | LICENSE file in repo, license headers in code |

### Gap Analysis Directives

1. **Accessibility audit**: Are the docs accessible to screen readers? Color contrast? Alt text on images?
2. **Translation resources**: Are there Somali or French speakers in the Bates College community who could help translate key documents?
3. **Print shop costs**: What would it cost to print flyers, quick reference cards, and workshop handouts?
4. **Community meeting venues**: Library, community center, Bates College spaces available for mesh workshops?
5. **Liability considerations**: Does the project need any legal protections (disclaimer, liability waiver for workshop participants)?

### User Decision Points

| Decision | Deadline | Impact if Delayed |
|----------|----------|-------------------|
| Community outreach timing (soft launch vs. hard launch) | Start of Week 7 | Affects materials urgency |
| Multilingual translation: do it now or later? | Mid-Week 7 | Affects inclusivity at launch |
| License choice (MIT, Apache 2.0, GPL, CC-BY) | Start of Week 7 | Blocks code publication |
| Community code of conduct adoption | Mid-Week 7 | Blocks community page |
| Bates College partnership formalized? | End of Week 7 | Affects curriculum delivery |

---

## Week 8: Integration Testing and Launch Prep

**Theme**: Full system integration test, community beta test, documentation review, launch readiness

**Duration**: 5-7 days
**Prerequisites**: All documentation complete, all systems operational, community materials ready

### Parallel Agent Tasks (5 agents)

#### Agent 8-1: Full Network Integration Test

**Objective**: Execute a comprehensive end-to-end integration test of the entire LA-Mesh system.

**Input Requirements**:
- All nodes deployed (or at least positioned for testing)
- All bridges operational
- MQTT monitoring active
- At least 2 non-operator testers available

**Work Items**:
1. Integration test plan:
   - **Test 1: Full mesh connectivity**
     * Every node can reach every other node (directly or via relay)
     * Measure end-to-end latency for worst-case path
     * Verify hop count for each node pair
   - **Test 2: SMS bridge end-to-end**
     * External phone -> SMS -> bridge -> mesh -> all nodes
     * Mesh node -> bridge -> SMS -> external phone
     * Multiple simultaneous SMS messages
   - **Test 3: Email/GPG bridge end-to-end**
     * Signed email -> bridge -> mesh -> all nodes (shows VERIFIED)
     * Unsigned email -> bridge -> mesh (shows UNVERIFIED or rejected)
     * Mesh -> bridge -> signed email -> recipient
   - **Test 4: Monitoring dashboard**
     * All nodes appear on dashboard
     * Status updates in real-time
     * Historical data accessible
   - **Test 5: Failure scenarios**
     * Kill one relay node -> verify mesh re-routes
     * Kill MQTT gateway -> verify mesh still works locally
     * Kill bridge server -> verify mesh unaffected
     * Power cycle all nodes -> verify recovery
   - **Test 6: Load test**
     * Send maximum sustained message rate
     * Identify bottlenecks
     * Document capacity limits
   - **Test 7: Security verification**
     * Attempt to join without PSK -> should fail
     * Attempt to read MQTT without auth -> should fail
     * Verify encryption on captured packets
   - **Test 8: New user onboarding**
     * Give a fresh device and quick start guide to a non-operator
     * Observe: can they set up and join the mesh independently?
     * Document friction points
2. Test execution and data collection
3. Bug triage: critical, major, minor classification
4. Fix critical and major bugs before beta

**Output Artifacts**:
- `docs/testing/integration-test-plan.md`
- `docs/testing/integration-test-results.md`
- Bug reports filed as GitHub issues
- Performance baseline document
- Go/no-go recommendation for beta

**Estimated Effort**: 6-8 hours (requires physical testing)

---

#### Agent 8-2: Community Beta Test Coordination

**Objective**: Run a controlled beta test with 5-10 community members.

**Input Requirements**:
- 5-10 beta testers recruited (mix of technical and non-technical)
- Devices available for testers (loaner or purchased)
- Feedback collection mechanism
- Integration test passing (from Agent 8-1, or at least no critical bugs)

**Work Items**:
1. Beta test plan:
   - Duration: 3-5 days within Week 8
   - Scope: basic messaging, coverage testing, onboarding experience
   - Feedback form: Google Form, GitHub issue, or paper form
   - Support channel: Signal group, email, or in-person office hours
2. Beta tester onboarding:
   - Give each tester a device (pre-flashed or with flash instructions)
   - Walk through quick start guide
   - Explain what to test and how to report issues
   - Set expectations: this is beta, things may not work perfectly
3. Feedback categories:
   - Ease of setup (1-5 scale + comments)
   - Message delivery reliability
   - Coverage in their area
   - Documentation clarity
   - Feature requests
   - Bugs encountered
4. Daily check-ins during beta:
   - Monitor dashboard for issues
   - Check in with testers
   - Quick-fix any blocking issues
5. Beta report:
   - Summarize feedback
   - Categorize issues
   - Prioritize fixes
   - Recommendation: ready for launch or needs another cycle?

**Output Artifacts**:
- `docs/testing/beta-test-plan.md`
- `docs/testing/beta-feedback-form.md`
- `docs/testing/beta-test-report.md`
- GitHub issues for all bugs and feature requests
- Go/no-go recommendation for public launch

**Estimated Effort**: 4-5 hours agent time + ongoing beta support

---

#### Agent 8-3: Documentation Final Review

**Objective**: Complete a final review of all documentation for accuracy, completeness, and consistency.

**Input Requirements**:
- All docs from Weeks 1-7
- Integration test results (may require doc updates)
- Beta feedback (may identify doc gaps)

**Work Items**:
1. Accuracy review:
   - All technical procedures still work with current firmware/configs
   - All links resolve (no broken links)
   - All screenshots/photos match current UI
   - All configuration examples match current format
2. Completeness review:
   - Every device type has a complete guide
   - Every system has operational documentation
   - Every decision has an ADR
   - Glossary covers all technical terms used
3. Consistency review:
   - Consistent terminology throughout
   - Consistent formatting (headings, code blocks, lists)
   - Consistent voice and tone
   - Consistent level of detail
4. Fresh-eyes review:
   - Have someone unfamiliar with the project read the quick start guide
   - Have a technical person review the architecture docs
   - Have a non-technical person review the community docs
5. Fix all identified issues

**Output Artifacts**:
- `docs/testing/documentation-review-checklist.md`
- All docs updated with fixes
- Link audit report
- Sign-off that docs are ready for public consumption

**Estimated Effort**: 3-4 hours agent time

---

#### Agent 8-4: Launch Readiness Assessment

**Objective**: Formal assessment of whether LA-Mesh is ready for public launch.

**Input Requirements**:
- Integration test results
- Beta test results
- Documentation review results
- All go/no-go criteria from previous weeks

**Work Items**:
1. Readiness checklist:
   - [ ] All fixed nodes deployed and operational
   - [ ] MQTT bridge operational and monitored
   - [ ] SMS bridge operational
   - [ ] Email/GPG bridge operational
   - [ ] All channels configured with proper encryption
   - [ ] Monitoring dashboard live
   - [ ] Incident response plan in place
   - [ ] Operations runbook complete
   - [ ] All documentation published on GitHub Pages
   - [ ] Community onboarding materials ready
   - [ ] Beta test feedback addressed
   - [ ] No critical bugs open
   - [ ] FCC compliance verified
   - [ ] Code of conduct published
   - [ ] License applied
   - [ ] At least 2 trained operators
   - [ ] Backup operator designated
   - [ ] PSK distribution method operational
   - [ ] Physical node access documented
2. Risk assessment:
   - What could go wrong at launch?
   - What is the fallback plan?
   - Who is on-call for the first week post-launch?
3. Launch plan:
   - Soft launch (invite-only, gradual expansion) vs. hard launch (public announcement)
   - Communication channels for launch announcement
   - Media/press consideration
   - Social media plan
4. Post-launch plan:
   - First 30 days: weekly operator meetings, daily monitoring
   - 30-60 days: bi-weekly meetings, optimizations based on usage data
   - 60-90 days: community governance structure, expansion planning

**Output Artifacts**:
- `docs/operations/launch-readiness-checklist.md`
- `docs/operations/launch-plan.md`
- `docs/operations/post-launch-plan.md`
- Final go/no-go recommendation

**Estimated Effort**: 3-4 hours agent time

---

#### Agent 8-5: Future Roadmap and Sustainability Plan

**Objective**: Document the path forward after initial launch, including sustainability and growth.

**Input Requirements**:
- Lessons learned from all 8 weeks
- Community feedback from beta
- Technical debt inventory
- Feature requests collected

**Work Items**:
1. Technical roadmap:
   - Phase 2 coverage expansion (additional node sites)
   - MeshCore re-evaluation (if ecosystem matures)
   - Additional bridge types (Matrix, Signal, Discord)
   - Sensor network integration (environmental monitoring)
   - Emergency alert system integration
   - Mesh-to-internet gateway improvements
2. Curriculum roadmap:
   - Advanced SDR course
   - Amateur radio licensing support (Technician class)
   - Network engineering fundamentals
   - Cybersecurity course using mesh as lab environment
3. Community sustainability:
   - Governance model (community council? Rotating operators?)
   - Funding sources (grants, donations, Bates College support)
   - Hardware fund for device lending/subsidizing
   - Regular maintenance volunteer schedule
   - Partnership development (other colleges, community orgs)
4. Technical debt:
   - Items deferred during 8-week sprint
   - Code quality improvements
   - Test coverage gaps
   - Documentation gaps identified but not filled
5. Metrics and success criteria:
   - Number of active nodes
   - Number of community members
   - Message volume trends
   - Coverage area growth
   - Workshop attendance
   - Student engagement metrics (if Bates partnership)

**Output Artifacts**:
- `docs/roadmap.md`
- `docs/sustainability-plan.md`
- `docs/technical-debt.md`
- GitHub project board with future milestones

**Estimated Effort**: 3-4 hours agent time

---

### Sequential Dependencies

```
Week 7 Complete
  + All documentation ready
  + All systems operational
  + Community materials approved
      |
      v
  Agent 8-1 (Integration Test) ─────────────┐
  Agent 8-3 (Doc Review) ───────────────────┤── Start immediately
  Agent 8-5 (Roadmap) ──────────────────────┘
      |
      v
  Agent 8-1 results (no critical bugs) gates:
  Agent 8-2 (Community Beta) ─── Cannot start until integration passes
      |
      v
  Agent 8-2 + 8-3 results feed:
  Agent 8-4 (Launch Readiness) ── Final assessment needs all inputs
      |
      v
  [USER REVIEW] Launch readiness checklist
  [USER DECISION] Go/No-Go for public launch
  [USER ACTION] Execute launch plan
      |
      v
  POST-LAUNCH: Follow post-launch plan from Agent 8-4
```

### Go/No-Go Criteria for Launch

| Criterion | Required? | Verification |
|-----------|-----------|-------------|
| Integration test: no critical failures | **Yes** | Test results document |
| Beta test: positive feedback, no blockers | **Yes** | Beta report |
| All documentation reviewed and published | **Yes** | Review checklist complete |
| At least 4 fixed nodes operational | **Yes** | Dashboard shows all green |
| SMS bridge working | No (can launch without) | SMS test passing |
| Email/GPG bridge working | No (can launch without) | Email test passing |
| Monitoring dashboard accessible | **Yes** | Dashboard URL loads |
| Incident response plan in place | **Yes** | Plan document exists, operators trained |
| At least 2 trained operators | **Yes** | Operators can perform runbook tasks |
| Community materials distributed | **Yes** | Flyers posted, website live |
| No open critical security issues | **Yes** | Security audit clean |
| FCC compliance verified | **Yes** | EIRP calculations documented |
| Legal review (if applicable) | No (nice to have) | Lawyer reviewed, or self-assessed |

### Gap Analysis Directives

1. **Launch timing**: Is there a local event (community fair, college orientation, etc.) that would be ideal for a public launch?
2. **Media strategy**: Should there be a press release? Local newspaper, college paper?
3. **Sustainability funding**: Are there grants available for community mesh networks? (Mozilla, Internet Society, EFF, etc.)
4. **Liability insurance**: Does the project need any liability coverage for deployed hardware on rooftops?
5. **Domain name**: Secure a proper domain (lamesh.org, la-mesh.net, etc.) before launch?

### User Decision Points

| Decision | Deadline | Impact if Delayed |
|----------|----------|-------------------|
| **LAUNCH GO/NO-GO** | End of Week 8 | Defines project completion |
| Soft launch vs. hard launch | End of Week 8 | Affects outreach intensity |
| Post-launch operator schedule | End of Week 8 | Affects operational readiness |
| Governance model selection | Post-launch (30 days) | Affects long-term sustainability |
| Expansion priorities | Post-launch (60 days) | Informs Phase 2 planning |

---

## Risk Register

| ID | Risk | Likelihood | Impact | Mitigation | Owner |
|----|------|-----------|--------|------------|-------|
| R1 | Hardware delivery delay (AliExpress) | **High** | High | Order from domestic vendors (Rokland, Amazon) as backup; order in Week 0 | User |
| R2 | T-Deck Pro firmware instability | **Medium** | Medium | Have fallback devices (G2, standard T-Deck); test extensively in Week 2 | Agent 2-3 |
| R3 | Rooftop/tower access denied | **Medium** | High | Identify 2x more candidate sites than needed; have portable/temporary options | User |
| R4 | MeshCore/Meshtastic decision paralysis | **Low** | High | Force decision at end of Week 1; default to Meshtastic if undecided | User |
| R5 | Insufficient coverage in target area | **Medium** | Medium | Plan for more nodes than minimum; use directional antennas for long links | Agent 3-1 |
| R6 | Maine winter weather damages outdoor nodes | **Medium** | Medium | IP65+ enclosures, temperature-rated batteries, spring maintenance plan | Agent 3-2 |
| R7 | SMS bridge cost overrun | **Low** | Low | Set monthly spending cap on SMS service; monitor usage | Agent 4-1 |
| R8 | Community engagement lower than expected | **Medium** | Medium | Partner with existing community orgs; Bates College provides student base | Agent 7-3 |
| R9 | Security vulnerability discovered post-deploy | **Low** | High | Incident response plan; ability to rotate PSKs quickly; monitoring | Agent 5-5 |
| R10 | Key person dependency (single operator) | **Medium** | High | Train at least 2 operators; document everything; share access credentials securely | Agent 7-5 |
| R11 | FCC compliance issue | **Low** | High | Calculate EIRP for every node; use conservative power settings; document compliance | Agent 6-3 |
| R12 | Bates College partnership falls through | **Medium** | Medium | Project is viable without Bates; focus on community deployment | User |
| R13 | HackRF arrives too late for Week 6 curriculum | **Medium** | Low | Write curriculum first, test with hardware when available; Week 6 is flexible | Agent 6-1 |
| R14 | MQTT broker reliability (self-hosted) | **Medium** | Medium | Use managed MQTT service, or deploy on reliable infrastructure | Agent 3-4 |

---

## Decision Log Template

Use this template to record all major decisions throughout the project.

```markdown
### Decision: [Title]

**Date**: YYYY-MM-DD
**Decision Maker**: [Name]
**Status**: Proposed | Accepted | Superseded | Deprecated

**Context**: [Why is this decision needed?]

**Options Considered**:
1. [Option A] -- Pros: ... Cons: ...
2. [Option B] -- Pros: ... Cons: ...
3. [Option C] -- Pros: ... Cons: ...

**Decision**: [Which option was chosen]

**Rationale**: [Why this option was chosen]

**Consequences**: [What changes as a result]

**Review Date**: [When to revisit this decision]
```

---

## Community Engagement Timeline

| Week | Activity | Audience | Purpose |
|------|----------|----------|---------|
| 1 | Bates College facilities inquiry | Bates admin | Secure tower/rooftop access |
| 2 | (Internal) | Project team | Device bring-up, no community activity |
| 3 | Informal outreach to potential beta testers | Friends, colleagues | Identify 5-10 willing beta testers |
| 4 | (Internal) | Project team | Bridge development |
| 5 | (Internal) | Project team | Security hardening |
| 6 | SDR workshop pilot with 2-3 students | Bates students | Test curriculum, get feedback |
| 7 | Community materials posted (library, coffee shops) | L-A community | Awareness building |
| 7 | Social media announcement | Online audience | Drive website traffic |
| 8 | Beta test invitations | 5-10 testers | Controlled testing |
| 8 | Flash party event (if ready) | Beta testers | Hands-on onboarding |
| Post | Public launch announcement | L-A community | Full network availability |
| Post | First community mesh walk | All members | Network testing + social |
| Post | Monthly community meeting | All members | Governance, feedback, growth |

---

## Summary: Agent Task Count by Week

| Week | Theme | Parallel Agents | Key Blocker |
|------|-------|----------------|-------------|
| 1 | Foundation and Scaffold | 5 | Hardware orders placed |
| 2 | Firmware and Device Bring-Up | 5 | Hardware received, firmware choice confirmed |
| 3 | Network Architecture and Deployment | 5 | Rooftop access, field testing |
| 4 | Bridge and Gateway Development | 5 | MQTT operational, SMS/email accounts |
| 5 | Security and Encryption | 5 | Bridges working, GPG basics |
| 6 | SDR and RF Education | 4 | HackRF received |
| 7 | Documentation and Community | 5 | All content from prior weeks |
| 8 | Integration Testing and Launch | 5 | All systems operational |
| **Total** | | **39 agent tasks** | |

---

## Appendix A: Meshtastic CLI Quick Reference

```bash
# Device info
meshtastic --info

# Set device name
meshtastic --set-owner "LA-Mesh-G2-01"

# Set region
meshtastic --set lora.region US

# Set device role
meshtastic --set device.role ROUTER          # Fixed relay
meshtastic --set device.role CLIENT          # Mobile user
meshtastic --set device.role ROUTER_CLIENT   # Hybrid

# Channel configuration
meshtastic --ch-set name "LA-Mesh" --ch-index 0
meshtastic --ch-set psk random --ch-index 0     # Generate random PSK
meshtastic --ch-set name "Admin" --ch-index 1

# Set TX power (dBm)
meshtastic --set lora.tx_power 22

# Enable GPS
meshtastic --set position.gps_enabled true

# MQTT settings
meshtastic --set mqtt.enabled true
meshtastic --set mqtt.address mqtt.example.com
meshtastic --set mqtt.username lamesh
meshtastic --set mqtt.password <from-env>

# Export config
meshtastic --export-config > device-config.yaml

# Import config
meshtastic --configure device-config.yaml

# Send test message
meshtastic --sendtext "Hello LA-Mesh!"

# Get node list
meshtastic --nodes
```

## Appendix B: Key URLs and Resources

| Resource | URL |
|----------|-----|
| Meshtastic Firmware Releases | https://github.com/meshtastic/firmware/releases |
| Meshtastic Web Flasher | https://flasher.meshtastic.org |
| Meshtastic Python API | https://github.com/meshtastic/python |
| Meshtastic Documentation | https://meshtastic.org/docs/ |
| MeshCore Repository | https://github.com/meshcore-dev/MeshCore |
| MeshCore FAQ | https://github.com/meshcore-dev/MeshCore/blob/main/docs/faq.md |
| Aurora T-Deck Firmware | https://wrew.tech/post/a-better-t-deck-firmware-for-those-who-want-to-run-meshcore |
| LILYGO T-Deck Pro | https://lilygo.cc/products/t-deck-plus-meshtastic |
| Rokland (US Meshtastic Vendor) | https://store.rokland.com |
| mesh-api (SMS/Email Bridge) | https://github.com/mr-tbot/mesh-api |
| HackRF / PortaPack Mayhem | https://github.com/portapack-mayhem/mayhem-firmware |
| TAILS OS | https://tails.net |
| GNURadio | https://www.gnuradio.org |
| LoRa Alliance | https://lora-alliance.org |
| FCC Part 15 Rules | https://www.ecfr.gov/current/title-47/chapter-I/subchapter-A/part-15 |
