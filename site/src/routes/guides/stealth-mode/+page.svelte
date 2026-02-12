<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Stealth Mode - LA-Mesh</title>
</svelte:head>

<nav class="breadcrumb">
	<a href="{base}/guides">Guides</a> / Stealth Mode
</nav>

<h1>Stealth Mode: Minimizing RF Footprint</h1>
<p class="intro">Configure a Meshtastic device for minimal RF visibility using CLIENT_HIDDEN mode.</p>

<section>
	<h2>Device Roles Comparison</h2>
	<table>
		<thead><tr><th>Role</th><th>Node List</th><th>Broadcasts NodeInfo</th><th>Rebroadcasts</th><th>Sends Position</th></tr></thead>
		<tbody>
			<tr><td>ROUTER</td><td>Yes</td><td>Yes</td><td>Yes (all)</td><td>Yes</td></tr>
			<tr><td>CLIENT</td><td>Yes</td><td>Yes</td><td>Yes</td><td>Yes</td></tr>
			<tr><td>CLIENT_MUTE</td><td>Yes</td><td>Yes</td><td>No</td><td>Yes</td></tr>
			<tr><td><strong>CLIENT_HIDDEN</strong></td><td><strong>No</strong></td><td><strong>No</strong></td><td><strong>No</strong></td><td><strong>No</strong></td></tr>
		</tbody>
	</table>
</section>

<section>
	<h2>Enable CLIENT_HIDDEN</h2>
	<pre class="code">{`# Set role to CLIENT_HIDDEN
meshtastic --set device.role CLIENT_HIDDEN

# Disable GPS position broadcast
meshtastic --set position.gps_enabled false
meshtastic --set position.fixed_position false

# Disable NodeInfo broadcast
meshtastic --set device.nodeinfo_broadcast_secs 0`}</pre>
</section>

<section>
	<h2>What CLIENT_HIDDEN Does</h2>
	<ul>
		<li>Device does not appear in other nodes' node lists</li>
		<li>Does not broadcast periodic NodeInfo packets</li>
		<li>Does not rebroadcast other nodes' messages</li>
		<li>Does not share GPS position</li>
		<li>Can still send and receive messages normally</li>
		<li>Can still use PKC for encrypted DMs</li>
	</ul>
</section>

<section>
	<h2>Limitations</h2>
	<ul>
		<li>When you <em>send</em> a message, your transmission is still detectable via SDR</li>
		<li>Your device's radio address is visible in packet headers (encrypted payload, but address is plain)</li>
		<li>Does not protect against traffic analysis or direction finding</li>
		<li>Reduces mesh resilience (hidden nodes don't relay)</li>
	</ul>
</section>

<section>
	<h2>When to Use</h2>
	<ul>
		<li>Situations requiring location privacy</li>
		<li>Operating in areas with potential surveillance</li>
		<li>Personal preference for minimal network footprint</li>
	</ul>
	<p>For maximum operational security, combine with <a href="{base}/curriculum/tails">TAILS OS</a> and air-gapped workflows.</p>
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
