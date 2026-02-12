<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Firmware Switching - LA-Mesh</title>
</svelte:head>

<nav class="breadcrumb">
	<a href="{base}/guides">Guides</a> / Firmware Switching
</nav>

<h1>Firmware Switching: Meshtastic &lt;-&gt; MeshCore</h1>
<p class="intro">Switch between Meshtastic and MeshCore firmware on ESP32-S3 devices. Use a dedicated evaluation device -- never your primary LA-Mesh node.</p>

<section class="warning">
	<strong>No dual-boot capability.</strong>
	<p>MeshCore and Meshtastic use incompatible partition tables, NVS schemas, and radio configurations. Switching requires a full flash erase (~60 seconds total).</p>
</section>

<section>
	<h2>Incompatibility Summary</h2>
	<table>
		<thead><tr><th>Aspect</th><th>Meshtastic</th><th>MeshCore</th></tr></thead>
		<tbody>
			<tr><td>Partition table</td><td>Custom (app + littlefs)</td><td>Different layout</td></tr>
			<tr><td>Configuration</td><td>YAML profiles via CLI</td><td>Web config tool</td></tr>
			<tr><td>Channel format</td><td>PSK + channel index</td><td>Room/password model</td></tr>
			<tr><td>Encryption</td><td>AES-256-CTR + X25519 PKC</td><td>AES-128-ECB</td></tr>
		</tbody>
	</table>
</section>

<section>
	<h2>Before Switching: Back Up</h2>
	<pre class="code">{`# Export current Meshtastic config
meshtastic --export-config > backup-meshtastic-$(date +%Y%m%d).yaml

# Record firmware version
meshtastic --info | grep Firmware`}</pre>
	<p>Flash erase destroys all state. Configuration, message history, node list, and Bluetooth pairings are lost.</p>
</section>

<section>
	<h2>Switch to MeshCore (Evaluation)</h2>
	<pre class="code">{`# 1. Erase flash (hold BOOT, press RESET, release BOOT first)
just flash-erase /dev/ttyUSB0

# 2. Flash MeshCore via web flasher (recommended)
#    Open https://flasher.meshcore.co.uk in Chrome/Edge
#    Or via CLI:
just flash-meshcore meshcore-firmware.bin /dev/ttyUSB0

# 3. Configure via https://config.meshcore.co.uk`}</pre>
</section>

<section>
	<h2>Switch Back to Meshtastic</h2>
	<pre class="code">{`# 1. Erase flash
just flash-erase /dev/ttyUSB0

# 2. One-command provisioning (fetch + verify + flash + configure)
just provision station-g2 /dev/ttyUSB0

# Or restore from backup:
meshtastic --configure backup-meshtastic-YYYYMMDD.yaml`}</pre>
</section>

<section>
	<h2>Automated Switch Script</h2>
	<pre class="code">{`just switch-firmware /dev/ttyUSB0`}</pre>
	<p>Interactive script that backs up, erases, flashes, and configures in one flow.</p>
</section>

<section>
	<h2>Quick Reference</h2>
	<table>
		<thead><tr><th>Action</th><th>Time</th><th>Command</th></tr></thead>
		<tbody>
			<tr><td>Erase flash</td><td>~5s</td><td><code>just flash-erase /dev/ttyUSB0</code></td></tr>
			<tr><td>Flash + configure Meshtastic</td><td>~45s</td><td><code>just provision station-g2 /dev/ttyUSB0</code></td></tr>
			<tr><td>Flash MeshCore</td><td>~30s</td><td>Web flasher or <code>just flash-meshcore</code></td></tr>
			<tr><td>Total switch time</td><td>~60s</td><td>Erase + flash + configure</td></tr>
		</tbody>
	</table>
</section>

<style>
	.breadcrumb { font-size: 0.85rem; color: #888; margin-bottom: 1rem; }
	.breadcrumb a { color: #00d4aa; text-decoration: none; }
	.intro { font-size: 1.1rem; color: #555; margin-bottom: 2rem; }
	section { margin-bottom: 3rem; }
	.warning { background: #fff3cd; border: 1px solid #ffc107; border-radius: 8px; padding: 1.25rem; }
	.warning strong { color: #856404; }
	.warning p { margin: 0.5rem 0 0; color: #856404; }
	.code { background: #1a1a2e; color: #00d4aa; padding: 1.25rem; border-radius: 8px; overflow-x: auto; font-size: 0.85rem; line-height: 1.5; }
	table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
	th, td { padding: 0.75rem; border: 1px solid #ddd; text-align: left; }
	th { background: #f5f5f5; font-weight: 600; }
	a { color: #00d4aa; }
</style>
