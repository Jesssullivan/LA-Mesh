import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import tailwindcss from '@tailwindcss/vite';
import type { Plugin } from 'vite';
// @ts-ignore — manifest import resolved by bundler
import manifest from '../firmware/manifest.json';

const fw = manifest.meshtastic;

// Skeleton-Tailwind v4 compatibility plugin (established pattern from tinyland.dev/MassageIthaca)
function skeletonTailwindV4Compat(): Plugin {
	return {
		name: 'skeleton-tailwind-v4-compat',
		enforce: 'pre',
		transform(code, id) {
			if (id.includes('@skeletonlabs/skeleton') && id.endsWith('.css')) {
				code = code
					.replace(/@variant\s+sm\s*{/g, '@media (min-width: 640px) {')
					.replace(/@variant\s+md\s*{/g, '@media (min-width: 768px) {')
					.replace(/@variant\s+lg\s*{/g, '@media (min-width: 1024px) {')
					.replace(/@variant\s+xl\s*{/g, '@media (min-width: 1280px) {')
					.replace(/@variant\s+2xl\s*{/g, '@media (min-width: 1536px) {')
					.replace(/@variant\s+dark\s*{/g, '.dark & {')
					.replace(/@apply\s+variant-/g, '@apply ');
				return { code, map: null };
			}
		}
	};
}

export default defineConfig({
	plugins: [
		skeletonTailwindV4Compat(),
		tailwindcss(),
		sveltekit()
	],
	define: {
		__FW_VERSION__: JSON.stringify(fw.version),
		__FW_VERSION_FULL__: JSON.stringify(fw.version_full),
		__FW_MIN_VERSION__: JSON.stringify(fw.min_version),
		__FW_BUILD_SOURCE__: JSON.stringify(fw.build.source),
		__FW_LAST_UPDATED__: JSON.stringify(manifest.last_updated),
		__FW_SHA256_G2__: JSON.stringify(fw.devices['station-g2'].sha256),
		__FW_TARGET_G2__: JSON.stringify(fw.devices['station-g2'].pio_env)
	}
});
