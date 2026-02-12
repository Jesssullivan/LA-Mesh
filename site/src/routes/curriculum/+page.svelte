<svelte:head>
	<title>Curriculum - LA-Mesh</title>
</svelte:head>

<h1>Curriculum</h1>
<p>Progressive education in mesh networking, RF engineering, and secure communications.</p>

<div class="levels">
	<div class="level">
		<div class="level-header">
			<span class="badge">Level 1</span>
			<h2>Mesh Basics</h2>
		</div>
		<p>Join the network, send messages, understand mesh topology.</p>
		<ul>
			<li>2-hour workshop</li>
			<li>~$25/person in equipment</li>
			<li>No prerequisites</li>
		</ul>
		<span class="status coming">Coming Week 7</span>
	</div>

	<div class="level">
		<div class="level-header">
			<span class="badge">Level 2</span>
			<h2>Device Configuration</h2>
		</div>
		<p>Firmware flashing, configuration optimization, solar node builds, MeshCore comparison.</p>
		<ul>
			<li>3-hour workshop</li>
			<li>Requires Level 1 completion</li>
		</ul>
		<span class="status coming">Coming Week 7</span>
	</div>

	<div class="level">
		<div class="level-header">
			<span class="badge">Level 3</span>
			<h2>Encryption and Security</h2>
		</div>
		<p>GPG keys, key signing ceremonies, TAILS OS, threat modeling, OPSEC fundamentals.</p>
		<ul>
			<li>4-hour workshop</li>
			<li>Requires Level 2 completion</li>
		</ul>
		<span class="status coming">Coming Week 7</span>
	</div>

	<div class="level">
		<div class="level-header">
			<span class="badge">Level 4</span>
			<h2>RF Engineering</h2>
		</div>
		<p>HackRF SDR, GNU Radio, Wireshark LoRa decoding, FCC regulations, NanoVNA antenna analysis, dBm calculations.</p>
		<ul>
			<li>6-hour split workshop</li>
			<li>HackRF H4M PortaPack provided</li>
		</ul>
		<span class="status coming">Coming Week 7</span>
	</div>

	<div class="level">
		<div class="level-header">
			<span class="badge">Level 5</span>
			<h2>Advanced Topics</h2>
		</div>
		<p>TEMPEST demonstrations, protocol analysis, bridge development, Reticulum deep dive.</p>
		<ul>
			<li>Ongoing seminar series</li>
			<li>Requires Level 4 completion</li>
		</ul>
		<span class="status coming">Coming Week 8+</span>
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
	}

	.level h2 {
		margin: 0;
	}

	.level ul {
		color: #555;
		font-size: 0.9rem;
	}

	.status.coming {
		display: inline-block;
		padding: 0.15rem 0.5rem;
		border-radius: 4px;
		font-size: 0.8rem;
		background: #888;
		color: white;
	}
</style>
