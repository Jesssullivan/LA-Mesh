<script>
	import { base } from '$app/paths';
	import '../app.css';

	let { children } = $props();

	const nav = [
		{ href: `${base}/`, label: 'Home' },
		{ href: `${base}/devices`, label: 'Devices' },
		{ href: `${base}/guides`, label: 'Guides' },
		{ href: `${base}/architecture`, label: 'Architecture' }
	];
</script>

<div class="flex flex-col min-h-screen bg-surface-900 text-surface-50">
	<header class="bg-surface-950 px-8">
		<nav class="flex items-center max-w-[1200px] mx-auto py-4 gap-8">
			<a href="{base}/" class="text-2xl font-bold font-mono text-primary-400 no-underline">LA-Mesh</a>
			<ul class="flex list-none m-0 p-0 gap-6">
				{#each nav as item}
					<li><a href={item.href} class="text-surface-400 no-underline text-sm hover:text-primary-400 transition-colors">{item.label}</a></li>
				{/each}
			</ul>
		</nav>
	</header>

	<main class="flex-1 max-w-[1200px] mx-auto p-8 w-full box-border">
		{@render children()}
	</main>

	<footer class="bg-surface-950 text-surface-500 text-center p-8 text-sm">
		<p>LA-Mesh - Community LoRa mesh network for Southern Maine</p>
		<p><a href="https://github.com/Jesssullivan/LA-Mesh" class="text-primary-400">GitHub</a></p>
	</footer>
</div>
