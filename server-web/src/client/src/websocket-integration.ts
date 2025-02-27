import * as monaco from 'monaco-editor';
import { MonacoLanguageClient } from 'monaco-languageclient';
import * as vscode from 'vscode';
import { CloseAction, ErrorAction, MessageTransports } from 'vscode-languageclient';
import { WebSocketMessageReader, WebSocketMessageWriter, toSocket } from 'vscode-ws-jsonrpc';
import { languageId, monacoWorkspaceFolder } from './config';

export const createWebSocket = (url: string): WebSocket => {
  const webSocket = new WebSocket(url);
  webSocket.onopen = async () => {
    const socket = toSocket(webSocket);
    const reader = new WebSocketMessageReader(socket);
    const writer = new WebSocketMessageWriter(socket);
    const languageClient = createLanguageClient({
      reader,
      writer,
    });
    await languageClient.start();
    reader.onClose(() => languageClient.stop());
  };
  return webSocket;
};

export const createLanguageClient = (transports: MessageTransports): MonacoLanguageClient => {
  return new MonacoLanguageClient({
    name: 'JSL',
    clientOptions: {
      // use a language id as a document selector
      documentSelector: [languageId],
      // disable the default error handler
      errorHandler: {
        error: () => ({ action: ErrorAction.Continue }),
        closed: () => ({ action: CloseAction.DoNotRestart }),
      },
      workspaceFolder: {
        index: 0,
        name: monacoWorkspaceFolder,
        uri: monaco.Uri.parse(`/${monacoWorkspaceFolder}`),
      },
      synchronize: {
        fileEvents: [vscode.workspace.createFileSystemWatcher('**/*.*')],
      },
    },
    // create a language client connection from the JSON RPC connection on demand
    connectionProvider: {
      get: () => {
        return Promise.resolve(transports);
      },
    },
  });
};
