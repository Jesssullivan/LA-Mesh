<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>LA-Mesh - Community LoRa Mesh Network</title>
</svelte:head>

<section class="hero">
	<h1>LA-Mesh</h1>
	<p class="tagline">Community LoRa mesh network for Southern Maine</p>
	<p>
		Encrypted mesh communications for the Lewiston-Auburn area.
		Infrastructure-independent, resilient, community-owned.
	</p>
	<p class="workshops">Free fortnightly workshops in the L-A area -- from mesh basics to TEMPEST and TAILS.</p>
</section>

<section class="cards">
	<a href="{base}/guides/community-onboarding" class="card">
		<h2>Join the Mesh</h2>
		<p>Get a device, learn the basics, start communicating</p>
	</a>

	<a href="{base}/devices" class="card">
		<h2>Devices</h2>
		<p>Station G2, T-Deck Plus/Pro, MeshAdv-Mini, HackRF</p>
	</a>

	<a href="{base}/curriculum" class="card">
		<h2>Learn</h2>
		<p>Workshops: mesh basics, encryption, SDR, TEMPEST, TAILS</p>
	</a>

	<a href="{base}/architecture" class="card">
		<h2>Architecture</h2>
		<p>Network topology, ADRs, protocol comparison, bridge design</p>
	</a>
</section>

<section class="features">
	<h2>What We Build</h2>
	<div class="feature-grid">
		<div>
			<h3>Encrypted Mesh</h3>
			<p>AES-256-CTR channel encryption + X25519 PKC for direct messages. No internet, no cell towers, no central authority. PSKs shared face-to-face only.</p>
		</div>
		<div>
			<h3>Relay Infrastructure</h3>
			<p>Station G2 nodes (30 dBm, 36 dBm EIRP) on rooftops and towers. Hub-and-spoke topology with mesh fallback. Solar-powered for year-round operation.</p>
		</div>
		<div>
			<h3>SMS/Email Bridge</h3>
			<p>MeshAdv-Mini Pi HAT running meshtasticd, Mosquitto MQTT, SMS/email gateway (in development), and GPG-signed email bridge. Mesh-to-internet gateway.</p>
		</div>
		<div>
			<h3>RF Education</h3>
			<p>Hands-on workshops: mesh basics, security, SDR with HackRF H4M, TEMPEST, TAILS integration. FCC Part 15 compliance, link budget calculations, protocol analysis.</p>
		</div>
	</div>
</section>

<section class="network-status">
	<h2>Network Configuration</h2>
	<div class="config-grid">
		<div class="config-item">
			<span class="label">Region</span>
			<span class="value">US (915 MHz ISM)</span>
		</div>
		<div class="config-item">
			<span class="label">Modem Preset</span>
			<span class="value">LONG_FAST</span>
		</div>
		<div class="config-item">
			<span class="label">Hop Limit</span>
			<span class="value">5</span>
		</div>
		<div class="config-item">
			<span class="label">Channels</span>
			<span class="value">LA-Mesh / LA-Admin / LA-Emergency</span>
		</div>
		<div class="config-item">
			<span class="label">Encryption</span>
			<span class="value">AES-256-CTR (channel) + PKC (DMs)</span>
		</div>
		<div class="config-item">
			<span class="label">Min Firmware</span>
			<span class="value">v2.7.15+ (CVE-2025-52464, CVE-2025-24797 fixes)</span>
		</div>
	</div>
</section>

<style>
	.hero {
		text-align: center;
		padding: 3rem 0;
		border-bottom: 1px solid #eee;
		margin-bottom: 2rem;
	}

	h1 {
		font-size: 3rem;
		margin: 0;
		color: #1a1a2e;
	}

	.tagline {
		font-size: 1.3rem;
		color: #666;
		margin: 0.5rem 0 1rem;
	}

	.workshops {
		font-size: 1rem;
		color: #00d4aa;
		font-weight: 600;
		margin-top: 0.5rem;
	}

	.cards {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
		gap: 1.5rem;
		margin-bottom: 3rem;
	}

	.card {
		padding: 1.5rem;
		border: 1px solid #ddd;
		border-radius: 8px;
		text-decoration: none;
		color: inherit;
		transition: border-color 0.2s, box-shadow 0.2s;
	}

	.card:hover {
		border-color: #00d4aa;
		box-shadow: 0 2px 8px rgba(0, 212, 170, 0.15);
	}

	.card h2 {
		margin: 0 0 0.5rem;
		color: #1a1a2e;
	}

	.card p {
		margin: 0;
		color: #666;
	}

	.features h2 {
		text-align: center;
		margin-bottom: 2rem;
	}

	.feature-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
		gap: 2rem;
		margin-bottom: 3rem;
	}

	.feature-grid h3 {
		color: #00d4aa;
		margin-bottom: 0.5rem;
	}

	.feature-grid p {
		color: #555;
		line-height: 1.6;
	}

	.network-status h2 {
		text-align: center;
		margin-bottom: 1.5rem;
	}

	.config-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
		gap: 0.75rem;
	}

	.config-item {
		display: flex;
		justify-content: space-between;
		padding: 0.75rem 1rem;
		background: #f9f9f9;
		border-radius: 6px;
		border-left: 3px solid #00d4aa;
	}

	.label {
		font-weight: 600;
		color: #555;
		font-size: 0.9rem;
	}

	.value {
		color: #1a1a2e;
		font-family: monospace;
		font-size: 0.9rem;
	}
</style>
