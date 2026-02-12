<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Architecture - LA-Mesh</title>
</svelte:head>

<h1>Architecture</h1>
<p>Technical decisions and network design for LA-Mesh.</p>

<section>
	<h2>Network Topology</h2>
	<p>Hub-and-spoke with mesh redundancy. High-power Station G2 routers on elevated sites provide backbone coverage, T-Deck clients form the user-facing mesh, and MeshAdv-Mini Pi HAT handles bridge/gateway duties.</p>

	<pre class="diagram">{`
                         ┌─────────────────────────┐
                         │   INTERNET / MQTT        │
                         └────────────┬────────────┘
                                      │
                         ┌────────────┴────────────┐
                         │   MeshAdv-Mini Gateway   │
                         │   meshtasticd + bridges  │
                         │   ROUTER_CLIENT          │
                         └────────────┬────────────┘
                                      │ LoRa 915 MHz
                    ┌─────────────────┼─────────────────┐
                    │                                     │
           ┌────────┴────────┐               ┌───────────┴────────┐
           │  Station G2 #1  │               │  Station G2 #2     │
           │  ROUTER 30 dBm  │               │  ROUTER 30 dBm     │
           │  Bates Tower    │               │  Downtown Relay    │
           └────────┬────────┘               └───────────┬────────┘
                    │                                     │
        ┌───────────┼───────────┐         ┌──────────────┼──────────┐
        │           │           │         │              │          │
   [T-Deck]    [T-Deck]   [T-Deck]  [T-Deck]       [T-Deck]
    Plus #1     Plus #2    Pro #1    Pro #2          Plus #3
    CLIENT      CLIENT     CLIENT    CLIENT          CLIENT
  `}</pre>

	<div class="specs">
		<div class="spec">
			<h4>Station G2 Link Budget</h4>
			<p>30 dBm TX + 6 dBi antenna = 36 dBm EIRP. Max path loss: 171 dB. Estimated range: 20+ km line-of-sight.</p>
		</div>
		<div class="spec">
			<h4>T-Deck Link Budget</h4>
			<p>22 dBm TX + 2 dBi antenna = 24 dBm EIRP. Max path loss: 160 dB. Estimated range: 5-10 km line-of-sight.</p>
		</div>
		<div class="spec">
			<h4>Hop Limit</h4>
			<p>Set to 5 (optimized for LA-Mesh coverage area). Higher than default 3 to ensure full campus + downtown reach.</p>
		</div>
	</div>
</section>

<section>
	<h2>Channel Architecture</h2>
	<table>
		<thead>
			<tr><th>Index</th><th>Channel</th><th>Purpose</th><th>PSK</th></tr>
		</thead>
		<tbody>
			<tr><td>0</td><td>LA-Mesh</td><td>Primary community channel</td><td>Unique 256-bit (shared in-person)</td></tr>
			<tr><td>1</td><td>LA-Admin</td><td>Operator coordination</td><td>Separate unique 256-bit</td></tr>
			<tr><td>2</td><td>LA-Emergency</td><td>Emergency use only</td><td>Separate unique 256-bit</td></tr>
		</tbody>
	</table>
	<p class="note">PSKs are never transmitted digitally. Shared face-to-face at community meetups and rotated quarterly.</p>
</section>

<section>
	<h2>Decision Records</h2>
	<div class="adr-list">
		<div class="adr">
			<span class="adr-id">ADR-001</span>
			<h3>Primary Firmware: Meshtastic</h3>
			<p>Meshtastic chosen for ecosystem maturity, MQTT bridge support, AES-256-CTR + X25519 PKC encryption. MeshCore evaluated on single device.</p>
			<span class="adr-status accepted">Accepted</span>
		</div>

		<div class="adr">
			<span class="adr-id">ADR-002</span>
			<h3>MeshCore Evaluation Scope</h3>
			<p>Single Station G2 running MeshCore for evaluation against 5 criteria: stability, routing efficiency, room server, companion app UX, AMMB bridge.</p>
			<span class="adr-status accepted">Accepted</span>
		</div>

		<div class="adr">
			<span class="adr-id">ADR-003</span>
			<h3>Hub-and-Spoke with Mesh Redundancy</h3>
			<p>Station G2 routers on elevated sites as backbone. Hop limit 5 for full coverage. Mesh fallback when routers unreachable.</p>
			<span class="adr-status accepted">Accepted</span>
		</div>

		<div class="adr">
			<span class="adr-id">ADR-004</span>
			<h3>3-Channel Encryption Scheme</h3>
			<p>Primary, admin, and emergency channels with unique PSKs. PKC enabled for DMs. Quarterly rotation. CVE-2025-52464 firmware requirement.</p>
			<span class="adr-status accepted">Accepted</span>
		</div>

		<div class="adr">
			<span class="adr-id">ADR-005</span>
			<h3>Self-Hosted MQTT Broker</h3>
			<p>Mosquitto on Raspberry Pi (MeshAdv-Mini gateway). Full control, no external dependency, free, enables local-first bridge architecture.</p>
			<span class="adr-status accepted">Accepted</span>
		</div>
	</div>
