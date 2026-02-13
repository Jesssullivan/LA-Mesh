<script>
	import { base } from '$app/paths';

</script>

<svelte:head>
	<title>Guides - LA-Mesh</title>
</svelte:head>

<h1 class="text-3xl font-bold text-surface-50 mb-2">Guides</h1>
<p class="text-surface-400 mb-8">Step-by-step instructions for joining and operating on the LA-Mesh network.</p>

<div class="grid gap-4">
	<a href="{base}/guides/community-onboarding" class="block p-5 border border-surface-700 rounded-lg bg-surface-800 no-underline text-inherit hover:border-primary-500 transition-colors">
		<h2 class="text-lg font-bold text-surface-50 m-0 mb-2">Community Onboarding</h2>
		<p class="text-surface-400 text-sm m-0">Welcome to LA-Mesh. Get your device, learn the basics, and join the mesh.</p>
	</a>

	<a href="{base}/guides/firmware-flashing" class="block p-5 border border-surface-700 rounded-lg bg-surface-800 no-underline text-inherit hover:border-primary-500 transition-colors">
		<h2 class="text-lg font-bold text-surface-50 m-0 mb-2">Firmware Flashing</h2>
		<p class="text-surface-400 text-sm m-0">Flash Meshtastic or MeshCore firmware via web flasher, CLI, or meshtasticd.</p>
	</a>

	<a href="{base}/guides/device-profiles" class="block p-5 border border-surface-700 rounded-lg bg-surface-800 no-underline text-inherit hover:border-primary-500 transition-colors">
		<h2 class="text-lg font-bold text-surface-50 m-0 mb-2">Device Profiles</h2>
		<p class="text-surface-400 text-sm m-0">Choose and apply the right configuration profile for your device role.</p>
	</a>

	<a href="{base}/guides/troubleshooting" class="block p-5 border border-surface-700 rounded-lg bg-surface-800 no-underline text-inherit hover:border-primary-500 transition-colors">
		<h2 class="text-lg font-bold text-surface-50 m-0 mb-2">Troubleshooting</h2>
		<p class="text-surface-400 text-sm m-0">Common issues and solutions for devices, network, firmware, and bridges.</p>
	</a>

	<a href="{base}/guides/node-deployment" class="block p-5 border border-surface-700 rounded-lg bg-surface-800 no-underline text-inherit hover:border-primary-500 transition-colors">
		<h2 class="text-lg font-bold text-surface-50 m-0 mb-2">Node Deployment</h2>
		<p class="text-surface-400 text-sm m-0">Site survey, preparation, installation, verification, and ongoing monitoring for relay nodes.</p>
	</a>

	<a href="{base}/guides/bench-testing" class="block p-5 border border-surface-700 rounded-lg bg-surface-800 no-underline text-inherit hover:border-primary-500 transition-colors">
		<h2 class="text-lg font-bold text-surface-50 m-0 mb-2">Bench Testing Protocol</h2>
		<p class="text-surface-400 text-sm m-0">6 structured test protocols: basic comms, indoor/outdoor range, multi-hop, antenna comparison, battery life.</p>
	</a>

	<a href="{base}/guides/key-management" class="block p-5 border border-surface-700 rounded-lg bg-surface-800 no-underline text-inherit hover:border-primary-500 transition-colors">
		<h2 class="text-lg font-bold text-surface-50 m-0 mb-2">Key Management</h2>
		<p class="text-surface-400 text-sm m-0">PSK lifecycle, operator roles, key rotation procedures, and credential management.</p>
	</a>

	<a href="{base}/guides/gpg" class="block p-5 border border-surface-700 rounded-lg bg-surface-800 no-underline text-inherit hover:border-primary-500 transition-colors">
		<h2 class="text-lg font-bold text-surface-50 m-0 mb-2">GPG Quick Start</h2>
		<p class="text-surface-400 text-sm m-0">Ed25519 key generation, signing, encryption, keyserver publishing, and firmware verification.</p>
	</a>

	<a href="{base}/guides/stealth-mode" class="block p-5 border border-surface-700 rounded-lg bg-surface-800 no-underline text-inherit hover:border-primary-500 transition-colors">
		<h2 class="text-lg font-bold text-surface-50 m-0 mb-2">Stealth Mode</h2>
		<p class="text-surface-400 text-sm m-0">Minimize RF footprint with CLIENT_HIDDEN mode, disable position broadcast, reduce network visibility.</p>
	</a>

	<a href="{base}/guides/solar-relay" class="block p-5 border border-surface-700 rounded-lg bg-surface-800 no-underline text-inherit hover:border-primary-500 transition-colors">
		<h2 class="text-lg font-bold text-surface-50 m-0 mb-2">Solar Relay Deployment</h2>
		<p class="text-surface-400 text-sm m-0">Panel sizing for 44.1N latitude, battery calculations, weatherproofing, and seasonal maintenance.</p>
	</a>

	<a href="{base}/guides/firmware-switching" class="block p-5 border border-surface-700 rounded-lg bg-surface-800 no-underline text-inherit hover:border-primary-500 transition-colors">
		<h2 class="text-lg font-bold text-surface-50 m-0 mb-2">Firmware Switching</h2>
		<p class="text-surface-400 text-sm m-0">Switch between Meshtastic and MeshCore firmware. Backup, erase, flash, and configure in ~60 seconds.</p>
	</a>

	<a href="{base}/guides/developing" class="block p-5 border border-surface-700 rounded-lg bg-surface-800 no-underline text-inherit hover:border-primary-500 transition-colors">
		<h2 class="text-lg font-bold text-surface-50 m-0 mb-2">Developer Guide</h2>
		<p class="text-surface-400 text-sm m-0">Dev environment setup (Nix or manual), repo structure, just recipes, branch strategy, and CI/CD.</p>
	</a>
</div>
