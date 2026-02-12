<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Firmware Flashing - LA-Mesh</title>
</svelte:head>

<nav class="breadcrumb">
	<a href="{base}/guides">Guides</a> / Firmware Flashing
</nav>

<h1>Firmware Flashing Guide</h1>
<p class="intro">Flash, verify, and configure Meshtastic firmware on LA-Mesh devices using the justfile pipeline.</p>

<section class="warning">
	<strong>Minimum Firmware Version: v2.7.15+</strong>
	<p>Earlier versions are vulnerable to CVE-2025-52464 (duplicate crypto keys), CVE-2025-24797, CVE-2025-55293, CVE-2025-55292, and CVE-2025-53627. Do not deploy devices with firmware older than v2.7.15. Note: v2.7.15 enforces PKI-only DMs (legacy DMs disabled).</p>
</section>

<section>
	<h2>Method 1: One-Command Provisioning (Recommended)</h2>
	<p>Clone the repo, enter the dev shell, and provision a device in one pipeline. This fetches the manifest-pinned firmware, verifies its SHA256 checksum, flashes it, applies the device profile, and configures LA-Mesh channels.</p>
	<pre class="code">{`git clone https://github.com/Jesssullivan/LA-Mesh.git
cd LA-Mesh
direnv allow                                    # or: nix develop
just provision station-g2 /dev/ttyUSB0`}</pre>

	<h3>What <code>just provision</code> does</h3>
	<table>
		<thead><tr><th>Step</th><th>Action</th><th>Detail</th></tr></thead>
		<tbody>
			<tr><td>1</td><td>Fetch firmware</td><td>Downloads pinned version from GitHub (cached locally)</td></tr>
			<tr><td>2</td><td>Verify checksum</td><td>SHA256 checked against <code>firmware/manifest.json</code></td></tr>
			<tr><td>3</td><td>Flash device</td><td>esptool.py <code>write-flash</code> at offset <code>0x260000</code></td></tr>
			<tr><td>4</td><td>Apply profile</td><td>Device role config (ROUTER, CLIENT, etc.)</td></tr>
			<tr><td>5</td><td>Set channels</td><td>LA-Mesh / LA-Admin / LA-Emergency (requires PSK env vars)</td></tr>
		</tbody>
	</table>
	<p>Device types: <code>station-g2</code>, <code>t-deck</code></p>
</section>

<section>
	<h2>Method 2: Step-by-Step CLI</h2>
	<p>For operators who want explicit control over each stage.</p>
	<pre class="code">{`# 1. Fetch firmware for a specific device
just fetch-firmware --device station-g2

# 2. Confirm pinned version
just firmware-versions

# 3. Flash (SHA256 verified automatically)
just flash-meshtastic firmware/.cache/firmware-station-g2-2.7.15.bin /dev/ttyUSB0

# 4. Apply device profile
just configure-profile station-g2-router /dev/ttyUSB0

# 5. Apply LA-Mesh channels (reads PSK from .env)
just configure-channels /dev/ttyUSB0`}</pre>
</section>

<section>
	<h2>Method 3: Web Flasher</h2>
	<p>For meetups or field use when the dev environment is unavailable.</p>
	<ol>
		<li>Connect device via USB-C (use a data cable, not charge-only)</li>
		<li>Open <code>flasher.meshtastic.org</code> in Chrome or Edge (WebSerial required)</li>
		<li>Select your device type and firmware version</li>
		<li>Click "Flash" and wait for completion (~2 minutes)</li>
	</ol>
	<p class="note">Web flasher does not verify against the LA-Mesh manifest. After flashing, apply the profile and channels manually via CLI.</p>
</section>

<section>
	<h2>Checksum Verification</h2>
	<p>All justfile flash commands verify firmware integrity automatically:</p>
	<ul>
		<li><code>firmware/manifest.json</code> pins the exact version and SHA256 hash per device</li>
		<li><code>just fetch-firmware</code> verifies the hash on download</li>
		<li><code>just flash-meshtastic</code> verifies the hash before flashing</li>
		<li><code>just provision</code> verifies the hash at step 2 -- refuses to flash on mismatch</li>
	</ul>
	<pre class="code">{`# After first download, populate manifest hashes
just firmware-update-hashes

# Verify what's pinned
just firmware-versions`}</pre>
	<p>If you see <strong>"CHECKSUM MISMATCH -- refusing to flash!"</strong>, the binary is corrupted or does not match the manifest. Re-download with <code>just fetch-firmware</code>.</p>
