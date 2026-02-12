<script>
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Architecture - LA-Mesh</title>
</svelte:head>

<h1>Architecture</h1>
<p>Technical decisions and network design for LA-Mesh.</p>

<section>
	<h2>Network Overview</h2>
	<p>LA-Mesh uses a hub-and-spoke topology with high-power Station G2 relay nodes on rooftops and towers providing backbone coverage, and T-Deck portable devices as endpoints.</p>

	<pre class="diagram">{`
    [Bates Tower]          [Downtown Relay]
    Station G2              Station G2
    ROUTER mode             ROUTER mode
        |                       |
        |    915 MHz LoRa       |
        +-------+-------+------+
                |       |
           [Home Base]  [Mobile]
           CLIENT_BASE   CLIENT
           T-Deck Plus   T-Deck Pro

    [MQTT Gateway] --- Internet --- [SMS Bridge]
    MeshAdv-Mini                    Raspberry Pi
  `}</pre>
</section>

<section>
	<h2>Decision Records</h2>
	<div class="adr-list">
		<div class="adr">
			<span class="adr-id">ADR-001</span>
			<h3>Primary Firmware: Meshtastic</h3>
			<p>Meshtastic chosen as primary firmware over MeshCore for ecosystem maturity, MQTT bridge support, and stronger encryption. MeshCore evaluated on single device.</p>
			<span class="adr-status">Proposed</span>
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
			<tr><td>Encryption</td><td>AES-256-CTR + X25519 PKC</td><td>AES-128-ECB (AEAD coming)</td></tr>
			<tr><td>Routing</td><td>Managed flood + next-hop DMs</td><td>Hybrid flood-then-direct</td></tr>
			<tr><td>Max Hops</td><td>7 (configurable)</td><td>64</td></tr>
			<tr><td>MQTT Bridge</td><td>Built-in</td><td>Third-party</td></tr>
			<tr><td>Interop</td><td colspan="2">NOT compatible - separate protocols</td></tr>
		</tbody>
	</table>
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
		font-size: 0.85rem;
		line-height: 1.4;
	}

	.adr-list {
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

	.adr-status {
		display: inline-block;
		background: #f0ad4e;
		color: white;
		padding: 0.1rem 0.4rem;
		border-radius: 3px;
		font-size: 0.75rem;
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
