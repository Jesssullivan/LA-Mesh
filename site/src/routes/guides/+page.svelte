<svelte:head>
	<title>Guides - LA-Mesh</title>
</svelte:head>

<h1>Guides</h1>

<div class="guide-list">
	<div class="guide">
		<h2>Getting Started</h2>
		<p>Flash firmware, configure your device, and join the LA-Mesh network.</p>
		<span class="status">Available</span>
	</div>

	<div class="guide">
		<h2>Device Setup: Station G2</h2>
		<p>Configure a Station G2 as a high-power relay/router for rooftop deployment.</p>
		<span class="status coming">Coming Week 2</span>
	</div>

	<div class="guide">
		<h2>Device Setup: T-Deck</h2>
		<p>Set up your T-Deck as a portable encrypted messenger.</p>
		<span class="status coming">Coming Week 2</span>
	</div>

	<div class="guide">
		<h2>SMS Bridge Setup</h2>
		<p>Deploy an SMS-to-mesh gateway using MeshAdv-Mini and a Raspberry Pi.</p>
		<span class="status coming">Coming Week 4</span>
	</div>

	<div class="guide">
		<h2>Encryption and Security</h2>
		<p>Channel encryption, PKC direct messages, GPG key management, and OPSEC basics.</p>
		<span class="status coming">Coming Week 5</span>
	</div>

	<div class="guide">
		<h2>TAILS Integration</h2>
		<p>Using TAILS OS with Meshtastic for maximum operational security.</p>
		<span class="status coming">Coming Week 5</span>
	</div>

	<div class="guide">
		<h2>Solar Relay Deployment</h2>
		<p>Build and deploy a solar-powered relay node for year-round operation.</p>
		<span class="status coming">Coming Week 3</span>
	</div>

	<div class="guide">
		<h2>Troubleshooting</h2>
		<p>Common issues and solutions for mesh network problems.</p>
		<span class="status coming">Coming Week 7</span>
	</div>
</div>

<style>
	.guide-list {
		display: grid;
		gap: 1rem;
		margin-top: 2rem;
	}

	.guide {
		padding: 1.25rem;
		border: 1px solid #ddd;
		border-radius: 8px;
		background: white;
	}

	.guide h2 {
		margin: 0 0 0.5rem;
		font-size: 1.2rem;
	}

	.guide p {
		margin: 0 0 0.75rem;
		color: #555;
	}

	.status {
		display: inline-block;
		padding: 0.15rem 0.5rem;
		border-radius: 4px;
		font-size: 0.8rem;
		background: #00d4aa;
		color: white;
	}

	.status.coming {
		background: #888;
	}
</style>
