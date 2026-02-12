<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Key Management - LA-Mesh</title>
</svelte:head>

<nav class="breadcrumb">
	<a href="{base}/guides">Guides</a> / Key Management
</nav>

<h1>Key Management Guide</h1>
<p class="intro">PSK lifecycle, operator roles, key rotation procedures, and credential management for LA-Mesh.</p>

<section>
	<h2>Key Types</h2>
	<table>
		<thead><tr><th>Key</th><th>Type</th><th>Stored Where</th><th>Rotated</th></tr></thead>
		<tbody>
			<tr><td>Channel PSK (x3)</td><td>Symmetric (AES-256)</td><td>Operator encrypted storage</td><td>Quarterly</td></tr>
			<tr><td>Device PKC key pair</td><td>Asymmetric (X25519)</td><td>On-device only</td><td>On firmware update</td></tr>
			<tr><td>MQTT credentials</td><td>Username/password</td><td>Encrypted keystore (KeePassXC)</td><td>On compromise</td></tr>
			<tr><td>SMTP credentials</td><td>API token</td><td>Encrypted keystore (KeePassXC)</td><td>On compromise</td></tr>
		</tbody>
	</table>
</section>

<section>
	<h2>PSK Generation</h2>
	<pre class="code">{`# Generate a 256-bit random PSK on a trusted machine
openssl rand -base64 32`}</pre>
	<p>Produces a key like: <code>K7xR2p4mN8vQwY3jH6fL0tBuI9sDcE5gA1rO7kZ4hXs=</code></p>
</section>

<section>
	<h2>PSK Distribution Rules</h2>
	<ol>
		<li>Generate on an air-gapped device or trusted machine</li>
		<li>Distribute ONLY in person, face-to-face</li>
		<li>Never send via text, email, Signal, or any digital channel</li>
		<li>Write on paper, show screen, or use QR code in-person</li>
		<li>Destroy paper copies after devices are configured</li>
		<li>Rotate quarterly or immediately on suspected compromise</li>
	</ol>
</section>

<section>
	<h2>PSK Application</h2>
	<pre class="code">{`# Apply PSK to device
meshtastic --ch-set psk "<base64-psk>" --ch-index 0

# Verify
meshtastic --info`}</pre>
</section>

<section>
	<h2>Compromise Response</h2>
	<table>
		<thead><tr><th>Event</th><th>Action</th></tr></thead>
		<tbody>
			<tr><td>Suspected PSK leak</td><td>Rotate affected channel immediately</td></tr>
			<tr><td>Device theft</td><td>Rotate all channels, attempt remote wipe via admin channel</td></tr>
			<tr><td>Firmware vulnerability</td><td>Update all devices, rotate PKC keys if needed</td></tr>
			<tr><td>Operator departure</td><td>Rotate admin channel PSK</td></tr>
		</tbody>
	</table>
</section>

<section>
	<h2>Recommended Tools</h2>
	<table>
		<thead><tr><th>Tool</th><th>Purpose</th></tr></thead>
		<tbody>
			<tr><td><a href="https://keepassxc.org">KeePassXC</a></td><td>Offline AES-256 encrypted credential storage for PSKs, MQTT/SMTP credentials, and API tokens</td></tr>
			<tr><td><a href="https://conversations.im/omemo/">OMEMO</a></td><td>Signal Protocol over federated XMPP -- end-to-end encrypted messaging for operator coordination</td></tr>
		</tbody>
	</table>
</section>

<style>
	.breadcrumb { font-size: 0.85rem; color: #888; margin-bottom: 1rem; }
	.breadcrumb a { color: #00d4aa; text-decoration: none; }
	.intro { font-size: 1.1rem; color: #555; margin-bottom: 2rem; }
	section { margin-bottom: 3rem; }
	.code { background: #1a1a2e; color: #00d4aa; padding: 1.25rem; border-radius: 8px; overflow-x: auto; font-size: 0.85rem; line-height: 1.5; }
	code { background: #f0f0f0; padding: 0.15rem 0.35rem; border-radius: 3px; font-size: 0.85rem; }
	table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
	th, td { padding: 0.75rem; border: 1px solid #ddd; text-align: left; }
	th { background: #f5f5f5; font-weight: 600; }
</style>
