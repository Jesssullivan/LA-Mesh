<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Devices - LA-Mesh</title>
</svelte:head>

<h1>Supported Devices</h1>

<div class="devices">
	<div class="device">
		<h2>Station G2</h2>
		<span class="role">Base Station / Relay</span>
		<p>High-power (up to 4.46W) base station for rooftop and tower deployment. ESP32-S3 + SX1262 with dedicated PA and ultra-low noise LNA.</p>
		<dl>
			<dt>Price</dt><dd>~$109</dd>
			<dt>TX Power</dt><dd>Up to 36.5 dBm</dd>
			<dt>Firmware</dt><dd>Meshtastic ROUTER mode</dd>
			<dt>Role</dt><dd>Fixed relay infrastructure</dd>
		</dl>
	</div>

	<div class="device">
		<h2>T-Deck Plus</h2>
		<span class="role">Mobile Client</span>
		<p>Full-featured portable client with 2.8" IPS LCD, QWERTY keyboard, GPS, and 2000 mAh battery. Best firmware support, M5Stack dual-boot capable.</p>
		<dl>
			<dt>Price</dt><dd>$77-82</dd>
			<dt>TX Power</dt><dd>22 dBm</dd>
			<dt>Firmware</dt><dd>Meshtastic CLIENT mode</dd>
			<dt>Role</dt><dd>Community member portable device</dd>
		</dl>
	</div>

	<div class="device">
		<h2>T-Deck Pro (E-Ink)</h2>
		<span class="role">Low-Power Client</span>
		<p>3.1" e-paper touchscreen, sunlight-readable, excellent battery life. Available in Audio and 4G LTE variants.</p>
		<dl>
			<dt>Price</dt><dd>$92-111</dd>
			<dt>TX Power</dt><dd>22 dBm</dd>
			<dt>Firmware</dt><dd>Meshtastic BaseUI</dd>
			<dt>Role</dt><dd>Battery-optimized portable</dd>
		</dl>
	</div>

	<div class="device">
		<h2>MeshAdv-Mini</h2>
		<span class="role">Pi HAT Gateway</span>
		<p>Custom PCB Raspberry Pi HAT with SX1262 LoRa, GPS, and I2C. Runs meshtasticd (Linux-native Meshtastic) for bridge/gateway duty.</p>
		<dl>
			<dt>Price</dt><dd>~$40 + Pi</dd>
			<dt>TX Power</dt><dd>22 dBm</dd>
			<dt>Firmware</dt><dd>meshtasticd (Linux)</dd>
			<dt>Role</dt><dd>SMS/Email bridge gateway</dd>
		</dl>
	</div>

	<div class="device">
		<h2>HackRF H4M PortaPack</h2>
		<span class="role">Education Tool</span>
		<p>Software-defined radio for LoRa spectrum analysis, protocol education, TEMPEST demonstrations, and RF engineering coursework. NOT a mesh participant.</p>
		<dl>
			<dt>Price</dt><dd>$200-350</dd>
			<dt>Firmware</dt><dd>Mayhem</dd>
			<dt>Role</dt><dd>RF analysis and education only</dd>
		</dl>
	</div>
</div>

<style>
	.devices {
		display: grid;
		gap: 2rem;
		margin-top: 2rem;
	}

	.device {
		padding: 1.5rem;
		border: 1px solid #ddd;
		border-radius: 8px;
		background: white;
	}

	.device h2 {
		margin: 0 0 0.25rem;
	}

	.role {
		display: inline-block;
		background: #00d4aa;
		color: white;
		padding: 0.15rem 0.5rem;
		border-radius: 4px;
		font-size: 0.8rem;
		margin-bottom: 0.75rem;
	}

	dl {
		display: grid;
		grid-template-columns: auto 1fr;
		gap: 0.25rem 1rem;
		margin: 1rem 0 0;
		font-size: 0.9rem;
	}

	dt {
		font-weight: 600;
		color: #555;
	}

	dd {
		margin: 0;
	}
</style>
