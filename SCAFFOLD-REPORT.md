# LA-Mesh: GitHub Pages Deployment + Bazel/Nix/Justfile Scaffold

## Research Report

**Date:** 2026-02-11
**Repo:** github.com/Jesssullivan/LA-Mesh
**Status:** Repository initialized locally (no commits pushed yet)
**Existing local files:** `.gitignore`, `.env.template`, `.githooks/pre-commit`, `.githooks/prepare-commit-msg`

---

## 1. jesssullivan.github.io Repository Analysis

### Architecture

| Property | Value |
|----------|-------|
| **Framework** | SvelteKit 5 (Svelte 5 with runes) |
| **Adapter** | `@sveltejs/adapter-static` (full SSG) |
| **CSS** | Tailwind CSS 4 + Skeleton UI 4 |
| **Content** | MDsveX (Markdown in Svelte) with Shiki syntax highlighting |
| **Search** | Pagefind (client-side search, post-build indexed) |
| **Comments** | Giscus (GitHub Discussions-backed) |
| **Changelog** | git-cliff (conventional commits) |
| **Testing** | Vitest (unit) + Playwright (E2E) + Lighthouse CI |
| **Linting** | ESLint + Prettier |
| **Task Runner** | Justfile |
| **Node** | 22 (via `.nvmrc`) |
| **Package Manager** | npm |
| **Custom Domain** | transscendsurvival.org |

### GitHub Pages Deployment Pattern

The site uses the **GitHub Actions artifact-based deployment** (not `gh-pages` branch):

```yaml
# .github/workflows/deploy-pages.yml
permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  build:
    steps:
      - npm ci
      - npm run build
      - actions/upload-pages-artifact (path: build)
  deploy:
    needs: build
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - actions/deploy-pages@v4
```

**Key observations:**
- Uses `actions/upload-pages-artifact@v3` + `actions/deploy-pages@v4` (modern pattern, no gh-pages branch)
- Concurrency group `pages` with `cancel-in-progress: false`
- Separate CI workflow validates PRs (lint, type-check, unit tests, build, E2E, Lighthouse)
- SvelteKit `adapter-static` outputs to `build/` directory with `precompress: true`
- `paths.base: ''` since it's a user site (root domain)

### Justfile Pattern

Clean, well-organized with sections:
- Development (`setup`, `dev`, `dev-open`)
- Building (`build`, `rebuild`, `preview`)
- Validation (`validate-frontmatter`, `check`, `test-redirects`, `test-unit`, `test-e2e`)
- Changelog (`changelog`, `changelog-preview`)
- Cleanup (`clean`, `clean-all`)
- Utilities (`sync`, `analyze`, `info`)

Uses `set dotenv-load := true` and `set shell := ["bash", "-euo", "pipefail", "-c"]`.

### .envrc Pattern (Simple)

```bash
dotenv_if_exists
PATH_add scripts
watch_file package.json
watch_file package-lock.json
export NODE_ENV="${NODE_ENV:-development}"
```

---

## 2. GloriousFlywheel Repository Analysis

### Architecture

| Property | Value |
|----------|-------|
| **Build System** | Bazel 7.4.0 (bzlmod via `MODULE.bazel`) + Nix flake |
| **IaC** | OpenTofu (Terraform-compatible) with GitLab state backend |
| **App** | SvelteKit 5 (Runner Dashboard) with Skeleton UI |
| **Docs** | SvelteKit 5 + MDsveX (separate `docs-site/` package) |
| **Container** | nix2container + rules_img (OCI) |
| **CI** | GitHub Actions (validate, pages, build-image, release) + GitLab CI |
| **Package Manager** | pnpm (monorepo with `pnpm-workspace.yaml`) |
| **Changelog** | git-cliff |
| **Dep Management** | Renovate (Nix + Bazel + npm grouping) |
| **Formatting** | treefmt-nix (nixpkgs-fmt, prettier, shfmt) |
| **Linting** | statix, deadnix (Nix), markdownlint-cli2 (Markdown) |

### Bazel Integration Pattern

**MODULE.bazel** (bzlmod, not WORKSPACE):
- `bazel_skylib`, `rules_pkg`, `rules_python`, `rules_shell`, `platforms`
- `aspect_rules_js` + `aspect_rules_ts` + `rules_nodejs` for SvelteKit
- `rules_img` for OCI container images
- `rules_nixpkgs_core` for Nix toolchain integration
- `npm.npm_translate_lock` from pnpm-lock.yaml
- Node.js 22.13.1 toolchain
- Nix packages imported: `opentofu`, `kubectl`, `yq-go`

**BUILD.bazel** (root):
- `npm_link_all_packages` at root
- `exports_files` for MODULE.bazel, flake.nix, flake.lock
- Filegroups for K8s manifests, Nix files, Tofu files
- `pkg_tar` deployment bundle

**docs-site/BUILD.bazel**:
- `js_run_binary` for production build
- `js_run_devserver` for dev server
- Sources include `../docs/**/*.md` content

**.bazelrc**:
- `--enable_bzlmod`
- `--disk_cache=~/.cache/bazel/<project>`
- `--sandbox_add_mount_pair=/nix` (critical for Nix integration)
- CI config: `--jobs=4`, no disk cache, `--color=yes`, `--curses=no`
- JS settings: `--experimental_allow_unresolved_symlinks`, `NODE_OPTIONS=--max-old-space-size=4096`
- `try-import %workspace%/user.bazelrc`

### Nix Flake Pattern

**Key elements for LA-Mesh to adopt:**
- `nixpkgs` pinned to `nixos-24.11`
- `flake-utils` for `eachDefaultSystem`
- `treefmt-nix` for formatting
- `devShells.default` with comprehensive tool list
- `devShells.ci` (lightweight, for CI jobs)
- OCI image building via `nix2container`
- `checks` for CI validation (formatting, statix, deadnix)
- `apps` for easy execution
- Bazel wrapper script: `writeShellScriptBin "bazel" 'exec ${pkgs.bazelisk}/bin/bazelisk "$@"'`

