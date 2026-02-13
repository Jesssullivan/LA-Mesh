<script>
	import { onMount } from 'svelte';

	onMount(() => {
		const script = document.createElement('script');
		script.src = 'https://giscus.app/client.js';
		script.setAttribute('data-repo', 'Jesssullivan/LA-Mesh');
		script.setAttribute('data-repo-id', 'R_kgDOROXdFQ');
		script.setAttribute('data-category', 'General');
		script.setAttribute('data-category-id', 'DIC_kwDOROXdFc4C2VRY');
		script.setAttribute('data-mapping', 'pathname');
		script.setAttribute('data-strict', '0');
		script.setAttribute('data-reactions-enabled', '1');
		script.setAttribute('data-emit-metadata', '0');
		script.setAttribute('data-input-position', 'top');
		script.setAttribute('data-theme', 'noborder_dark');
		script.setAttribute('data-lang', 'en');
		script.setAttribute('crossorigin', 'anonymous');
		script.async = true;

		const container = document.getElementById('giscus-container');
		if (container) container.appendChild(script);
	});
</script>

<section class="mt-12 pt-8 border-t border-surface-700">
	<div id="giscus-container"></div>
</section>
