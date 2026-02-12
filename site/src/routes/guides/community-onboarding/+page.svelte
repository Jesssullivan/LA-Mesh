<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Community Onboarding - LA-Mesh</title>
</svelte:head>

<nav class="breadcrumb">
	<a href="{base}/guides">Guides</a> / Community Onboarding
</nav>

<h1>Community Onboarding Guide</h1>
<p class="intro">Welcome to LA-Mesh! This guide walks you through joining the community mesh network in the Lewiston-Auburn area.</p>

<section>
	<h2>What You Need</h2>

	<div class="options">
		<div class="option recommended">
			<h3>Option A: Dedicated Device (Recommended)</h3>
			<p>Purchase a T-Deck Plus (~$82) or T-Deck Pro e-ink (~$111). These are standalone mesh radios with keyboards and screens -- no phone needed.</p>
		</div>

		<div class="option">
			<h3>Option B: Phone + Bluetooth Device</h3>
			<p>Any Meshtastic-compatible device (~$25-80) paired with the Meshtastic app on your phone:</p>
			<ul>
				<li><strong>Android</strong>: Meshtastic app on Google Play</li>
				<li><strong>iOS</strong>: Meshtastic app on App Store</li>
			</ul>
		</div>
	</div>
</section>

<section>
	<h2>Getting Connected</h2>

	<div class="steps">
		<div class="step">
			<span class="step-num">1</span>
			<div>
				<h3>Get Your Device Configured</h3>
				<p>Attend a community meetup where an LA-Mesh operator will provision your device:</p>
				<pre class="code">{`just provision t-deck /dev/ttyUSB0`}</pre>
				<p>This single command fetches the manifest-pinned firmware (v2.7.15+), verifies its SHA256 checksum, flashes it, applies the device profile, and configures LA-Mesh channels with the shared PSK.</p>
				<p class="note"><strong>Why in-person?</strong> The encryption key (PSK) is only shared face-to-face for security. We never send it digitally. The <code>just provision</code> command reads the PSK from the operator's local environment.</p>
			</div>
		</div>

		<div class="step">
			<span class="step-num">2</span>
			<div>
				<h3>Learn the Basics</h3>
				<p>At the meetup, you'll learn:</p>
				<ul>
					<li>How to send and receive messages</li>
					<li>How to read the node list</li>
					<li>What the signal quality numbers mean</li>
					<li>Basic mesh etiquette</li>
				</ul>
			</div>
		</div>

		<div class="step">
			<span class="step-num">3</span>
			<div>
				<h3>Stay Connected</h3>
				<ul>
					<li>Keep your device charged and powered on when in the L-A area</li>
					<li>Your device automatically relays messages for other users</li>
					<li>Check for firmware updates at community meetups</li>
				</ul>
			</div>
		</div>
	</div>
</section>

<section>
	<h2>Mesh Etiquette</h2>
	<ol class="etiquette">
		<li><strong>Keep messages concise</strong> -- LoRa is low bandwidth (~1 text message per second)</li>
		<li><strong>Don't spam</strong> -- excessive messages use airtime that everyone shares</li>
		<li><strong>Emergency channel is for emergencies only</strong> -- false alarms erode trust</li>
		<li><strong>Report issues</strong> -- coverage gaps, connectivity problems, suspicious activity</li>
		<li><strong>Attend meetups</strong> -- for PSK rotations and firmware updates</li>
		<li><strong>Share knowledge</strong> -- help newcomers get set up</li>
	</ol>
</section>

<section>
	<h2>Frequently Asked Questions</h2>

	<div class="faq-list">
		<details>
			<summary>Can people read my messages?</summary>
			<p>Channel messages are encrypted (AES-256) -- only LA-Mesh members with the PSK can read them. For private conversations, use Direct Messages, which have additional end-to-end encryption that even other LA-Mesh members can't read.</p>
		</details>

		<details>
			<summary>How far does the signal reach?</summary>
			<p>Typically 1-5 km in urban areas, up to 20+ km with line-of-sight to a router. Your messages can "hop" through other devices to reach further.</p>
		</details>

		<details>
			<summary>Does it use the internet?</summary>
			<p>No! The mesh operates entirely on LoRa radio. No WiFi, no cell service, no internet needed. The gateway bridge provides optional SMS/email connectivity.</p>
		</details>

		<details>
			<summary>Can I see my location on the network?</summary>
			<p>If GPS is enabled, your position is shared with other mesh users. You can disable GPS in your device settings if you prefer not to share location.</p>
		</details>

		<details>
			<summary>What happens if a tower node goes down?</summary>
			<p>The mesh re-routes around it. With multiple routers, the network is resilient to individual node failures.</p>
		</details>

		<details>
			<summary>Can I use this for voice calls?</summary>
			<p>No. LoRa is text-only due to low bandwidth. Think of it like texting, not calling.</p>
		</details>
	</div>
