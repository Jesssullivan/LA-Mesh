<script>
	import { base } from '$app/paths';
	import '../app.css';

	let { children } = $props();

	const nav = [
		{ href: `${base}/`, label: 'Home' },
		{ href: `${base}/devices`, label: 'Devices' },
		{ href: `${base}/architecture`, label: 'Architecture' },
		{ href: 'https://meshmap.net/', label: 'Mesh Map', external: true },
		{ href: 'https://flasher.meshtastic.org/', label: 'Flash Firmware', external: true, bold: true }
	];

	/** @type {{ href: string, label: string }[]} */
	const resources = [
		{ href: 'https://sdrradiolab.com/', label: 'SDRRadiolab' },
		{ href: 'https://tails.net/', label: 'TAILS OS' },
		{ href: 'https://tak.gov/', label: 'ATAK' },
		{ href: 'https://keepassxc.org/', label: 'KeePassXC' },
		{ href: 'https://shop.uniteng.com/', label: 'B&Q Consulting' }
	];
</script>

<div class="flex flex-col min-h-screen bg-surface-900 text-surface-50">
	<header class="bg-surface-950 px-8">
		<nav class="flex items-center max-w-[1200px] mx-auto py-4 gap-8">
			<a href="{base}/" class="text-2xl font-bold font-mono text-primary-400 no-underline">LA-Mesh</a>
			<ul class="flex list-none m-0 p-0 gap-6 flex-wrap">
				{#each nav as item}
					<li><a href={item.href} class="no-underline text-sm hover:text-primary-400 transition-colors {item.bold ? 'font-bold text-primary-400' : 'text-surface-400'}" target={item.external ? '_blank' : undefined} rel={item.external ? 'noopener noreferrer' : undefined}>{item.label}</a></li>
				{/each}
				<li class="relative group">
					<span class="text-surface-400 text-sm cursor-pointer hover:text-primary-400 transition-colors">Resources</span>
					<ul class="absolute hidden group-hover:block list-none m-0 p-2 bg-surface-800 border border-surface-700 rounded-lg min-w-[160px] z-10 top-full left-0">
						{#each resources as r}
							<li><a href={r.href} target="_blank" rel="noopener noreferrer" class="block px-3 py-1.5 text-surface-400 no-underline text-sm hover:text-primary-400 transition-colors">{r.label}</a></li>
						{/each}
					</ul>
				</li>
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
