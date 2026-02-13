<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>GPG Guide - LA-Mesh</title>
</svelte:head>

<nav class="text-sm text-surface-500 mb-4">
	<a href="{base}/guides" class="text-primary-400 no-underline">Guides</a> / GPG
</nav>

<h1>GPG Quick Start</h1>
<p class="text-lg text-surface-400 mb-8">Generate keys, sign and encrypt messages, verify firmware downloads, and publish your public key.</p>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">What GPG Does for LA-Mesh</h2>
	<ul class="text-surface-300 pl-6 mb-4">
		<li class="mb-1">Verify GPG signatures on email bridge messages</li>
		<li class="mb-1">Sign and encrypt arbitrary messages for specific recipients over insecure channels</li>
		<li class="mb-1">Verify downloaded firmware and TAILS ISO integrity</li>
	</ul>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Generate a Key Pair (Ed25519)</h2>
	<pre class="bg-surface-800 text-primary-400 p-5 rounded-lg overflow-x-auto text-sm leading-relaxed font-mono">{`# Generate Ed25519 signing key + cv25519 encryption subkey
gpg --quick-gen-key "Your Name <you@example.com>" ed25519 cert 0
# Add encryption subkey
gpg --quick-add-key $(gpg -k --with-colons you@example.com | \\
  grep fpr | head -1 | cut -d: -f10) cv25519 encr 0`}</pre>
	<p class="text-surface-300 mb-4">Ed25519 keys are shorter, faster, and more secure than RSA-4096 for modern use.</p>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Publish Your Public Key</h2>
	<pre class="bg-surface-800 text-primary-400 p-5 rounded-lg overflow-x-auto text-sm leading-relaxed font-mono">{`# Upload to keyserver
gpg --keyserver hkps://keys.openpgp.org --send-keys <KEY-ID>

# Export for in-person exchange via QR code
gpg --export <KEY-ID> | qrencode -o pubkey-qr.png`}</pre>
	<p class="text-surface-300 mb-4">Keyserver: <a href="https://keys.openpgp.org" class="text-primary-400">keys.openpgp.org</a></p>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Sign and Encrypt</h2>
	<pre class="bg-surface-800 text-primary-400 p-5 rounded-lg overflow-x-auto text-sm leading-relaxed font-mono">{`# Clearsign a message (readable + signature)
gpg --clearsign message.txt

# Encrypt for a specific recipient
gpg --encrypt --armor --recipient recipient@example.com message.txt

# Verify a signature
gpg --verify message.txt.asc`}</pre>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Verify Downloaded Files</h2>
	<pre class="bg-surface-800 text-primary-400 p-5 rounded-lg overflow-x-auto text-sm leading-relaxed font-mono">{`# Verify firmware release signature
gpg --verify firmware-2.7.15.zip.sig firmware-2.7.15.zip

# Verify TAILS ISO
gpg --verify tails-amd64-7.4.2.iso.sig tails-amd64-7.4.2.iso`}</pre>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Client Setup</h2>
	<table class="w-full border-collapse mt-4">
		<thead><tr><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Platform</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Client</th><th class="bg-surface-800 text-surface-300 p-3 text-left text-xs uppercase tracking-wider">Notes</th></tr></thead>
		<tbody>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Thunderbird</td><td class="p-3 text-surface-200 border-b border-surface-700">Built-in OpenPGP</td><td class="p-3 text-surface-200 border-b border-surface-700">No Enigmail needed (Thunderbird 78+)</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">TAILS</td><td class="p-3 text-surface-200 border-b border-surface-700">Kleopatra (built-in)</td><td class="p-3 text-surface-200 border-b border-surface-700">GUI key manager included in TAILS</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">Linux CLI</td><td class="p-3 text-surface-200 border-b border-surface-700">gpg</td><td class="p-3 text-surface-200 border-b border-surface-700">Installed by default on most distributions</td></tr>
			<tr><td class="p-3 text-surface-200 border-b border-surface-700">macOS</td><td class="p-3 text-surface-200 border-b border-surface-700">GPG Suite</td><td class="p-3 text-surface-200 border-b border-surface-700">Integrates with Apple Mail</td></tr>
		</tbody>
	</table>
</section>