</section>

<section>
	<h2>Community Meetups</h2>
	<div class="meetup-info">
		<div class="config-item">
			<span class="label">Location</span>
			<span class="value">TBD (Lewiston-Auburn area)</span>
		</div>
		<div class="config-item">
			<span class="label">Frequency</span>
			<span class="value">Monthly (more often during setup phase)</span>
		</div>
		<div class="config-item">
			<span class="label">Purpose</span>
			<span class="value">Onboarding, PSK rotation, firmware updates, coverage reports</span>
		</div>
	</div>
</section>

<section>
	<h2>Recommended Resources</h2>
	<ul>
		<li><a href="https://gajim.org/">Gajim</a> -- open-source XMPP client with OMEMO encryption for operator coordination</li>
	</ul>
</section>

<section>
	<h2>Want to Help?</h2>
	<ul>
		<li><strong>Host a node</strong>: If you have a high location (rooftop, hilltop), we may be able to place a relay node</li>
		<li><strong>Volunteer</strong>: Help at meetups, assist with installations, contribute to documentation</li>
		<li><strong>Spread the word</strong>: Tell neighbors, friends, community organizations</li>
	</ul>
</section>

<style>
	.breadcrumb {
		font-size: 0.85rem;
		color: #888;
		margin-bottom: 1rem;
	}

	.breadcrumb a {
		color: #00d4aa;
		text-decoration: none;
	}

	.intro {
		font-size: 1.1rem;
		color: #555;
		margin-bottom: 2rem;
	}

	section {
		margin-bottom: 3rem;
	}

	.options {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
		gap: 1rem;
	}

	.option {
		padding: 1.25rem;
		border: 1px solid #ddd;
		border-radius: 8px;
		background: white;
	}

	.option.recommended {
		border-color: #00d4aa;
		border-width: 2px;
	}

	.option h3 {
		margin-top: 0;
	}

	.steps {
		display: grid;
		gap: 1.5rem;
	}

	.step {
		display: flex;
		gap: 1.25rem;
		padding: 1.25rem;
		border: 1px solid #ddd;
		border-radius: 8px;
		background: white;
	}

	.step-num {
		display: flex;
		align-items: center;
		justify-content: center;
		width: 40px;
		height: 40px;
		min-width: 40px;
		background: #1a1a2e;
		color: #00d4aa;
		border-radius: 50%;
		font-weight: bold;
		font-size: 1.2rem;
	}

	.step h3 {
		margin-top: 0;
	}

	.note {
		font-size: 0.9rem;
		color: #888;
		font-style: italic;
	}

	.code {
		background: #1a1a2e;
		color: #00d4aa;
		padding: 1rem;
		border-radius: 8px;
		overflow-x: auto;
		font-size: 0.85rem;
		line-height: 1.5;
		margin: 0.75rem 0;
	}

	code {
		background: #f0f0f0;
		padding: 0.15rem 0.35rem;
		border-radius: 3px;
		font-size: 0.85rem;
	}

	.etiquette li {
		margin-bottom: 0.5rem;
	}

	.faq-list {
		display: grid;
		gap: 0.5rem;
	}

	details {
		padding: 1rem;
		border: 1px solid #ddd;
		border-radius: 8px;
		background: white;
	}

	summary {
		cursor: pointer;
		font-weight: 600;
		color: #1a1a2e;
	}

	details p {
		margin: 0.75rem 0 0;
		color: #555;
	}

	.meetup-info {
		display: grid;
		gap: 0.5rem;
	}

	.config-item {
		display: flex;
		justify-content: space-between;
		padding: 0.75rem 1rem;
		background: #f9f9f9;
		border-radius: 6px;
		border-left: 3px solid #00d4aa;
	}

	.label {
		font-weight: 600;
		color: #555;
	}

	.value {
		color: #1a1a2e;
	}
</style>
