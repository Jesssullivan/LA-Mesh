<script>
	import Giscus from '$lib/components/Giscus.svelte';
	import { page } from '$app/state';

	let { children } = $props();

	let isGuidePage = $derived(page.url.pathname !== '/guides' && page.url.pathname !== '/guides/');
</script>

{@render children()}

{#if isGuidePage}
	<Giscus />
{/if}
