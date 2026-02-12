<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>SDR and RF Engineering - LA-Mesh Curriculum</title>
</svelte:head>

<nav class="breadcrumb">
	<a href="{base}/curriculum">Curriculum</a> / SDR and RF Engineering
</nav>

<h1>Level 4: Software-Defined Radio and LoRa Analysis</h1>
<div class="meta">
	<span>6 hours (two 3-hour sessions)</span>
	<span>Requires Level 3</span>
	<span>HackRF H4M provided</span>
	<span>Free -- fortnightly at Bates College</span>
</div>

<section>
	<h2>Learning Objectives</h2>
	<ol>
		<li>Explain what SDR is and how it differs from traditional radio</li>
		<li>Use an SDR to observe the 915 MHz ISM band</li>
		<li>Identify LoRa transmissions on a waterfall display</li>
		<li>Understand FCC Part 15 rules for 915 MHz</li>
		<li>Set up GNU Radio with gr-lora_sdr for LoRa analysis</li>
		<li>Understand TEMPEST and emanation security concepts</li>
		<li>Build a LoRa protocol analysis flowgraph</li>
	</ol>
</section>

<section>
	<h2>Session 1: SDR Fundamentals (3 hours)</h2>
	<h3>Part 1: SDR Fundamentals (30 min)</h3>
	<p>Sampling, Nyquist theorem, quadrature (I/Q), dynamic range. Traditional radio uses fixed hardware filters; SDR does filtering in software.</p>

	<h3>Part 2: FCC Part 15.247 (20 min)</h3>
	<table>
		<thead><tr><th>Parameter</th><th>Limit</th></tr></thead>
		<tbody>
			<tr><td>Max conducted power</td><td>30 dBm (1W)</td></tr>
			<tr><td>Max EIRP (with antenna)</td><td>36 dBm (4W)</td></tr>
			<tr><td>Frequency</td><td>902-928 MHz ISM</td></tr>
			<tr><td>Modulation</td><td>Spread spectrum required</td></tr>
		</tbody>
	</table>

	<h3>Part 3: Live Spectrum Observation (45 min)</h3>
	<p>RTL-SDR waterfall of 915 MHz band. Identify LoRa chirps, WiFi, and other ISM traffic.</p>

	<h3>Part 4: LoRa Signal Anatomy (30 min)</h3>
	<p>Chirp structure, preamble, spreading factors (SF7-SF12), bandwidth, coding rate, time-on-air calculations.</p>

	<h3>Part 5: GNU Radio + gr-lora_sdr (45 min)</h3>
	<p>Build a receive flowgraph: RTL-SDR Source -> Channel Filter -> gr-lora Demodulator -> Message Debug.</p>

	<h3>Part 6: RF Troubleshooting (30 min)</h3>
	<p>Link budget: TX power + TX antenna gain - path loss + RX antenna gain = received power. Compare against receiver sensitivity.</p>
</section>

<section>
	<h2>Session 2: Advanced Topics (3 hours)</h2>
	<h3>Part 7: TEMPEST and Emanation Security (45 min)</h3>
	<p><strong>TEMPEST</strong>: electromagnetic emanations from displays and cables leak data. Originally an NSA program (declassified).</p>
	<table>
		<thead><tr><th>Tool</th><th>Purpose</th></tr></thead>
		<tbody>
			<tr><td>TempestSDR (Java)</td><td>HDMI emanation capture with HackRF</td></tr>
			<tr><td>gr-tempest (GNURadio OOT)</td><td>GNURadio-based TEMPEST receiver</td></tr>
			<tr><td>deep-tempest</td><td>CNN-enhanced HDMI recovery (Correa-Londono et al., LADC 2024)</td></tr>
		</tbody>
	</table>
	<p><strong>Countermeasures</strong>: shielded cables, display filters, TEMPEST-rated equipment, physical distance.</p>
	<p><strong>Legal</strong>: receiving emanations is receive-only (legal), but ECPA considerations apply.</p>

	<h3>Part 8: LoRa Protocol Analysis with GNURadio (45 min)</h3>
	<table>
		<thead><tr><th>Tool</th><th>Source</th><th>Notes</th></tr></thead>
		<tbody>
			<tr><td>gr-lora_sdr v0.5.8</td><td>EPFL (Tapparel)</td><td>Full TX/RX, best documented</td></tr>
			<tr><td>Meshtastic_SDR</td><td>Community</td><td>Receives all US presets simultaneously</td></tr>
		</tbody>
	</table>
	<p><strong>Exercise</strong>: Build a receive flowgraph, capture packets from a known Meshtastic transmission, and observe why encrypted payloads look random (AES-256 working correctly).</p>
</section>

<style>
	.breadcrumb { font-size: 0.85rem; color: #888; margin-bottom: 1rem; }
	.breadcrumb a { color: #00d4aa; text-decoration: none; }
	.meta { display: flex; gap: 1rem; flex-wrap: wrap; font-size: 0.85rem; color: #888; margin-bottom: 2rem; }
	.meta span { background: #f5f5f5; padding: 0.2rem 0.5rem; border-radius: 3px; }
	section { margin-bottom: 3rem; }
	table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
	th, td { padding: 0.75rem; border: 1px solid #ddd; text-align: left; }
	th { background: #f5f5f5; font-weight: 600; }
</style>