### .envrc Pattern (Comprehensive)

- `nix_direnv_version` check (use cached devShell if nix-direnv available)
- `use flake` for Nix integration
- `dotenv_if_exists` for secrets
- Environment variable exports from YAML config
- `PATH_add scripts`
- `watch_file` for flake.nix, flake.lock, .bazelversion
- Interactive shell hints
- Helper functions (`switch_env`)

### Justfile Pattern (Enterprise)

400+ lines organized into sections:
- Configuration (yaml-driven)
- Development Workflows (`check`, `check-full`, `dev`, `info`)
- Nix Commands (`nix-build`, `nix-check`, `nix-update`, `nix-show`, `nix-shell`, `nix-fmt`)
- OpenTofu Commands (`tofu-init`, `tofu-plan`, `tofu-apply`, `tofu-deploy`)
- Bazel Commands (`bazel-build`, `bazel-test`, `bazel-build-ci`, `bazel-clean`)
- Kubernetes Commands
- Formatting (`fmt`, `fmt-check`)
- Security/Linting
- CI Simulation (`ci-local`)
- Documentation Site (`docs-dev`, `docs-build`, `docs-install`)
- TeX Research (`tex`, `tex-clean`, `tex-watch`)
- Changelog

### GitHub Actions Workflows

1. **validate.yml** - PR/push validation: org config, OpenTofu modules (matrix), stacks (matrix), app tests, markdown lint
2. **pages.yml** - Docs deployment: pnpm, `DOCS_BASE_PATH` env var for project pages prefix
3. **build-image.yml** - Container builds: GHCR push via docker/build-push-action
4. **release.yml** - Tag-triggered releases: GitHub Release creation + container push

### Notable Pattern: llms.txt Generation

The `docs-site/scripts/generate-llms-txt.js` prebuild script collects all `docs/**/*.md` files and generates a single `static/llms.txt` for LLM context consumption. This is a forward-thinking pattern LA-Mesh should adopt.

---

## 3. GitHub Pages for LA-Mesh (Project Site)

### Project Site vs User Site

| Aspect | User Site (jesssullivan.github.io) | Project Site (LA-Mesh) |
|--------|-------------------------------------|------------------------|
| URL | `https://jesssullivan.github.io/` | `https://jesssullivan.github.io/LA-Mesh/` |
| Branch | any (Actions-based) | any (Actions-based) |
| `paths.base` | `''` (empty) | `'/LA-Mesh'` |
| Custom domain | transscendsurvival.org | Optional (e.g., mesh.transscendsurvival.org) |
| Adapter | adapter-static | adapter-static |

**Critical:** The SvelteKit config must set `paths.base` to `/LA-Mesh` for project sites. GloriousFlywheel handles this with `DOCS_BASE_PATH` env var.

### Recommended Static Site Generator: SvelteKit + MDsveX

**Recommendation: SvelteKit + MDsveX + Skeleton UI** (matching the existing ecosystem)

**Rationale:**
1. **Consistency** - Both jesssullivan.github.io and GloriousFlywheel use this exact stack
2. **Proven patterns** - GitHub Pages deployment, Bazel BUILD files, Justfile recipes all exist
3. **Rich features** - Mermaid diagrams (for mesh topology), Shiki code highlighting, Tailwind
4. **Extensibility** - Can embed interactive components (mesh topology visualizer, device configurator)
5. **pnpm monorepo** - Fits naturally alongside other packages (scripts, tools)

**Alternatives considered:**

| Generator | Pros | Cons for LA-Mesh |
|-----------|------|------------------|
| MkDocs Material | Great search, Python ecosystem fits | Different stack, no interactivity |
| mdBook | Simple, great for Rust projects | Too basic, no custom components |
| Hugo | Fast, Go-based | Different ecosystem, less interactive |
| Docusaurus | React, versioning built-in | React not Svelte, heavier |
| Zola | Fast Rust SSG | Limited plugin ecosystem |

### Custom Domain Setup

If desired, a subdomain like `mesh.transscendsurvival.org` can be configured:

1. Add `CNAME` file to `static/` with domain name
2. Configure DNS: `CNAME mesh -> jesssullivan.github.io`
3. Enable in GitHub repo Settings > Pages > Custom domain
4. Enforce HTTPS

---

## 4. Bazel Integration for LA-Mesh

### Build Targets

LA-Mesh is a mixed project (docs, firmware configs, Python scripts, shell scripts). Bazel excels at:

1. **Documentation site build** (`//site:build`, `//site:dev`)
2. **Python script validation** (`//scripts:test`)
3. **Configuration file validation** (`//configs:validate`)
4. **Deployment artifact bundling** (`//:deployment_bundle`)
5. **Markdown linting** (`//docs:lint`)

### Meshtastic Firmware and Bazel

Meshtastic firmware uses **PlatformIO** (on top of ESP-IDF) - not Bazel. Bazel should NOT attempt to build firmware. Instead:

- Firmware builds remain PlatformIO-based (or use prebuilt binaries)
- Bazel validates firmware configuration files (YAML/JSON device profiles)
- Bazel bundles firmware configs into deployment artifacts
- The Nix devShell provides PlatformIO/esptool for development

### Proposed MODULE.bazel

