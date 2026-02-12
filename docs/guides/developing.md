# Developer Guide

**Prerequisites**: Git, Nix (recommended) or manual tool installation

---

## Quick Start

### Option A: Nix (Recommended)

```bash
# Clone the repo
git clone https://github.com/Jesssullivan/LA-Mesh.git
cd LA-Mesh

# Enter the dev shell (provides all tools)
nix develop

# Or with direnv (auto-enters shell on cd)
direnv allow

# Verify tools
just info
```

The Nix dev shell provides: meshtastic CLI, esptool.py, hackrf tools, bazelisk, just, nodejs, pnpm, git-cliff, shellcheck, ruff, and more.

### Option B: Manual Installation

```bash
# Python tools
pip install meshtastic esptool ruff

# Node tools
npm install -g pnpm

# Rust tools (optional)
cargo install just git-cliff

# Bazel
npm install -g @bazel/bazelisk
```

---

## Repository Structure

```
LA-Mesh/
├── site/              # SvelteKit documentation site
├── docs/              # Markdown documentation
│   ├── architecture/  # ADRs, topology, protocol comparison
│   ├── devices/       # Per-device documentation
│   ├── guides/        # How-to guides
│   └── research/      # Deep-dive research reports
├── configs/           # Device and channel configurations
│   ├── profiles/      # Per-device-role YAML profiles
│   ├── channels/      # Channel templates (no PSKs)
│   └── network/       # Network topology configs
├── bridges/           # SMS, email, MQTT bridge code
├── tools/             # Scripts for flash, test, configure, monitor
├── curriculum/        # Educational modules (5 levels)
├── hardware/          # Inventory, BOM, deployment guides
├── firmware/          # Firmware notes and checksums
├── scripts/           # Build and utility scripts
└── captures/          # SDR capture storage (gitignored)
```

---

## Common Tasks

### Documentation Site

```bash
# Start dev server (hot reload)
just dev

# Build for production
just build

# Preview production build
just preview
```

### Validation

```bash
# Run all checks
just check

# Individual checks
just fmt-check    # Format check (no modifications)
just fmt          # Auto-format
just nix-check    # Nix flake checks
```

### Device Management

```bash
# Get device info
just mesh-info

# See all visible nodes
just mesh-nodes

# Send a message
just mesh-send "Hello from dev!"

# Export device config
just mesh-export-config

# Apply a profile
just mesh-apply-profile station-g2-router
```

### Firmware

```bash
# Flash firmware
just flash firmware.bin

# Erase flash (factory reset at chip level)
just flash-erase

# Chip info
just flash-info
```

---

## Branch Strategy

LA-Mesh uses a simple branch model:

| Branch | Purpose |
|--------|---------|
| `main` | Production, deploys to GitHub Pages |
| `feature/*` | Feature development |
| `fix/*` | Bug fixes |

PRs target `main`. CI must pass before merge.

---

## CI/CD

### GitHub Actions Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `ci.yml` | Push/PR to main | Lint, validate, build site |
| `deploy-pages.yml` | Push to main (docs/site changes) | Deploy GitHub Pages |
| `firmware-check.yml` | Weekly cron (Monday 6 AM UTC) | Check for firmware updates |
| `security-scan.yml` | Push/PR to main | Gitleaks, ShellCheck, YAML lint |

---

## Security

### Files That Must NEVER Be Committed

- `.env` files (use `.env.template` for structure)
- PSK values (channel encryption keys)
- API keys (Twilio, SMTP, MQTT credentials)
- Private keys (SSH, GPG, TLS)
- `.claude/`, `CLAUDE.md`, `.mcp.json` (dev tooling, git-excluded)

### Pre-Commit Hook

The `.githooks/pre-commit` hook blocks commits containing:
- `.env` files
- Credential patterns (`*_secret*`, `*_token*`, `*.pem`, `*.key`)
- Local-only files (`.claude/`, `.githooks/`, `.gitignore`)

Enable hooks:
```bash
git config core.hooksPath .githooks
```

---

## Adding a New Device Profile

1. Copy an existing profile from `configs/profiles/`
2. Modify settings for the new device/role
3. Test on a physical device: `meshtastic --configure configs/profiles/new-profile.yaml`
4. Document the profile in `docs/guides/device-profiles.md`
5. Add to the inventory in `hardware/inventory.md`

---

## Adding Bridge Functionality

1. Create a new bridge module in `bridges/<type>/`
2. Follow the pattern of existing bridges (MQTT subscription, message parsing)
3. Create `.env.template` for credentials
4. Create systemd service file in `bridges/systemd/`
5. Document in `bridges/README.md`
6. Update `docs/architecture/` with design doc
