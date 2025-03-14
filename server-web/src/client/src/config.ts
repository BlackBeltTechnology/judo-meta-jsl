export interface JSLScopeNameInfo extends ScopeNameInfo {
  path: string;
}

export interface ScopeNameInfo {
  language?: string;
  injections?: string[];
}

export const languageId = 'jsl';
export const theme = 'vs-dark-plus';
export const modelFileName = 'example.jsl';
export const websocketPort = 5051;
export const languageConfigurationPath = './grammar/language-configuration.json';
export const grammarPath = './grammar/syntaxes/jsl.tmLanguage';
export const grammars: { [scopeName: string]: JSLScopeNameInfo } = {
  'source.jsl': {
    language: languageId,
    path: grammarPath,
  },
};
export const monacoWorkspaceFolder = 'workspace';
export const monacoWorkspaceFilePath = `/${monacoWorkspaceFolder}/${modelFileName}`;
