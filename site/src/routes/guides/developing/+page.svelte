<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Developer Guide - LA-Mesh</title>
</svelte:head>

<nav class="text-sm text-surface-500 mb-4">
	<a href="{base}/guides" class="text-primary-400 no-underline">Guides</a> / Developer Guide
</nav>

<h1>Developer Guide</h1>
<p class="text-lg text-surface-400 mb-8">Set up the LA-Mesh development environment, build the site, flash devices, and contribute.</p>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Quick Start (Nix + direnv)</h2>
	<pre class="bg-surface-800 text-primary-400 p-5 rounded-lg overflow-x-auto text-sm leading-relaxed font-mono">{`git clone https://github.com/Jesssullivan/LA-Mesh.git
cd LA-Mesh
direnv allow        # auto-enters Nix dev shell on cd
just info           # verify all tools are available`}</pre>
	<p class="text-surface-300 mb-4">The Nix dev shell provides: meshtastic CLI, esptool.py, hackrf tools, bazelisk, just, nodejs, pnpm, git-cliff, shellcheck, ruff.</p>
	<p class="text-surface-300 mb-4">Without Nix: <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">pip install meshtastic esptool ruff</code>, <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">npm install -g pnpm</code>, <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">cargo install just git-cliff</code>.</p>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Repository Structure</h2>
	<pre class="bg-surface-800 text-primary-400 p-5 rounded-lg overflow-x-auto text-sm leading-relaxed font-mono">{`LA-Mesh/
├── site/              # SvelteKit documentation site
├── docs/              # Markdown documentation
├── configs/           # Device profiles and channel templates
├── bridges/           # SMS, email, MQTT bridge code
├── tools/             # Scripts: flash, test, configure, monitor
├── curriculum/        # Educational workshop modules
├── hardware/          # Inventory, BOM, deployment guides
├── firmware/          # Manifest, checksums, version pinning
└── captures/          # SDR capture storage (gitignored)`}</pre>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Common Just Recipes</h2>
	<table class="w-full border-collapse mt-4">
		<thead><tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Command</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Purpose</th></tr></thead>
		<tbody>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just dev</code></td><td class="p-3 text-surface-200 border-b border-surface-700">Start docs site dev server (hot reload)</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just build</code></td><td class="p-3 text-surface-200 border-b border-surface-700">Build site for production</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just check</code></td><td class="p-3 text-surface-200 border-b border-surface-700">Run all validations (format + type check)</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just ci</code></td><td class="p-3 text-surface-200 border-b border-surface-700">Full CI simulation (check + build)</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just provision &lt;device&gt; &lt;port&gt;</code></td><td class="p-3 text-surface-200 border-b border-surface-700">One-command device provisioning</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just fetch-firmware</code></td><td class="p-3 text-surface-200 border-b border-surface-700">Download and verify firmware</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just firmware-versions</code></td><td class="p-3 text-surface-200 border-b border-surface-700">Show pinned firmware versions</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just firmware-check</code></td><td class="p-3 text-surface-200 border-b border-surface-700">Check for upstream updates</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just mesh-info</code></td><td class="p-3 text-surface-200 border-b border-surface-700">Show connected device info</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just mesh-nodes</code></td><td class="p-3 text-surface-200 border-b border-surface-700">List visible mesh nodes</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just configure-profile &lt;profile&gt;</code></td><td class="p-3 text-surface-200 border-b border-surface-700">Apply device configuration profile</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just configure-channels</code></td><td class="p-3 text-surface-200 border-b border-surface-700">Apply LA-Mesh channel config</td></tr>
		</tbody>
	</table>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Branch Strategy</h2>
	<table class="w-full border-collapse mt-4">
		<thead><tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Branch</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Purpose</th></tr></thead>
		<tbody>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">main</code></td><td class="p-3 text-surface-200 border-b border-surface-700">Production -- deploys to GitHub Pages</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">feature/*</code></td><td class="p-3 text-surface-200 border-b border-surface-700">Feature development</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">fix/*</code></td><td class="p-3 text-surface-200 border-b border-surface-700">Bug fixes</td></tr>
		</tbody>
	</table>
	<p class="text-surface-300 mb-4">PRs target <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">main</code>. CI must pass before merge.</p>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">CI/CD Workflows</h2>
	<table class="w-full border-collapse mt-4">
		<thead><tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Workflow</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Trigger</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Purpose</th></tr></thead>
		<tbody>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">ci.yml</code></td><td class="p-3 text-surface-200 border-b border-surface-700">Push/PR to main</td><td class="p-3 text-surface-200 border-b border-surface-700">Lint, validate, build site</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">deploy-pages.yml</code></td><td class="p-3 text-surface-200 border-b border-surface-700">Push to main</td><td class="p-3 text-surface-200 border-b border-surface-700">Deploy GitHub Pages</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">firmware-check.yml</code></td><td class="p-3 text-surface-200 border-b border-surface-700">Weekly cron</td><td class="p-3 text-surface-200 border-b border-surface-700">Check for firmware updates</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">security-scan.yml</code></td><td class="p-3 text-surface-200 border-b border-surface-700">Push/PR to main</td><td class="p-3 text-surface-200 border-b border-surface-700">Gitleaks, ShellCheck, YAML lint</td></tr>
		</tbody>
	</table>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Security: Never Commit</h2>
	<ul class="text-surface-300 pl-6 mb-4">
		<li class="mb-1">Secrets (never committed -- use encrypted storage)</li>
		<li class="mb-1">PSK values (channel encryption keys)</li>
		<li class="mb-1">API keys (SMS gateway, SMTP, MQTT credentials)</li>
		<li class="mb-1">Private keys (SSH, GPG, TLS)</li>
	</ul>
	<p class="text-surface-300 mb-4">Enable the pre-commit hook: <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">git config core.hooksPath .githooks</code></p>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Recommended Operating Systems</h2>
	<table class="w-full border-collapse mt-4">
		<thead><tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">OS</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Use Case</th></tr></thead>
		<tbody>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700"><a href="https://linuxmint.com" class="text-primary-400">Linux Mint</a></td><td class="p-3 text-surface-200 border-b border-surface-700">Desktop OS for mesh operators -- stable, beginner-friendly, full hardware support</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700"><a href="https://rockylinux.org" class="text-primary-400">Rocky Linux</a></td><td class="p-3 text-surface-200 border-b border-surface-700">Server OS for gateway and bridge nodes -- enterprise-grade, long-term support</td></tr>
		</tbody>
	</table>
</section>
