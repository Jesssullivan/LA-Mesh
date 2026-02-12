<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Mesh Basics - LA-Mesh Curriculum</title>
</svelte:head>

<nav class="breadcrumb">
	<a href="{base}/curriculum">Curriculum</a> / Mesh Basics
</nav>

<h1>Mesh Networking Basics</h1>
<div class="meta">
	<span>2-3 hour workshop</span>
	<span>Free -- fortnightly at Bates College</span>
</div>

<section>
	<h2>Learning Objectives</h2>
	<ol>
		<li>Explain what LoRa and mesh networking are in plain terms</li>
		<li>Power on and navigate a T-Deck device</li>
		<li>Send and receive text messages on LA-Mesh</li>
		<li>Understand channels, PSKs, and basic encryption concepts</li>
		<li>Read the node list and interpret signal quality (SNR/RSSI)</li>
	</ol>
</section>

<section>
	<h2>Part 1: What Is a Mesh Network? (30 min)</h2>
	<p>Every device is a relay. If one node goes down, the network re-routes around it. No cell towers, no internet needed.</p>
	<p><strong>Analogy</strong>: A bucket brigade -- each person passes the bucket to the next. If one person steps away, the chain re-routes.</p>
</section>

<section>
	<h2>Part 2: What Is LoRa? (20 min)</h2>
	<table>
		<thead><tr><th>What</th><th>Value</th><th>Plain English</th></tr></thead>
		<tbody>
			<tr><td>Frequency</td><td>915 MHz</td><td>UHF radio band, passes through some obstacles</td></tr>
			<tr><td>Range</td><td>1-20 km</td><td>Across town, further with good antennas</td></tr>
			<tr><td>Speed</td><td>~0.7 kbps</td><td>About 1 text message per second</td></tr>
			<tr><td>Power</td><td>Days on battery</td><td>T-Deck lasts 1-3 days on a charge</td></tr>
			<tr><td>License</td><td>None needed</td><td>FCC Part 15 -- free to use</td></tr>
		</tbody>
	</table>
</section>

<section>
	<h2>Part 3: Your First Message (45 min)</h2>
	<ol>
		<li><strong>Power on</strong>: Hold power button for 3 seconds</li>
		<li><strong>Home screen</strong>: Identify node list, channel indicator, battery level</li>
		<li><strong>Send a message</strong>: Navigate to message screen, type, press Send</li>
		<li><strong>Check node list</strong>: How many nodes? What does SNR mean?</li>
	</ol>
	<p><strong>Exercise</strong>: Pair up. Walk to opposite sides of the building. Send messages. Note SNR degradation with distance.</p>
</section>

<section>
	<h2>Part 4: Mesh Routing (20 min)</h2>
	<pre class="code">{`You ──(hop 1)──→ Router A ──(hop 2)──→ Router B ──(hop 3)──→ Friend`}</pre>
	<pre class="code">{`meshtastic --traceroute '!<node-id>'`}</pre>
</section>

<section>
	<h2>Part 5: Channels and Encryption (20 min)</h2>
	<ul>
		<li>Default PSK (<code>AQ==</code>) is publicly known -- NEVER used on LA-Mesh</li>
		<li>LA-Mesh uses custom 32-byte PSK distributed in-person only</li>
		<li>Direct messages use additional PKC (Public Key Cryptography)</li>
	</ul>
</section>

<section>
	<h2>Resources</h2>
	<ul>
		<li><a href="https://meshtastic.org/docs/">Meshtastic documentation</a></li>
		<li><a href="https://site.meshtastic.org">Meshtastic Site Planner</a></li>
		<li><a href="{base}/guides/community-onboarding">LA-Mesh onboarding guide</a></li>
	</ul>
</section>

<style>
	.breadcrumb { font-size: 0.85rem; color: #888; margin-bottom: 1rem; }
	.breadcrumb a { color: #00d4aa; text-decoration: none; }
	.meta { display: flex; gap: 1rem; flex-wrap: wrap; font-size: 0.85rem; color: #888; margin-bottom: 2rem; }
	.meta span { background: #f5f5f5; padding: 0.2rem 0.5rem; border-radius: 3px; }
	section { margin-bottom: 3rem; }
	.code { background: #1a1a2e; color: #00d4aa; padding: 1.25rem; border-radius: 8px; overflow-x: auto; font-size: 0.85rem; line-height: 1.5; }
	code { background: #f0f0f0; padding: 0.15rem 0.35rem; border-radius: 3px; font-size: 0.85rem; }
	table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
	th, td { padding: 0.75rem; border: 1px solid #ddd; text-align: left; }
	th { background: #f5f5f5; font-weight: 600; }
	a { color: #00d4aa; }
</style>
