<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Troubleshooting - LA-Mesh</title>
</svelte:head>

<nav class="text-sm text-surface-500 mb-4">
	<a href="{base}/guides" class="text-primary-400 no-underline">Guides</a> / Troubleshooting
</nav>

<h1>Troubleshooting Guide</h1>
<p class="text-lg text-surface-400 mb-8">Common issues and solutions for LA-Mesh devices and network.</p>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Device Issues</h2>

	<h3 class="text-surface-100 mt-8">Device won't power on</h3>
	<table class="w-full border-collapse mt-4">
		<thead><tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Check</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Action</th></tr></thead>
		<tbody>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Battery dead</td><td class="p-3 text-surface-200 border-b border-surface-700">Charge for at least 30 minutes via USB-C</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Stuck state</td><td class="p-3 text-surface-200 border-b border-surface-700">Hold power button for 10+ seconds to force restart</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Hardware failure</td><td class="p-3 text-surface-200 border-b border-surface-700">Try a different USB cable, check for physical damage</td></tr>
		</tbody>
	</table>

	<h3 class="text-surface-100 mt-8">Device not detected on USB</h3>
	<table class="w-full border-collapse mt-4">
		<thead><tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Check</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Action</th></tr></thead>
		<tbody>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Cable is charge-only</td><td class="p-3 text-surface-200 border-b border-surface-700">Use a data-capable USB-C cable</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Wrong driver</td><td class="p-3 text-surface-200 border-b border-surface-700">ESP32-S3 uses built-in USB, CP2102/CH340 for older chips</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Port in use</td><td class="p-3 text-surface-200 border-b border-surface-700">Close other serial monitors, check <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">ls /dev/ttyUSB* /dev/ttyACM*</code></td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Bootloader mode needed</td><td class="p-3 text-surface-200 border-b border-surface-700">Hold BOOT, press RESET, release BOOT</td></tr>
		</tbody>
	</table>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Network Issues</h2>

	<h3 class="text-surface-100 mt-8">Can't see other nodes</h3>
	<table class="w-full border-collapse mt-4">
		<thead><tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Check</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Action</th></tr></thead>
		<tbody>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Wrong channel PSK</td><td class="p-3 text-surface-200 border-b border-surface-700">Verify PSK matches: <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">meshtastic --info</code></td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Wrong region</td><td class="p-3 text-surface-200 border-b border-surface-700">Must be set to <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">US</code>: <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">meshtastic --set lora.region US</code></td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Wrong modem preset</td><td class="p-3 text-surface-200 border-b border-surface-700">Must match network: <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">meshtastic --set lora.modem_preset LONG_FAST</code></td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Out of range</td><td class="p-3 text-surface-200 border-b border-surface-700">Move closer to a known node, check antenna</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Antenna disconnected</td><td class="p-3 text-surface-200 border-b border-surface-700">Verify antenna is firmly connected to SMA port</td></tr>
		</tbody>
	</table>

	<h3 class="text-surface-100 mt-8">Messages not delivering</h3>
	<table class="w-full border-collapse mt-4">
		<thead><tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Check</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Action</th></tr></thead>
		<tbody>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Hop limit too low</td><td class="p-3 text-surface-200 border-b border-surface-700">Should be 5 for LA-Mesh (check: <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">meshtastic --info</code>)</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Airtime exhausted</td><td class="p-3 text-surface-200 border-b border-surface-700">Wait a few minutes (device enforces duty cycle limits)</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Channel congestion</td><td class="p-3 text-surface-200 border-b border-surface-700">Too many nodes transmitting; reduce message frequency</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Device role wrong</td><td class="p-3 text-surface-200 border-b border-surface-700">ROUTER nodes should have <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">rebroadcast_mode: ALL</code></td></tr>
		</tbody>
	</table>

	<h3 class="text-surface-100 mt-8">Poor signal quality (low SNR)</h3>
	<table class="w-full border-collapse mt-4">
		<thead><tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Action</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Expected Improvement</th></tr></thead>
		<tbody>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Move to open area</td><td class="p-3 text-surface-200 border-b border-surface-700">+10-20 dB</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Raise antenna height</td><td class="p-3 text-surface-200 border-b border-surface-700">+3-6 dB per doubling of height</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Use external antenna</td><td class="p-3 text-surface-200 border-b border-surface-700">+3-10 dB over stock whip</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Reduce distance</td><td class="p-3 text-surface-200 border-b border-surface-700">+6 dB per halving of distance</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Clear obstructions</td><td class="p-3 text-surface-200 border-b border-surface-700">Trees: -3 to -10 dB, Buildings: -10 to -30 dB</td></tr>
		</tbody>
	</table>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Firmware Issues</h2>

	<h3 class="text-surface-100 mt-8">Flash fails</h3>
	<table class="w-full border-collapse mt-4">
		<thead><tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Error</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Solution</th></tr></thead>
		<tbody>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">"Failed to connect"</td><td class="p-3 text-surface-200 border-b border-surface-700">Enter bootloader mode (BOOT + RESET)</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">"Invalid head of packet"</td><td class="p-3 text-surface-200 border-b border-surface-700">Erase flash first: <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just flash-erase</code></td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">"Timed out"</td><td class="p-3 text-surface-200 border-b border-surface-700">Try lower baud rate (115200 instead of 921600)</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Permission denied</td><td class="p-3 text-surface-200 border-b border-surface-700"><code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">sudo usermod -aG dialout $USER</code> (re-login)</td></tr>
		</tbody>
	</table>

	<h3 class="text-surface-100 mt-8">Device stuck in boot loop</h3>
	<ol class="text-surface-300 pl-6 mb-4">
		<li class="mb-1">Enter bootloader mode (BOOT + RESET)</li>
		<li class="mb-1">Erase flash: <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just flash-erase</code></li>
		<li class="mb-1">Re-flash firmware: <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just flash-meshtastic firmware.bin</code></li>
		<li class="mb-1">Re-apply configuration profile</li>
	</ol>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Bridge Issues</h2>

	<h3 class="text-surface-100 mt-8">SMS bridge not sending</h3>
	<table class="w-full border-collapse mt-4">
		<thead><tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Check</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Action</th></tr></thead>
		<tbody>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">SMS gateway credentials</td><td class="p-3 text-surface-200 border-b border-surface-700">Verify in operator keystore</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">MQTT connection</td><td class="p-3 text-surface-200 border-b border-surface-700">Check: <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">systemctl status mosquitto</code></td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Bridge running</td><td class="p-3 text-surface-200 border-b border-surface-700">Check: <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">systemctl status lamesh-sms-bridge</code></td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Phone format</td><td class="p-3 text-surface-200 border-b border-surface-700">Must be E.164: <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">+12075551234</code></td></tr>
		</tbody>
	</table>

	<h3 class="text-surface-100 mt-8">MQTT not receiving mesh messages</h3>
	<table class="w-full border-collapse mt-4">
		<thead><tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Check</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Action</th></tr></thead>
		<tbody>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">meshtasticd running</td><td class="p-3 text-surface-200 border-b border-surface-700">Check: <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">systemctl status meshtasticd</code></td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">MQTT enabled on device</td><td class="p-3 text-surface-200 border-b border-surface-700">Verify: <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">meshtastic --info</code> (MQTT section)</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Topic mismatch</td><td class="p-3 text-surface-200 border-b border-surface-700">Default: <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">msh/US/2/json/LongFast/+</code></td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Mosquitto running</td><td class="p-3 text-surface-200 border-b border-surface-700">Check: <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">systemctl status mosquitto</code></td></tr>
		</tbody>
	</table>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Getting Help</h2>
	<ol class="text-surface-300 pl-6 mb-4">
		<li class="mb-1">Check this troubleshooting guide</li>
		<li class="mb-1">Check <a href="https://meshtastic.org/docs/" class="text-primary-400">Meshtastic documentation</a></li>
		<li class="mb-1">Ask at a community meetup</li>
		<li class="mb-1">Open an issue: <a href="https://github.com/Jesssullivan/LA-Mesh/issues" class="text-primary-400">GitHub Issues</a></li>
	</ol>
</section>
