<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Guides - LA-Mesh</title>
</svelte:head>

<h1>Guides</h1>
<p>Step-by-step instructions for joining and operating on the LA-Mesh network.</p>

<div class="guide-list">
	<a href="{base}/guides/community-onboarding" class="guide">
		<h2>Community Onboarding</h2>
		<p>Welcome to LA-Mesh. Get your device, learn the basics, and join the mesh.</p>
		<span class="status">Start Here</span>
	</a>

	<a href="{base}/guides/firmware-flashing" class="guide">
		<h2>Firmware Flashing</h2>
		<p>Flash Meshtastic or MeshCore firmware via web flasher, CLI, or meshtasticd.</p>
		<span class="status">Available</span>
	</a>

	<a href="{base}/guides/device-profiles" class="guide">
		<h2>Device Profiles</h2>
		<p>Choose and apply the right configuration profile for your device role.</p>
		<span class="status">Available</span>
	</a>

	<a href="{base}/guides/troubleshooting" class="guide">
		<h2>Troubleshooting</h2>
		<p>Common issues and solutions for devices, network, firmware, and bridges.</p>
		<span class="status">Available</span>
	</a>

	<div class="guide">
		<h2>Node Deployment</h2>
		<p>Site survey, preparation, installation, verification, and ongoing monitoring for relay nodes.</p>
		<span class="status">Available</span>
	</div>

	<div class="guide">
		<h2>Bench Testing Protocol</h2>
		<p>6 structured test protocols: basic comms, indoor/outdoor range, multi-hop, antenna comparison, battery life.</p>
		<span class="status">Available</span>
	</div>

	<div class="guide">
		<h2>Key Management</h2>
		<p>PSK lifecycle, operator roles, key rotation procedures, and GPG quickstart.</p>
		<span class="status">Available</span>
	</div>

	<div class="guide">
		<h2>Solar Relay Deployment</h2>
		<p>Panel sizing for 44.1N latitude, battery calculations, weatherproofing, and seasonal maintenance.</p>
		<span class="status">Available</span>
	</div>

	<div class="guide">
		<h2>Developer Guide</h2>
		<p>Dev environment setup (Nix or manual), repo structure, branch strategy, and CI/CD pipeline.</p>
		<span class="status">Available</span>
	</div>
</div>

<style>
	p {
		color: #555;
		margin-bottom: 2rem;
	}

	.guide-list {
		display: grid;
		gap: 1rem;
	}

	.guide {
		display: block;
		padding: 1.25rem;
		border: 1px solid #ddd;
		border-radius: 8px;
		background: white;
		text-decoration: none;
		color: inherit;
		transition: border-color 0.2s, box-shadow 0.2s;
	}

	a.guide:hover {
		border-color: #00d4aa;
		box-shadow: 0 2px 8px rgba(0, 212, 170, 0.15);
	}

	.guide h2 {
		margin: 0 0 0.5rem;
		font-size: 1.2rem;
	}

	.guide p {
		margin: 0 0 0.75rem;
		color: #555;
	}

	.status {
		display: inline-block;
		padding: 0.15rem 0.5rem;
		border-radius: 4px;
		font-size: 0.8rem;
		background: #00d4aa;
		color: white;
	}
</style>
