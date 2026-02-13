<script>
	/** @type {{ status: 'working' | 'planned' | 'experimental' }} */
	let { status } = $props();

	/** @type {Record<string, string>} */
	const styles = {
		working: 'bg-green-500/20 text-green-400',
		planned: 'bg-yellow-500/20 text-yellow-400',
		experimental: 'bg-orange-500/20 text-orange-400'
	};

	/** @type {Record<string, string>} */
	const labels = {
		working: 'Working',
		planned: 'Planned',
		experimental: 'Experimental'
	};
</script>

<span class="px-2 py-0.5 rounded text-xs font-medium {styles[status]}">
	{labels[status]}
</span>
