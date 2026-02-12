<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>TAILS and Secure Comms - LA-Mesh Curriculum</title>
</svelte:head>

<nav class="breadcrumb">
	<a href="{base}/curriculum">Curriculum</a> / TAILS and Secure Communications
</nav>

<h1>TAILS OS and Secure Communications</h1>
<div class="meta">
	<span>3-hour lab</span>
	<span>USB drives provided</span>
	<span>Free -- fortnightly at Bates College</span>
</div>

<section>
	<h2>Learning Objectives</h2>
	<ol>
		<li>Explain what TAILS OS is and why it exists</li>
		<li>Boot TAILS from a USB drive and verify signatures</li>
		<li>Combine air-gapped mesh communication with TAILS</li>
		<li>Configure persistent encrypted storage</li>
		<li>Use Kleopatra for GPG key management in TAILS</li>
		<li>Make informed decisions about operational security trade-offs</li>
	</ol>
</section>

<section>
	<h2>Part 1: TAILS Introduction (30 min)</h2>
	<p>TAILS (The Amnesic Incognito Live System) is a portable OS that routes all traffic through Tor and leaves no trace on the host computer.</p>
	<p>Download: <a href="https://tails.net/install/">tails.net/install</a></p>
</section>

<section>
	<h2>Part 2: Hands-On Boot and Setup (45 min)</h2>
	<ol>
		<li>Boot from USB (BIOS: F12/F2 for boot menu)</li>
		<li>Configure persistent encrypted volume</li>
		<li>Connect to Tor network</li>
		<li>Use Kleopatra for GPG key generation and management</li>
	</ol>
</section>

<section>
	<h2>Part 3: Mesh + TAILS (45 min)</h2>
	<pre class="code">{`# Install meshtastic-cli in TAILS
pip install --user meshtastic

# Connect to device via USB
meshtastic --port /dev/ttyUSB0 --info`}</pre>
	<p>Cross-reference: <a href="{base}/guides/gpg">GPG guide</a> for key generation details.</p>
</section>

<section>
	<h2>Part 4: 5-Layer OpSec Model (30 min)</h2>
	<table>
		<thead><tr><th>Layer</th><th>Concern</th><th>Tool</th></tr></thead>
		<tbody>
			<tr><td>Physical</td><td>Device access, location</td><td>CLIENT_HIDDEN mode, secure storage</td></tr>
			<tr><td>Digital</td><td>Data persistence</td><td>TAILS amnesic mode</td></tr>
			<tr><td>Communications</td><td>Content privacy</td><td>AES-256 + PKC, GPG</td></tr>
			<tr><td>Behavioral</td><td>Patterns, timing</td><td>Awareness, randomization</td></tr>
			<tr><td>Network</td><td>Traffic analysis</td><td>Tor, mesh routing</td></tr>
		</tbody>
	</table>
</section>

<section>
	<h2>Part 5: Practical Scenarios (30 min)</h2>
	<ul>
		<li>Journalist source protection</li>
		<li>Protest communications</li>
		<li>Disaster response when infrastructure is compromised</li>
	</ul>
</section>

<section>
	<h2>Part 6: Honest Assessment (15 min)</h2>
	<p>What TAILS + mesh <strong>can</strong> protect: message content, digital forensics, metadata (partially).</p>
	<p>What it <strong>cannot</strong> protect: RF direction finding, physical surveillance, compelled disclosure, hardware implants.</p>
</section>

<style>
	.breadcrumb { font-size: 0.85rem; color: #888; margin-bottom: 1rem; }
	.breadcrumb a { color: #00d4aa; text-decoration: none; }
	.meta { display: flex; gap: 1rem; flex-wrap: wrap; font-size: 0.85rem; color: #888; margin-bottom: 2rem; }
	.meta span { background: #f5f5f5; padding: 0.2rem 0.5rem; border-radius: 3px; }
	section { margin-bottom: 3rem; }
	.code { background: #1a1a2e; color: #00d4aa; padding: 1.25rem; border-radius: 8px; overflow-x: auto; font-size: 0.85rem; line-height: 1.5; }
	table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
	th, td { padding: 0.75rem; border: 1px solid #ddd; text-align: left; }
	th { background: #f5f5f5; font-weight: 600; }
	a { color: #00d4aa; }
</style>
