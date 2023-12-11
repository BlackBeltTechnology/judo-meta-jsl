// @ts-ignore
import * as monaco from 'monaco-editor';

// @ts-ignore
self.MonacoEnvironment = {
    getWorker: async (_: any, label: string) => {
        let worker;
        switch (label) {
            default:
                worker = await import('monaco-editor/esm/vs/editor/editor.worker?worker');
        }
        return new worker.default();
    }
};
