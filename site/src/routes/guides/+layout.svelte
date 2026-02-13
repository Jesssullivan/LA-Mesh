<script>
	import Giscus from '$lib/components/Giscus.svelte';
	import { page } from '$app/stores';

	// Only show Giscus on individual guide pages, not the index
	$: isGuidePage = $page.url.pathname !== '/guides' && $page.url.pathname !== '/guides/';
</script>

<slot />

{#if isGuidePage}
	<Giscus />
{/if}
