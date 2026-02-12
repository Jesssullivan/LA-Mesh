<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Developer Guide - LA-Mesh</title>
</svelte:head>

<nav class="breadcrumb">
	<a href="{base}/guides">Guides</a> / Developer Guide
</nav>

<h1>Developer Guide</h1>
<p class="intro">Set up the LA-Mesh development environment, build the site, flash devices, and contribute.</p>

<section>
	<h2>Quick Start (Nix + direnv)</h2>
	<pre class="code">{`git clone https://github.com/Jesssullivan/LA-Mesh.git
cd LA-Mesh
direnv allow        # auto-enters Nix dev shell on cd
just info           # verify all tools are available`}</pre>
	<p>The Nix dev shell provides: meshtastic CLI, esptool.py, hackrf tools, bazelisk, just, nodejs, pnpm, git-cliff, shellcheck, ruff.</p>
	<p>Without Nix: <code>pip install meshtastic esptool ruff</code>, <code>npm install -g pnpm</code>, <code>cargo install just git-cliff</code>.</p>
</section>

<section>
	<h2>Repository Structure</h2>
	<pre class="code">{`LA-Mesh/
├── site/              # SvelteKit documentation site
├── docs/              # Markdown documentation
├── configs/           # Device profiles and channel templates
├── bridges/           # SMS, email, MQTT bridge code
├── tools/             # Scripts: flash, test, configure, monitor
├── curriculum/        # Educational modules (5 levels)
├── hardware/          # Inventory, BOM, deployment guides
├── firmware/          # Manifest, checksums, version pinning
└── captures/          # SDR capture storage (gitignored)`}</pre>
</section>

<section>
	<h2>Common Just Recipes</h2>
	<table>
		<thead><tr><th>Command</th><th>Purpose</th></tr></thead>
		<tbody>
			<tr><td><code>just dev</code></td><td>Start docs site dev server (hot reload)</td></tr>
			<tr><td><code>just build</code></td><td>Build site for production</td></tr>
			<tr><td><code>just check</code></td><td>Run all validations (format + type check)</td></tr>
			<tr><td><code>just ci</code></td><td>Full CI simulation (check + build)</td></tr>
			<tr><td><code>just provision &lt;device&gt; &lt;port&gt;</code></td><td>One-command device provisioning</td></tr>
			<tr><td><code>just fetch-firmware</code></td><td>Download and verify firmware</td></tr>
			<tr><td><code>just firmware-versions</code></td><td>Show pinned firmware versions</td></tr>
			<tr><td><code>just firmware-check</code></td><td>Check for upstream updates</td></tr>
			<tr><td><code>just mesh-info</code></td><td>Show connected device info</td></tr>
			<tr><td><code>just mesh-nodes</code></td><td>List visible mesh nodes</td></tr>
			<tr><td><code>just configure-profile &lt;profile&gt;</code></td><td>Apply device configuration profile</td></tr>
			<tr><td><code>just configure-channels</code></td><td>Apply LA-Mesh channel config</td></tr>
		</tbody>
	</table>
</section>

<section>
	<h2>Branch Strategy</h2>
	<table>
		<thead><tr><th>Branch</th><th>Purpose</th></tr></thead>
		<tbody>
			<tr><td><code>main</code></td><td>Production -- deploys to GitHub Pages</td></tr>
			<tr><td><code>feature/*</code></td><td>Feature development</td></tr>
			<tr><td><code>fix/*</code></td><td>Bug fixes</td></tr>
		</tbody>
	</table>
	<p>PRs target <code>main</code>. CI must pass before merge.</p>
</section>

<section>
	<h2>CI/CD Workflows</h2>
	<table>
		<thead><tr><th>Workflow</th><th>Trigger</th><th>Purpose</th></tr></thead>
		<tbody>
			<tr><td><code>ci.yml</code></td><td>Push/PR to main</td><td>Lint, validate, build site</td></tr>
			<tr><td><code>deploy-pages.yml</code></td><td>Push to main</td><td>Deploy GitHub Pages</td></tr>
			<tr><td><code>firmware-check.yml</code></td><td>Weekly cron</td><td>Check for firmware updates</td></tr>
			<tr><td><code>security-scan.yml</code></td><td>Push/PR to main</td><td>Gitleaks, ShellCheck, YAML lint</td></tr>
		</tbody>
	</table>
</section>

<section>
	<h2>Security: Never Commit</h2>
	<ul>
		<li><code>.env</code> files (use <code>.env.template</code> for structure)</li>
		<li>PSK values (channel encryption keys)</li>
		<li>API keys (SMS gateway, SMTP, MQTT credentials)</li>
		<li>Private keys (SSH, GPG, TLS)</li>
	</ul>
	<p>Enable the pre-commit hook: <code>git config core.hooksPath .githooks</code></p>
</section>

<style>
	.breadcrumb { font-size: 0.85rem; color: #888; margin-bottom: 1rem; }
	.breadcrumb a { color: #00d4aa; text-decoration: none; }
	.intro { font-size: 1.1rem; color: #555; margin-bottom: 2rem; }
	section { margin-bottom: 3rem; }
	.code { background: #1a1a2e; color: #00d4aa; padding: 1.25rem; border-radius: 8px; overflow-x: auto; font-size: 0.85rem; line-height: 1.5; }
	table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
	th, td { padding: 0.75rem; border: 1px solid #ddd; text-align: left; }
	th { background: #f5f5f5; font-weight: 600; }
	a { color: #00d4aa; }
</style>
