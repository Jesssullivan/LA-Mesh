<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Stealth Mode - LA-Mesh</title>
</svelte:head>

<nav class="text-sm text-surface-500 mb-4">
	<a href="{base}/guides" class="text-primary-400 no-underline">Guides</a> / Stealth Mode
</nav>

<h1>Stealth Mode: Minimizing RF Footprint</h1>
<p class="text-lg text-surface-400 mb-8">Configure a Meshtastic device for minimal RF visibility using CLIENT_HIDDEN mode.</p>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Device Roles Comparison</h2>
	<table class="w-full border-collapse mt-4">
		<thead><tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Role</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Node List</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Broadcasts NodeInfo</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Rebroadcasts</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Sends Position</th></tr></thead>
		<tbody>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">ROUTER</td><td class="p-3 text-surface-200 border-b border-surface-700">Yes</td><td class="p-3 text-surface-200 border-b border-surface-700">Yes</td><td class="p-3 text-surface-200 border-b border-surface-700">Yes (all)</td><td class="p-3 text-surface-200 border-b border-surface-700">Yes</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">CLIENT</td><td class="p-3 text-surface-200 border-b border-surface-700">Yes</td><td class="p-3 text-surface-200 border-b border-surface-700">Yes</td><td class="p-3 text-surface-200 border-b border-surface-700">Yes</td><td class="p-3 text-surface-200 border-b border-surface-700">Yes</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">CLIENT_MUTE</td><td class="p-3 text-surface-200 border-b border-surface-700">Yes</td><td class="p-3 text-surface-200 border-b border-surface-700">Yes</td><td class="p-3 text-surface-200 border-b border-surface-700">No</td><td class="p-3 text-surface-200 border-b border-surface-700">Yes</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700"><strong>CLIENT_HIDDEN</strong></td><td class="p-3 text-surface-200 border-b border-surface-700"><strong>No</strong></td><td class="p-3 text-surface-200 border-b border-surface-700"><strong>No</strong></td><td class="p-3 text-surface-200 border-b border-surface-700"><strong>No</strong></td><td class="p-3 text-surface-200 border-b border-surface-700"><strong>No</strong></td></tr>
		</tbody>
	</table>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Enable CLIENT_HIDDEN</h2>
	<pre class="bg-surface-800 text-primary-400 p-5 rounded-lg overflow-x-auto text-sm leading-relaxed font-mono">{`# Set role to CLIENT_HIDDEN
meshtastic --set device.role CLIENT_HIDDEN

# Disable GPS position broadcast
meshtastic --set position.gps_enabled false
meshtastic --set position.fixed_position false

# Disable NodeInfo broadcast
meshtastic --set device.nodeinfo_broadcast_secs 0`}</pre>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">What CLIENT_HIDDEN Does</h2>
	<ul class="text-surface-300 pl-6 mb-4">
		<li class="mb-1">Device does not appear in other nodes' node lists</li>
		<li class="mb-1">Does not broadcast periodic NodeInfo packets</li>
		<li class="mb-1">Does not rebroadcast other nodes' messages</li>
		<li class="mb-1">Does not share GPS position</li>
		<li class="mb-1">Can still send and receive messages normally</li>
		<li class="mb-1">Can still use PKC for encrypted DMs</li>
	</ul>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Limitations</h2>
	<ul class="text-surface-300 pl-6 mb-4">
		<li class="mb-1">When you <em>send</em> a message, your transmission is still detectable via SDR</li>
		<li class="mb-1">Your device's radio address is visible in packet headers (encrypted payload, but address is plain)</li>
		<li class="mb-1">Does not protect against traffic analysis or direction finding</li>
		<li class="mb-1">Reduces mesh resilience (hidden nodes don't relay)</li>
	</ul>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">When to Use</h2>
	<ul class="text-surface-300 pl-6 mb-4">
		<li class="mb-1">Situations requiring location privacy</li>
		<li class="mb-1">Operating in areas with potential surveillance</li>
		<li class="mb-1">Personal preference for minimal network footprint</li>
	</ul>
	<p class="text-surface-300 mb-4">For maximum operational security, combine with <a href="{base}/curriculum/tails" class="text-primary-400">TAILS OS</a> and air-gapped workflows.</p>
</section>
