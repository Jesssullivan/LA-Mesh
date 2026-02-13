<script>
	import { base } from '$app/paths';
	import { onMount } from 'svelte';

	/** @type {HTMLDivElement} */
	let topologyEl;
	/** @type {HTMLDivElement} */
	let bridgeEl;

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
		if (bridgeEl) {
			const { svg } = await mermaid.render('bridge-diagram', bridgeEl.dataset.graph);
			bridgeEl.innerHTML = svg;
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
	<p class="text-surface-300 mb-4">Hub-and-spoke with mesh redundancy. High-power Station G2 routers on elevated sites provide backbone coverage, T-Deck clients form the user-facing mesh, and MeshAdv-Mini Pi HAT handles bridge/gateway duties.</p>

	<div class="overflow-x-auto my-6" bind:this={topologyEl}
		data-graph={`graph TD
		INET["INTERNET / MQTT"]
		GW["MeshAdv-Mini Gateway\nmeshtasticd + bridges\nROUTER_CLIENT"]
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
		R1 --- C1
		R1 --- C2
		R1 --- C3
		R2 --- C4
		R2 --- C5`}>
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

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Decision Records</h2>
	<div class="grid gap-4 mt-4">
		<div class="p-4 border border-surface-700 rounded-lg bg-surface-800">
			<span class="font-mono text-sm text-surface-500">ADR-001</span>
			<h3 class="text-surface-50 font-semibold mt-1 mb-2">Primary Firmware: Meshtastic</h3>
			<p class="text-surface-400 text-sm m-0 mb-2">Meshtastic chosen for ecosystem maturity, MQTT bridge support, AES-256-CTR + X25519 PKC encryption. MeshCore evaluated on single device.</p>
			<span class="px-2 py-0.5 rounded text-xs font-medium bg-green-500/20 text-green-400">Accepted</span>
		</div>

		<div class="p-4 border border-surface-700 rounded-lg bg-surface-800">
			<span class="font-mono text-sm text-surface-500">ADR-002</span>
			<h3 class="text-surface-50 font-semibold mt-1 mb-2">MeshCore Evaluation Scope</h3>
			<p class="text-surface-400 text-sm m-0 mb-2">Single Station G2 running MeshCore for evaluation against 5 criteria: stability, routing efficiency, room server, companion app UX, AMMB bridge.</p>
			<span class="px-2 py-0.5 rounded text-xs font-medium bg-green-500/20 text-green-400">Accepted</span>
		</div>

		<div class="p-4 border border-surface-700 rounded-lg bg-surface-800">
			<span class="font-mono text-sm text-surface-500">ADR-003</span>
			<h3 class="text-surface-50 font-semibold mt-1 mb-2">Hub-and-Spoke with Mesh Redundancy</h3>
			<p class="text-surface-400 text-sm m-0 mb-2">Station G2 routers on elevated sites as backbone. Hop limit 5 for full coverage. Mesh fallback when routers unreachable.</p>
			<span class="px-2 py-0.5 rounded text-xs font-medium bg-green-500/20 text-green-400">Accepted</span>
		</div>

		<div class="p-4 border border-surface-700 rounded-lg bg-surface-800">
			<span class="font-mono text-sm text-surface-500">ADR-004</span>
			<h3 class="text-surface-50 font-semibold mt-1 mb-2">3-Channel Encryption Scheme</h3>
			<p class="text-surface-400 text-sm m-0 mb-2">Primary, admin, and emergency channels with unique PSKs. PKC enabled for DMs. Quarterly rotation. CVE-2025-52464 firmware requirement.</p>
			<span class="px-2 py-0.5 rounded text-xs font-medium bg-green-500/20 text-green-400">Accepted</span>
		</div>

		<div class="p-4 border border-surface-700 rounded-lg bg-surface-800">
			<span class="font-mono text-sm text-surface-500">ADR-005</span>
			<h3 class="text-surface-50 font-semibold mt-1 mb-2">Self-Hosted MQTT Broker</h3>
			<p class="text-surface-400 text-sm m-0 mb-2">Mosquitto on Raspberry Pi (MeshAdv-Mini gateway). Full control, no external dependency, free, enables local-first bridge architecture.</p>
			<span class="px-2 py-0.5 rounded text-xs font-medium bg-green-500/20 text-green-400">Accepted</span>
		</div>
	</div>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Protocol Comparison</h2>
	<div class="overflow-x-auto">
		<table class="w-full border-collapse mt-4">
			<thead>
				<tr>
					<th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Aspect</th>
					<th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Meshtastic</th>
					<th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">MeshCore</th>
				</tr>
			</thead>
			<tbody>
				<tr class="border-b border-surface-700"><td class="p-3 text-surface-200 font-semibold">Encryption</td><td class="p-3 text-surface-200">AES-256-CTR + X25519 PKC</td><td class="p-3 text-surface-200">AES-128-ECB (ChaChaPoly AEAD coming)</td></tr>
				<tr class="border-b border-surface-700"><td class="p-3 text-surface-200 font-semibold">Routing</td><td class="p-3 text-surface-200">Managed flood + next-hop DMs</td><td class="p-3 text-surface-200">Hybrid flood-then-direct</td></tr>
				<tr class="border-b border-surface-700"><td class="p-3 text-surface-200 font-semibold">Max Hops</td><td class="p-3 text-surface-200">7 (configurable)</td><td class="p-3 text-surface-200">64</td></tr>
				<tr class="border-b border-surface-700"><td class="p-3 text-surface-200 font-semibold">MQTT Bridge</td><td class="p-3 text-surface-200">Built-in (native)</td><td class="p-3 text-surface-200">Third-party only</td></tr>
				<tr class="border-b border-surface-700"><td class="p-3 text-surface-200 font-semibold">PKC (DMs)</td><td class="p-3 text-surface-200">X25519 + AES-256-CCM</td><td class="p-3 text-surface-200">Ed25519 + ECDH + AES-128</td></tr>
				<tr class="border-b border-surface-700"><td class="p-3 text-surface-200 font-semibold">Device Support</td><td class="p-3 text-surface-200">100+ devices, all major vendors</td><td class="p-3 text-surface-200">65+ devices, growing</td></tr>
				<tr class="border-b border-surface-700"><td class="p-3 text-surface-200 font-semibold">Client Repeating</td><td class="p-3 text-surface-200">All roles can repeat</td><td class="p-3 text-surface-200">Clients never repeat (by design)</td></tr>
				<tr class="border-b border-surface-700"><td class="p-3 text-surface-200 font-semibold">Room Server</td><td class="p-3 text-surface-200">No equivalent</td><td class="p-3 text-surface-200">Dedicated always-on relay with history</td></tr>
				<tr class="border-b border-surface-700"><td class="p-3 text-surface-200 font-semibold">CVE-2025-52464</td><td class="p-3 text-surface-200">Fixed in v2.7.15+</td><td class="p-3 text-surface-200">Not affected (different key model)</td></tr>
				<tr><td class="p-3 text-surface-200 font-semibold">Interop</td><td class="p-3 text-surface-200" colspan="2">NOT compatible -- separate protocols, AMMB bridge for limited interop</td></tr>
			</tbody>
		</table>
	</div>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Bridge Architecture</h2>
	<div class="overflow-x-auto my-6" bind:this={bridgeEl}
		data-graph={`graph TD
		MESH["Mesh Devices"]
		GW["MeshAdv-Mini Gateway"]
		MSTD["meshtasticd"]
		MQTT["Mosquitto MQTT"]
		SMS["SMS Bridge\nPython"]
		EMAIL["Email Bridge\nPython / SMTP + GPG"]
		SMSGW["SMS Gateway\n(TBD)"]
		SMTPGW["SMTP Server"]
		CELL["Cell Network"]
		NET["Internet"]
		MESH -- LoRa 915 MHz --- GW
		GW --- MSTD
		MSTD --- MQTT
		MQTT --- SMS
		MQTT --- EMAIL
		SMS --- SMSGW
		EMAIL --- SMTPGW
		SMSGW --- CELL
		SMTPGW --- NET`}>
		<pre class="bg-surface-800 text-primary-400 p-6 rounded-lg overflow-x-auto text-sm leading-relaxed">Loading diagram...</pre>
	</div>
</section>

<style>
	:global(.mermaid-container svg),
	:global(div[data-graph] svg) {
		max-width: 100%;
		height: auto;
	}
</style>
