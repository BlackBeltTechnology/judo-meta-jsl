import { defineConfig } from 'vite';
import { readFileSync } from 'node:fs';
import { pathToFileURL, fileURLToPath } from 'node:url';
import { dirname } from 'node:path';

const __dirname = dirname(fileURLToPath(import.meta.url));

export default defineConfig({
  base: './',
  assetsInclude: ['**/*.wasm'],
  build: {
    target: 'esnext',
    rollupOptions: {
      output: {
        manualChunks: {
          'vscode': ['vscode'],
          'monaco-languageclient': ['monaco-languageclient'],
          'monaco-editor-workers': ['monaco-editor-workers'],
          'vscode-oniguruma': ['vscode-oniguruma'],
          'jszip': ['jszip'],
        },
      },
    },
  },
  optimizeDeps: {
    esbuildOptions: {
      plugins: [{
        name: 'import.meta.url',
        setup ({ onLoad }) {
          // Help vite that bundles/move files in dev mode without touching `import.meta.url` which breaks asset urls
          onLoad({ filter: /.*\.js/, namespace: 'file' }, async args => {
            const code = readFileSync(args.path, 'utf8');

            const assetImportMetaUrlRE = /\bnew\s+URL\s*\(\s*('[^']+'|"[^"]+"|`[^`]+`)\s*,\s*import\.meta\.url\s*(?:,\s*)?\)/g;
            let i = 0;
            let newCode = '';
            for (let match = assetImportMetaUrlRE.exec(code); match != null; match = assetImportMetaUrlRE.exec(code)) {
              newCode += code.slice(i, match.index);

              const path = match[1].slice(1, -1);
              const resolved = await import.meta.resolve!(path, pathToFileURL(args.path));

              newCode += `new URL(${JSON.stringify(fileURLToPath(resolved))}, import.meta.url)`;

              i = assetImportMetaUrlRE.lastIndex;
            }
            newCode += code.slice(i);

            return { contents: newCode };
          })
        }
      }]
    }
  },
  define: {
    rootDirectory: JSON.stringify(__dirname),
  },
})
