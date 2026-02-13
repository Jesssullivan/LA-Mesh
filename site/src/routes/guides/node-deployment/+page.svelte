<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Node Deployment - LA-Mesh</title>
</svelte:head>

<nav class="text-sm text-surface-500 mb-4">
	<a href="{base}/guides" class="text-primary-400 no-underline">Guides</a> / Node Deployment
</nav>

<h1>Node Deployment Guide</h1>
<p class="text-lg text-surface-400 mb-8">Site survey, hardware preparation, installation, verification, and monitoring for fixed infrastructure nodes.</p>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Deployment Phases</h2>
	<ol class="text-surface-300 pl-6 mb-4">
		<li class="mb-1">Site survey and approval</li>
		<li class="mb-1">Hardware preparation</li>
		<li class="mb-1">Physical installation</li>
		<li class="mb-1">Configuration and verification</li>
		<li class="mb-1">Monitoring and maintenance</li>
	</ol>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Phase 1: Site Survey</h2>
	<table class="w-full border-collapse mt-4">
		<thead>
			<tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Criterion</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Requirement</th></tr>
		</thead>
		<tbody>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Elevation</td><td class="p-3 text-surface-200 border-b border-surface-700">Highest available point with clear line-of-sight</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Power</td><td class="p-3 text-surface-200 border-b border-surface-700">Continuous 5V USB-C (mains or solar + battery)</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Access</td><td class="p-3 text-surface-200 border-b border-surface-700">Physical access for maintenance (quarterly minimum)</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Permission</td><td class="p-3 text-surface-200 border-b border-surface-700">Written approval from property owner/manager</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">RF environment</td><td class="p-3 text-surface-200 border-b border-surface-700">Minimal 915 MHz interference (check with SDR)</td></tr>
		</tbody>
	</table>
	<p class="text-surface-300 mb-4">Use <a href="https://site.meshtastic.org" class="text-primary-400">Meshtastic Site Planner</a> for terrain analysis and coverage prediction.</p>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Phase 2: Hardware Preparation</h2>
	<ol class="text-surface-300 pl-6 mb-4">
		<li class="mb-1">Flash firmware: <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just provision station-g2 /dev/ttyUSB0</code></li>
		<li class="mb-1">Verify firmware v2.7.15+: <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">meshtastic --info</code></li>
		<li class="mb-1">Run bench test suite before deployment</li>
		<li class="mb-1">Assemble enclosure with cable glands and desiccant</li>
		<li class="mb-1">Test antenna (SWR check if meter available)</li>
	</ol>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Phase 3: Installation</h2>
	<ul class="text-surface-300 pl-6 mb-4">
		<li class="mb-1">Mount enclosure with appropriate hardware (Tapcon for masonry, stainless for wood)</li>
		<li class="mb-1">Route antenna cable with drip loop to prevent water ingress</li>
		<li class="mb-1">Apply dielectric grease to all SMA connections</li>
		<li class="mb-1">Seal cable glands with marine silicone</li>
		<li class="mb-1">Connect power (verify voltage before connecting device)</li>
	</ul>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Phase 4: Verification</h2>
	<pre class="bg-surface-800 text-primary-400 p-5 rounded-lg overflow-x-auto text-sm leading-relaxed font-mono">{`# Verify device is operational
meshtastic --port /dev/ttyUSB0 --info

# Set fixed position for infrastructure node
meshtastic --setlat 44.1003 --setlon -70.2148 --setalt 60

# Run integration tests
./tools/test/integration-tests.sh --port /dev/ttyUSB0`}</pre>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Phase 5: Monitoring</h2>
	<ul class="text-surface-300 pl-6 mb-4">
		<li class="mb-1">Check MQTT telemetry for battery voltage and uptime</li>
		<li class="mb-1">Verify node appears in mesh node list</li>
		<li class="mb-1">Schedule quarterly maintenance visits</li>
		<li class="mb-1">Document site access procedures and emergency contacts</li>
	</ul>
</section>