</section>

<section>
	<h2>Protocol Comparison</h2>
	<table>
		<thead>
			<tr><th>Aspect</th><th>Meshtastic</th><th>MeshCore</th></tr>
		</thead>
		<tbody>
			<tr><td>Encryption</td><td>AES-256-CTR + X25519 PKC</td><td>AES-128-ECB (ChaChaPoly AEAD coming)</td></tr>
			<tr><td>Routing</td><td>Managed flood + next-hop DMs</td><td>Hybrid flood-then-direct</td></tr>
			<tr><td>Max Hops</td><td>7 (configurable)</td><td>64</td></tr>
			<tr><td>MQTT Bridge</td><td>Built-in (native)</td><td>Third-party only</td></tr>
			<tr><td>PKC (DMs)</td><td>X25519 + AES-256-CCM</td><td>Ed25519 + ECDH + AES-128</td></tr>
			<tr><td>Device Support</td><td>100+ devices, all major vendors</td><td>65+ devices, growing</td></tr>
			<tr><td>Client Repeating</td><td>All roles can repeat</td><td>Clients never repeat (by design)</td></tr>
			<tr><td>Room Server</td><td>No equivalent</td><td>Dedicated always-on relay with history</td></tr>
			<tr><td>CVE-2025-52464</td><td>Fixed in v2.6.11+</td><td>Not affected (different key model)</td></tr>
			<tr><td>Interop</td><td colspan="2">NOT compatible -- separate protocols, AMMB bridge for limited interop</td></tr>
		</tbody>
	</table>
</section>

<section>
	<h2>Bridge Architecture</h2>
	<pre class="diagram">{`
  [Mesh Devices]  ←── LoRa 915 MHz ──→  [MeshAdv-Mini Gateway]
                                               │
                                          meshtasticd
                                               │
                                          Mosquitto MQTT
                                         ┌─────┴─────┐
                                    [SMS Bridge]  [Email Bridge]
                                    Python/Twilio  Python/SMTP
                                         │              │
                                    Twilio API     SMTP + GPG
                                         │              │
                                   Cell Network    Internet
  `}</pre>
</section>

<style>
	section {
		margin-bottom: 3rem;
	}

	.diagram {
		background: #1a1a2e;
		color: #00d4aa;
		padding: 1.5rem;
		border-radius: 8px;
		overflow-x: auto;
		font-size: 0.8rem;
		line-height: 1.4;
	}

	.specs {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
		gap: 1rem;
		margin-top: 1.5rem;
	}

	.spec {
		padding: 1rem;
		background: #f9f9f9;
		border-radius: 6px;
		border-left: 3px solid #00d4aa;
	}

	.spec h4 {
		margin: 0 0 0.5rem;
		color: #1a1a2e;
	}

	.spec p {
		margin: 0;
		font-size: 0.9rem;
		color: #555;
	}

	.note {
		font-size: 0.85rem;
		color: #888;
		font-style: italic;
		margin-top: 0.5rem;
	}

	.adr-list {
		display: grid;
		gap: 1rem;
		margin-top: 1rem;
	}

	.adr {
		padding: 1rem;
		border: 1px solid #ddd;
		border-radius: 8px;
		background: white;
	}

	.adr-id {
		font-family: monospace;
		font-size: 0.85rem;
		color: #888;
	}

	.adr h3 {
		margin: 0.25rem 0 0.5rem;
	}

	.adr p {
		margin: 0 0 0.5rem;
		color: #555;
		font-size: 0.9rem;
	}

	.adr-status {
		display: inline-block;
		padding: 0.1rem 0.4rem;
		border-radius: 3px;
		font-size: 0.75rem;
		color: white;
	}

	.adr-status.accepted {
		background: #00d4aa;
	}

	table {
		width: 100%;
		border-collapse: collapse;
		margin-top: 1rem;
	}

	th, td {
		padding: 0.75rem;
		border: 1px solid #ddd;
		text-align: left;
	}

	th {
		background: #f5f5f5;
		font-weight: 600;
	}
</style>
