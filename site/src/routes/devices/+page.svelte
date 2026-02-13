<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Devices - LA-Mesh</title>
</svelte:head>

<h1 class="text-3xl font-bold text-surface-50 mb-8">Supported Devices</h1>

<div class="grid gap-8 mt-8">
	<div class="p-6 border border-surface-700 rounded-lg bg-surface-800">
		<h2 class="text-xl font-bold text-surface-50 m-0 mb-1">Station G2</h2>
		<span class="inline-block px-2 py-0.5 rounded text-xs font-medium bg-primary-500/20 text-primary-400 mb-3">Base Station / Relay</span>
		<p class="text-surface-300 mb-4">ESP32-S3 + SX1262 with dedicated PA and LNA. Up to 4.46W output. Designed for rooftop / tower mounting.</p>
		<dl class="grid grid-cols-[auto_1fr] gap-x-4 gap-y-1 text-sm">
			<dt class="font-semibold text-surface-400">Price</dt><dd class="text-surface-200 m-0">~$109</dd>
			<dt class="font-semibold text-surface-400">TX Power</dt><dd class="text-surface-200 m-0">Up to 36.5 dBm</dd>
			<dt class="font-semibold text-surface-400">Firmware</dt><dd class="text-surface-200 m-0">Meshtastic ROUTER</dd>
			<dt class="font-semibold text-surface-400">Role</dt><dd class="text-surface-200 m-0">Fixed relay</dd>
		</dl>
	</div>

	<div class="p-6 border border-surface-700 rounded-lg bg-surface-800">
		<h2 class="text-xl font-bold text-surface-50 m-0 mb-1">T-Deck Plus</h2>
		<span class="inline-block px-2 py-0.5 rounded text-xs font-medium bg-primary-500/20 text-primary-400 mb-3">Mobile Client</span>
		<p class="text-surface-300 mb-4">2.8" IPS LCD, QWERTY keyboard, GPS, 2000 mAh battery. Dual-boot capable (M5Stack).</p>
		<dl class="grid grid-cols-[auto_1fr] gap-x-4 gap-y-1 text-sm">
			<dt class="font-semibold text-surface-400">Price</dt><dd class="text-surface-200 m-0">$77-82</dd>
			<dt class="font-semibold text-surface-400">TX Power</dt><dd class="text-surface-200 m-0">22 dBm</dd>
			<dt class="font-semibold text-surface-400">Firmware</dt><dd class="text-surface-200 m-0">Meshtastic CLIENT</dd>
			<dt class="font-semibold text-surface-400">Role</dt><dd class="text-surface-200 m-0">Portable handheld</dd>
		</dl>
	</div>

	<div class="p-6 border border-surface-700 rounded-lg bg-surface-800">
		<h2 class="text-xl font-bold text-surface-50 m-0 mb-1">T-Deck Pro (E-Ink)</h2>
		<span class="inline-block px-2 py-0.5 rounded text-xs font-medium bg-primary-500/20 text-primary-400 mb-3">Low-Power Client</span>
		<p class="text-surface-300 mb-4">3.1" e-paper touchscreen, sunlight-readable. Available in Audio and 4G LTE variants. Also the target for a sidecar QoL app project: TOTP push brokering for Duo, mp3 playback, and Rx-only mode — part of Jess's ongoing work toward daily smartphone independence.</p>
		<dl class="grid grid-cols-[auto_1fr] gap-x-4 gap-y-1 text-sm">
			<dt class="font-semibold text-surface-400">Price</dt><dd class="text-surface-200 m-0">$92-111</dd>
			<dt class="font-semibold text-surface-400">TX Power</dt><dd class="text-surface-200 m-0">22 dBm</dd>
			<dt class="font-semibold text-surface-400">Firmware</dt><dd class="text-surface-200 m-0">Meshtastic BaseUI</dd>
			<dt class="font-semibold text-surface-400">Role</dt><dd class="text-surface-200 m-0">Portable handheld + sidecar app dev</dd>
		</dl>
	</div>

	<div class="p-6 border border-surface-700 rounded-lg bg-surface-800">
		<h2 class="text-xl font-bold text-surface-50 m-0 mb-1">FireElmo-SDR</h2>
		<span class="inline-block px-2 py-0.5 rounded text-xs font-medium bg-primary-500/20 text-primary-400 mb-3">Custom PCB + Software</span>
		<p class="text-surface-300 mb-4">Custom PCB and software project — Raspberry Pi HAT with SX1262 LoRa, GPS, and I2C. Runs meshtasticd (Linux-native Meshtastic) for bridge/gateway duties. Another of Jess's projects toward smartphone independence.</p>
		<dl class="grid grid-cols-[auto_1fr] gap-x-4 gap-y-1 text-sm">
			<dt class="font-semibold text-surface-400">Price</dt><dd class="text-surface-200 m-0">~$40 + Pi</dd>
			<dt class="font-semibold text-surface-400">TX Power</dt><dd class="text-surface-200 m-0">22 dBm</dd>
			<dt class="font-semibold text-surface-400">Firmware</dt><dd class="text-surface-200 m-0">meshtasticd (Linux)</dd>
			<dt class="font-semibold text-surface-400">Role</dt><dd class="text-surface-200 m-0">SMS/Email bridge gateway</dd>
		</dl>
	</div>

	<div class="p-6 border border-surface-700 rounded-lg bg-surface-800">
		<h2 class="text-xl font-bold text-surface-50 m-0 mb-1">HackRF H4M PortaPack</h2>
		<span class="inline-block px-2 py-0.5 rounded text-xs font-medium bg-primary-500/20 text-primary-400 mb-3">Education Tool</span>
		<p class="text-surface-300 mb-4">Software-defined radio for LoRa spectrum analysis, protocol education, and TEMPEST demos. Not a mesh participant.</p>
		<dl class="grid grid-cols-[auto_1fr] gap-x-4 gap-y-1 text-sm">
			<dt class="font-semibold text-surface-400">Price</dt><dd class="text-surface-200 m-0">$200-350</dd>
			<dt class="font-semibold text-surface-400">Firmware</dt><dd class="text-surface-200 m-0">Mayhem</dd>
			<dt class="font-semibold text-surface-400">Role</dt><dd class="text-surface-200 m-0">RF analysis and education only</dd>
		</dl>
	</div>
</div>
