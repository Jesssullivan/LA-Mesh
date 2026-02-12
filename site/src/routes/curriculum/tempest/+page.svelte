<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>TEMPEST and Emanation Security - LA-Mesh Curriculum</title>
</svelte:head>

<nav class="breadcrumb">
	<a href="{base}/curriculum">Curriculum</a> / TEMPEST and Emanation Security
</nav>

<h1>TEMPEST and Emanation Security</h1>
<div class="meta">
	<span>3-hour lab</span>
	<span>HackRF H4M provided</span>
	<span>Free -- fortnightly at Bates College</span>
</div>

<section class="warning">
	<strong>Safety and Legal Rules</strong>
	<p>All TEMPEST exercises use <strong>your own equipment only</strong>. Capturing emanations from equipment you do not own may violate federal law.</p>
	<table>
		<thead><tr><th>Regulation</th><th>Scope</th><th>Key Point</th></tr></thead>
		<tbody>
			<tr><td>47 CFR 15.9</td><td>FCC Part 15</td><td>Receive-only devices are generally permitted</td></tr>
			<tr><td>18 U.S.C. 2511 (ECPA)</td><td>Wiretap Act</td><td>Intentional interception of others' communications is prohibited</td></tr>
			<tr><td>FCC Part 15</td><td>Unintentional radiators</td><td>Devices must accept interference, including from emanations</td></tr>
		</tbody>
	</table>
	<p>When in doubt: <strong>own equipment only, own premises only</strong>.</p>
</section>

<section>
	<h2>Learning Objectives</h2>
	<ol>
		<li>Explain what electromagnetic emanations are and how they leak information</li>
		<li>Use PortaPack Looking Glass for wideband spectrum survey</li>
		<li>Reconstruct a VGA display signal using TempestSDR and HackRF</li>
		<li>Understand HDMI emanation capture and CNN-enhanced recovery</li>
		<li>Identify keyboard emanation signatures</li>
		<li>Apply countermeasures and assess mesh network implications</li>
	</ol>
</section>

<section>
	<h2>Part 1: Emanation Theory (25 min)</h2>
	<p>Every electronic device radiates electromagnetic energy as a side effect of normal operation. Displays, cables, and keyboards all produce unintentional emissions that can be captured and reconstructed at a distance.</p>
	<p><strong>Van Eck phreaking</strong> (1985): Wim van Eck demonstrated that CRT display contents could be reconstructed from electromagnetic emanations at a distance, using inexpensive equipment.</p>
	<table>
		<thead><tr><th>Year</th><th>Development</th><th>Significance</th></tr></thead>
		<tbody>
			<tr><td>1985</td><td>Van Eck, "Electromagnetic Radiation from Video Display Units"</td><td>First public demonstration of display emanation capture</td></tr>
			<tr><td>2004</td><td>Kuhn, "Electromagnetic Eavesdropping Risks of Flat-Panel Displays"</td><td>Extended to LCD/flat-panel displays</td></tr>
			<tr><td>2009</td><td>Vuagnoux and Pasini, "Compromising Electromagnetic Emanations of Wired and Wireless Keyboards"</td><td>Keyboard emanations at 20 meters</td></tr>
			<tr><td>2020</td><td>gr-tempest (GNU Radio OOT module)</td><td>Open-source SDR-based TEMPEST receiver</td></tr>
			<tr><td>2024</td><td>Correa-Londono et al., "Deep-TEMPEST" (LADC 2024)</td><td>CNN-enhanced HDMI emanation recovery</td></tr>
		</tbody>
	</table>
	<p><strong>How video emanations work</strong>: Display cables carry high-frequency signals (pixel clocks of 25-600 MHz). These signals radiate from unshielded or poorly shielded cables and can be received with a wideband SDR, then demodulated by synchronizing to the pixel clock, horizontal sync, and vertical sync.</p>
</section>

<section>
	<h2>Lab 1: Spectrum Survey (30 min)</h2>
	<p>Use the PortaPack H4M in <strong>Looking Glass</strong> mode for a wideband spectrum survey to identify emanation peaks from lab equipment.</p>
	<ol>
		<li>Power on the HackRF H4M with PortaPack (Mayhem firmware from SD card)</li>
		<li>Navigate to <strong>Looking Glass</strong> (wideband spectrum view)</li>
		<li>Set range: 50 MHz - 500 MHz (covers VGA pixel clocks)</li>
		<li>Turn on a VGA monitor connected to a test laptop</li>
		<li>Identify the emanation peak -- note center frequency and bandwidth</li>
		<li>Change the display content (white screen vs. text) and observe signal changes</li>
	</ol>
	<p><strong>Expected result</strong>: Visible peaks near the monitor's pixel clock frequency (typically 25-165 MHz for VGA).</p>
</section>

