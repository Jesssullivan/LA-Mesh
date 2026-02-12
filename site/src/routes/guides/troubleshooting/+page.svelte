<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Troubleshooting - LA-Mesh</title>
</svelte:head>

<nav class="breadcrumb">
	<a href="{base}/guides">Guides</a> / Troubleshooting
</nav>

<h1>Troubleshooting Guide</h1>
<p class="intro">Common issues and solutions for LA-Mesh devices and network.</p>

<section>
	<h2>Device Issues</h2>

	<h3>Device won't power on</h3>
	<table>
		<thead><tr><th>Check</th><th>Action</th></tr></thead>
		<tbody>
			<tr><td>Battery dead</td><td>Charge for at least 30 minutes via USB-C</td></tr>
			<tr><td>Stuck state</td><td>Hold power button for 10+ seconds to force restart</td></tr>
			<tr><td>Hardware failure</td><td>Try a different USB cable, check for physical damage</td></tr>
		</tbody>
	</table>

	<h3>Device not detected on USB</h3>
	<table>
		<thead><tr><th>Check</th><th>Action</th></tr></thead>
		<tbody>
			<tr><td>Cable is charge-only</td><td>Use a data-capable USB-C cable</td></tr>
			<tr><td>Wrong driver</td><td>ESP32-S3 uses built-in USB, CP2102/CH340 for older chips</td></tr>
			<tr><td>Port in use</td><td>Close other serial monitors, check <code>ls /dev/ttyUSB* /dev/ttyACM*</code></td></tr>
			<tr><td>Bootloader mode needed</td><td>Hold BOOT, press RESET, release BOOT</td></tr>
		</tbody>
	</table>
</section>

<section>
	<h2>Network Issues</h2>

	<h3>Can't see other nodes</h3>
	<table>
		<thead><tr><th>Check</th><th>Action</th></tr></thead>
		<tbody>
			<tr><td>Wrong channel PSK</td><td>Verify PSK matches: <code>meshtastic --info</code></td></tr>
			<tr><td>Wrong region</td><td>Must be set to <code>US</code>: <code>meshtastic --set lora.region US</code></td></tr>
			<tr><td>Wrong modem preset</td><td>Must match network: <code>meshtastic --set lora.modem_preset LONG_FAST</code></td></tr>
			<tr><td>Out of range</td><td>Move closer to a known node, check antenna</td></tr>
			<tr><td>Antenna disconnected</td><td>Verify antenna is firmly connected to SMA port</td></tr>
		</tbody>
	</table>

	<h3>Messages not delivering</h3>
	<table>
		<thead><tr><th>Check</th><th>Action</th></tr></thead>
		<tbody>
			<tr><td>Hop limit too low</td><td>Should be 5 for LA-Mesh (check: <code>meshtastic --info</code>)</td></tr>
			<tr><td>Airtime exhausted</td><td>Wait a few minutes (device enforces duty cycle limits)</td></tr>
			<tr><td>Channel congestion</td><td>Too many nodes transmitting; reduce message frequency</td></tr>
			<tr><td>Device role wrong</td><td>ROUTER nodes should have <code>rebroadcast_mode: ALL</code></td></tr>
		</tbody>
	</table>

	<h3>Poor signal quality (low SNR)</h3>
	<table>
		<thead><tr><th>Action</th><th>Expected Improvement</th></tr></thead>
		<tbody>
			<tr><td>Move to open area</td><td>+10-20 dB</td></tr>
			<tr><td>Raise antenna height</td><td>+3-6 dB per doubling of height</td></tr>
			<tr><td>Use external antenna</td><td>+3-10 dB over stock whip</td></tr>
			<tr><td>Reduce distance</td><td>+6 dB per halving of distance</td></tr>
			<tr><td>Clear obstructions</td><td>Trees: -3 to -10 dB, Buildings: -10 to -30 dB</td></tr>
		</tbody>
	</table>
</section>

<section>
	<h2>Firmware Issues</h2>

	<h3>Flash fails</h3>
	<table>
		<thead><tr><th>Error</th><th>Solution</th></tr></thead>
		<tbody>
			<tr><td>"Failed to connect"</td><td>Enter bootloader mode (BOOT + RESET)</td></tr>
			<tr><td>"Invalid head of packet"</td><td>Erase flash first: <code>just flash-erase</code></td></tr>
			<tr><td>"Timed out"</td><td>Try lower baud rate (115200 instead of 921600)</td></tr>
			<tr><td>Permission denied</td><td><code>sudo usermod -aG dialout $USER</code> (re-login)</td></tr>
		</tbody>
	</table>

	<h3>Device stuck in boot loop</h3>
	<ol>
		<li>Enter bootloader mode (BOOT + RESET)</li>
		<li>Erase flash: <code>just flash-erase</code></li>
		<li>Re-flash firmware: <code>just flash-meshtastic firmware.bin</code></li>
		<li>Re-apply configuration profile</li>
	</ol>
</section>

<section>
	<h2>Bridge Issues</h2>

	<h3>SMS bridge not sending</h3>
	<table>
		<thead><tr><th>Check</th><th>Action</th></tr></thead>
		<tbody>
			<tr><td>SMS gateway credentials</td><td>Verify in operator keystore</td></tr>
			<tr><td>MQTT connection</td><td>Check: <code>systemctl status mosquitto</code></td></tr>
			<tr><td>Bridge running</td><td>Check: <code>systemctl status lamesh-sms-bridge</code></td></tr>
			<tr><td>Phone format</td><td>Must be E.164: <code>+12075551234</code></td></tr>
		</tbody>
	</table>

	<h3>MQTT not receiving mesh messages</h3>
	<table>
		<thead><tr><th>Check</th><th>Action</th></tr></thead>
		<tbody>
			<tr><td>meshtasticd running</td><td>Check: <code>systemctl status meshtasticd</code></td></tr>
			<tr><td>MQTT enabled on device</td><td>Verify: <code>meshtastic --info</code> (MQTT section)</td></tr>
			<tr><td>Topic mismatch</td><td>Default: <code>msh/US/2/json/LongFast/+</code></td></tr>
			<tr><td>Mosquitto running</td><td>Check: <code>systemctl status mosquitto</code></td></tr>
		</tbody>
	</table>
</section>

<section>
	<h2>Getting Help</h2>
	<ol>
		<li>Check this troubleshooting guide</li>
		<li>Check <a href="https://meshtastic.org/docs/">Meshtastic documentation</a></li>
		<li>Ask at a community meetup</li>
		<li>Open an issue: <a href="https://github.com/Jesssullivan/LA-Mesh/issues">GitHub Issues</a></li>
	</ol>
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

	h3 {
		margin-top: 2rem;
	}

	table {
		width: 100%;
		border-collapse: collapse;
		margin-top: 0.5rem;
		margin-bottom: 1rem;
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

	code {
		background: #f0f0f0;
		padding: 0.15rem 0.35rem;
		border-radius: 3px;
		font-size: 0.85rem;
	}

	a {
		color: #00d4aa;
	}

	ol {
		padding-left: 1.5rem;
	}

	li {
		margin-bottom: 0.5rem;
	}
</style>
