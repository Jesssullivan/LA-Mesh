<script>
	import { base } from '$app/paths';
	import StatusBadge from '$lib/components/StatusBadge.svelte';

	// Injected from firmware/manifest.json at build time via vite.config.ts
	const fwVersion = __FW_VERSION__;
	const fwVersionFull = __FW_VERSION_FULL__;
	const fwMinVersion = __FW_MIN_VERSION__;
	const fwBuildSource = __FW_BUILD_SOURCE__;
	const fwLastUpdated = __FW_LAST_UPDATED__;
	const fwSha256G2 = __FW_SHA256_G2__;
	const fwTargetG2 = __FW_TARGET_G2__;
</script>

<svelte:head>
	<title>LA-Mesh - Community LoRa Mesh Network</title>
</svelte:head>

<!-- Hero -->
<section class="text-center py-12 border-b border-surface-700 mb-8">
	<h1 class="text-5xl font-bold font-mono text-primary-400 m-0">LA-Mesh</h1>
	<p class="text-xl text-surface-400 mt-2 mb-4">Community LoRa mesh network for Southern Maine</p>
	<div class="flex justify-center gap-3 mt-6 flex-wrap">
		<img src="https://github.com/Jesssullivan/LA-Mesh/actions/workflows/build-firmware.yml/badge.svg" alt="Build Firmware" class="h-5" />
		<img src="https://github.com/Jesssullivan/LA-Mesh/actions/workflows/deploy-pages.yml/badge.svg" alt="Deploy Pages" class="h-5" />
		<img src="https://github.com/Jesssullivan/LA-Mesh/actions/workflows/ci.yml/badge.svg" alt="CI" class="h-5" />
	</div>
</section>

<!-- Nav Cards -->
<section class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
	<a href="{base}/guides/community-onboarding" class="p-6 border border-surface-700 rounded-lg bg-surface-800 no-underline text-inherit hover:border-primary-500 transition-colors">
		<div class="flex items-center justify-between mb-2">
			<h2 class="text-lg font-bold text-surface-50 m-0">Join the Mesh</h2>
			<StatusBadge status="working" />
		</div>
		<p class="text-surface-400 text-sm m-0">Get a device, learn the basics, start communicating</p>
	</a>

	<a href="{base}/devices" class="p-6 border border-surface-700 rounded-lg bg-surface-800 no-underline text-inherit hover:border-primary-500 transition-colors">
		<div class="flex items-center justify-between mb-2">
			<h2 class="text-lg font-bold text-surface-50 m-0">Devices</h2>
			<StatusBadge status="working" />
		</div>
		<p class="text-surface-400 text-sm m-0">Station G2, T-Deck Plus/Pro, FireElmo-SDR, HackRF</p>
	</a>

	<a href="{base}/architecture" class="p-6 border border-surface-700 rounded-lg bg-surface-800 no-underline text-inherit hover:border-primary-500 transition-colors">
		<div class="flex items-center justify-between mb-2">
			<h2 class="text-lg font-bold text-surface-50 m-0">Architecture</h2>
			<StatusBadge status="working" />
		</div>
		<p class="text-surface-400 text-sm m-0">Network topology, ADRs, protocol comparison, bridge design</p>
	</a>
</section>

<!-- Firmware Status -->
<section class="mb-12">
	<h2 class="text-center text-surface-50 mb-6">Firmware Status</h2>
	<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
		<div class="p-4 bg-surface-800 border border-surface-700 rounded-lg">
			<span class="text-xs text-surface-500 uppercase tracking-wider">Version</span>
			<p class="font-mono text-primary-400 text-lg m-0 mt-1">v{fwVersion}</p>
		</div>
		<div class="p-4 bg-surface-800 border border-surface-700 rounded-lg">
			<span class="text-xs text-surface-500 uppercase tracking-wider">Min Required</span>
			<p class="font-mono text-primary-400 text-lg m-0 mt-1">v{fwMinVersion}+</p>
		</div>
		<div class="p-4 bg-surface-800 border border-surface-700 rounded-lg">
			<span class="text-xs text-surface-500 uppercase tracking-wider">Build Source</span>
			<p class="font-mono text-primary-400 text-lg m-0 mt-1">{fwBuildSource === 'custom' ? 'Custom (LA-Mesh)' : 'Upstream'}</p>
		</div>
		<div class="p-4 bg-surface-800 border border-surface-700 rounded-lg">
			<span class="text-xs text-surface-500 uppercase tracking-wider">Target</span>
			<p class="font-mono text-primary-400 text-lg m-0 mt-1">{fwTargetG2}</p>
		</div>
		<div class="p-4 bg-surface-800 border border-surface-700 rounded-lg">
			<span class="text-xs text-surface-500 uppercase tracking-wider">Full Build</span>
			<p class="font-mono text-primary-400 text-sm m-0 mt-1">{fwVersionFull}</p>
		</div>
		<div class="p-4 bg-surface-800 border border-surface-700 rounded-lg">
			<span class="text-xs text-surface-500 uppercase tracking-wider">Manifest Updated</span>
			<p class="font-mono text-primary-400 text-lg m-0 mt-1">{fwLastUpdated}</p>
		</div>
	</div>
	<p class="text-xs text-surface-500 font-mono mt-3 break-all text-center">SHA256 (station-g2): {fwSha256G2}</p>