```starlark
module(
    name = "la-mesh",
    version = "0.1.0",
)

# Core rules
bazel_dep(name = "bazel_skylib", version = "1.8.2")
bazel_dep(name = "rules_pkg", version = "1.1.0")
bazel_dep(name = "rules_python", version = "1.4.1")
bazel_dep(name = "rules_shell", version = "0.6.0")
bazel_dep(name = "platforms", version = "0.0.10")

# Python toolchain
python = use_extension("@rules_python//python/extensions:python.bzl", "python")
python.toolchain(
    ignore_root_user_error = True,
    python_version = "3.12",
)

# JavaScript rules (for docs site)
bazel_dep(name = "aspect_rules_js", version = "2.9.2")
bazel_dep(name = "aspect_rules_ts", version = "3.8.3")
bazel_dep(name = "aspect_bazel_lib", version = "2.22.5")
bazel_dep(name = "rules_nodejs", version = "6.7.3")

# pnpm integration
npm = use_extension("@aspect_rules_js//npm:extensions.bzl", "npm", dev_dependency = True)
npm.npm_translate_lock(
    name = "npm",
    pnpm_lock = "//:pnpm-lock.yaml",
    verify_node_modules_ignored = ".bazelignore",
)
use_repo(npm, "npm")

# Node.js toolchain
node = use_extension("@rules_nodejs//nodejs:extensions.bzl", "node", dev_dependency = True)
node.toolchain(
    name = "nodejs",
    node_version = "22.13.1",
)

# Nix integration
bazel_dep(name = "rules_nixpkgs_core", version = "0.13.0")

nix_repo = use_extension("@rules_nixpkgs_core//nixpkgs:extensions.bzl", "nix_repo")
nix_repo.file(
    name = "nixpkgs",
    file = "//:flake.lock",
    file_deps = ["//:flake.nix"],
)
use_repo(nix_repo, "nixpkgs")
```

### Proposed Root BUILD.bazel

```starlark
load("@npm//:defs.bzl", "npm_link_all_packages")
load("@rules_pkg//pkg:tar.bzl", "pkg_tar")

package(default_visibility = ["//visibility:public"])

npm_link_all_packages(name = "node_modules")

exports_files([
    "MODULE.bazel",
    "flake.nix",
    "flake.lock",
])

# All documentation content
filegroup(
    name = "docs_content",
    srcs = glob(["docs/**/*.md"]),
)

# All device configuration profiles
filegroup(
    name = "device_configs",
    srcs = glob(["configs/**/*.yaml", "configs/**/*.json"]),
)

# All curriculum content
filegroup(
    name = "curriculum",
    srcs = glob(["curriculum/**"]),
)

# Nix configuration
filegroup(
    name = "nix_files",
    srcs = [
        "flake.lock",
        "flake.nix",
    ],
)

# Deployment bundle
pkg_tar(
    name = "deployment_bundle",
    srcs = [
        ":docs_content",
        ":device_configs",
        ":nix_files",
    ],
    extension = "tar.gz",
    strip_prefix = ".",
)
```

### Proposed .bazelrc

```
# LA-Mesh Bazel Configuration

# Build settings
build --jobs=auto
build --verbose_failures

# Enable Bzlmod
common --enable_bzlmod

# Disk cache
build --disk_cache=~/.cache/bazel/la-mesh

# Nix integration
build --sandbox_add_mount_pair=/nix

# Async remote cache
build --experimental_remote_cache_async
build --experimental_guard_against_concurrent_changes

# JavaScript / SvelteKit
build --experimental_allow_unresolved_symlinks
build --action_env=NODE_OPTIONS=--max-old-space-size=4096

# Test settings
test --test_output=errors
test --test_verbose_timeout_warnings

# CI configuration
build:ci --jobs=4
build:ci --disk_cache=
build:ci --color=yes
build:ci --curses=no
test:ci --test_output=all

# User overrides
try-import %workspace%/user.bazelrc
```

---

## 5. Nix Flake Design

### Available Nix Packages (Verified)

| Package | nixpkgs attribute | Purpose |
|---------|-------------------|---------|
| meshtastic-cli | `python3Packages.meshtastic` | Device management CLI |
| esptool | `esptool` | ESP32 flashing |
| platformio | `platformio` | Firmware build system |
| hackrf | `hackrf` | HackRF tools (hackrf_transfer, etc.) |
| gnuradio | `gnuradio` | SDR signal processing |
| gqrx | `gqrx` | SDR receiver GUI |
| rtl-sdr | `rtl-sdr` | RTL-SDR tools |
| bazelisk | `bazelisk` | Bazel launcher |
| nodejs 22 | `nodejs_22` | SvelteKit build |
| pnpm | `nodePackages.pnpm` | Package manager |
| just | `just` | Task runner |
| git-cliff | `git-cliff` | Changelog generation |

