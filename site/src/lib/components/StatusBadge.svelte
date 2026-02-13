<script>
	/** @type {{ status: 'working' | 'experimental' }} */
	let { status } = $props();

	/** @type {Record<string, string>} */
	const styles = {
		working: 'bg-green-500/20 text-green-400',
		experimental: 'bg-orange-500/20 text-orange-400'
	};

	/** @type {Record<string, string>} */
	const labels = {
		working: 'Working',
		experimental: 'Experimental'
	};
</script>

<span class="px-2 py-0.5 rounded text-xs font-medium {styles[status]}">
	{labels[status]}
</span>
