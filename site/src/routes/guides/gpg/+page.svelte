<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>GPG Guide - LA-Mesh</title>
</svelte:head>

<nav class="breadcrumb">
	<a href="{base}/guides">Guides</a> / GPG
</nav>

<h1>GPG Quick Start</h1>
<p class="intro">Generate keys, sign and encrypt messages, verify firmware downloads, and publish your public key.</p>

<section>
	<h2>What GPG Does for LA-Mesh</h2>
	<ul>
		<li>Verify GPG signatures on email bridge messages</li>
		<li>Sign and encrypt arbitrary messages for specific recipients over insecure channels</li>
		<li>Verify downloaded firmware and TAILS ISO integrity</li>
	</ul>
</section>

<section>
	<h2>Generate a Key Pair (Ed25519)</h2>
	<pre class="code">{`# Generate Ed25519 signing key + cv25519 encryption subkey
gpg --quick-gen-key "Your Name <you@example.com>" ed25519 cert 0
# Add encryption subkey
gpg --quick-add-key $(gpg -k --with-colons you@example.com | \\
  grep fpr | head -1 | cut -d: -f10) cv25519 encr 0`}</pre>
	<p>Ed25519 keys are shorter, faster, and more secure than RSA-4096 for modern use.</p>
</section>

<section>
	<h2>Publish Your Public Key</h2>
	<pre class="code">{`# Upload to keyserver
gpg --keyserver hkps://keys.openpgp.org --send-keys <KEY-ID>

# Export for in-person exchange via QR code
gpg --export <KEY-ID> | qrencode -o pubkey-qr.png`}</pre>
	<p>Keyserver: <a href="https://keys.openpgp.org">keys.openpgp.org</a></p>
</section>

<section>
	<h2>Sign and Encrypt</h2>
	<pre class="code">{`# Clearsign a message (readable + signature)
gpg --clearsign message.txt

# Encrypt for a specific recipient
gpg --encrypt --armor --recipient recipient@example.com message.txt

# Verify a signature
gpg --verify message.txt.asc`}</pre>
</section>

<section>
	<h2>Verify Downloaded Files</h2>
	<pre class="code">{`# Verify firmware release signature
gpg --verify firmware-2.7.15.zip.sig firmware-2.7.15.zip

# Verify TAILS ISO
gpg --verify tails-amd64-7.4.2.iso.sig tails-amd64-7.4.2.iso`}</pre>
</section>

<section>
	<h2>Client Setup</h2>
	<table>
		<thead><tr><th>Platform</th><th>Client</th><th>Notes</th></tr></thead>
		<tbody>
			<tr><td>Thunderbird</td><td>Built-in OpenPGP</td><td>No Enigmail needed (Thunderbird 78+)</td></tr>
			<tr><td>TAILS</td><td>Kleopatra (built-in)</td><td>GUI key manager included in TAILS</td></tr>
			<tr><td>Linux CLI</td><td>gpg</td><td>Installed by default on most distributions</td></tr>
			<tr><td>macOS</td><td>GPG Suite</td><td>Integrates with Apple Mail</td></tr>
		</tbody>
	</table>
</section>

<style>
	.breadcrumb { font-size: 0.85rem; color: #888; margin-bottom: 1rem; }
	.breadcrumb a { color: #00d4aa; text-decoration: none; }
	.intro { font-size: 1.1rem; color: #555; margin-bottom: 2rem; }
	section { margin-bottom: 3rem; }
	.code { background: #1a1a2e; color: #00d4aa; padding: 1.25rem; border-radius: 8px; overflow-x: auto; font-size: 0.85rem; line-height: 1.5; }
	table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
	th, td { padding: 0.75rem; border: 1px solid #ddd; text-align: left; }
	th { background: #f5f5f5; font-weight: 600; }
	a { color: #00d4aa; }
</style>