**Note:** The `python3Packages.meshtastic` package has a known issue (nixpkgs#318938) requiring `python3Packages.packaging` as a co-dependency. The flake should include both.

### Proposed flake.nix

```nix
{
  description = "LA-Mesh - LoRa mesh network infrastructure for southern Maine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, treefmt-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Treefmt configuration
        treefmtEval = treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          programs = {
            nixpkgs-fmt.enable = true;
            prettier.enable = true;
            shfmt.enable = true;
          };
        };

        # Bazel wrapper
        bazelWrapper = pkgs.writeShellScriptBin "bazel" ''
          exec ${pkgs.bazelisk}/bin/bazelisk "$@"
        '';

        # Meshtastic Python environment
        meshtasticPython = pkgs.python3.withPackages (ps: with ps; [
          meshtastic
          packaging
          pyserial
          protobuf
          pyyaml
          requests
          tabulate
        ]);

        # Development tools
        devTools = with pkgs; [
          # ---- Meshtastic / LoRa ----
          meshtasticPython
          esptool

          # ---- SDR / RF Analysis ----
          hackrf
          rtl-sdr
          # gnuradio  # Uncomment if needed (large dependency)

          # ---- Build Tooling ----
          bazel-buildtools
          bazelisk
          bazelWrapper
          just
          git-cliff

          # ---- Node.js / SvelteKit ----
          nodejs_22
          nodePackages.pnpm

          # ---- Nix Tooling ----
          nixpkgs-fmt
          statix
          deadnix

          # ---- Development Utilities ----
          jq
          yq-go
          direnv
          nix-direnv
          git
          gh

          # ---- Documentation ----
          # tectonic  # Uncomment for LaTeX/PDF generation
        ];

      in
      {
        # Default development shell
        devShells.default = pkgs.mkShell {
          name = "la-mesh-dev";
          packages = devTools;

          shellHook = ''
            echo "LA-Mesh Development Environment"
            echo "================================"
            echo ""
            echo "Available tools:"
            echo "  meshtastic         - Meshtastic CLI"
            echo "  esptool            - ESP32 flash tool"
            echo "  hackrf_transfer    - HackRF tools"
            echo "  just               - Task runner"
            echo "  bazel              - Build system (via bazelisk)"
            echo ""
            echo "Quick commands:"
            echo "  just               - List all tasks"
            echo "  just dev           - Start docs dev server"
            echo "  just build         - Build docs site"
            echo "  just flash         - Flash Meshtastic firmware"
            echo ""

            if command -v direnv &> /dev/null; then
              eval "$(direnv hook bash 2>/dev/null || direnv hook zsh 2>/dev/null || true)"
            fi
          '';
        };

        # CI shell (lightweight, no RF tools)
        devShells.ci = pkgs.mkShell {
          name = "la-mesh-ci";
          packages = with pkgs; [
            bazel-buildtools
            bazelisk
            bazelWrapper
            nodejs_22
            nodePackages.pnpm
            just
            git
          ];
        };

        # Checks
        checks = {
          formatting = treefmtEval.config.build.check self;
          statix = pkgs.runCommand "statix-check" { } ''
            ${pkgs.statix}/bin/statix check ${self} && touch $out
          '';
          deadnix = pkgs.runCommand "deadnix-check" { } ''
            ${pkgs.deadnix}/bin/deadnix --fail ${self} && touch $out
          '';
        };

        # Formatter
        formatter = treefmtEval.config.build.wrapper;
      }
    );
}
```

### Proposed .envrc

```bash
# LA-Mesh - direnv configuration
# ===============================
# Prerequisites: direnv, nix with flakes enabled
# Setup: direnv allow

# Nix integration (use nix-direnv if available for caching)
if has nix_direnv_version; then
  nix_direnv_version 3.0.0
  use flake
else
  use flake
fi

# Load .env file if it exists (for local secrets)
dotenv_if_exists

# Add scripts to PATH
PATH_add scripts

# Bazel cache directory
export BAZEL_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/bazel"

# Default log level
export LOG_LEVEL="${LOG_LEVEL:-INFO}"

# File watches
watch_file flake.nix
watch_file flake.lock
watch_file .bazelversion
watch_file site/package.json

# Interactive hints
if [ -t 1 ]; then
  echo ""
  echo "LA-Mesh Development Environment"
  echo "================================"
  echo ""
  echo "Quick commands:"
  echo "  just              - List all available tasks"
  echo "  just dev          - Start docs dev server"
  echo "  just info         - Show environment info"
  echo ""
fi
```

---

## 6. Justfile Design

### Proposed Justfile

```just
# LA-Mesh - Community LoRa Mesh Network for Southern Maine
# ========================================================
#
# Prerequisites:
#   - just (https://github.com/casey/just)
#   - direnv (loads Nix devShell automatically)
#   - Nix with flakes enabled
#
# Quick Start:
#   just setup    # First-time setup
#   just dev      # Start docs dev server
#   just          # List all commands

set dotenv-load := true
set shell := ["bash", "-euo", "pipefail", "-c"]

root := justfile_directory()

# List available commands
default:
    @just --list --unsorted

# =============================================================================
# Setup
# =============================================================================

# First-time setup
setup:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Setting up LA-Mesh development environment..."

    if [ ! -f .env ]; then
        echo "Creating .env from .env.template..."
        cp .env.template .env
        echo "Edit .env with your configuration"
    fi

    cd site && pnpm install
    echo ""
    echo "Setup complete! Run 'just dev' to start the docs server."

# Show environment info
info:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "LA-Mesh Environment"
    echo "==================="
    echo "Node:       $(node --version 2>/dev/null || echo 'not found')"
    echo "pnpm:       $(pnpm --version 2>/dev/null || echo 'not found')"
    echo "Bazel:      $(bazel --version 2>/dev/null | head -1 || echo 'not found')"
    echo "Meshtastic: $(meshtastic --version 2>/dev/null || echo 'not found')"
    echo "esptool:    $(esptool.py version 2>/dev/null | head -1 || echo 'not found')"
    echo "hackrf:     $(hackrf_info 2>/dev/null | head -1 || echo 'not found / not connected')"
    echo "Root:       {{root}}"

# =============================================================================
# Documentation Site
# =============================================================================

# Start docs site dev server
dev:
    cd site && pnpm dev

# Start docs dev server and open browser
dev-open:
    cd site && pnpm dev -- --open

# Build docs site for production
build:
    cd site && DOCS_BASE_PATH=/LA-Mesh pnpm build

# Preview production build
preview: build
    cd site && pnpm preview

# Install site dependencies
site-install:
    cd site && pnpm install

# Type-check the docs site
site-check:
    cd site && pnpm check

# =============================================================================
# Validation
# =============================================================================

# Run all validations
check: fmt-check nix-check site-check
    @echo "All checks passed!"

# Run full CI pipeline locally
ci: check build
    @echo "CI simulation complete!"

# =============================================================================
# Meshtastic Device Management
# =============================================================================

# Show connected Meshtastic device info
mesh-info:
    meshtastic --info

# List nodes in the mesh
mesh-nodes:
    meshtastic --nodes

# Send a test message
mesh-send message:
    meshtastic --sendtext "{{message}}"

# Export device config to YAML
mesh-export-config device="":
    #!/usr/bin/env bash
    set -euo pipefail
    DEVICE_FLAG=""
    if [ -n "{{device}}" ]; then
        DEVICE_FLAG="--port {{device}}"
    fi
    meshtastic $DEVICE_FLAG --export-config > configs/devices/export-$(date +%Y%m%d-%H%M%S).yaml
    echo "Config exported to configs/devices/"

# Apply a device profile
mesh-apply-profile profile:
    meshtastic --configure configs/profiles/{{profile}}.yaml

# Set device to client-mute mode (relay only)
mesh-set-relay:
    meshtastic --set device.role CLIENT_MUTE

# Set device channel config for LA-Mesh
mesh-set-channel:
    meshtastic --ch-set name "LA-Mesh" --ch-index 0

# =============================================================================
# Firmware
# =============================================================================

# Flash Meshtastic firmware to ESP32 device
flash firmware_file port="/dev/ttyUSB0":
    esptool.py --chip esp32 --port {{port}} write_flash 0x10000 {{firmware_file}}

# Erase ESP32 flash (factory reset)
flash-erase port="/dev/ttyUSB0":
    esptool.py --chip esp32 --port {{port}} erase_flash

# Check connected ESP32 device
flash-info port="/dev/ttyUSB0":
    esptool.py --chip auto --port {{port}} chip_id

# =============================================================================
# SDR / RF Analysis
# =============================================================================

# Capture LoRa spectrum with HackRF (915 MHz band, 2M samples)
sdr-capture duration="10" output="captures/lora-capture":
    hackrf_transfer -r {{output}}-$(date +%Y%m%d-%H%M%S).raw \
        -f 915000000 -s 2000000 -n $(({{duration}} * 2000000))

# Show HackRF device info
sdr-info:
    hackrf_info

# =============================================================================
# Nix Commands
# =============================================================================

# Run Nix flake check
nix-check:
    nix flake check

# Update flake inputs
nix-update:
    nix flake update

# Show flake outputs
nix-show:
    nix flake show

# Enter development shell (if not using direnv)
nix-shell:
    nix develop

# Format Nix files
nix-fmt:
    nix fmt

# =============================================================================
# Bazel Commands
# =============================================================================

# Build all Bazel targets
bazel-build:
    bazel build //...

# Run all Bazel tests
bazel-test:
    bazel test //...

# Build with CI config
bazel-build-ci:
    bazel build --config=ci //...

# Clean Bazel outputs
bazel-clean:
    bazel clean

# Clean everything including cache
bazel-clean-all:
    bazel clean --expunge

# =============================================================================
# Formatting
# =============================================================================

# Format all files
fmt: nix-fmt
    cd site && pnpm format 2>/dev/null || true
    @echo "All files formatted!"

# Check formatting
fmt-check:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Checking Nix formatting..."
    nix fmt -- --check . 2>/dev/null || { echo "Run 'just nix-fmt' to fix"; exit 1; }
    echo "All formatting checks passed!"

# =============================================================================
# Changelog
# =============================================================================

# Generate changelog
changelog:
    git cliff --output CHANGELOG.md

# Preview changelog
changelog-preview:
    git cliff --unreleased

# =============================================================================
# GitHub Pages Deployment (manual trigger)
# =============================================================================

# Deploy to GitHub Pages (normally handled by CI)
deploy: build
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Deployment is handled by GitHub Actions on push to main."
    echo "To trigger manually: gh workflow run deploy-pages.yml"
    echo ""
    echo "To preview locally: just preview"

# =============================================================================
# Cleanup
# =============================================================================

# Remove build artifacts
clean:
    rm -rf site/build site/.svelte-kit
    rm -rf result result-*

# Deep clean
clean-all: clean bazel-clean
    rm -rf site/node_modules .direnv/
    @echo "Deep clean complete!"
```

---

## 7. GitHub Actions CI/CD

### Workflow 1: CI (PR Validation)

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main, dev]
  pull_request:
    branches: [main]

