<script>
	import { base } from '$app/paths';
	import StatusBadge from '$lib/components/StatusBadge.svelte';
</script>

<svelte:head>
	<title>Devices - LA-Mesh</title>
</svelte:head>

<h1 class="text-3xl font-bold text-surface-50 mb-8">Supported Devices</h1>

<div class="grid gap-8 mt-8">
	<div class="p-6 border border-surface-700 rounded-lg bg-surface-800">
		<div class="flex items-center gap-3 mb-1">
			<h2 class="text-xl font-bold text-surface-50 m-0">Station G2</h2>
			<StatusBadge status="working" />
		</div>
		<span class="inline-block px-2 py-0.5 rounded text-xs font-medium bg-primary-500/20 text-primary-400 mb-3">Base Station / Relay</span>
		<p class="text-surface-300 mb-4">High-power (up to 4.46W) base station for rooftop and tower deployment. ESP32-S3 + SX1262 with dedicated PA and ultra-low noise LNA.</p>
		<dl class="grid grid-cols-[auto_1fr] gap-x-4 gap-y-1 text-sm">
			<dt class="font-semibold text-surface-400">Price</dt><dd class="text-surface-200 m-0">~$109</dd>
			<dt class="font-semibold text-surface-400">TX Power</dt><dd class="text-surface-200 m-0">Up to 36.5 dBm</dd>
			<dt class="font-semibold text-surface-400">Firmware</dt><dd class="text-surface-200 m-0">Meshtastic ROUTER mode</dd>
			<dt class="font-semibold text-surface-400">Role</dt><dd class="text-surface-200 m-0">Fixed relay infrastructure</dd>
		</dl>
	</div>

	<div class="p-6 border border-surface-700 rounded-lg bg-surface-800">
		<div class="flex items-center gap-3 mb-1">
			<h2 class="text-xl font-bold text-surface-50 m-0">T-Deck Plus</h2>
			<StatusBadge status="working" />
		</div>
		<span class="inline-block px-2 py-0.5 rounded text-xs font-medium bg-primary-500/20 text-primary-400 mb-3">Mobile Client</span>
		<p class="text-surface-300 mb-4">Full-featured portable client with 2.8" IPS LCD, QWERTY keyboard, GPS, and 2000 mAh battery. Best firmware support, M5Stack dual-boot capable.</p>
		<dl class="grid grid-cols-[auto_1fr] gap-x-4 gap-y-1 text-sm">
			<dt class="font-semibold text-surface-400">Price</dt><dd class="text-surface-200 m-0">$77-82</dd>
			<dt class="font-semibold text-surface-400">TX Power</dt><dd class="text-surface-200 m-0">22 dBm</dd>
			<dt class="font-semibold text-surface-400">Firmware</dt><dd class="text-surface-200 m-0">Meshtastic CLIENT mode</dd>
			<dt class="font-semibold text-surface-400">Role</dt><dd class="text-surface-200 m-0">Community member portable device</dd>
		</dl>
	</div>

	<div class="p-6 border border-surface-700 rounded-lg bg-surface-800">
		<div class="flex items-center gap-3 mb-1">
			<h2 class="text-xl font-bold text-surface-50 m-0">T-Deck Pro (E-Ink)</h2>
			<StatusBadge status="working" />
		</div>
		<span class="inline-block px-2 py-0.5 rounded text-xs font-medium bg-primary-500/20 text-primary-400 mb-3">Low-Power Client</span>
		<p class="text-surface-300 mb-4">3.1" e-paper touchscreen, sunlight-readable, excellent battery life. Available in Audio and 4G LTE variants.</p>
		<dl class="grid grid-cols-[auto_1fr] gap-x-4 gap-y-1 text-sm">
			<dt class="font-semibold text-surface-400">Price</dt><dd class="text-surface-200 m-0">$92-111</dd>
			<dt class="font-semibold text-surface-400">TX Power</dt><dd class="text-surface-200 m-0">22 dBm</dd>
			<dt class="font-semibold text-surface-400">Firmware</dt><dd class="text-surface-200 m-0">Meshtastic BaseUI</dd>
			<dt class="font-semibold text-surface-400">Role</dt><dd class="text-surface-200 m-0">Battery-optimized portable</dd>
		</dl>
	</div>

	<div class="p-6 border border-surface-700 rounded-lg bg-surface-800">
		<div class="flex items-center gap-3 mb-1">
			<h2 class="text-xl font-bold text-surface-50 m-0">MeshAdv-Mini</h2>
			<StatusBadge status="experimental" />
		</div>
		<span class="inline-block px-2 py-0.5 rounded text-xs font-medium bg-primary-500/20 text-primary-400 mb-3">Pi HAT Gateway</span>
		<p class="text-surface-300 mb-4">Custom PCB Raspberry Pi HAT with SX1262 LoRa, GPS, and I2C. Runs meshtasticd (Linux-native Meshtastic) for bridge/gateway duty.</p>
		<dl class="grid grid-cols-[auto_1fr] gap-x-4 gap-y-1 text-sm">
			<dt class="font-semibold text-surface-400">Price</dt><dd class="text-surface-200 m-0">~$40 + Pi</dd>
			<dt class="font-semibold text-surface-400">TX Power</dt><dd class="text-surface-200 m-0">22 dBm</dd>
			<dt class="font-semibold text-surface-400">Firmware</dt><dd class="text-surface-200 m-0">meshtasticd (Linux)</dd>
			<dt class="font-semibold text-surface-400">Role</dt><dd class="text-surface-200 m-0">SMS/Email bridge gateway</dd>
		</dl>
	</div>

	<div class="p-6 border border-surface-700 rounded-lg bg-surface-800">
		<div class="flex items-center gap-3 mb-1">
			<h2 class="text-xl font-bold text-surface-50 m-0">HackRF H4M PortaPack</h2>
			<StatusBadge status="working" />
		</div>
		<span class="inline-block px-2 py-0.5 rounded text-xs font-medium bg-primary-500/20 text-primary-400 mb-3">Education Tool</span>
		<p class="text-surface-300 mb-4">Software-defined radio for LoRa spectrum analysis, protocol education, TEMPEST demonstrations, and RF engineering coursework. NOT a mesh participant.</p>
		<dl class="grid grid-cols-[auto_1fr] gap-x-4 gap-y-1 text-sm">
			<dt class="font-semibold text-surface-400">Price</dt><dd class="text-surface-200 m-0">$200-350</dd>
			<dt class="font-semibold text-surface-400">Firmware</dt><dd class="text-surface-200 m-0">Mayhem</dd>
			<dt class="font-semibold text-surface-400">Role</dt><dd class="text-surface-200 m-0">RF analysis and education only</dd>
		</dl>
	</div>
</div>
