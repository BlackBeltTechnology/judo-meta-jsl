import * as monaco from 'monaco-editor';
import * as vscode from 'vscode';
import { whenReady } from '@codingame/monaco-vscode-theme-defaults-default-extension';
import { LogLevel } from 'vscode/services';
import { createConfiguredEditor, createModelReference } from 'vscode/monaco';
import { ExtensionHostKind, registerExtension } from 'vscode/extensions';
import getConfigurationServiceOverride, {
  updateUserConfiguration,
} from '@codingame/monaco-vscode-configuration-service-override';
import getThemeServiceOverride from '@codingame/monaco-vscode-theme-service-override';
import getTextmateServiceOverride from '@codingame/monaco-vscode-textmate-service-override';
import { initServices } from 'monaco-languageclient';
import {
  RegisteredFileSystemProvider,
  registerFileSystemOverlay,
  RegisteredMemoryFile,
} from '@codingame/monaco-vscode-files-service-override';
import { Uri } from 'vscode';
import { loadWASM } from 'vscode-oniguruma';
import {
  extension,
  languageConfigurationPath,
  languageId,
  modelFileName,
  monacoWorkspaceFilePath,
  monacoWorkspaceFolder,
  theme,
  websocketPort,
} from './config';
import { createUrl } from './utils';
import { createWebSocket } from './websocket-integration';
import { createEncodedTokensProvider } from './textmate-support';
import _onigWasm from 'vscode-oniguruma/release/onig.wasm?url';
import './useWorker';

const content = await (await fetch(`./${modelFileName}`)).text();
const languageConfiguration: monaco.languages.LanguageConfiguration = await (
  await fetch(languageConfigurationPath)
).json();

// Taken from https://github.com/microsoft/vscode/blob/829230a5a83768a3494ebbc61144e7cde9105c73/src/vs/workbench/services/textMate/browser/textMateService.ts#L33-L40
async function loadVSCodeOnigurumaWASM(): Promise<Response | ArrayBuffer> {
  const response = await fetch(_onigWasm);
  const contentType = response.headers.get('content-type');
  if (contentType === 'application/wasm') {
    return response;
  }

  // Using the response directly only works if the server sets the MIME type 'application/wasm'.
  // Otherwise, a TypeError is thrown when using the streaming compiler.
  // We therefore use the non-streaming compiler :(.
  return await response.arrayBuffer();
}

export const startJSLClient = async () => {
  // init vscode-api
  await initServices({
    userServices: {
      ...getThemeServiceOverride(),
      ...getTextmateServiceOverride(),
      ...getConfigurationServiceOverride(),
    },
    debugLogging: true,
    workspaceConfig: {
      workspaceProvider: {
        trusted: true,
        workspace: {
          workspaceUri: Uri.file(`/${monacoWorkspaceFolder}`),
        },
        async open() {
          return false;
        },
      },
      developmentOptions: {
        logLevel: LogLevel.Debug,
      },
    },
  });

  console.log('Loading themes...');
  await whenReady();
  console.info('Themes loaded.');

  registerExtension(extension, ExtensionHostKind.LocalProcess);

  const data: ArrayBuffer | Response = await loadVSCodeOnigurumaWASM();
  await loadWASM(data);

  const encodedLanguageId = monaco.languages.getEncodedLanguageId(languageId);

  const tokensProvider = createEncodedTokensProvider(encodedLanguageId);

  monaco.languages.setTokensProvider(languageId, tokensProvider);
  monaco.languages.setLanguageConfiguration(languageId, languageConfiguration);

  const config: Record<string, any> = {
    'editor.fontSize': 12,
    'workbench.colorTheme': theme,
  };

  await updateUserConfiguration(JSON.stringify(config));

  const fileSystemProvider = new RegisteredFileSystemProvider(false);
  fileSystemProvider.registerFile(new RegisteredMemoryFile(vscode.Uri.file(monacoWorkspaceFilePath), content));
  registerFileSystemOverlay(1, fileSystemProvider);

  // use the file create before
  const modelRef = await createModelReference(monaco.Uri.file(monacoWorkspaceFilePath));
  modelRef.object.setLanguageId(languageId);

  // create monaco editor
  const editor = createConfiguredEditor(document.getElementById('container')!, {
    model: modelRef.object.textEditorModel,
    automaticLayout: true,
    theme,
  });

  // create the web socket and configure to start the language client on open, can add extra parameters to the url if needed.
  createWebSocket(
    createUrl(
      'localhost',
      websocketPort,
      '/jsl',
      {
        // Used to parse an auth token or additional parameters such as import IDs to the language server
        authorization: 'UserAuth',
        // By commenting above line out and commenting below line in, connection to language server will be denied.
        // authorization: 'FailedUserAuth'
      },
      false,
    ),
  );

  return editor;
};