jobs:
  validate:
    name: Validate
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: pnpm

      - run: pnpm install --frozen-lockfile

      - name: Type check
        run: cd site && pnpm check

      - name: Build
        run: cd site && DOCS_BASE_PATH=/LA-Mesh pnpm build

  lint-markdown:
    name: Lint Markdown
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Lint Markdown
        uses: DavidAnson/markdownlint-cli2-action@v20
        with:
          globs: |
            docs/**/*.md
            curriculum/**/*.md
```

### Workflow 2: Deploy Pages

```yaml
# .github/workflows/deploy-pages.yml
name: Deploy to Pages

on:
  push:
    branches: [main]
    paths:
      - docs/**
      - site/**
      - curriculum/**
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: pnpm

      - run: pnpm install --frozen-lockfile

      - name: Build site
        run: cd site && pnpm build
        env:
          DOCS_BASE_PATH: /LA-Mesh

      - uses: actions/configure-pages@v4

      - uses: actions/upload-pages-artifact@v3
        with:
          path: site/build

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

### Workflow 3: Release

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - "v*.*.*"

permissions:
  contents: write

jobs:
  create-release:
    name: Create Release
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Generate Release Notes
        id: notes
        run: |
          PREV_TAG=$(git describe --tags --abbrev=0 HEAD^ 2>/dev/null || echo "")
          if [ -z "$PREV_TAG" ]; then
            NOTES="Initial release of LA-Mesh"
          else
            NOTES=$(git log $PREV_TAG..${{ github.ref_name }} --pretty=format:"- %s" --reverse)
          fi
          echo "notes<<EOF" >> $GITHUB_OUTPUT
          echo "$NOTES" >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

      - name: Create Release
        uses: softprops/action-gh-release@v2
        with:
          name: Release ${{ github.ref_name }}
          body: |
            ## Changes

            ${{ steps.notes.outputs.notes }}

            ## Getting Started

            ```bash
            git clone https://github.com/Jesssullivan/LA-Mesh.git
            cd LA-Mesh
            just setup
            just dev
            ```
          draft: false
          prerelease: false
```

---

## 8. Proposed Repository Structure

```
LA-Mesh/
|
|-- .bazelignore              # Bazel ignore patterns
|-- .bazelrc                  # Bazel configuration
|-- .bazelversion             # Pin Bazel version (7.4.0)
|-- .envrc                    # direnv + Nix integration
|-- .env.template             # Environment variable template (EXISTS)
|-- .github/
|   |-- workflows/
|   |   |-- ci.yml            # PR validation
|   |   |-- deploy-pages.yml  # GitHub Pages deployment
|   |   `-- release.yml       # Tag-based releases
|   `-- CODEOWNERS            # Optional
|-- .githooks/                # Local-only hooks (EXISTS, gitignored)
|   |-- pre-commit
|   `-- prepare-commit-msg
|-- .gitignore                # (EXISTS - needs update for committed files)
|-- .markdownlint-cli2.yaml   # Markdown linting config
|-- .npmrc                    # pnpm config (shamefully-hoist=true)
|-- BUILD.bazel               # Root Bazel build file
|-- CHANGELOG.md              # Generated by git-cliff
|-- Justfile                  # Task runner
|-- LICENSE                   # Project license
|-- MODULE.bazel              # Bazel module config (bzlmod)
|-- WORKSPACE.bazel           # Minimal workspace file
|-- cliff.toml                # git-cliff configuration
|-- flake.lock                # Nix flake lock
|-- flake.nix                 # Nix flake
|-- package.json              # Root pnpm workspace
|-- pnpm-lock.yaml            # pnpm lockfile
|-- pnpm-workspace.yaml       # pnpm workspace config
|-- renovate.json5            # Dependency management
|
|-- configs/                  # Device configurations
|   |-- BUILD.bazel
|   |-- profiles/             # Reusable device profiles
|   |   |-- relay-node.yaml   # Solar relay node config
|   |   |-- client-node.yaml  # End-user client config
|   |   |-- router.yaml       # Router mode config
|   |   `-- bridge.yaml       # MQTT/serial bridge config
|   |-- devices/              # Specific device configs (exported)
|   |   `-- .gitkeep
|   `-- channels/             # Channel configurations
|       |-- la-mesh-primary.yaml
|       `-- la-mesh-admin.yaml
|
|-- curriculum/               # Educational material / coursework
|   |-- BUILD.bazel
|   |-- 01-intro-to-mesh/
|   |   |-- lesson.md
|   |   |-- exercises.md
|   |   `-- slides.md
|   |-- 02-lora-fundamentals/
|   |   |-- lesson.md
|   |   `-- exercises.md
|   |-- 03-meshtastic-setup/
|   |   |-- lesson.md
|   |   `-- exercises.md
|   |-- 04-network-planning/
|   |   |-- lesson.md
|   |   `-- exercises.md
|   |-- 05-solar-nodes/
|   |   |-- lesson.md
|   |   `-- exercises.md
|   |-- 06-bridge-gateway/
|   |   |-- lesson.md
|   |   `-- exercises.md
|   `-- 07-rf-analysis/
|       |-- lesson.md
|       `-- exercises.md
|
|-- docs/                     # Documentation source (Markdown)
|   |-- BUILD.bazel
|   |-- index.md              # Landing page / overview
|   |-- getting-started/
|   |   |-- quick-start.md
|   |   |-- hardware-list.md
|   |   |-- first-node.md
|   |   `-- join-network.md
|   |-- guides/
|   |   |-- solar-relay.md
|   |   |-- mqtt-bridge.md
|   |   |-- sms-bridge.md
|   |   |-- portapack-sdr.md
|   |   |-- network-planning.md
|   |   `-- troubleshooting.md
|   |-- reference/
|   |   |-- device-profiles.md
|   |   |-- channel-config.md
|   |   |-- frequency-plan.md
|   |   `-- hardware-comparison.md
|   |-- architecture/
|   |   |-- network-topology.md
|   |   |-- coverage-map.md
|   |   `-- bridge-design.md
|   `-- contributing/
|       |-- development-setup.md
|       `-- style-guide.md
|
|-- firmware/                 # Firmware-related files
|   |-- BUILD.bazel
|   |-- .gitkeep
|   |-- variants/             # Custom Meshtastic firmware variants
|   |   `-- .gitkeep
|   `-- platformio/           # PlatformIO configs for custom builds
|       `-- .gitkeep
|
|-- scripts/                  # Utility scripts
|   |-- BUILD.bazel
|   |-- flash-device.sh       # Device flashing helper
|   |-- export-config.sh      # Batch config export
|   |-- mesh-monitor.py       # Network monitoring script
|   |-- generate-llms-txt.js  # LLM context generator (prebuild)
|   `-- validate-configs.py   # Config file validation
|
|-- site/                     # SvelteKit documentation site
|   |-- BUILD.bazel
|   |-- .gitignore
|   |-- mdsvex.config.js
|   |-- package.json
|   |-- svelte.config.js
|   |-- tsconfig.json
|   |-- vite.config.ts
|   |-- scripts/
|   |   `-- generate-llms-txt.js
|   |-- src/
|   |   |-- app.css
|   |   |-- app.d.ts
|   |   |-- app.html
|   |   |-- lib/
|   |   |   |-- components/
|   |   |   |   |-- MdsvexLayout.svelte
|   |   |   |   |-- Nav.svelte
|   |   |   |   |-- MeshTopology.svelte  # Interactive mesh visualizer
|   |   |   |   `-- CoverageMap.svelte   # Coverage area map
|   |   |   `-- utils/
|   |   `-- routes/
|   |       |-- +layout.svelte
|   |       |-- +layout.ts
|   |       |-- +page.svelte             # Landing page
|   |       |-- docs/
|   |       |   `-- [...slug]/
|   |       |       |-- +page.svelte
|   |       |       `-- +page.ts
|   |       `-- curriculum/
|   |           `-- [...slug]/
|   |               |-- +page.svelte
|   |               `-- +page.ts
|   `-- static/
|       |-- CNAME              # Custom domain (optional)
|       |-- favicon.ico
|       `-- llms.txt           # Generated at build time
|
`-- bridge/                   # Bridge/gateway software
    |-- BUILD.bazel
    |-- mqtt/                  # MQTT bridge scripts
    |   |-- meshtastic-mqtt.py
    |   `-- config.yaml
    |-- sms/                   # SMS gateway bridge
    |   |-- sms-bridge.py
    |   `-- config.yaml
    `-- email/                 # Email-to-mesh bridge
        |-- email-bridge.py
        `-- config.yaml
```

---

## 9. Additional Configuration Files

### .bazelversion

```
7.4.0
```

### .bazelignore

```
node_modules
site/node_modules
site/.svelte-kit
site/build
.direnv
```

### WORKSPACE.bazel

```starlark
# LA-Mesh - Bazel Workspace
# Intentionally minimal - using Bzlmod (MODULE.bazel)
workspace(name = "la-mesh")
```

### pnpm-workspace.yaml

```yaml
packages:
  - 'site'
```

### package.json (root)

```json
{
  "name": "la-mesh",
  "private": true,
  "type": "module",
  "engines": {
    "node": ">=20.0.0"
  }
}
```

### .npmrc

```
shamefully-hoist=true
```

### cliff.toml

```toml
[changelog]
header = """
# Changelog

All notable changes to the LA-Mesh project.\n
"""
body = """
{%- macro remote_url() -%}
  https://github.com/Jesssullivan/LA-Mesh
{%- endmacro -%}

{% if version -%}
    ## [{{ version | trim_start_matches(pat="v") }}] - {{ timestamp | date(format="%Y-%m-%d") }}
{% else -%}
    ## [Unreleased]
{% endif -%}

{% for group, commits in commits | group_by(attribute="group") %}
    ### {{ group | striptags | trim | upper_first }}
    {% for commit in commits %}
        - {% if commit.scope %}**{{ commit.scope }}**: {% endif %}{{ commit.message | upper_first }}\
          {% if commit.breaking %} (**BREAKING**){% endif %}\
          ([{{ commit.id | truncate(length=7, end="") }}]({{ self::remote_url() }}/commit/{{ commit.id }}))
    {%- endfor %}
{% endfor %}
"""
trim = true

[git]
conventional_commits = true
filter_unconventional = false
commit_parsers = [
    { message = "^feat", group = "Features" },
    { message = "^fix", group = "Bug Fixes" },
    { message = "^docs", group = "Documentation" },
    { message = "^perf", group = "Performance" },
    { message = "^refactor", group = "Refactoring" },
    { message = "^style", group = "Styling" },
    { message = "^test", group = "Testing" },
    { message = "^chore", group = "Miscellaneous" },
    { message = "^ci", group = "CI/CD" },
    { message = "^curriculum", group = "Curriculum" },
    { message = "^Merge", skip = true },
]
tag_pattern = "v[0-9].*"
sort_commits = "newest"
```

### .markdownlint-cli2.yaml

```yaml
config:
  line-length: false
  single-h1: false
  no-bare-urls: false
  blanks-around-fences: false
  no-trailing-punctuation: false
  fenced-code-language: false
  ol-prefix: false
  link-fragments: false
  blanks-around-lists: false
  no-duplicate-heading:
    siblings_only: true
  blanks-around-tables: false
  no-emphasis-as-heading: false
```

### renovate.json5

```json5
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["config:recommended"],
  "nix": { "enabled": true },
  "bazel-module": { "enabled": true },
  "packageRules": [
    {
      "matchManagers": ["nix"],
      "groupName": "nix flake inputs"
    },
    {
      "matchManagers": ["bazel-module"],
      "groupName": "bazel dependencies"
    },
    {
      "matchManagers": ["npm"],
      "matchPackagePatterns": ["@skeletonlabs/*"],
      "groupName": "skeleton ui"
    },
    {
      "matchManagers": ["npm"],
      "matchPackagePatterns": ["@sveltejs/*", "svelte", "svelte-check"],
      "groupName": "svelte ecosystem"
    },
    {
      "matchManagers": ["npm"],
      "matchPackagePatterns": ["vite", "@tailwindcss/*", "tailwindcss"],
      "groupName": "vite and tailwind"
    }
  ]
}
```

---

## 10. .gitignore Update

The existing `.gitignore` in the repo excludes files that should be committed (like `.envrc`, `.gitignore` itself). This needs to be restructured. The `.gitignore` that gets committed should be different from the local-only gitignore.

**Strategy:** The `.githooks/pre-commit` already blocks local-only files (`.claude/`, `CLAUDE.md`, `.mcp.json`, `.githooks/`, `.gitignore`). However, the `.gitignore` file itself should be committed. The pre-commit hook should be updated to remove `.gitignore` from the block list.

**Recommended committed .gitignore:**

```gitignore
# =============================================================================
# LA-Mesh .gitignore
# =============================================================================

# Environment and Secrets
.env
.env.*
!.env.template
!.env.example

# Build artifacts
/dist/
/build/
/out/
/_site/
/.cache/
/result
/result-*

# Bazel
/bazel-*
/.bazel/
user.bazelrc

# Nix
.direnv/

# Python
__pycache__/
*.py[cod]
*.egg-info/
.venv/
venv/

# Node
node_modules/
.pnpm-store/

# SvelteKit
site/.svelte-kit/
site/build/

# Editor state
.idea/
.vscode/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Firmware blobs (track via Git LFS or separate)
*.bin
*.uf2
*.hex
*.elf
!firmware/.gitkeep

# SDR captures (large files)
*.raw
*.iq
*.cf32
*.cs8

# Model files
*.gguf
*.safetensors

# Credential patterns
*_secret*
*_token*
*_key.json
*.pem
*.key
*.p12
*.pfx
id_rsa
id_ed25519
id_ecdsa

# Claude Code / AI (local only)
.claude/
CLAUDE.md
.mcp.json
.serena

# Local development (not committed)
notes/
scratch/
*.local.md
.dev-notes/
```

---

## Sprint Integration Points

### Phase 1: Foundation (Sprint 1, ~1 week)

**Deliverables:**
- [ ] Push initial scaffold to `main` (structure, configs, Justfile, flake.nix)
- [ ] Enable GitHub Pages in repo settings (Actions deployment source)
- [ ] Verify `nix develop` shell works on macOS and Linux
- [ ] Verify `just dev` starts docs site locally

**Go/No-Go Criteria:**
- `nix develop` resolves all dependencies without errors
- `just dev` serves a blank SvelteKit site at `localhost:5173`
- `.envrc` + `direnv allow` auto-enters dev shell

**Files to create:**
1. `flake.nix`, `MODULE.bazel`, `WORKSPACE.bazel`, `BUILD.bazel`
2. `.bazelrc`, `.bazelversion`, `.bazelignore`
3. `.envrc`, `Justfile`
4. `pnpm-workspace.yaml`, `package.json`, `.npmrc`
5. `cliff.toml`, `.markdownlint-cli2.yaml`, `renovate.json5`
6. `.github/workflows/ci.yml`, `.github/workflows/deploy-pages.yml`
7. Updated `.gitignore` (committed version)

### Phase 2: Docs Site (Sprint 2, ~1 week)

**Deliverables:**
- [ ] SvelteKit site scaffolded in `site/` with MDsveX
- [ ] Landing page with project overview
- [ ] At least 3 docs pages (quick-start, hardware-list, network-topology)
- [ ] Mermaid diagram support for mesh topology visualization
- [ ] `llms.txt` generation prebuild script
- [ ] GitHub Pages live at `jesssullivan.github.io/LA-Mesh/`

**Go/No-Go Criteria:**
- `just build` produces `site/build/` with valid HTML
- GitHub Actions deploys successfully on push to main
- Pages accessible at `https://jesssullivan.github.io/LA-Mesh/`

**Files to create:**
1. `site/` directory (SvelteKit scaffold from GloriousFlywheel pattern)
2. `site/BUILD.bazel`
3. `docs/index.md`, `docs/getting-started/quick-start.md`
4. `scripts/generate-llms-txt.js`

### Phase 3: Device Management (Sprint 3, ~1 week)

**Deliverables:**
- [ ] Meshtastic device profiles in `configs/profiles/`
- [ ] Config validation script (`scripts/validate-configs.py`)
- [ ] Justfile recipes for device management (`mesh-info`, `mesh-export-config`, `mesh-apply-profile`)
- [ ] Firmware flashing recipes (`flash`, `flash-erase`)
- [ ] Device management guide in docs

**Go/No-Go Criteria:**
- `just mesh-info` successfully queries a connected Meshtastic device
- `just mesh-apply-profile relay-node` applies config to device
- Config validation catches invalid YAML

### Phase 4: Bridge Software (Sprint 4, ~1-2 weeks)

**Deliverables:**
- [ ] MQTT bridge script in `bridge/mqtt/`
- [ ] SMS bridge scaffold in `bridge/sms/`
- [ ] Bridge configuration docs
- [ ] Bazel test targets for bridge scripts

**Go/No-Go Criteria:**
- MQTT bridge connects Meshtastic device to MQTT broker
- Automated tests validate bridge configurations

### Phase 5: Curriculum (Sprint 5, ~2 weeks)

**Deliverables:**
- [ ] At least 4 curriculum modules in `curriculum/`
- [ ] Curriculum rendered on docs site
- [ ] Exercises and hands-on labs

**Go/No-Go Criteria:**
- All curriculum Markdown renders correctly on the site
- Each module has lesson + exercises

### Phase 6: Bazel CI Integration (Sprint 6, ~1 week)

**Deliverables:**
- [ ] Bazel builds all validation targets
- [ ] CI runs Bazel tests on PRs
- [ ] Config validation via Bazel rules
- [ ] Deployment bundle target

**Go/No-Go Criteria:**
- `bazel build //...` succeeds
- `bazel test //...` passes
- CI workflow uses Bazel for validation

---

## Gap Analysis

### Resolved by This Scaffold

| Gap | Resolution |
|-----|-----------|
| No CI/CD | GitHub Actions for Pages + PR validation |
| No reproducible dev env | Nix flake with all tools |
| No task automation | Justfile with 30+ recipes |
| No build system | Bazel + Nix integration |
| No docs site | SvelteKit + MDsveX (matching existing ecosystem) |
| No device management | Justfile recipes + meshtastic-cli in Nix shell |
| No dependency management | Renovate for Nix, Bazel, npm |

### Known Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| `python3Packages.meshtastic` packaging bug | CLI won't work in Nix shell | Include `packaging` as explicit dependency; pin nixpkgs commit |
| PlatformIO in Nix is fragile | Can't build custom firmware in Nix | Use PlatformIO outside Nix or use FHS env; rely on prebuilt binaries |
| Bazel + pnpm integration complexity | Build failures | Follow GloriousFlywheel pattern exactly; `aspect_rules_js` is proven |
| Private repo + GitHub Pages | Pages requires paid plan for private repos | Make repo public or use GitHub Pro |
| Large firmware binaries in git | Repo bloat | `.gitignore` blocks `*.bin`/`*.uf2`; use Git LFS or external storage |

### Not Covered (Future Work)

| Item | Notes |
|------|-------|
| Interactive mesh topology map | Needs Leaflet/MapLibre + device GPS data |
| Coverage modeling | RF propagation modeling (SPLAT!, RadioMobile) |
| MeshCore integration | Separate companion app, out of scope for initial scaffold |
| PortaPack firmware management | Complex build system, track separately |
| Automated network monitoring | `mesh-monitor.py` is a placeholder |
| Custom domain (mesh.transscendsurvival.org) | DNS + CNAME setup after Phase 2 |

---

## Key Patterns Adopted from GloriousFlywheel

1. **Bzlmod over WORKSPACE** - MODULE.bazel with `bazel_dep()` calls
2. **rules_nixpkgs_core** - Nix toolchain integration for Bazel
3. **Bazel wrapper script** - `writeShellScriptBin "bazel"` wrapping bazelisk
4. **treefmt-nix** - Unified formatting (nixpkgs-fmt, prettier, shfmt)
5. **devShells.ci** - Lightweight CI shell without heavy dev tools
6. **Nix checks** - statix + deadnix in `checks` output
7. **SvelteKit + MDsveX docs site** - Exact same stack as docs-site/
8. **DOCS_BASE_PATH env var** - For project pages base path
9. **llms.txt generation** - Prebuild script for LLM context
10. **Renovate with grouped packages** - Nix, Bazel, npm groups
11. **git-cliff + cliff.toml** - Conventional commits changelog
12. **markdownlint-cli2** - Markdown quality gates
13. **pnpm monorepo** - Workspace-level lockfile management
14. **Justfile section organization** - Consistent structure with headers
15. **`.envrc` with nix-direnv caching** - Fast shell loading
