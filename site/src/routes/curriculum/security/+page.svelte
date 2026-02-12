<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Security - LA-Mesh Curriculum</title>
</svelte:head>

<nav class="breadcrumb">
	<a href="{base}/curriculum">Curriculum</a> / Security
</nav>

<h1>Level 3: Mesh Network Security</h1>
<div class="meta">
	<span>2-hour workshop</span>
	<span>Requires Level 1-2</span>
	<span>Free -- fortnightly at Bates College</span>
</div>

<section>
	<h2>Learning Objectives</h2>
	<ol>
		<li>Generate and manage secure PSK keys</li>
		<li>Enable and verify PKC for direct messages</li>
		<li>Explain CVE-2025-52464 and its implications</li>
		<li>Perform a basic threat model for a community mesh</li>
		<li>Follow operational security practices for key distribution</li>
	</ol>
</section>

<section>
	<h2>Part 1: Encryption Layers (25 min)</h2>
	<table>
		<thead><tr><th>Layer</th><th>Mechanism</th><th>Who Can Read</th></tr></thead>
		<tbody>
			<tr><td>Channel</td><td>AES-256-CTR</td><td>All devices with PSK</td></tr>
			<tr><td>Direct Message</td><td>X25519 + AES-256-CCM</td><td>Only recipient</td></tr>
		</tbody>
	</table>
	<pre class="code">{`meshtastic --info  # Check your device's public key`}</pre>
</section>

<section>
	<h2>Part 2: PSK Management (25 min)</h2>
	<pre class="code">{`# Generate a 256-bit PSK
openssl rand -base64 32

# Apply to device
meshtastic --ch-set psk "<your-base64-psk>" --ch-index 0`}</pre>
	<table>
		<thead><tr><th>PSK</th><th>Bits</th><th>Security</th></tr></thead>
		<tbody>
			<tr><td><code>AQ==</code> (default)</td><td>8</td><td>NONE -- publicly known</td></tr>
			<tr><td>Short passphrase</td><td>~40-60</td><td>Weak</td></tr>
			<tr><td>16-byte random</td><td>128</td><td>Good</td></tr>
			<tr><td><strong>32-byte random</strong></td><td><strong>256</strong></td><td><strong>Strong -- LA-Mesh standard</strong></td></tr>
		</tbody>
	</table>
</section>

<section>
	<h2>Part 3: CVE-2025-52464 Case Study (20 min)</h2>
	<p><strong>CVSSv4: 9.5 (Critical)</strong> -- Vendors cloned firmware images without regenerating keys, causing identical key pairs across thousands of devices.</p>
	<p><strong>Fix</strong>: Firmware v2.7.15+ forces key regeneration. LA-Mesh policy: no device below v2.7.15. v2.7.15 also fixes CVE-2025-24797, CVE-2025-55293, CVE-2025-55292, CVE-2025-53627 and enforces PKI-only DMs.</p>
	<pre class="code">{`meshtastic --info | grep "Firmware"`}</pre>
</section>

<section>
	<h2>Part 4: Threat Modeling (30 min)</h2>
	<table>
		<thead><tr><th>Actor</th><th>Capability</th><th>Likelihood</th></tr></thead>
		<tbody>
			<tr><td>Curious neighbor</td><td>SDR receiver, basic skills</td><td>Medium</td></tr>
			<tr><td>Local law enforcement</td><td>Professional RF equipment</td><td>Low-Medium</td></tr>
			<tr><td>Sophisticated adversary</td><td>Full SDR suite, traffic analysis</td><td>Very Low</td></tr>
			<tr><td>Prankster/troll</td><td>Meshtastic device</td><td>Medium</td></tr>
		</tbody>
	</table>
</section>

<section>
	<h2>Part 5: Operational Security (20 min)</h2>
	<ul>
		<li>Enable PKC for direct messages (enforced in v2.7.15+)</li>
		<li>Use a device PIN/screen lock</li>
		<li>Disable GPS position sharing if OpSec requires it</li>
		<li>Monitor node list for unknown devices</li>
		<li>Keep firmware updated</li>
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
</style>
