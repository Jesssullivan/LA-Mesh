<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Bench Testing - LA-Mesh</title>
</svelte:head>

<nav class="breadcrumb">
	<a href="{base}/guides">Guides</a> / Bench Testing
</nav>

<h1>Bench Testing Protocol</h1>
<p class="intro">6 structured test protocols to establish baseline RF performance before field deployment.</p>

<section>
	<h2>Equipment Needed</h2>
	<ul>
		<li>2+ configured Meshtastic devices (v2.7.15+)</li>
		<li>USB cables for serial connection</li>
		<li>Laptop with meshtastic CLI</li>
		<li>Notebook for recording observations</li>
		<li>Tape measure or known distances</li>
	</ul>
</section>

<section>
	<h2>Test 1: Basic Communication (Indoor)</h2>
	<p>Verify two devices can exchange messages at close range.</p>
	<pre class="code">{`# On device A
meshtastic --port /dev/ttyUSB0 --sendtext "TEST-1-$(date +%s)"

# On device B -- verify message received
meshtastic --port /dev/ttyACM0 --info`}</pre>
	<table>
		<thead><tr><th>Metric</th><th>Expected</th></tr></thead>
		<tbody>
			<tr><td>Delivery</td><td>100% at &lt;5m indoor</td></tr>
			<tr><td>Latency</td><td>&lt;5 seconds</td></tr>
			<tr><td>SNR</td><td>&gt;10 dB</td></tr>
		</tbody>
	</table>
</section>

<section>
	<h2>Test 2: Indoor Range</h2>
	<p>Walk devices to opposite ends of building. Record SNR/RSSI at each distance.</p>
</section>

<section>
	<h2>Test 3: Outdoor Range</h2>
	<p>Open field test. Walk apart in 100m increments, recording SNR/RSSI. Note first packet loss distance.</p>
</section>

<section>
	<h2>Test 4: Multi-Hop</h2>
	<p>Place 3+ devices in a line. Verify messages hop through intermediate nodes.</p>
	<pre class="code">{`meshtastic --traceroute '!<node-id>'`}</pre>
</section>

<section>
	<h2>Test 5: Antenna Comparison</h2>
	<p>Swap antennas on same device at same location. Record SNR/RSSI for stock vs upgraded antenna.</p>
</section>

<section>
	<h2>Test 6: Battery Life</h2>
	<p>Fully charge device, enable periodic telemetry, record time until shutdown. Document device role and screen settings.</p>
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
</style>
