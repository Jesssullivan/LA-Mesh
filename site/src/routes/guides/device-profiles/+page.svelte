<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Device Profiles - LA-Mesh</title>
</svelte:head>

<nav class="text-sm text-surface-500 mb-4">
	<a href="{base}/guides" class="text-primary-400 no-underline">Guides</a> / Device Profiles
</nav>

<h1>Device Profiles</h1>
<p class="text-lg text-surface-400 mb-8">LA-Mesh uses pre-configured YAML profiles optimized for each device role. Profiles set radio parameters, power management, GPS intervals, and network behavior.</p>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Which Profile Do I Need?</h2>
	<div class="flex flex-wrap items-center gap-2 p-6 bg-surface-800 rounded-lg">
		<div class="bg-surface-700 border border-surface-600 px-4 py-2 rounded-md font-medium text-surface-200">Is this a fixed relay on a rooftop or tower?</div>
		<div class="text-primary-400 font-bold text-sm">Yes</div>
		<div class="bg-surface-900 text-primary-400 px-4 py-2 rounded-md font-mono">station-g2-router</div>
		<div class="text-primary-400 font-bold text-sm">No</div>
		<div class="bg-surface-700 border border-surface-600 px-4 py-2 rounded-md font-medium text-surface-200">Is this a gateway with internet access?</div>
		<div class="text-primary-400 font-bold text-sm">Yes</div>
		<div class="bg-surface-900 text-primary-400 px-4 py-2 rounded-md font-mono">meshadv-mini-gateway</div>
		<div class="text-primary-400 font-bold text-sm">No</div>
		<div class="bg-surface-700 border border-surface-600 px-4 py-2 rounded-md font-medium text-surface-200">Is this a T-Deck Pro (e-ink screen)?</div>
		<div class="text-primary-400 font-bold text-sm">Yes</div>
		<div class="bg-surface-900 text-primary-400 px-4 py-2 rounded-md font-mono">tdeck-pro-eink-client</div>
		<div class="text-primary-400 font-bold text-sm">No</div>
		<div class="bg-surface-900 text-primary-400 px-4 py-2 rounded-md font-mono">tdeck-plus-client</div>
	</div>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Profile Details</h2>

	<div class="grid gap-6">
		<div class="p-6 border border-surface-700 rounded-lg bg-surface-800">
			<div class="flex items-center gap-4 mb-3">
				<h3 class="m-0 font-mono text-surface-100">station-g2-router</h3>
				<span class="px-2 py-0.5 rounded text-xs font-semibold text-white bg-red-500">ROUTER</span>
			</div>
			<p class="text-surface-400 m-0 mb-4">High-power relay for rooftop and tower deployment. Always-on, no power saving.</p>
			<table class="w-full border-collapse mt-4">
				<tbody>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">Device Role</td><td class="p-3 text-surface-200 border-b border-surface-700">ROUTER</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">TX Power</td><td class="p-3 text-surface-200 border-b border-surface-700">30 dBm (1 W)</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">Modem Preset</td><td class="p-3 text-surface-200 border-b border-surface-700">LONG_FAST</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">Hop Limit</td><td class="p-3 text-surface-200 border-b border-surface-700">5</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">Position Broadcast</td><td class="p-3 text-surface-200 border-b border-surface-700">Every 15 min (fixed position)</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">Bluetooth</td><td class="p-3 text-surface-200 border-b border-surface-700">Disabled</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">WiFi</td><td class="p-3 text-surface-200 border-b border-surface-700">Disabled</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">Power Saving</td><td class="p-3 text-surface-200 border-b border-surface-700">Disabled (never sleeps)</td></tr>
				</tbody>
			</table>
		</div>

		<div class="p-6 border border-surface-700 rounded-lg bg-surface-800">
			<div class="flex items-center gap-4 mb-3">
				<h3 class="m-0 font-mono text-surface-100">tdeck-plus-client</h3>
				<span class="px-2 py-0.5 rounded text-xs font-semibold text-white bg-primary-500">CLIENT</span>
			</div>
			<p class="text-surface-400 m-0 mb-4">Portable device for community members. Balanced power and connectivity.</p>
			<table class="w-full border-collapse mt-4">
				<tbody>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">Device Role</td><td class="p-3 text-surface-200 border-b border-surface-700">CLIENT</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">TX Power</td><td class="p-3 text-surface-200 border-b border-surface-700">22 dBm</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">Modem Preset</td><td class="p-3 text-surface-200 border-b border-surface-700">LONG_FAST</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">Hop Limit</td><td class="p-3 text-surface-200 border-b border-surface-700">5</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">GPS Interval</td><td class="p-3 text-surface-200 border-b border-surface-700">Every 2 min</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">Position Broadcast</td><td class="p-3 text-surface-200 border-b border-surface-700">Every 15 min</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">Bluetooth</td><td class="p-3 text-surface-200 border-b border-surface-700">Enabled (for phone app)</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">Power Saving</td><td class="p-3 text-surface-200 border-b border-surface-700">Light sleep when idle</td></tr>
				</tbody>
			</table>
		</div>

		<div class="p-6 border border-surface-700 rounded-lg bg-surface-800">
			<div class="flex items-center gap-4 mb-3">
				<h3 class="m-0 font-mono text-surface-100">tdeck-pro-eink-client</h3>
				<span class="px-2 py-0.5 rounded text-xs font-semibold text-white bg-primary-500">CLIENT</span>
			</div>
			<p class="text-surface-400 m-0 mb-4">E-ink device optimized for maximum battery life. Aggressive power saving.</p>
			<table class="w-full border-collapse mt-4">
				<tbody>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">Device Role</td><td class="p-3 text-surface-200 border-b border-surface-700">CLIENT</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">TX Power</td><td class="p-3 text-surface-200 border-b border-surface-700">22 dBm</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">Modem Preset</td><td class="p-3 text-surface-200 border-b border-surface-700">LONG_FAST</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">Hop Limit</td><td class="p-3 text-surface-200 border-b border-surface-700">5</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">GPS Interval</td><td class="p-3 text-surface-200 border-b border-surface-700">Every 5 min</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">Position Broadcast</td><td class="p-3 text-surface-200 border-b border-surface-700">Every 30 min</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">Bluetooth</td><td class="p-3 text-surface-200 border-b border-surface-700">Enabled</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">Power Saving</td><td class="p-3 text-surface-200 border-b border-surface-700">Deep sleep when idle</td></tr>
				</tbody>
			</table>
		</div>

		<div class="p-6 border border-surface-700 rounded-lg bg-surface-800">
			<div class="flex items-center gap-4 mb-3">
				<h3 class="m-0 font-mono text-surface-100">meshadv-mini-gateway</h3>
				<span class="px-2 py-0.5 rounded text-xs font-semibold text-white bg-blue-500">ROUTER_CLIENT</span>
			</div>
			<p class="text-surface-400 m-0 mb-4">Raspberry Pi HAT for SMS/email bridge and MQTT gateway duty. Always-on, wired power.</p>
			<table class="w-full border-collapse mt-4">
				<tbody>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">Device Role</td><td class="p-3 text-surface-200 border-b border-surface-700">ROUTER_CLIENT</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">TX Power</td><td class="p-3 text-surface-200 border-b border-surface-700">22 dBm</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">Modem Preset</td><td class="p-3 text-surface-200 border-b border-surface-700">LONG_FAST</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">Hop Limit</td><td class="p-3 text-surface-200 border-b border-surface-700">5</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">MQTT</td><td class="p-3 text-surface-200 border-b border-surface-700">Enabled (local Mosquitto)</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">Serial</td><td class="p-3 text-surface-200 border-b border-surface-700">Enabled (debug logging)</td></tr>
					<tr><td class="p-3 text-surface-200 border-b border-surface-700 font-semibold w-2/5">Power Saving</td><td class="p-3 text-surface-200 border-b border-surface-700">Disabled (always-on)</td></tr>
				</tbody>
			</table>
		</div>
	</div>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Applying a Profile</h2>
	<pre class="bg-surface-800 text-primary-400 p-5 rounded-lg overflow-x-auto text-sm leading-relaxed font-mono">{`# Apply with auto-backup
just configure-profile station-g2-router /dev/ttyUSB0

# Apply channels (reads PSK from operator keystore)
just configure-channels /dev/ttyUSB0

# Verify configuration
meshtastic --port /dev/ttyUSB0 --info`}</pre>
</section>
