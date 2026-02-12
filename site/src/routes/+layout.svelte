<script>
	import { base } from '$app/paths';

	let { children } = $props();

	const nav = [
		{ href: `${base}/`, label: 'Home' },
		{ href: `${base}/devices`, label: 'Devices' },
		{ href: `${base}/guides`, label: 'Guides' },
		{ href: `${base}/curriculum`, label: 'Curriculum' },
		{ href: `${base}/architecture`, label: 'Architecture' }
	];
</script>

<div class="app">
	<header>
		<nav>
			<a href="{base}/" class="logo">LA-Mesh</a>
			<ul>
				{#each nav as item}
					<li><a href={item.href}>{item.label}</a></li>
				{/each}
			</ul>
		</nav>
	</header>

	<main>
		{@render children()}
	</main>

	<footer>
		<p>LA-Mesh - Community LoRa mesh network for Southern Maine</p>
		<p><a href="https://github.com/Jesssullivan/LA-Mesh">GitHub</a></p>
	</footer>
</div>

<style>
	:global(body) {
		margin: 0;
		font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
		color: #1a1a1a;
		background: #fafafa;
	}

	.app {
		display: flex;
		flex-direction: column;
		min-height: 100vh;
	}

	header {
		background: #1a1a2e;
		color: white;
		padding: 0 2rem;
	}

	nav {
		display: flex;
		align-items: center;
		max-width: 1200px;
		margin: 0 auto;
		padding: 1rem 0;
		gap: 2rem;
	}

	.logo {
		font-size: 1.5rem;
		font-weight: bold;
		color: #00d4aa;
		text-decoration: none;
	}

	ul {
		display: flex;
		list-style: none;
		margin: 0;
		padding: 0;
		gap: 1.5rem;
	}

	ul a {
		color: #ccc;
		text-decoration: none;
		font-size: 0.9rem;
	}

	ul a:hover {
		color: #00d4aa;
	}

	main {
		flex: 1;
		max-width: 1200px;
		margin: 0 auto;
		padding: 2rem;
		width: 100%;
		box-sizing: border-box;
	}

	footer {
		background: #1a1a2e;
		color: #888;
		text-align: center;
		padding: 2rem;
		font-size: 0.85rem;
	}

	footer a {
		color: #00d4aa;
	}
</style>
