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
		Encrypted mesh communications for the Lewiston-Auburn area and Bates College campus.
		Infrastructure-independent, resilient, community-owned.
	</p>
</section>

<section class="cards">
	<a href="{base}/guides" class="card">
		<h2>Get Started</h2>
		<p>Join the mesh network with your device</p>
	</a>

	<a href="{base}/devices" class="card">
		<h2>Devices</h2>
		<p>Supported hardware and setup guides</p>
	</a>

	<a href="{base}/curriculum" class="card">
		<h2>Learn</h2>
		<p>RF engineering, SDR, and secure communications</p>
	</a>

	<a href="{base}/architecture" class="card">
		<h2>Architecture</h2>
		<p>Network design and technical decisions</p>
	</a>
</section>

<section class="features">
	<h2>What We Build</h2>
	<div class="feature-grid">
		<div>
			<h3>Encrypted Mesh</h3>
			<p>AES-256 encrypted communications over LoRa radio. No internet, no cell towers, no central authority.</p>
		</div>
		<div>
			<h3>Relay Infrastructure</h3>
			<p>High-power Station G2 nodes on rooftops and towers providing wide area coverage across L-A.</p>
		</div>
		<div>
			<h3>SMS/Email Bridge</h3>
			<p>GPG-signed message bridges connecting the mesh to SMS and encrypted email.</p>
		</div>
		<div>
			<h3>RF Education</h3>
			<p>HackRF SDR labs, LoRa protocol analysis, TEMPEST demonstrations, and secure communications curriculum.</p>
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
	}

	.feature-grid h3 {
		color: #00d4aa;
		margin-bottom: 0.5rem;
	}

	.feature-grid p {
		color: #555;
		line-height: 1.6;
	}
</style>
