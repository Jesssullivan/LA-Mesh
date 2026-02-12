<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Solar Relay Deployment - LA-Mesh</title>
</svelte:head>

<nav class="breadcrumb">
	<a href="{base}/guides">Guides</a> / Solar Relay Deployment
</nav>

<h1>Solar Relay Deployment</h1>
<p class="intro">Panel sizing, battery calculations, weatherproofing, and seasonal maintenance for solar-powered Station G2 relay nodes at 44.1&deg;N latitude.</p>

<section>
	<h2>Power Budget</h2>
	<table>
		<thead><tr><th>Parameter</th><th>Value</th><th>Notes</th></tr></thead>
		<tbody>
			<tr><td>Station G2 power draw</td><td>~0.5 W average</td><td>TX bursts up to 1.5 W at 30 dBm</td></tr>
			<tr><td>Daily energy</td><td>~12 Wh</td><td>0.5 W x 24 hours</td></tr>
			<tr><td>Winter peak sun hours (44.1&deg;N)</td><td>~3 hours</td><td>December/January worst case</td></tr>
			<tr><td>Summer peak sun hours</td><td>~5.5 hours</td><td>June/July</td></tr>
		</tbody>
	</table>
</section>

<section>
	<h2>Recommended Components</h2>
	<table>
		<thead><tr><th>Component</th><th>Minimum Spec</th><th>Recommended</th></tr></thead>
		<tbody>
			<tr><td>Solar panel</td><td>10 W</td><td>20 W (winter headroom)</td></tr>
			<tr><td>Battery</td><td>12 Ah LiFePO4 (12V)</td><td>20 Ah LiFePO4 (3+ days autonomy)</td></tr>
			<tr><td>Charge controller</td><td>PWM 5A</td><td>MPPT 10A (better low-light performance)</td></tr>
			<tr><td>Voltage regulator</td><td>12V to 5V USB-C buck converter</td><td>Rated 3A continuous</td></tr>
		</tbody>
	</table>
	<p>Station G2 accepts 12V DC input directly -- use this instead of USB when available to avoid buck converter losses.</p>
</section>

<section>
	<h2>Panel Mounting</h2>
	<ul>
		<li><strong>Tilt angle</strong>: Fixed at 44&deg; (equal to latitude) for year-round average</li>
		<li><strong>Winter optimization</strong>: Tilt to 59&deg; (latitude + 15&deg;) for December-February</li>
		<li><strong>Summer optimization</strong>: Tilt to 29&deg; (latitude - 15&deg;) for June-August</li>
		<li><strong>Orientation</strong>: True south (not magnetic south -- ~14&deg; declination in Maine)</li>
		<li><strong>Shading</strong>: No shading from 9 AM to 3 PM year-round</li>
	</ul>
</section>

<section>
	<h2>Weatherproofing</h2>
	<ul>
		<li>IP65+ enclosure for electronics (NEMA 4X rated for outdoor use)</li>
		<li>Cable glands for all wire entry points -- seal with marine silicone</li>
		<li>Drip loop on antenna cable to prevent water ingress at connector</li>
		<li>Dielectric grease on all SMA connections</li>
		<li>Desiccant packets inside enclosure (replace quarterly)</li>
		<li>Mount enclosure on north side of pole/structure (minimize solar heating)</li>
		<li>Ensure drainage holes at bottom of enclosure</li>
	</ul>
</section>

<section>
	<h2>Cable Routing</h2>
	<ul>
		<li>UV-resistant conduit for all external cable runs</li>
		<li>Minimum bend radius: 5x cable diameter</li>
		<li>Secure cables every 30 cm with UV-rated zip ties</li>
		<li>Ground the antenna coax shield at the enclosure entry point</li>
		<li>Use outdoor-rated LMR-400 coax for antenna runs over 3 m</li>
	</ul>
</section>

<section>
	<h2>Maintenance Schedule</h2>
	<table>
		<thead><tr><th>Frequency</th><th>Task</th></tr></thead>
		<tbody>
			<tr><td>Monthly</td><td>Check MQTT telemetry for battery voltage (should be 12.8-13.2V)</td></tr>
			<tr><td>Quarterly</td><td>Visual inspection: panel, cables, enclosure seal, desiccant</td></tr>
			<tr><td>Bi-annually</td><td>Clean panel surface, check SMA connections, verify antenna SWR</td></tr>
			<tr><td>Annually</td><td>Replace desiccant, re-apply dielectric grease, check battery health</td></tr>
			<tr><td>After storms</td><td>Inspect for physical damage, check antenna alignment</td></tr>
		</tbody>
	</table>
</section>

<section>
	<h2>Provisioning</h2>
	<pre class="code">{`# Flash and configure before deployment
just provision station-g2 /dev/ttyUSB0

# Set fixed GPS position (no GPS module needed for fixed relay)
meshtastic --setlat 44.1003 --setlon -70.2148 --setalt 60

# Run bench test suite before deployment
just test-integration /dev/ttyUSB0`}</pre>
	<p>See <a href="{base}/guides/node-deployment">Node Deployment Guide</a> for full installation procedures.</p>
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
	a { color: #00d4aa; }
</style>
