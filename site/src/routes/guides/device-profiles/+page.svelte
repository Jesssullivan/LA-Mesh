<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Device Profiles - LA-Mesh</title>
</svelte:head>

<nav class="breadcrumb">
	<a href="{base}/guides">Guides</a> / Device Profiles
</nav>

<h1>Device Profiles</h1>
<p class="intro">LA-Mesh uses pre-configured YAML profiles optimized for each device role. Profiles set radio parameters, power management, GPS intervals, and network behavior.</p>

<section>
	<h2>Which Profile Do I Need?</h2>
	<div class="flowchart">
		<div class="flow-step">Is this a fixed relay on a rooftop or tower?</div>
		<div class="flow-arrow">Yes</div>
		<div class="flow-result">station-g2-router</div>
		<div class="flow-arrow">No</div>
		<div class="flow-step">Is this a gateway with internet access?</div>
		<div class="flow-arrow">Yes</div>
		<div class="flow-result">meshadv-mini-gateway</div>
		<div class="flow-arrow">No</div>
		<div class="flow-step">Is this a T-Deck Pro (e-ink screen)?</div>
		<div class="flow-arrow">Yes</div>
		<div class="flow-result">tdeck-pro-eink-client</div>
		<div class="flow-arrow">No</div>
		<div class="flow-result">tdeck-plus-client</div>
	</div>
</section>

<section>
	<h2>Profile Details</h2>

	<div class="profiles">
		<div class="profile">
			<div class="profile-header">
				<h3>station-g2-router</h3>
				<span class="role-badge router">ROUTER</span>
			</div>
			<p>High-power relay for rooftop and tower deployment. Always-on, no power saving.</p>
			<table>
				<tbody>
					<tr><td>Device Role</td><td>ROUTER</td></tr>
					<tr><td>TX Power</td><td>30 dBm (1 W)</td></tr>
					<tr><td>Modem Preset</td><td>LONG_FAST</td></tr>
					<tr><td>Hop Limit</td><td>5</td></tr>
					<tr><td>Position Broadcast</td><td>Every 15 min (fixed position)</td></tr>
					<tr><td>Bluetooth</td><td>Disabled</td></tr>
					<tr><td>WiFi</td><td>Disabled</td></tr>
					<tr><td>Power Saving</td><td>Disabled (never sleeps)</td></tr>
				</tbody>
			</table>
		</div>

		<div class="profile">
			<div class="profile-header">
				<h3>tdeck-plus-client</h3>
				<span class="role-badge client">CLIENT</span>
			</div>
			<p>Portable device for community members. Balanced power and connectivity.</p>
			<table>
				<tbody>
					<tr><td>Device Role</td><td>CLIENT</td></tr>
					<tr><td>TX Power</td><td>22 dBm</td></tr>
					<tr><td>Modem Preset</td><td>LONG_FAST</td></tr>
					<tr><td>Hop Limit</td><td>5</td></tr>
					<tr><td>GPS Interval</td><td>Every 2 min</td></tr>
					<tr><td>Position Broadcast</td><td>Every 15 min</td></tr>
					<tr><td>Bluetooth</td><td>Enabled (for phone app)</td></tr>
					<tr><td>Power Saving</td><td>Light sleep when idle</td></tr>
				</tbody>
			</table>
		</div>

		<div class="profile">
			<div class="profile-header">
				<h3>tdeck-pro-eink-client</h3>
				<span class="role-badge client">CLIENT</span>
			</div>
			<p>E-ink device optimized for maximum battery life. Aggressive power saving.</p>
			<table>
				<tbody>
					<tr><td>Device Role</td><td>CLIENT</td></tr>
					<tr><td>TX Power</td><td>22 dBm</td></tr>
					<tr><td>Modem Preset</td><td>LONG_FAST</td></tr>
					<tr><td>Hop Limit</td><td>5</td></tr>
					<tr><td>GPS Interval</td><td>Every 5 min</td></tr>
					<tr><td>Position Broadcast</td><td>Every 30 min</td></tr>
					<tr><td>Bluetooth</td><td>Enabled</td></tr>
					<tr><td>Power Saving</td><td>Deep sleep when idle</td></tr>
				</tbody>
			</table>
		</div>

		<div class="profile">
			<div class="profile-header">
				<h3>meshadv-mini-gateway</h3>
				<span class="role-badge gateway">ROUTER_CLIENT</span>
			</div>
			<p>Raspberry Pi HAT for SMS/email bridge and MQTT gateway duty. Always-on, wired power.</p>
			<table>
				<tbody>
					<tr><td>Device Role</td><td>ROUTER_CLIENT</td></tr>
					<tr><td>TX Power</td><td>22 dBm</td></tr>
					<tr><td>Modem Preset</td><td>LONG_FAST</td></tr>
					<tr><td>Hop Limit</td><td>5</td></tr>
					<tr><td>MQTT</td><td>Enabled (local Mosquitto)</td></tr>
					<tr><td>Serial</td><td>Enabled (debug logging)</td></tr>
					<tr><td>Power Saving</td><td>Disabled (always-on)</td></tr>
				</tbody>
			</table>
		</div>
	</div>
</section>

<section>
	<h2>Applying a Profile</h2>
	<pre class="code">{`# Apply with auto-backup
just configure-profile station-g2-router /dev/ttyUSB0

# Apply channels (reads PSK from environment)
just configure-channels /dev/ttyUSB0

# Verify configuration
meshtastic --port /dev/ttyUSB0 --info`}</pre>
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

	.flowchart {
		display: flex;
		flex-wrap: wrap;
		align-items: center;
		gap: 0.5rem;
		padding: 1.5rem;
		background: #f9f9f9;
		border-radius: 8px;
	}

	.flow-step {
		background: white;
		border: 1px solid #ddd;
		padding: 0.5rem 1rem;
		border-radius: 6px;
		font-weight: 500;
	}

	.flow-arrow {
		color: #00d4aa;
		font-weight: bold;
		font-size: 0.85rem;
	}

	.flow-result {
		background: #1a1a2e;
		color: #00d4aa;
		padding: 0.5rem 1rem;
		border-radius: 6px;
		font-family: monospace;
	}

	.profiles {
		display: grid;
		gap: 1.5rem;
	}

	.profile {
		padding: 1.5rem;
		border: 1px solid #ddd;
		border-radius: 8px;
		background: white;
	}

	.profile-header {
		display: flex;
		align-items: center;
		gap: 1rem;
		margin-bottom: 0.75rem;
	}

	.profile h3 {
		margin: 0;
		font-family: monospace;
	}

	.role-badge {
		padding: 0.15rem 0.5rem;
		border-radius: 4px;
		font-size: 0.75rem;
		font-weight: 600;
		color: white;
	}

	.role-badge.router { background: #e74c3c; }
	.role-badge.client { background: #00d4aa; }
	.role-badge.gateway { background: #3498db; }

	.profile p {
		color: #555;
		margin: 0 0 1rem;
	}

	table {
		width: 100%;
		border-collapse: collapse;
	}

	td {
		padding: 0.5rem 0.75rem;
		border: 1px solid #eee;
		font-size: 0.9rem;
	}

	td:first-child {
		font-weight: 600;
		color: #555;
		width: 40%;
	}

	.code {
		background: #1a1a2e;
		color: #00d4aa;
		padding: 1.25rem;
		border-radius: 8px;
		overflow-x: auto;
		font-size: 0.85rem;
		line-height: 1.5;
	}
</style>
