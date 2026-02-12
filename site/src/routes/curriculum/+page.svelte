<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Curriculum - LA-Mesh</title>
</svelte:head>

<h1>Curriculum</h1>
<p>Progressive education in mesh networking, RF engineering, and secure communications. Each level builds on the previous.</p>

<div class="levels">
	<div class="level">
		<div class="level-header">
			<span class="badge">Level 1-2</span>
			<h2>Mesh Basics</h2>
		</div>
		<p>6-part workshop covering mesh networking fundamentals and hands-on device setup.</p>
		<ul>
			<li>What is a mesh network? Topology, resilience, real-world applications</li>
			<li>LoRa radio: chirp spread spectrum, 915 MHz ISM, range vs data rate tradeoffs</li>
			<li>First message: power on, pair, send and receive on LA-Mesh</li>
			<li>Routing: hops, RSSI, SNR, how messages traverse the mesh</li>
			<li>Channels and encryption: AES-256, PSK, what "encrypted" really means</li>
		</ul>
		<div class="meta">
			<span>2-hour workshop</span>
			<span>~$25/person equipment</span>
			<span>No prerequisites</span>
		</div>
		<span class="status">Available</span>
	</div>

	<div class="level">
		<div class="level-header">
			<span class="badge">Level 3</span>
			<h2>Encryption and Security</h2>
		</div>
		<p>5-part workshop on the full encryption stack, threat modeling, and operational security.</p>
		<ul>
			<li>3-layer encryption model: LoRa physical, AES-256-CTR channel, X25519 PKC for DMs</li>
			<li>PSK management: generation, secure distribution, rotation ceremony</li>
			<li>Case study: CVE-2025-52464 (duplicate crypto keys from vendor cloning)</li>
			<li>Threat modeling: actor/capability matrix for realistic adversary assessment</li>
			<li>OpSec practices: metadata awareness, position sharing, TAILS integration</li>
		</ul>
		<div class="meta">
			<span>4-hour workshop</span>
			<span>Requires Level 1-2</span>
		</div>
		<span class="status">Available</span>
	</div>

	<div class="level">
		<div class="level-header">
			<span class="badge">Level 4</span>
			<h2>SDR and RF Engineering</h2>
		</div>
		<p>6-part lab using HackRF H4M for hands-on RF analysis and LoRa protocol dissection.</p>
		<ul>
			<li>SDR fundamentals: sampling, Nyquist, quadrature, dynamic range</li>
			<li>FCC Part 15.247: legal limits (30 dBm conducted, 36 dBm EIRP at 915 MHz)</li>
			<li>Live spectrum observation: RTL-SDR waterfall of 915 MHz band</li>
			<li>LoRa signal anatomy: chirp structure, spreading factors, bandwidth, coding rate</li>
			<li>GNU Radio + gr-lora_sdr: building a LoRa receiver flowgraph</li>
			<li>RF troubleshooting: link budget calculations, antenna patterns, path loss</li>
		</ul>
		<div class="meta">
			<span>6-hour split workshop</span>
			<span>HackRF H4M provided</span>
			<span>Requires Level 3</span>
		</div>
		<span class="status">Available</span>
	</div>

	<div class="level">
		<div class="level-header">
			<span class="badge">Level 5</span>
			<h2>TAILS and Secure Communications</h2>
		</div>
		<p>6-part lab on maximum operational security using TAILS OS with mesh networking.</p>
		<ul>
			<li>TAILS introduction: amnesic system, Tor routing, persistence volumes</li>
			<li>Mesh + TAILS combination: meshtastic-cli on TAILS, air-gapped workflows</li>
			<li>Hands-on: boot TAILS from USB, verify signatures, configure persistence</li>
			<li>5-layer OpSec model: physical, digital, communications, behavioral, network</li>
			<li>Practical scenarios: journalist protection, protest communications, disaster response</li>
			<li>Honest assessment: what TAILS can and cannot protect against</li>
		</ul>
		<div class="meta">
			<span>4-hour lab</span>
			<span>USB drives provided</span>
			<span>Requires Level 3</span>
		</div>
		<span class="status">Available</span>
	</div>
</div>

<style>
	.levels {
		display: grid;
		gap: 1.5rem;
		margin-top: 2rem;
	}

	.level {
		padding: 1.5rem;
		border: 1px solid #ddd;
		border-radius: 8px;
		background: white;
	}

	.level-header {
		display: flex;
		align-items: center;
		gap: 1rem;
		margin-bottom: 0.75rem;
	}

	.badge {
		background: #1a1a2e;
		color: #00d4aa;
		padding: 0.25rem 0.75rem;
		border-radius: 4px;
		font-size: 0.85rem;
		font-weight: 600;
		white-space: nowrap;
	}

	.level h2 {
		margin: 0;
	}

	.level p {
		color: #555;
		margin: 0 0 0.75rem;
	}

	.level ul {
		color: #555;
		font-size: 0.9rem;
		margin: 0 0 1rem;
		padding-left: 1.5rem;
	}

	.level li {
		margin-bottom: 0.25rem;
	}

	.meta {
		display: flex;
		gap: 1rem;
		flex-wrap: wrap;
		font-size: 0.85rem;
		color: #888;
		margin-bottom: 0.75rem;
	}

	.meta span {
		background: #f5f5f5;
		padding: 0.2rem 0.5rem;
		border-radius: 3px;
	}

	.status {
		display: inline-block;
		padding: 0.15rem 0.5rem;
		border-radius: 4px;
		font-size: 0.8rem;
		background: #00d4aa;
		color: white;
	}
</style>
