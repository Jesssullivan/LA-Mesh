<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Community Onboarding - LA-Mesh</title>
</svelte:head>

<nav class="text-sm text-surface-500 mb-4">
	<a href="{base}/guides" class="text-primary-400 no-underline">Guides</a> / Community Onboarding
</nav>

<h1>Community Onboarding Guide</h1>
<p class="text-lg text-surface-400 mb-8">Welcome to LA-Mesh! This guide walks you through joining the community mesh network in the Lewiston-Auburn area.</p>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">What You Need</h2>

	<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
		<div class="p-5 border border-primary-500 border-2 rounded-lg bg-surface-800">
			<h3 class="mt-0 text-surface-100">Option A: Dedicated Device (Recommended)</h3>
			<p class="text-surface-300 mb-4">Purchase a T-Deck Plus (~$82) or T-Deck Pro e-ink (~$111). These are standalone mesh radios with keyboards and screens -- no phone needed.</p>
		</div>

		<div class="p-5 border border-surface-700 rounded-lg bg-surface-800">
			<h3 class="mt-0 text-surface-100">Option B: Phone + Bluetooth Device</h3>
			<p class="text-surface-300 mb-4">Any Meshtastic-compatible device (~$25-80) paired with the Meshtastic app on your phone:</p>
			<ul class="text-surface-300 pl-6 mb-4">
				<li class="mb-1"><strong>Android</strong>: Meshtastic app on Google Play</li>
				<li class="mb-1"><strong>iOS</strong>: Meshtastic app on App Store</li>
			</ul>
		</div>
	</div>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Getting Connected</h2>

	<div class="grid gap-6">
		<div class="flex gap-5 p-5 border border-surface-700 rounded-lg bg-surface-800">
			<span class="flex items-center justify-center w-10 h-10 min-w-[40px] bg-surface-900 text-primary-400 rounded-full font-bold text-xl">1</span>
			<div>
				<h3 class="mt-0 text-surface-100">Get Your Device Configured</h3>
				<p class="text-surface-300 mb-4">Attend a community meetup where an LA-Mesh operator will provision your device:</p>
				<pre class="bg-surface-800 text-primary-400 p-5 rounded-lg overflow-x-auto text-sm leading-relaxed font-mono">{`just provision t-deck /dev/ttyUSB0`}</pre>
				<p class="text-surface-300 mb-4">This single command fetches the manifest-pinned firmware (v2.7.15+), verifies its SHA256 checksum, flashes it, applies the device profile, and configures LA-Mesh channels with the shared PSK.</p>
				<p class="text-sm text-surface-400 italic"><strong>Why in-person?</strong> The encryption key (PSK) is only shared face-to-face for security. We never send it digitally. The <code class="font-mono text-primary-400 bg-surface-800 px-1.5 py-0.5 rounded text-sm">just provision</code> command reads the PSK from the operator's local environment.</p>
			</div>
		</div>

		<div class="flex gap-5 p-5 border border-surface-700 rounded-lg bg-surface-800">
			<span class="flex items-center justify-center w-10 h-10 min-w-[40px] bg-surface-900 text-primary-400 rounded-full font-bold text-xl">2</span>
			<div>
				<h3 class="mt-0 text-surface-100">Learn the Basics</h3>
				<p class="text-surface-300 mb-4">At the meetup, you'll learn:</p>
				<ul class="text-surface-300 pl-6 mb-4">
					<li class="mb-1">How to send and receive messages</li>
					<li class="mb-1">How to read the node list</li>
					<li class="mb-1">What the signal quality numbers mean</li>
					<li class="mb-1">Basic mesh etiquette</li>
				</ul>
			</div>
		</div>

		<div class="flex gap-5 p-5 border border-surface-700 rounded-lg bg-surface-800">
			<span class="flex items-center justify-center w-10 h-10 min-w-[40px] bg-surface-900 text-primary-400 rounded-full font-bold text-xl">3</span>
			<div>
				<h3 class="mt-0 text-surface-100">Stay Connected</h3>
				<ul class="text-surface-300 pl-6 mb-4">
					<li class="mb-1">Keep your device charged and powered on when in the L-A area</li>
					<li class="mb-1">Your device automatically relays messages for other users</li>
					<li class="mb-1">Check for firmware updates at community meetups</li>
				</ul>
			</div>
		</div>
	</div>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Mesh Etiquette</h2>
	<ol class="text-surface-300 pl-6 mb-4">
		<li class="mb-1"><strong>Keep messages concise</strong> -- LoRa is low bandwidth (~1 text message per second)</li>
		<li class="mb-1"><strong>Don't spam</strong> -- excessive messages use airtime that everyone shares</li>
		<li class="mb-1"><strong>Emergency channel is for emergencies only</strong> -- false alarms erode trust</li>
		<li class="mb-1"><strong>Report issues</strong> -- coverage gaps, connectivity problems, suspicious activity</li>
		<li class="mb-1"><strong>Attend meetups</strong> -- for PSK rotations and firmware updates</li>
		<li class="mb-1"><strong>Share knowledge</strong> -- help newcomers get set up</li>
	</ol>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Frequently Asked Questions</h2>

	<div class="grid gap-2">
		<details class="p-4 border border-surface-700 rounded-lg bg-surface-800">
			<summary class="cursor-pointer font-semibold text-surface-100">Can people read my messages?</summary>
			<p class="text-surface-400 mt-3 m-0">Channel messages are encrypted (AES-256) -- only LA-Mesh members with the PSK can read them. For private conversations, use Direct Messages, which have additional end-to-end encryption that even other LA-Mesh members can't read.</p>
		</details>

		<details class="p-4 border border-surface-700 rounded-lg bg-surface-800">
			<summary class="cursor-pointer font-semibold text-surface-100">How far does the signal reach?</summary>
			<p class="text-surface-400 mt-3 m-0">Typically 1-5 km in urban areas, up to 20+ km with line-of-sight to a router. Your messages can "hop" through other devices to reach further.</p>
		</details>

		<details class="p-4 border border-surface-700 rounded-lg bg-surface-800">
			<summary class="cursor-pointer font-semibold text-surface-100">Does it use the internet?</summary>
			<p class="text-surface-400 mt-3 m-0">No! The mesh operates entirely on LoRa radio. No WiFi, no cell service, no internet needed. The gateway bridge provides optional SMS/email connectivity.</p>
		</details>

		<details class="p-4 border border-surface-700 rounded-lg bg-surface-800">
			<summary class="cursor-pointer font-semibold text-surface-100">Can I see my location on the network?</summary>
			<p class="text-surface-400 mt-3 m-0">If GPS is enabled, your position is shared with other mesh users. You can disable GPS in your device settings if you prefer not to share location.</p>
		</details>

		<details class="p-4 border border-surface-700 rounded-lg bg-surface-800">
			<summary class="cursor-pointer font-semibold text-surface-100">What happens if a tower node goes down?</summary>
			<p class="text-surface-400 mt-3 m-0">The mesh re-routes around it. With multiple routers, the network is resilient to individual node failures.</p>
		</details>

		<details class="p-4 border border-surface-700 rounded-lg bg-surface-800">
			<summary class="cursor-pointer font-semibold text-surface-100">Can I use this for voice calls?</summary>
			<p class="text-surface-400 mt-3 m-0">No. LoRa is text-only due to low bandwidth. Think of it like texting, not calling.</p>
		</details>
	</div>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Community Meetups</h2>
	<div class="grid gap-2">
		<div class="flex justify-between p-3 bg-surface-800 rounded-md border-l-[3px] border-primary-400">
			<span class="font-semibold text-surface-400">Location</span>
			<span class="text-surface-200">TBD (Lewiston-Auburn area)</span>
		</div>
		<div class="flex justify-between p-3 bg-surface-800 rounded-md border-l-[3px] border-primary-400">
			<span class="font-semibold text-surface-400">Frequency</span>
			<span class="text-surface-200">Monthly (more often during setup phase)</span>
		</div>
		<div class="flex justify-between p-3 bg-surface-800 rounded-md border-l-[3px] border-primary-400">
			<span class="font-semibold text-surface-400">Purpose</span>
			<span class="text-surface-200">Onboarding, PSK rotation, firmware updates, coverage reports</span>
		</div>
	</div>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Recommended Resources</h2>
	<ul class="text-surface-300 pl-6 mb-4">
		<li class="mb-1"><a href="https://gajim.org/" class="text-primary-400">Gajim</a> -- open-source XMPP client with OMEMO encryption for operator coordination</li>
	</ul>
</section>

<section class="mb-12">
	<h2 class="text-2xl font-bold text-surface-50 mb-4">Want to Help?</h2>
	<ul class="text-surface-300 pl-6 mb-4">
		<li class="mb-1"><strong>Host a node</strong>: If you have a high location (rooftop, hilltop), we may be able to place a relay node</li>
		<li class="mb-1"><strong>Volunteer</strong>: Help at meetups, assist with installations, contribute to documentation</li>
		<li class="mb-1"><strong>Spread the word</strong>: Tell neighbors, friends, community organizations</li>
	</ul>
</section>
