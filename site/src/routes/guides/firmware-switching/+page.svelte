<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Firmware Switching - LA-Mesh</title>
</svelte:head>

<nav class="text-sm text-surface-500 mb-4">
	<a href="{base}/guides" class="text-primary-400 no-underline">Guides</a> / Firmware Switching
</nav>

<h1>Firmware Switching: Meshtastic &lt;-&gt; MeshCore</h1>
<p class="text-lg text-surface-400 mb-8">Switch between Meshtastic and MeshCore firmware on ESP32-S3 devices. Use a dedicated evaluation device -- never your primary LA-Mesh node.</p>

<div class="p-5 bg-yellow-500/10 border border-yellow-500/30 rounded-lg mb-8">
	<strong class="text-yellow-400">No dual-boot capability.</strong>
	<p class="text-yellow-300/80 mt-2 m-0">MeshCore and Meshtastic use incompatible partition tables, NVS schemas, and radio configurations. Switching requires a full flash erase (~60 seconds total).</p>
</div>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Incompatibility Summary</h2>
	<table class="w-full border-collapse mt-4">
		<thead><tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Aspect</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Meshtastic</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">MeshCore</th></tr></thead>
		<tbody>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Partition table</td><td class="p-3 text-surface-200 border-b border-surface-700">Custom (app + littlefs)</td><td class="p-3 text-surface-200 border-b border-surface-700">Different layout</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Configuration</td><td class="p-3 text-surface-200 border-b border-surface-700">YAML profiles via CLI</td><td class="p-3 text-surface-200 border-b border-surface-700">Web config tool</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Channel format</td><td class="p-3 text-surface-200 border-b border-surface-700">PSK + channel index</td><td class="p-3 text-surface-200 border-b border-surface-700">Room/password model</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Encryption</td><td class="p-3 text-surface-200 border-b border-surface-700">AES-256-CTR + X25519 PKC</td><td class="p-3 text-surface-200 border-b border-surface-700">AES-128-ECB</td></tr>
		</tbody>
	</table>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Before Switching: Back Up</h2>
	<pre class="bg-surface-800 text-primary-400 p-5 rounded-lg overflow-x-auto text-sm leading-relaxed font-mono">{`# Export current Meshtastic config
meshtastic --export-config > backup-meshtastic-$(date +%Y%m%d).yaml

# Record firmware version
meshtastic --info | grep Firmware`}</pre>
	<p class="text-surface-300 mb-4">Flash erase destroys all state. Configuration, message history, node list, and Bluetooth pairings are lost.</p>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Switch to MeshCore (Evaluation)</h2>
	<pre class="bg-surface-800 text-primary-400 p-5 rounded-lg overflow-x-auto text-sm leading-relaxed font-mono">{`# 1. Erase flash (hold BOOT, press RESET, release BOOT first)
just flash-erase /dev/ttyUSB0

# 2. Flash MeshCore via web flasher (recommended)
#    Open https://flasher.meshcore.co.uk in Chrome/Edge
#    Or via CLI:
just flash-meshcore meshcore-firmware.bin /dev/ttyUSB0

# 3. Configure via https://config.meshcore.co.uk`}</pre>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Switch Back to Meshtastic</h2>
	<pre class="bg-surface-800 text-primary-400 p-5 rounded-lg overflow-x-auto text-sm leading-relaxed font-mono">{`# 1. Erase flash
just flash-erase /dev/ttyUSB0

# 2. One-command provisioning (fetch + verify + flash + configure)
just provision station-g2 /dev/ttyUSB0

# Or restore from backup:
meshtastic --configure backup-meshtastic-YYYYMMDD.yaml`}</pre>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Automated Switch Script</h2>
	<pre class="bg-surface-800 text-primary-400 p-5 rounded-lg overflow-x-auto text-sm leading-relaxed font-mono">{`just switch-firmware /dev/ttyUSB0`}</pre>
	<p class="text-surface-300 mb-4">Interactive script that backs up, erases, flashes, and configures in one flow.</p>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Quick Reference</h2>
	<table class="w-full border-collapse mt-4">
		<thead><tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Action</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Time</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Command</th></tr></thead>
		<tbody>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Erase flash</td><td class="p-3 text-surface-200 border-b border-surface-700">~5s</td><td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just flash-erase /dev/ttyUSB0</code></td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Flash + configure Meshtastic</td><td class="p-3 text-surface-200 border-b border-surface-700">~45s</td><td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just provision station-g2 /dev/ttyUSB0</code></td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Flash MeshCore</td><td class="p-3 text-surface-200 border-b border-surface-700">~30s</td><td class="p-3 text-surface-200 border-b border-surface-700">Web flasher or <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just flash-meshcore</code></td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Total switch time</td><td class="p-3 text-surface-200 border-b border-surface-700">~60s</td><td class="p-3 text-surface-200 border-b border-surface-700">Erase + flash + configure</td></tr>
		</tbody>
	</table>
</section>
