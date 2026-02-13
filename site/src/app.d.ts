// See https://svelte.dev/docs/kit/types#app.d.ts
// for information about these interfaces
declare global {
	namespace App {
		// interface Error {}
		// interface Locals {}
		// interface PageData {}
		// interface PageState {}
		// interface Platform {}
	}

	// Injected by vite.config.ts from firmware/manifest.json
	declare const __FW_VERSION__: string;
	declare const __FW_VERSION_FULL__: string;
	declare const __FW_MIN_VERSION__: string;
	declare const __FW_BUILD_SOURCE__: string;
	declare const __FW_LAST_UPDATED__: string;
	declare const __FW_SHA256_G2__: string;
	declare const __FW_TARGET_G2__: string;
}

export {};
