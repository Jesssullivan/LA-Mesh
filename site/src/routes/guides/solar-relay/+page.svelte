<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Solar Relay Deployment - LA-Mesh</title>
</svelte:head>

<nav class="text-sm text-surface-500 mb-4">
	<a href="{base}/guides" class="text-primary-400 no-underline">Guides</a> / Solar Relay Deployment
</nav>

<h1>Solar Relay Deployment</h1>
<p class="text-lg text-surface-400 mb-8">Panel sizing, battery calculations, weatherproofing, and seasonal maintenance for solar-powered Station G2 relay nodes at 44.1&deg;N latitude.</p>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Power Budget</h2>
	<table class="w-full border-collapse mt-4">
		<thead><tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Parameter</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Value</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Notes</th></tr></thead>
		<tbody>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Station G2 power draw</td><td class="p-3 text-surface-200 border-b border-surface-700">~0.5 W average</td><td class="p-3 text-surface-200 border-b border-surface-700">TX bursts up to 1.5 W at 30 dBm</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Daily energy</td><td class="p-3 text-surface-200 border-b border-surface-700">~12 Wh</td><td class="p-3 text-surface-200 border-b border-surface-700">0.5 W x 24 hours</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Winter peak sun hours (44.1&deg;N)</td><td class="p-3 text-surface-200 border-b border-surface-700">~3 hours</td><td class="p-3 text-surface-200 border-b border-surface-700">December/January worst case</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Summer peak sun hours</td><td class="p-3 text-surface-200 border-b border-surface-700">~5.5 hours</td><td class="p-3 text-surface-200 border-b border-surface-700">June/July</td></tr>
		</tbody>
	</table>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Recommended Components</h2>
	<table class="w-full border-collapse mt-4">
		<thead><tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Component</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Minimum Spec</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Recommended</th></tr></thead>
		<tbody>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Solar panel</td><td class="p-3 text-surface-200 border-b border-surface-700">10 W</td><td class="p-3 text-surface-200 border-b border-surface-700">20 W (winter headroom)</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Battery</td><td class="p-3 text-surface-200 border-b border-surface-700">12 Ah LiFePO4 (12V)</td><td class="p-3 text-surface-200 border-b border-surface-700">20 Ah LiFePO4 (3+ days autonomy)</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Charge controller</td><td class="p-3 text-surface-200 border-b border-surface-700">PWM 5A</td><td class="p-3 text-surface-200 border-b border-surface-700">MPPT 10A (better low-light performance)</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Voltage regulator</td><td class="p-3 text-surface-200 border-b border-surface-700">12V to 5V USB-C buck converter</td><td class="p-3 text-surface-200 border-b border-surface-700">Rated 3A continuous</td></tr>
		</tbody>
	</table>
	<p class="text-surface-300 mb-4">Station G2 accepts 12V DC input directly -- use this instead of USB when available to avoid buck converter losses.</p>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Panel Mounting</h2>
	<ul class="text-surface-300 pl-6 mb-4">
		<li class="mb-1"><strong>Tilt angle</strong>: Fixed at 44&deg; (equal to latitude) for year-round average</li>
		<li class="mb-1"><strong>Winter optimization</strong>: Tilt to 59&deg; (latitude + 15&deg;) for December-February</li>
		<li class="mb-1"><strong>Summer optimization</strong>: Tilt to 29&deg; (latitude - 15&deg;) for June-August</li>
		<li class="mb-1"><strong>Orientation</strong>: True south (not magnetic south -- ~14&deg; declination in Maine)</li>
		<li class="mb-1"><strong>Shading</strong>: No shading from 9 AM to 3 PM year-round</li>
	</ul>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Weatherproofing</h2>
	<ul class="text-surface-300 pl-6 mb-4">
		<li class="mb-1">IP65+ enclosure for electronics (NEMA 4X rated for outdoor use)</li>
		<li class="mb-1">Cable glands for all wire entry points -- seal with marine silicone</li>
		<li class="mb-1">Drip loop on antenna cable to prevent water ingress at connector</li>
		<li class="mb-1">Dielectric grease on all SMA connections</li>
		<li class="mb-1">Desiccant packets inside enclosure (replace quarterly)</li>
		<li class="mb-1">Mount enclosure on north side of pole/structure (minimize solar heating)</li>
		<li class="mb-1">Ensure drainage holes at bottom of enclosure</li>
	</ul>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Cable Routing</h2>
	<ul class="text-surface-300 pl-6 mb-4">
		<li class="mb-1">UV-resistant conduit for all external cable runs</li>
		<li class="mb-1">Minimum bend radius: 5x cable diameter</li>
		<li class="mb-1">Secure cables every 30 cm with UV-rated zip ties</li>
		<li class="mb-1">Ground the antenna coax shield at the enclosure entry point</li>
		<li class="mb-1">Use outdoor-rated LMR-400 coax for antenna runs over 3 m</li>
	</ul>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Maintenance Schedule</h2>
	<table class="w-full border-collapse mt-4">
		<thead><tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Frequency</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Task</th></tr></thead>
		<tbody>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Monthly</td><td class="p-3 text-surface-200 border-b border-surface-700">Check MQTT telemetry for battery voltage (should be 12.8-13.2V)</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Quarterly</td><td class="p-3 text-surface-200 border-b border-surface-700">Visual inspection: panel, cables, enclosure seal, desiccant</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Bi-annually</td><td class="p-3 text-surface-200 border-b border-surface-700">Clean panel surface, check SMA connections, verify antenna SWR</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Annually</td><td class="p-3 text-surface-200 border-b border-surface-700">Replace desiccant, re-apply dielectric grease, check battery health</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">After storms</td><td class="p-3 text-surface-200 border-b border-surface-700">Inspect for physical damage, check antenna alignment</td></tr>
		</tbody>
	</table>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Provisioning</h2>
	<pre class="bg-surface-800 text-primary-400 p-5 rounded-lg overflow-x-auto text-sm leading-relaxed font-mono">{`# Flash and configure before deployment
just provision station-g2 /dev/ttyUSB0

# Set fixed GPS position (no GPS module needed for fixed relay)
meshtastic --setlat 44.1003 --setlon -70.2148 --setalt 60

# Run bench test suite before deployment
just test-integration /dev/ttyUSB0`}</pre>
	<p class="text-surface-300 mb-4">See <a href="{base}/guides/node-deployment" class="text-primary-400">Node Deployment Guide</a> for full installation procedures.</p>
</section>
