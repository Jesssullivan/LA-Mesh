<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Firmware Flashing - LA-Mesh</title>
</svelte:head>

<nav class="text-sm text-surface-500 mb-4">
	<a href="{base}/guides" class="text-primary-400 no-underline">Guides</a> / Firmware Flashing
</nav>

<h1>Firmware Flashing Guide</h1>
<p class="text-lg text-surface-400 mb-8">Flash, verify, and configure Meshtastic firmware on LA-Mesh devices using the justfile pipeline.</p>

<div class="p-5 bg-yellow-500/10 border border-yellow-500/30 rounded-lg mb-8">
	<strong class="text-yellow-400">Minimum Firmware Version: v2.7.15+</strong>
	<p class="text-yellow-300/80 mt-2 m-0">Earlier versions are vulnerable to CVE-2025-52464 (duplicate crypto keys), CVE-2025-24797, CVE-2025-55293, CVE-2025-55292, and CVE-2025-53627. Do not deploy devices with firmware older than v2.7.15. Note: v2.7.15 enforces PKI-only DMs (legacy DMs disabled).</p>
</div>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Method 1: One-Command Provisioning (Recommended)</h2>
	<p class="text-surface-300 mb-4">Clone the repo, enter the dev shell, and provision a device in one pipeline. This fetches the manifest-pinned firmware, verifies its SHA256 checksum, flashes it, applies the device profile, and configures LA-Mesh channels.</p>
	<pre class="bg-surface-800 text-primary-400 p-5 rounded-lg overflow-x-auto text-sm leading-relaxed font-mono">{`git clone https://github.com/Jesssullivan/LA-Mesh.git
cd LA-Mesh
direnv allow                                    # or: nix develop
just provision station-g2 /dev/ttyUSB0`}</pre>

	<h3 class="text-surface-100 mt-6">What <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just provision</code> does</h3>
	<table class="w-full border-collapse mt-4">
		<thead><tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Step</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Action</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Detail</th></tr></thead>
		<tbody>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">1</td><td class="p-3 text-surface-200 border-b border-surface-700">Fetch firmware</td><td class="p-3 text-surface-200 border-b border-surface-700">Downloads pinned version from GitHub (cached locally)</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">2</td><td class="p-3 text-surface-200 border-b border-surface-700">Verify checksum</td><td class="p-3 text-surface-200 border-b border-surface-700">SHA256 checked against <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">firmware/manifest.json</code></td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">3</td><td class="p-3 text-surface-200 border-b border-surface-700">Flash device</td><td class="p-3 text-surface-200 border-b border-surface-700">esptool.py <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">write-flash</code> at offset <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">0x260000</code></td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">4</td><td class="p-3 text-surface-200 border-b border-surface-700">Apply profile</td><td class="p-3 text-surface-200 border-b border-surface-700">Device role config (ROUTER, CLIENT, etc.)</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">5</td><td class="p-3 text-surface-200 border-b border-surface-700">Set channels</td><td class="p-3 text-surface-200 border-b border-surface-700">LA-Mesh / LA-Admin / LA-Emergency (requires PSK from operator's encrypted keystore)</td></tr>
		</tbody>
	</table>
	<p class="text-surface-300 mb-4">Device types: <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">station-g2</code>, <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">t-deck</code></p>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Method 2: Step-by-Step CLI</h2>
	<p class="text-surface-300 mb-4">For operators who want explicit control over each stage.</p>
	<pre class="bg-surface-800 text-primary-400 p-5 rounded-lg overflow-x-auto text-sm leading-relaxed font-mono">{`# 1. Fetch firmware for a specific device
just fetch-firmware --device station-g2

# 2. Confirm pinned version
just firmware-versions

# 3. Flash (SHA256 verified automatically)
just flash-meshtastic firmware/.cache/firmware-station-g2-2.7.15.bin /dev/ttyUSB0

# 4. Apply device profile
just configure-profile station-g2-router /dev/ttyUSB0

# 5. Apply LA-Mesh channels (reads PSK from operator keystore)
just configure-channels /dev/ttyUSB0`}</pre>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Method 3: Web Flasher</h2>
	<p class="text-surface-300 mb-4">For meetups or field use when the dev environment is unavailable.</p>
	<ol class="text-surface-300 pl-6 mb-4">
		<li class="mb-1">Connect device via USB-C (use a data cable, not charge-only)</li>
		<li class="mb-1">Open <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">flasher.meshtastic.org</code> in Chrome or Edge (WebSerial required)</li>
		<li class="mb-1">Select your device type and firmware version</li>
		<li class="mb-1">Click "Flash" and wait for completion (~2 minutes)</li>
	</ol>
	<p class="text-sm text-surface-400 italic">Web flasher does not verify against the LA-Mesh manifest. After flashing, apply the profile and channels manually via CLI.</p>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Checksum Verification</h2>
	<p class="text-surface-300 mb-4">All justfile flash commands verify firmware integrity automatically:</p>
	<ul class="text-surface-300 pl-6 mb-4">
		<li class="mb-1"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">firmware/manifest.json</code> pins the exact version and SHA256 hash per device</li>
		<li class="mb-1"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just fetch-firmware</code> verifies the hash on download</li>
		<li class="mb-1"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just flash-meshtastic</code> verifies the hash before flashing</li>
		<li class="mb-1"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just provision</code> verifies the hash at step 2 -- refuses to flash on mismatch</li>
	</ul>
	<pre class="bg-surface-800 text-primary-400 p-5 rounded-lg overflow-x-auto text-sm leading-relaxed font-mono">{`# After first download, populate manifest hashes
just firmware-update-hashes

# Verify what's pinned
just firmware-versions`}</pre>
	<p class="text-surface-300 mb-4">If you see <strong>"CHECKSUM MISMATCH -- refusing to flash!"</strong>, the binary is corrupted or does not match the manifest. Re-download with <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just fetch-firmware</code>.</p>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Version Parity</h2>
	<p class="text-surface-300 mb-4">All devices provisioned from the same repo clone get identical firmware versions -- the manifest is the single source of truth.</p>
	<pre class="bg-surface-800 text-primary-400 p-5 rounded-lg overflow-x-auto text-sm leading-relaxed font-mono">{`# Check pinned versions
just firmware-versions

# Check if upstream has a newer release
just firmware-check`}</pre>
	<p class="text-surface-300 mb-4">To update the pinned version: edit <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">firmware/manifest.json</code>, run <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just fetch-firmware</code>, then <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just firmware-update-hashes</code>.</p>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Post-Flash Configuration</h2>
	<table class="w-full border-collapse mt-4">
		<thead><tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Device</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Profile</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Command</th></tr></thead>
		<tbody>
			<tr>
				<td class="p-3 text-surface-200 border-b border-surface-700">Station G2 (relay)</td>
				<td class="p-3 text-surface-200 border-b border-surface-700">station-g2-router</td>
				<td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just configure-profile station-g2-router</code></td>
			</tr>
			<tr>
				<td class="p-3 text-surface-200 border-b border-surface-700">T-Deck Plus</td>
				<td class="p-3 text-surface-200 border-b border-surface-700">tdeck-plus-client</td>
				<td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just configure-profile tdeck-plus-client</code></td>
			</tr>
			<tr>
				<td class="p-3 text-surface-200 border-b border-surface-700">T-Deck Pro (e-ink)</td>
				<td class="p-3 text-surface-200 border-b border-surface-700">tdeck-pro-eink-client</td>
				<td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just configure-profile tdeck-pro-eink-client</code></td>
			</tr>
			<tr>
				<td class="p-3 text-surface-200 border-b border-surface-700">FireElmo-SDR</td>
				<td class="p-3 text-surface-200 border-b border-surface-700">fireelmo-sdr-gateway</td>
				<td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just configure-profile fireelmo-sdr-gateway</code></td>
			</tr>
		</tbody>
	</table>
	<p class="text-surface-300 mb-4">Then apply LA-Mesh channel configuration (requires PSK from operator's encrypted keystore):</p>
	<pre class="bg-surface-800 text-primary-400 p-5 rounded-lg overflow-x-auto text-sm leading-relaxed font-mono">{`just configure-channels /dev/ttyUSB0`}</pre>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Troubleshooting</h2>
	<table class="w-full border-collapse mt-4">
		<thead><tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Error</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Solution</th></tr></thead>
		<tbody>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">"Failed to connect"</td><td class="p-3 text-surface-200 border-b border-surface-700">Enter bootloader mode (BOOT + RESET)</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">"CHECKSUM MISMATCH"</td><td class="p-3 text-surface-200 border-b border-surface-700">Re-download: <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just fetch-firmware</code>, then <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just firmware-update-hashes</code></td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">"Invalid head of packet"</td><td class="p-3 text-surface-200 border-b border-surface-700">Erase flash first: <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just flash-erase</code></td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">"Timed out"</td><td class="p-3 text-surface-200 border-b border-surface-700">Try lower baud rate (115200 instead of 921600)</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Permission denied</td><td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">sudo usermod -aG dialout $USER</code> (re-login required)</td></tr>
		</tbody>
	</table>
</section>
