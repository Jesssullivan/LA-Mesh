<script>
	import { base } from '$app/paths';
	import { onMount } from 'svelte';

	/** @type {HTMLDivElement} */
	let topologyEl;

	onMount(async () => {
		// @ts-ignore — CDN import has no type declarations
		const { default: mermaid } = await import('https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs');
		mermaid.initialize({
			startOnLoad: false,
			theme: 'dark',
			themeVariables: {
				primaryColor: '#1e293b',
				primaryTextColor: '#e2e8f0',
				primaryBorderColor: '#475569',
				lineColor: '#22d3ee',
				secondaryColor: '#0f172a',
				tertiaryColor: '#1e293b',
				background: '#0f172a',
				mainBkg: '#1e293b',
				nodeBorder: '#475569',
				clusterBkg: '#0f172a',
				titleColor: '#e2e8f0',
				edgeLabelBackground: '#1e293b'
			}
		});
		if (topologyEl) {
			const { svg } = await mermaid.render('topology-diagram', topologyEl.dataset.graph);
			topologyEl.innerHTML = svg;
		}
	});
</script>

<svelte:head>
	<title>Architecture - LA-Mesh</title>
</svelte:head>

<h1 class="text-3xl font-bold text-surface-50 mb-2">Architecture</h1>
<p class="text-surface-400 mb-8">Technical decisions and network design for LA-Mesh.</p>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Network Topology</h2>
	<p class="text-surface-300 mb-4">Fully meshed topology with managed flood routing. Every node can relay for every other node. High-power Station G2 routers on elevated sites extend coverage, T-Deck clients participate as both endpoints and relays, and the FireElmo-SDR Pi HAT handles bridge/gateway duties to external networks.</p>

	<div class="overflow-x-auto my-6" bind:this={topologyEl}
		data-graph={`graph TD
		INET["INTERNET / MQTT"]
		GW["FireElmo-SDR Gateway\nmeshtasticd + bridges\nROUTER_CLIENT"]
		R1["Station G2 #1\nROUTER 30 dBm\nCampus Relay"]
		R2["Station G2 #2\nROUTER 30 dBm\nDowntown Relay"]
		C1["T-Deck Plus #1\nCLIENT"]
		C2["T-Deck Plus #2\nCLIENT"]
		C3["T-Deck Pro #1\nCLIENT"]
		C4["T-Deck Pro #2\nCLIENT"]
		C5["T-Deck Plus #3\nCLIENT"]
		INET --- GW
		GW -- LoRa 915 MHz --- R1
		GW -- LoRa 915 MHz --- R2
		R1 --- R2
		R1 --- C1
		R1 --- C2
		R1 --- C3
		R2 --- C4
		R2 --- C5
		C1 -.- C2
		C3 -.- C4`}>
		<pre class="bg-surface-800 text-primary-400 p-6 rounded-lg overflow-x-auto text-sm leading-relaxed">Loading diagram...</pre>
	</div>

	<div class="grid grid-cols-1 md:grid-cols-3 gap-4 mt-6">
		<div class="p-4 bg-surface-800 rounded-lg border-l-3 border-primary-500">
			<h4 class="text-surface-50 font-semibold m-0 mb-2">Station G2 Link Budget</h4>
			<p class="text-surface-400 text-sm m-0">30 dBm TX + 6 dBi antenna = 36 dBm EIRP. Max path loss: 171 dB. Estimated range: 20+ km line-of-sight.</p>
		</div>
		<div class="p-4 bg-surface-800 rounded-lg border-l-3 border-primary-500">
			<h4 class="text-surface-50 font-semibold m-0 mb-2">T-Deck Link Budget</h4>
			<p class="text-surface-400 text-sm m-0">22 dBm TX + 2 dBi antenna = 24 dBm EIRP. Max path loss: 160 dB. Estimated range: 5-10 km line-of-sight.</p>
		</div>
		<div class="p-4 bg-surface-800 rounded-lg border-l-3 border-primary-500">
			<h4 class="text-surface-50 font-semibold m-0 mb-2">Hop Limit</h4>
			<p class="text-surface-400 text-sm m-0">Set to 5 (optimized for LA-Mesh coverage area). Higher than default 3 to ensure full L-A area reach.</p>
		</div>
	</div>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Channel Architecture</h2>
	<div class="overflow-x-auto">
		<table class="w-full border-collapse mt-4">
			<thead>
				<tr>
					<th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Index</th>
					<th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Channel</th>
					<th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Purpose</th>
					<th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">PSK</th>
				</tr>
			</thead>
			<tbody>
				<tr class="border-b border-surface-700"><td class="p-3 text-surface-200">0</td><td class="p-3 text-surface-200 font-mono">LA-Mesh</td><td class="p-3 text-surface-200">Primary community channel</td><td class="p-3 text-surface-200">Unique 256-bit (shared in-person)</td></tr>
				<tr class="border-b border-surface-700"><td class="p-3 text-surface-200">1</td><td class="p-3 text-surface-200 font-mono">LA-Admin</td><td class="p-3 text-surface-200">Operator coordination</td><td class="p-3 text-surface-200">Separate unique 256-bit</td></tr>
				<tr><td class="p-3 text-surface-200">2</td><td class="p-3 text-surface-200 font-mono">LA-Emergcy</td><td class="p-3 text-surface-200">Emergency use only</td><td class="p-3 text-surface-200">Separate unique 256-bit</td></tr>
			</tbody>
		</table>
	</div>
	<p class="text-sm text-surface-500 italic mt-2">PSKs are never transmitted digitally. Shared face-to-face at community meetups and rotated quarterly.</p>
</section>

<style>
	:global(.mermaid-container svg),
	:global(div[data-graph] svg) {
		max-width: 100%;
		height: auto;
	}
</style>