</section>

<section>
	<h2>Version Parity</h2>
	<p>All devices provisioned from the same repo clone get identical firmware versions -- the manifest is the single source of truth.</p>
	<pre class="code">{`# Check pinned versions
just firmware-versions

# Check if upstream has a newer release
just firmware-check`}</pre>
	<p>To update the pinned version: edit <code>firmware/manifest.json</code>, run <code>just fetch-firmware</code>, then <code>just firmware-update-hashes</code>.</p>
</section>

<section>
	<h2>Post-Flash Configuration</h2>
	<table>
		<thead><tr><th>Device</th><th>Profile</th><th>Command</th></tr></thead>
		<tbody>
			<tr>
				<td>Station G2 (relay)</td>
				<td>station-g2-router</td>
				<td><code>just configure-profile station-g2-router</code></td>
			</tr>
			<tr>
				<td>T-Deck Plus</td>
				<td>tdeck-plus-client</td>
				<td><code>just configure-profile tdeck-plus-client</code></td>
			</tr>
			<tr>
				<td>T-Deck Pro (e-ink)</td>
				<td>tdeck-pro-eink-client</td>
				<td><code>just configure-profile tdeck-pro-eink-client</code></td>
			</tr>
			<tr>
				<td>MeshAdv-Mini</td>
				<td>meshadv-mini-gateway</td>
				<td><code>just configure-profile meshadv-mini-gateway</code></td>
			</tr>
		</tbody>
	</table>
	<p>Then apply LA-Mesh channel configuration (requires PSK environment variables):</p>
	<pre class="code">{`just configure-channels /dev/ttyUSB0`}</pre>
</section>

<section>
	<h2>Troubleshooting</h2>
	<table>
		<thead><tr><th>Error</th><th>Solution</th></tr></thead>
		<tbody>
			<tr><td>"Failed to connect"</td><td>Enter bootloader mode (BOOT + RESET)</td></tr>
			<tr><td>"CHECKSUM MISMATCH"</td><td>Re-download: <code>just fetch-firmware</code>, then <code>just firmware-update-hashes</code></td></tr>
			<tr><td>"Invalid head of packet"</td><td>Erase flash first: <code>just flash-erase</code></td></tr>
			<tr><td>"Timed out"</td><td>Try lower baud rate (115200 instead of 921600)</td></tr>
			<tr><td>Permission denied</td><td><code>sudo usermod -aG dialout $USER</code> (re-login required)</td></tr>
		</tbody>
	</table>
</section>

<style>
	.breadcrumb {
		font-size: 0.85rem;
		color: #888;
		margin-bottom: 1rem;
	}

	.breadcrumb a {
		color: #00d4aa;
		text-decoration: none;
	}

	.intro {
		font-size: 1.1rem;
		color: #555;
		margin-bottom: 2rem;
	}

	section {
		margin-bottom: 3rem;
	}

	.warning {
		background: #fff3cd;
		border: 1px solid #ffc107;
		border-radius: 8px;
		padding: 1.25rem;
	}

	.warning strong {
		color: #856404;
	}

	.warning p {
		margin: 0.5rem 0 0;
		color: #856404;
	}

	.code {
		background: #1a1a2e;
		color: #00d4aa;
		padding: 1.25rem;
		border-radius: 8px;
		overflow-x: auto;
		font-size: 0.85rem;
		line-height: 1.5;
	}

	code {
		background: #f0f0f0;
		padding: 0.15rem 0.35rem;
		border-radius: 3px;
		font-size: 0.85rem;
	}

	.note {
		font-size: 0.9rem;
		color: #888;
		font-style: italic;
	}

	table {
		width: 100%;
		border-collapse: collapse;
		margin-top: 1rem;
	}

	th, td {
		padding: 0.75rem;
		border: 1px solid #ddd;
		text-align: left;
	}

	th {
		background: #f5f5f5;
		font-weight: 600;
	}
</style>
