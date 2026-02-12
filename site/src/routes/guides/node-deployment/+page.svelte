<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Node Deployment - LA-Mesh</title>
</svelte:head>

<nav class="breadcrumb">
	<a href="{base}/guides">Guides</a> / Node Deployment
</nav>

<h1>Node Deployment Guide</h1>
<p class="intro">Site survey, hardware preparation, installation, verification, and monitoring for fixed infrastructure nodes.</p>

<section>
	<h2>Deployment Phases</h2>
	<ol>
		<li>Site survey and approval</li>
		<li>Hardware preparation</li>
		<li>Physical installation</li>
		<li>Configuration and verification</li>
		<li>Monitoring and maintenance</li>
	</ol>
</section>

<section>
	<h2>Phase 1: Site Survey</h2>
	<table>
		<thead>
			<tr><th>Criterion</th><th>Requirement</th></tr>
		</thead>
		<tbody>
			<tr><td>Elevation</td><td>Highest available point with clear line-of-sight</td></tr>
			<tr><td>Power</td><td>Continuous 5V USB-C (mains or solar + battery)</td></tr>
			<tr><td>Access</td><td>Physical access for maintenance (quarterly minimum)</td></tr>
			<tr><td>Permission</td><td>Written approval from property owner/manager</td></tr>
			<tr><td>RF environment</td><td>Minimal 915 MHz interference (check with SDR)</td></tr>
		</tbody>
	</table>
	<p>Use <a href="https://site.meshtastic.org">Meshtastic Site Planner</a> for terrain analysis and coverage prediction.</p>
</section>

<section>
	<h2>Phase 2: Hardware Preparation</h2>
	<ol>
		<li>Flash firmware: <code>just provision station-g2 /dev/ttyUSB0</code></li>
		<li>Verify firmware v2.7.15+: <code>meshtastic --info</code></li>
		<li>Run bench test suite before deployment</li>
		<li>Assemble enclosure with cable glands and desiccant</li>
		<li>Test antenna (SWR check if meter available)</li>
	</ol>
</section>

<section>
	<h2>Phase 3: Installation</h2>
	<ul>
		<li>Mount enclosure with appropriate hardware (Tapcon for masonry, stainless for wood)</li>
		<li>Route antenna cable with drip loop to prevent water ingress</li>
		<li>Apply dielectric grease to all SMA connections</li>
		<li>Seal cable glands with marine silicone</li>
		<li>Connect power (verify voltage before connecting device)</li>
	</ul>
</section>

<section>
	<h2>Phase 4: Verification</h2>
	<pre class="code">{`# Verify device is operational
meshtastic --port /dev/ttyUSB0 --info

# Set fixed position for infrastructure node
meshtastic --setlat 44.1003 --setlon -70.2148 --setalt 60

# Run integration tests
./tools/test/integration-tests.sh --port /dev/ttyUSB0`}</pre>
</section>

<section>
	<h2>Phase 5: Monitoring</h2>
	<ul>
		<li>Check MQTT telemetry for battery voltage and uptime</li>
		<li>Verify node appears in mesh node list</li>
		<li>Schedule quarterly maintenance visits</li>
		<li>Document site access procedures and emergency contacts</li>
	</ul>
</section>

<style>
	.breadcrumb { font-size: 0.85rem; color: #888; margin-bottom: 1rem; }
	.breadcrumb a { color: #00d4aa; text-decoration: none; }
	.intro { font-size: 1.1rem; color: #555; margin-bottom: 2rem; }
	section { margin-bottom: 3rem; }
	.code { background: #1a1a2e; color: #00d4aa; padding: 1.25rem; border-radius: 8px; overflow-x: auto; font-size: 0.85rem; line-height: 1.5; }
	code { background: #f0f0f0; padding: 0.15rem 0.35rem; border-radius: 3px; font-size: 0.85rem; }
	table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
	th, td { padding: 0.75rem; border: 1px solid #ddd; text-align: left; }
	th { background: #f5f5f5; font-weight: 600; }
</style>
