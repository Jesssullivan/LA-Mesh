<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Bench Testing - LA-Mesh</title>
</svelte:head>

<nav class="text-sm text-surface-500 mb-4">
	<a href="{base}/guides" class="text-primary-400 no-underline">Guides</a> / Bench Testing
</nav>

<h1>Bench Testing Protocol</h1>
<p class="text-lg text-surface-400 mb-8">6 structured test protocols to establish baseline RF performance before field deployment.</p>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Equipment Needed</h2>
	<ul class="text-surface-300 pl-6 mb-4">
		<li class="mb-1">2+ configured Meshtastic devices (v2.7.15+)</li>
		<li class="mb-1">USB cables for serial connection</li>
		<li class="mb-1">Laptop with meshtastic CLI</li>
		<li class="mb-1">Notebook for recording observations</li>
		<li class="mb-1">Tape measure or known distances</li>
	</ul>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Test 1: Basic Communication (Indoor)</h2>
	<p class="text-surface-300 mb-4">Verify two devices can exchange messages at close range.</p>
	<pre class="bg-surface-800 text-primary-400 p-5 rounded-lg overflow-x-auto text-sm leading-relaxed font-mono">{`# On device A
meshtastic --port /dev/ttyUSB0 --sendtext "TEST-1-$(date +%s)"

# On device B -- verify message received
meshtastic --port /dev/ttyACM0 --info`}</pre>
	<table class="w-full border-collapse mt-4">
		<thead><tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Metric</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Expected</th></tr></thead>
		<tbody>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Delivery</td><td class="p-3 text-surface-200 border-b border-surface-700">100% at &lt;5m indoor</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Latency</td><td class="p-3 text-surface-200 border-b border-surface-700">&lt;5 seconds</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">SNR</td><td class="p-3 text-surface-200 border-b border-surface-700">&gt;10 dB</td></tr>
		</tbody>
	</table>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Test 2: Indoor Range</h2>
	<p class="text-surface-300 mb-4">Walk devices to opposite ends of building. Record SNR/RSSI at each distance.</p>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Test 3: Outdoor Range</h2>
	<p class="text-surface-300 mb-4">Open field test. Walk apart in 100m increments, recording SNR/RSSI. Note first packet loss distance.</p>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Test 4: Multi-Hop</h2>
	<p class="text-surface-300 mb-4">Place 3+ devices in a line. Verify messages hop through intermediate nodes.</p>
	<pre class="bg-surface-800 text-primary-400 p-5 rounded-lg overflow-x-auto text-sm leading-relaxed font-mono">{`meshtastic --traceroute '!<node-id>'`}</pre>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Test 5: Antenna Comparison</h2>
	<p class="text-surface-300 mb-4">Swap antennas on same device at same location. Record SNR/RSSI for stock vs upgraded antenna.</p>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Test 6: Battery Life</h2>
	<p class="text-surface-300 mb-4">Fully charge device, enable periodic telemetry, record time until shutdown. Document device role and screen settings.</p>
</section>