</section>

<!-- Clone to Flash -->
<section class="mb-12">
	<h2 class="text-center text-surface-50 mb-6">Clone to Flash</h2>
	<div class="p-6 bg-surface-800 border border-surface-700 rounded-lg overflow-x-auto">
		<pre class="font-mono text-sm text-surface-200 leading-relaxed m-0"><code><span class="text-surface-500"># Clone and enter the repo</span>
git clone https://github.com/Jesssullivan/LA-Mesh.git && cd LA-Mesh

<span class="text-surface-500"># Enter nix devshell (provides meshtastic, esptool, jq)</span>
nix develop

<span class="text-surface-500"># Setup and fetch firmware</span>
just setup
just fetch-firmware

<span class="text-surface-500"># Flash and configure a Station G2</span>
just flash-g2
just configure-g2
just mesh-set-role</code></pre>
	</div>
</section>

<!-- Justfile Quick Reference -->
<section class="mb-12">
	<h2 class="text-center text-surface-50 mb-6">Justfile Quick Reference</h2>
	<div class="overflow-x-auto">
		<table class="w-full border-collapse">
			<thead>
				<tr>
					<th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Command</th>
					<th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Description</th>
					<th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Status</th>
				</tr>
			</thead>
			<tbody>
				<tr class="border-b border-surface-700">
					<td class="p-3 font-mono text-primary-400 text-sm">just setup</td>
					<td class="p-3 text-surface-200 text-sm">Install tools and verify environment</td>
					<td class="p-3"><StatusBadge status="working" /></td>
				</tr>
				<tr class="border-b border-surface-700">
					<td class="p-3 font-mono text-primary-400 text-sm">just fetch-firmware</td>
					<td class="p-3 text-surface-200 text-sm">Download and verify firmware binaries</td>
					<td class="p-3"><StatusBadge status="working" /></td>
				</tr>
				<tr class="border-b border-surface-700">
					<td class="p-3 font-mono text-primary-400 text-sm">just flash-g2</td>
					<td class="p-3 text-surface-200 text-sm">Flash Station G2 (erase + 3-partition write)</td>
					<td class="p-3"><StatusBadge status="working" /></td>
				</tr>
				<tr class="border-b border-surface-700">
					<td class="p-3 font-mono text-primary-400 text-sm">just configure-g2</td>
					<td class="p-3 text-surface-200 text-sm">Apply profile + channels to Station G2</td>
					<td class="p-3"><StatusBadge status="working" /></td>
				</tr>
				<tr class="border-b border-surface-700">
					<td class="p-3 font-mono text-primary-400 text-sm">just mesh-set-role</td>
					<td class="p-3 text-surface-200 text-sm">Set ROUTER role (do last -- kills USB)</td>
					<td class="p-3"><StatusBadge status="working" /></td>
				</tr>
				<tr>
					<td class="p-3 font-mono text-primary-400 text-sm">just build-firmware</td>
					<td class="p-3 text-surface-200 text-sm">Build custom firmware from source</td>
					<td class="p-3"><StatusBadge status="working" /></td>
				</tr>
			</tbody>
		</table>
	</div>
</section>

<!-- Network Configuration -->
<section class="mb-8">
	<h2 class="text-center text-surface-50 mb-6">Network Configuration</h2>
	<div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
		<div class="flex justify-between p-3 bg-surface-800 rounded-lg border-l-3 border-primary-500">
			<span class="font-semibold text-surface-400 text-sm">Region</span>
			<span class="font-mono text-surface-200 text-sm">US (915 MHz ISM)</span>
		</div>
		<div class="flex justify-between p-3 bg-surface-800 rounded-lg border-l-3 border-primary-500">
			<span class="font-semibold text-surface-400 text-sm">Modem Preset</span>
			<span class="font-mono text-surface-200 text-sm">LONG_FAST</span>
		</div>
		<div class="flex justify-between p-3 bg-surface-800 rounded-lg border-l-3 border-primary-500">
			<span class="font-semibold text-surface-400 text-sm">Hop Limit</span>
			<span class="font-mono text-surface-200 text-sm">5</span>
		</div>
		<div class="flex justify-between p-3 bg-surface-800 rounded-lg border-l-3 border-primary-500">
			<span class="font-semibold text-surface-400 text-sm">Channels</span>
			<span class="font-mono text-surface-200 text-sm">LA-Mesh / LA-Admin / LA-Emergcy</span>
		</div>
		<div class="flex justify-between p-3 bg-surface-800 rounded-lg border-l-3 border-primary-500">
			<span class="font-semibold text-surface-400 text-sm">Encryption</span>
			<span class="font-mono text-surface-200 text-sm">AES-256-CTR + PKC (DMs)</span>
		</div>
		<div class="flex justify-between p-3 bg-surface-800 rounded-lg border-l-3 border-primary-500">
			<span class="font-semibold text-surface-400 text-sm">Min Firmware</span>
			<span class="font-mono text-surface-200 text-sm">v{fwMinVersion}+</span>
		</div>
	</div>
</section>