<section>
	<h2>Lab 2: VGA Reconstruction (35 min)</h2>
	<p>Reconstruct a VGA display signal using TempestSDR with HackRF tethered to a laptop.</p>
	<ol>
		<li>Connect HackRF H4M to laptop via USB (tethered mode, not standalone)</li>
		<li>Start TempestSDR:
			<pre class="code">{`# Clone and build TempestSDR
git clone https://github.com/martinmarinov/TempestSDR.git
cd TempestSDR/JavaGUI
make

# Launch with HackRF backend
java -jar JTempestSDR.jar`}</pre>
		</li>
		<li>Set the target resolution (e.g., 1024x768 @ 60 Hz for VGA)</li>
		<li>Tune to the emanation frequency identified in Lab 1</li>
		<li>Adjust frame rate and resolution until the image locks</li>
		<li>Move the HackRF antenna to find optimal reception angle and distance</li>
	</ol>
	<p><strong>Expected result</strong>: Recognizable (noisy) image of the target VGA display at 1-3 meters.</p>
</section>

<section>
	<h2>Lab 3: HDMI and deep-tempest (35 min)</h2>
	<table>
		<thead><tr><th>Interface</th><th>Pixel Clock</th><th>Shielding</th><th>Emanation Difficulty</th></tr></thead>
		<tbody>
			<tr><td>VGA (analog)</td><td>25-165 MHz</td><td>Minimal</td><td>Easiest</td></tr>
			<tr><td>DVI (digital)</td><td>25-165 MHz (single-link)</td><td>Moderate</td><td>Medium</td></tr>
			<tr><td>HDMI (digital)</td><td>25-600 MHz (TMDS)</td><td>Good</td><td>Harder, but possible</td></tr>
			<tr><td>DisplayPort</td><td>162-810 MHz</td><td>Good</td><td>Hardest</td></tr>
		</tbody>
	</table>
	<p><strong>deep-tempest</strong> (Correa-Londono et al., LADC 2024) uses a convolutional neural network to enhance noisy HDMI emanation captures. The CNN is trained on pairs of (noisy capture, clean original) to denoise and sharpen the reconstructed image.</p>
	<pre class="code">{`# deep-tempest setup (requires Python 3.10+, CUDA recommended)
git clone https://github.com/emidan19/deep-tempest.git
cd deep-tempest
pip install -r requirements.txt

# gr-tempest for raw capture
# Build the GNU Radio OOT module for TEMPEST reception
git clone https://github.com/nash-pillai/gr-tempest.git
cd gr-tempest && mkdir build && cd build
cmake .. && make && sudo make install`}</pre>
	<p><strong>Workflow</strong>: Capture raw IQ with gr-tempest, feed into deep-tempest CNN for enhanced reconstruction.</p>
</section>

<section>
	<h2>Keyboard Emanations (20 min)</h2>
	<p>Vuagnoux and Pasini (2009) demonstrated that wired and wireless keyboards emit detectable electromagnetic signatures for individual keystrokes, recoverable at distances up to 20 meters.</p>
	<table>
		<thead><tr><th>Keyboard Type</th><th>Emanation Range</th><th>Recovery Method</th></tr></thead>
		<tbody>
			<tr><td>PS/2 wired</td><td>Up to 20 m</td><td>Clock/data line emanation capture</td></tr>
			<tr><td>USB wired</td><td>Up to 5 m</td><td>Differential signaling reduces range</td></tr>
			<tr><td>Wireless (2.4 GHz)</td><td>Up to 30 m</td><td>Direct RF interception (KeySweeper-style)</td></tr>
			<tr><td>Bluetooth LE</td><td>Up to 10 m</td><td>BLE sniffing (paired, encrypted)</td></tr>
		</tbody>
	</table>
	<p><strong>Key insight</strong>: Even encrypted wireless keyboards leak timing metadata. Emanations are a physical-layer attack that bypasses encryption entirely.</p>
</section>

<section>
	<h2>Countermeasures (20 min)</h2>
	<table>
		<thead><tr><th>Countermeasure</th><th>Effectiveness</th><th>Cost</th></tr></thead>
		<tbody>
			<tr><td>Ferrite cores on cables</td><td>Low -- reduces some high-frequency emissions</td><td>$2-5</td></tr>
			<tr><td>Shielded cables (STP)</td><td>Moderate -- reduces cable emanations</td><td>$10-30</td></tr>
			<tr><td>Display filters / privacy screens</td><td>Low -- optical only, no RF effect</td><td>$20-50</td></tr>
			<tr><td>Distance (inverse square law)</td><td>Moderate -- signal drops 6 dB per doubling</td><td>Free</td></tr>
			<tr><td>RF noise generators</td><td>Moderate -- raises noise floor</td><td>$50-200</td></tr>
			<tr><td>TEMPEST-rated equipment (NSTISSAM/1-92)</td><td>High -- military-grade shielding</td><td>$5,000+</td></tr>
			<tr><td>Faraday cage / shielded room</td><td>Very high -- blocks all RF</td><td>$500-10,000+</td></tr>
		</tbody>
	</table>
	<p>For most community mesh operators, <strong>distance and awareness</strong> are the practical countermeasures. Full TEMPEST protection is primarily relevant for high-security environments.</p>
