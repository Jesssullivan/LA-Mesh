import adapter from '@sveltejs/adapter-static';
import { mdsvex, escapeSvelte } from 'mdsvex';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';
import { createHighlighter } from 'shiki';
import remarkGfm from 'remark-gfm';
import rehypeSlug from 'rehype-slug';
import rehypeAutolinkHeadings from 'rehype-autolink-headings';
import rehypeExternalLinks from 'rehype-external-links';

const basePath = process.env.DOCS_BASE_PATH || '';

const highlighter = await createHighlighter({
	themes: ['github-dark-default'],
	langs: ['bash', 'json', 'yaml', 'toml', 'javascript', 'typescript', 'svelte', 'css', 'html', 'python', 'shell']
});

/** @type {import('mdsvex').MdsvexOptions} */
const mdsvexOptions = {
	extensions: ['.md', '.svx'],
	remarkPlugins: [remarkGfm],
	rehypePlugins: [
		rehypeSlug,
		[rehypeAutolinkHeadings, { behavior: 'wrap' }],
		[rehypeExternalLinks, { target: '_blank' }]
	],
	highlight: {
		highlighter: (code, lang) => {
			const html = escapeSvelte(
				highlighter.codeToHtml(code, {
					lang: lang || 'text',
					theme: 'github-dark-default'
				})
			);
			return `{@html \`${html}\`}`;
		}
	}
};

/** @type {import('@sveltejs/kit').Config} */
const config = {
	extensions: ['.svelte', '.md', '.svx'],
	preprocess: [vitePreprocess(), mdsvex(mdsvexOptions)],

	kit: {
		adapter: adapter({
			pages: 'build',
			assets: 'build',
			fallback: '404.html',
			precompress: true,
			strict: false
		}),
		paths: {
			base: basePath
		}
	}
};

export default config;
