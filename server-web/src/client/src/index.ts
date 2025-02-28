import { LogLevel } from '@codingame/monaco-vscode-api';
import { createModelReference } from '@codingame/monaco-vscode-api/monaco';
import getConfigurationServiceOverride, {
  updateUserConfiguration,
} from '@codingame/monaco-vscode-configuration-service-override';
import * as monaco from '@codingame/monaco-vscode-editor-api';
import { Uri } from '@codingame/monaco-vscode-editor-api';
import {
  RegisteredFileSystemProvider,
  RegisteredMemoryFile,
  registerFileSystemOverlay,
} from '@codingame/monaco-vscode-files-service-override';
import getTextmateServiceOverride from '@codingame/monaco-vscode-textmate-service-override';
import getThemeServiceOverride from '@codingame/monaco-vscode-theme-service-override';
import { configureDefaultWorkerFactory } from 'monaco-editor-wrapper/workers/workerLoaders';
import { MonacoLanguageClient } from 'monaco-languageclient';
import { ConsoleLogger } from 'monaco-languageclient/tools';
import { initServices } from 'monaco-languageclient/vscode/services';
import ReconnectingWebSocket from 'reconnecting-websocket';
import { CloseAction, ErrorAction, MessageTransports } from 'vscode-languageclient/browser.js';
import { WebSocketMessageReader, WebSocketMessageWriter } from 'vscode-ws-jsonrpc';
import { IWebSocket } from 'vscode-ws-jsonrpc/src/socket/socket';
import {
  languageConfigurationPath,
  languageId,
  modelFileName,
  monacoWorkspaceFilePath,
  theme,
  websocketPort,
} from './config';
import { createEncodedTokensProvider } from './textmate-support';
import { createUrl } from './utils';

export const startJSLClient = async () => {
  const logger = new ConsoleLogger(LogLevel.Debug);
  const htmlContainer = document.getElementById('container')!;
  await initServices(
    {
      serviceOverrides: {
        ...getThemeServiceOverride(),
        ...getTextmateServiceOverride(),
        ...getConfigurationServiceOverride(),
      },
    },
    {
      htmlContainer,
      logger,
    },
  );

  monaco.languages.register({
    id: languageId,
    extensions: ['jsl'],
    aliases: ['JSL', languageId],
    mimetypes: ['application/x-jsl'],
  });

  const encodedLanguageId = monaco.languages.getEncodedLanguageId(languageId);

  const tokensProvider = createEncodedTokensProvider(encodedLanguageId);

  const languageConfiguration = await (await fetch(languageConfigurationPath)).json();

  monaco.languages.setTokensProvider(languageId, tokensProvider);
  monaco.languages.setLanguageConfiguration(languageId, languageConfiguration);

  const config: Record<string, any> = {
    'editor.fontSize': 12,
    'workbench.colorTheme': theme,
  };

  await updateUserConfiguration(JSON.stringify(config));

  configureDefaultWorkerFactory(logger);

  const content = await (await fetch(`./${modelFileName}`)).text();

  const fileSystemProvider = new RegisteredFileSystemProvider(false);
  fileSystemProvider.registerFile(new RegisteredMemoryFile(Uri.file(monacoWorkspaceFilePath), content));
  registerFileSystemOverlay(1, fileSystemProvider);

  const modelRef = await createModelReference(monaco.Uri.file(monacoWorkspaceFilePath));
  modelRef.object.setLanguageId(languageId);

  const editor = monaco.editor.create(htmlContainer, {
    model: modelRef.object.textEditorModel,
    automaticLayout: true,
    theme,
  });
  initWebSocketAndStartClient(createUrl('localhost', websocketPort, '/jsl', {}, false));

  return editor;
};

function initWebSocketAndStartClient(url: string) {
  const webSocket = new ReconnectingWebSocket(url);
  function toSocket(s: ReconnectingWebSocket): IWebSocket {
    return {
      send: (content) => s.send(content),
      onMessage: (cb) => {
        s.onmessage = (event) => cb(event.data);
      },
      onError: (cb) => {
        s.onerror = (event: any) => {
          if (Object.hasOwn(event, 'message')) {
            cb(event.message);
          }
        };
      },
      onClose: (cb) => {
        s.onclose = (event) => cb(event.code, event.reason);
      },
      dispose: () => s.close(),
    };
  }
  webSocket.onopen = () => {
    const socket = toSocket(webSocket);
    const reader = new WebSocketMessageReader(socket);
    const writer = new WebSocketMessageWriter(socket);
    const languageClient = createLanguageClient({
      reader,
      writer,
    });
    languageClient.start();
    reader.onClose(() => languageClient.stop());
  };
  return webSocket;
}

function createLanguageClient(messageTransports: MessageTransports) {
  return new MonacoLanguageClient({
    name: 'JSL Language Client',
    clientOptions: {
      documentSelector: ['jsl'],
      errorHandler: {
        error: () => ({ action: ErrorAction.Continue }),
        closed: () => ({ action: CloseAction.DoNotRestart }),
      },
    },
    messageTransports,
  });
}
