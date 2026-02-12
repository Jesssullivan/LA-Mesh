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
<p class="intro">How to flash Meshtastic or MeshCore firmware onto LA-Mesh supported devices.</p>

<section class="warning">
	<strong>Minimum Firmware Version: v2.6.11+</strong>
	<p>Earlier versions are vulnerable to CVE-2025-52464 (duplicate crypto keys from vendor image cloning). Do not deploy devices with firmware older than 2.6.11.</p>
</section>

<section>
	<h2>Method 1: Web Flasher (Recommended)</h2>
	<p>The easiest method. No software installation required.</p>
	<ol>
		<li>Connect device via USB-C (use a data cable, not charge-only)</li>
		<li>Open <code>flasher.meshtastic.org</code> in Chrome or Edge (WebSerial required)</li>
		<li>Select your device type from the dropdown</li>
		<li>Choose firmware version (latest stable)</li>
		<li>Click "Flash" and wait for completion (~2 minutes)</li>
		<li>Device will reboot with fresh firmware</li>
	</ol>
	<p class="note">Web flasher works in Chrome and Edge. Firefox and Safari do not support WebSerial.</p>
</section>

<section>
	<h2>Method 2: CLI with esptool</h2>
	<p>For advanced users or scripted deployments.</p>
	<pre class="code">{`# Enter bootloader mode (hold BOOT, press RESET, release BOOT)

# Erase flash first (recommended for clean install)
esptool.py --chip auto --port /dev/ttyUSB0 erase_flash

# Flash firmware
esptool.py --chip auto --port /dev/ttyUSB0 \\
  --baud 921600 write_flash 0x0 firmware.bin`}</pre>
	<p>Or use the justfile recipe:</p>
	<pre class="code">{`just flash-meshtastic firmware-2.6.11.bin /dev/ttyUSB0`}</pre>
</section>

<section>
	<h2>Method 3: MeshAdv-Mini (meshtasticd)</h2>
	<p>The MeshAdv-Mini Pi HAT runs meshtasticd (Linux-native Meshtastic) directly on the Raspberry Pi. No flashing needed -- install via package manager.</p>
	<pre class="code">{`# Install meshtasticd
sudo apt install meshtasticd

# Configure for MeshAdv-Mini hardware
sudo nano /etc/meshtasticd/config.yaml

# Start the service
sudo systemctl enable --now meshtasticd`}</pre>
</section>

<section>
	<h2>Post-Flash Configuration</h2>
	<p>After flashing, apply the appropriate LA-Mesh device profile:</p>
	<table>
		<thead>
			<tr><th>Device</th><th>Profile</th><th>Command</th></tr>
		</thead>
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
		<thead>
			<tr><th>Error</th><th>Solution</th></tr>
		</thead>
		<tbody>
			<tr><td>"Failed to connect"</td><td>Enter bootloader mode (BOOT + RESET)</td></tr>
			<tr><td>"Invalid head of packet"</td><td>Erase flash first: <code>just flash-erase</code></td></tr>
			<tr><td>"Timed out"</td><td>Try lower baud rate (115200 instead of 921600)</td></tr>
			<tr><td>Permission denied</td><td><code>sudo usermod -aG dialout $USER</code> (re-login)</td></tr>
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
