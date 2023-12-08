import { IExtensionManifest } from '@codingame/monaco-vscode-api/extensions';
import { JSLScopeNameInfo } from './types';

export const languageId = 'jsl';
export const theme = 'vs-dark';
export const modelFileName = 'example.jsl';
export const websocketPort = 30001;
export const languageConfigurationPath = './grammar/language-configuration.json';
export const grammarPath = './grammar/jsl.tmLanguage.json';
export const grammars: { [scopeName: string]: JSLScopeNameInfo } = {
  'source.jsl': {
    language: languageId,
    path: grammarPath,
  },
};
export const extension: IExtensionManifest = {
  name: 'jsl-client',
  publisher: 'Blackbelt Technology',
  version: '1.0.0',
  engines: {
    vscode: '^1.78.0',
  },
  contributes: {
    languages: [
      {
        id: languageId,
        aliases: ['JSL', languageId],
        extensions: ['.jsl'],
      },
    ],
  },
};
export const monacoWorkspaceFolder = 'workspace';
export const monacoWorkspaceFilePath = `/${monacoWorkspaceFolder}/${modelFileName}`;
