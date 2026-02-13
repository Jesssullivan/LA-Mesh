<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Curriculum - LA-Mesh</title>
</svelte:head>

<h1 class="text-3xl font-bold text-surface-50 mb-2">Curriculum</h1>

<div class="p-4 bg-yellow-500/10 border border-yellow-500/30 rounded-lg mb-8">
	<p class="text-yellow-400 font-semibold m-0 mb-1">Being Restructured</p>
	<p class="text-yellow-300/80 text-sm m-0">The curriculum section is being reorganized. Workshop content is moving into the guides section. The pages below are preserved but may be outdated.</p>
</div>

<p class="text-surface-400 mb-8">Hands-on workshops in mesh networking, RF engineering, and secure communications. Pick any topic that interests you. All workshops are free. We meet fortnightly in the L-A area.</p>

<div class="grid gap-6 mt-8">
	<a href="{base}/curriculum/mesh-basics" class="block p-6 border border-surface-700 rounded-lg bg-surface-800 no-underline text-inherit hover:border-primary-500 transition-colors">
		<div class="flex items-center gap-4 mb-3">
			<span class="px-3 py-1 rounded text-sm font-semibold bg-surface-950 text-primary-400 whitespace-nowrap">Fundamentals</span>
			<h2 class="text-xl font-bold text-surface-50 m-0">Mesh Basics</h2>
		</div>
		<p class="text-surface-400 mb-3">6-part workshop covering mesh networking fundamentals and hands-on device setup.</p>
		<ul class="text-surface-400 text-sm pl-6 mb-4">
			<li class="mb-1">What is a mesh network? Topology, resilience, real-world applications</li>
			<li class="mb-1">LoRa radio: chirp spread spectrum, 915 MHz ISM, range vs data rate tradeoffs</li>
			<li class="mb-1">First message: power on, pair, send and receive on LA-Mesh</li>
			<li class="mb-1">Routing: hops, RSSI, SNR, how messages traverse the mesh</li>
			<li class="mb-1">Channels and encryption: AES-256, PSK, what "encrypted" really means</li>
		</ul>
		<div class="flex gap-4 flex-wrap text-sm text-surface-500 mb-3">
			<span class="bg-surface-700 px-2 py-0.5 rounded">2-hour workshop</span>
		</div>
	</a>

	<a href="{base}/curriculum/security" class="block p-6 border border-surface-700 rounded-lg bg-surface-800 no-underline text-inherit hover:border-primary-500 transition-colors">
		<div class="flex items-center gap-4 mb-3">
			<span class="px-3 py-1 rounded text-sm font-semibold bg-surface-950 text-primary-400 whitespace-nowrap">Security</span>
			<h2 class="text-xl font-bold text-surface-50 m-0">Encryption and Security</h2>
		</div>
		<p class="text-surface-400 mb-3">5-part workshop on the full encryption stack, threat modeling, and operational security.</p>
		<ul class="text-surface-400 text-sm pl-6 mb-4">
			<li class="mb-1">3-layer encryption model: LoRa physical, AES-256-CTR channel, X25519 PKC for DMs</li>
			<li class="mb-1">PSK management: generation, secure distribution, rotation ceremony</li>
			<li class="mb-1">Case study: CVE-2025-52464 (duplicate crypto keys from vendor cloning)</li>
			<li class="mb-1">Threat modeling: actor/capability matrix for realistic adversary assessment</li>
			<li class="mb-1">OpSec practices: metadata awareness, position sharing, TAILS integration</li>
		</ul>
		<div class="flex gap-4 flex-wrap text-sm text-surface-500 mb-3">
			<span class="bg-surface-700 px-2 py-0.5 rounded">4-hour workshop</span>
		</div>
	</a>

	<a href="{base}/curriculum/sdr" class="block p-6 border border-surface-700 rounded-lg bg-surface-800 no-underline text-inherit hover:border-primary-500 transition-colors">
		<div class="flex items-center gap-4 mb-3">
			<span class="px-3 py-1 rounded text-sm font-semibold bg-surface-950 text-primary-400 whitespace-nowrap">SDR / RF</span>
			<h2 class="text-xl font-bold text-surface-50 m-0">SDR and RF Engineering</h2>
		</div>
		<p class="text-surface-400 mb-3">7-part lab using HackRF H4M for hands-on RF analysis and LoRa protocol dissection.</p>
		<ul class="text-surface-400 text-sm pl-6 mb-4">
			<li class="mb-1">SDR fundamentals: sampling, Nyquist, quadrature, dynamic range</li>
			<li class="mb-1">FCC Part 15.247: legal limits (30 dBm conducted, 36 dBm EIRP at 915 MHz)</li>
			<li class="mb-1">Live spectrum observation: RTL-SDR waterfall of 915 MHz band</li>
			<li class="mb-1">LoRa signal anatomy: chirp structure, spreading factors, bandwidth, coding rate</li>
			<li class="mb-1">GNU Radio + gr-lora_sdr: building a LoRa receiver flowgraph</li>
		</ul>
		<div class="flex gap-4 flex-wrap text-sm text-surface-500 mb-3">
			<span class="bg-surface-700 px-2 py-0.5 rounded">6 hours (two 3-hour sessions)</span>
			<span class="bg-surface-700 px-2 py-0.5 rounded">HackRF H4M provided</span>
		</div>
	</a>

	<a href="{base}/curriculum/tempest" class="block p-6 border border-surface-700 rounded-lg bg-surface-800 no-underline text-inherit hover:border-primary-500 transition-colors">
		<div class="flex items-center gap-4 mb-3">
			<span class="px-3 py-1 rounded text-sm font-semibold bg-surface-950 text-primary-400 whitespace-nowrap">EMSEC</span>
			<h2 class="text-xl font-bold text-surface-50 m-0">TEMPEST and Emanation Security</h2>
		</div>
		<p class="text-surface-400 mb-3">3-hour lab on electromagnetic emanation analysis using HackRF H4M and PortaPack Mayhem.</p>
		<ul class="text-surface-400 text-sm pl-6 mb-4">
			<li class="mb-1">Emanation theory: Van Eck phreaking, video signal reconstruction</li>
			<li class="mb-1">Lab: spectrum survey with PortaPack Looking Glass</li>
			<li class="mb-1">Lab: VGA reconstruction with TempestSDR + HackRF</li>
			<li class="mb-1">Lab: HDMI capture with deep-tempest CNN enhancement</li>
			<li class="mb-1">Keyboard emanations, countermeasures, mesh implications</li>
		</ul>
		<div class="flex gap-4 flex-wrap text-sm text-surface-500 mb-3">
			<span class="bg-surface-700 px-2 py-0.5 rounded">3-hour lab</span>
			<span class="bg-surface-700 px-2 py-0.5 rounded">HackRF H4M provided</span>
		</div>
	</a>

	<a href="{base}/curriculum/tails" class="block p-6 border border-surface-700 rounded-lg bg-surface-800 no-underline text-inherit hover:border-primary-500 transition-colors">
		<div class="flex items-center gap-4 mb-3">
			<span class="px-3 py-1 rounded text-sm font-semibold bg-surface-950 text-primary-400 whitespace-nowrap">Privacy</span>
			<h2 class="text-xl font-bold text-surface-50 m-0">TAILS and Secure Communications</h2>
		</div>
		<p class="text-surface-400 mb-3">6-part lab on maximum operational security using TAILS OS with mesh networking.</p>
		<ul class="text-surface-400 text-sm pl-6 mb-4">
			<li class="mb-1">TAILS introduction: amnesic system, Tor routing, persistence volumes</li>
			<li class="mb-1">Mesh + TAILS combination: meshtastic-cli on TAILS, air-gapped workflows</li>
			<li class="mb-1">Hands-on: boot TAILS from USB, verify signatures, configure persistence</li>
			<li class="mb-1">5-layer OpSec model: physical, digital, communications, behavioral, network</li>
			<li class="mb-1">Practical scenarios: journalist protection, protest communications, disaster response</li>
		</ul>
		<div class="flex gap-4 flex-wrap text-sm text-surface-500 mb-3">
			<span class="bg-surface-700 px-2 py-0.5 rounded">3-hour lab</span>
			<span class="bg-surface-700 px-2 py-0.5 rounded">USB drives provided</span>
		</div>
	</a>
</div>
