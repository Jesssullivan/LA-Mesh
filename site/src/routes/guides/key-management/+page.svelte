<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Key Management - LA-Mesh</title>
</svelte:head>

<nav class="text-sm text-surface-500 mb-4">
	<a href="{base}/guides" class="text-primary-400 no-underline">Guides</a> / Key Management
</nav>

<h1>Key Management Guide</h1>
<p class="text-lg text-surface-400 mb-8">PSK lifecycle, operator roles, key rotation procedures, and credential management for LA-Mesh.</p>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Key Types</h2>
	<table class="w-full border-collapse mt-4">
		<thead><tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Key</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Type</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Stored Where</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Rotated</th></tr></thead>
		<tbody>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Channel PSK (x3)</td><td class="p-3 text-surface-200 border-b border-surface-700">Symmetric (AES-256)</td><td class="p-3 text-surface-200 border-b border-surface-700">Operator encrypted storage</td><td class="p-3 text-surface-200 border-b border-surface-700">Quarterly</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Device PKC key pair</td><td class="p-3 text-surface-200 border-b border-surface-700">Asymmetric (X25519)</td><td class="p-3 text-surface-200 border-b border-surface-700">On-device only</td><td class="p-3 text-surface-200 border-b border-surface-700">On firmware update</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">MQTT credentials</td><td class="p-3 text-surface-200 border-b border-surface-700">Username/password</td><td class="p-3 text-surface-200 border-b border-surface-700">Encrypted keystore (KeePassXC)</td><td class="p-3 text-surface-200 border-b border-surface-700">On compromise</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">SMTP credentials</td><td class="p-3 text-surface-200 border-b border-surface-700">API token</td><td class="p-3 text-surface-200 border-b border-surface-700">Encrypted keystore (KeePassXC)</td><td class="p-3 text-surface-200 border-b border-surface-700">On compromise</td></tr>
		</tbody>
	</table>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">PSK Generation</h2>
	<pre class="bg-surface-800 text-primary-400 p-5 rounded-lg overflow-x-auto text-sm leading-relaxed font-mono">{`# Generate a 256-bit random PSK on a trusted machine
openssl rand -base64 32`}</pre>
	<p class="text-surface-300 mb-4">Produces a key like: <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">K7xR2p4mN8vQwY3jH6fL0tBuI9sDcE5gA1rO7kZ4hXs=</code></p>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">PSK Distribution Rules</h2>
	<ol class="text-surface-300 pl-6 mb-4">
		<li class="mb-1">Generate on an air-gapped device or trusted machine</li>
		<li class="mb-1">Distribute ONLY in person, face-to-face</li>
		<li class="mb-1">Never send via text, email, Signal, or any digital channel</li>
		<li class="mb-1">Write on paper, show screen, or use QR code in-person</li>
		<li class="mb-1">Destroy paper copies after devices are configured</li>
		<li class="mb-1">Rotate quarterly or immediately on suspected compromise</li>
	</ol>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">PSK Application</h2>
	<pre class="bg-surface-800 text-primary-400 p-5 rounded-lg overflow-x-auto text-sm leading-relaxed font-mono">{`# Apply PSK to device
meshtastic --ch-set psk "<base64-psk>" --ch-index 0

# Verify
meshtastic --info`}</pre>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Compromise Response</h2>
	<table class="w-full border-collapse mt-4">
		<thead><tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Event</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Action</th></tr></thead>
		<tbody>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Suspected PSK leak</td><td class="p-3 text-surface-200 border-b border-surface-700">Rotate affected channel immediately</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Device theft</td><td class="p-3 text-surface-200 border-b border-surface-700">Rotate all channels, attempt remote wipe via admin channel</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Firmware vulnerability</td><td class="p-3 text-surface-200 border-b border-surface-700">Update all devices, rotate PKC keys if needed</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Operator departure</td><td class="p-3 text-surface-200 border-b border-surface-700">Rotate admin channel PSK</td></tr>
		</tbody>
	</table>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Recommended Tools</h2>
	<table class="w-full border-collapse mt-4">
		<thead><tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Tool</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Purpose</th></tr></thead>
		<tbody>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700"><a href="https://keepassxc.org" class="text-primary-400">KeePassXC</a></td><td class="p-3 text-surface-200 border-b border-surface-700">Offline AES-256 encrypted credential storage for PSKs, MQTT/SMTP credentials, and API tokens</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700"><a href="https://conversations.im/omemo/" class="text-primary-400">OMEMO</a></td><td class="p-3 text-surface-200 border-b border-surface-700">Signal Protocol over federated XMPP -- end-to-end encrypted messaging for operator coordination</td></tr>
		</tbody>
	</table>
</section>
