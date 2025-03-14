import { defineConfig } from 'vite';
import { resolve } from 'node:path';

export default defineConfig({
  base: '',
  resolve: {
    alias: [
      { find: '~', replacement: resolve(__dirname, 'src') },
    ],
  },
  worker: {
    format: 'es',
  },
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'monaco-languageclient': ['monaco-languageclient'],
          'vscode-ws-jsonrpc': ['vscode-ws-jsonrpc'],
          'vscode-oniguruma': ['vscode-oniguruma'],
          'vscode-textmate': ['vscode-textmate'],
          'jszip': ['jszip'],
        },
      },
    },
  },
})