</section>

<section>
	<h2>Mesh Implications (15 min)</h2>
	<p>TEMPEST attacks are relevant to mesh operators because:</p>
	<ul>
		<li><strong>Encryption does not protect screen content</strong> -- AES-256 encrypts radio traffic, but what you display on screen radiates in the clear</li>
		<li><strong>Air-gapped workflows are not immune</strong> -- a TAILS session on a laptop still emits video emanations</li>
		<li><strong>Operational security must include physical-layer awareness</strong> -- where you read sensitive messages matters</li>
	</ul>
	<p>Cross-references:</p>
	<ul>
		<li><a href="{base}/curriculum/security">Mesh Network Security</a> -- encryption layers, threat modeling</li>
		<li><a href="{base}/curriculum/tails">TAILS and Secure Communications</a> -- 5-layer OpSec model</li>
		<li><a href="{base}/guides/stealth-mode">Stealth Mode Guide</a> -- reducing device RF signature</li>
	</ul>
</section>

<section>
	<h2>Equipment</h2>
	<table>
		<thead><tr><th>Item</th><th>Purpose</th><th>Provided</th></tr></thead>
		<tbody>
			<tr><td>HackRF H4M + PortaPack</td><td>Standalone spectrum survey (Looking Glass) and tethered SDR capture</td><td>Yes</td></tr>
			<tr><td>Laptop with USB port</td><td>TempestSDR host, gr-tempest, deep-tempest</td><td>Bring your own</td></tr>
			<tr><td>VGA monitor + cable</td><td>Target for emanation reconstruction</td><td>Yes</td></tr>
			<tr><td>HDMI monitor + cable</td><td>Target for HDMI emanation lab</td><td>Yes</td></tr>
			<tr><td>Directional antenna (optional)</td><td>Improved reception at distance</td><td>Available</td></tr>
		</tbody>
	</table>
</section>

<section>
	<h2>Software</h2>
	<table>
		<thead><tr><th>Tool</th><th>Source</th><th>Purpose</th></tr></thead>
		<tbody>
			<tr><td>TempestSDR</td><td><a href="https://github.com/martinmarinov/TempestSDR">GitHub</a></td><td>Real-time video emanation reconstruction (Java)</td></tr>
			<tr><td>gr-tempest</td><td><a href="https://github.com/nash-pillai/gr-tempest">GitHub</a></td><td>GNU Radio OOT module for TEMPEST reception</td></tr>
			<tr><td>deep-tempest</td><td><a href="https://github.com/emidan19/deep-tempest">GitHub</a></td><td>CNN-enhanced HDMI emanation recovery</td></tr>
			<tr><td>Mayhem firmware</td><td><a href="https://github.com/portapack-mayhem/mayhem-firmware">GitHub</a></td><td>PortaPack firmware with Looking Glass, spectrum analysis</td></tr>
		</tbody>
	</table>
</section>

<section>
	<h2>References</h2>
	<ul>
		<li>Van Eck, W. (1985). "Electromagnetic Radiation from Video Display Units: An Eavesdropping Risk?" <em>Computers & Security</em>, 4(4), 269-286.</li>
		<li>Kuhn, M.G. (2004). "Electromagnetic Eavesdropping Risks of Flat-Panel Displays." <em>4th Workshop on Privacy Enhancing Technologies</em>.</li>
		<li>Vuagnoux, M. and Pasini, S. (2009). "Compromising Electromagnetic Emanations of Wired and Wireless Keyboards." <em>USENIX Security Symposium</em>.</li>
		<li>Correa-Londono, S. et al. (2024). "Deep-TEMPEST: Using Deep Learning to Eavesdrop on HDMI from its Unintentional Electromagnetic Emanations." <em>LADC 2024</em>.</li>
	</ul>
</section>

<style>
	.breadcrumb { font-size: 0.85rem; color: #888; margin-bottom: 1rem; }
	.breadcrumb a { color: #00d4aa; text-decoration: none; }
	.meta { display: flex; gap: 1rem; flex-wrap: wrap; font-size: 0.85rem; color: #888; margin-bottom: 2rem; }
	.meta span { background: #f5f5f5; padding: 0.2rem 0.5rem; border-radius: 3px; }
	section { margin-bottom: 3rem; }
	.warning { background: #fff3cd; border: 1px solid #ffc107; border-radius: 8px; padding: 1.25rem; }
	.warning strong { color: #856404; }
	.warning p { margin: 0.5rem 0 0; color: #856404; }
	.warning table { margin-top: 0.75rem; }
	.code { background: #1a1a2e; color: #00d4aa; padding: 1.25rem; border-radius: 8px; overflow-x: auto; font-size: 0.85rem; line-height: 1.5; }
	table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
	th, td { padding: 0.75rem; border: 1px solid #ddd; text-align: left; }
	th { background: #f5f5f5; font-weight: 600; }
	a { color: #00d4aa; }
</style>
