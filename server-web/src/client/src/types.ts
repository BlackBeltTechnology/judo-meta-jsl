import { ScopeName } from 'vscode-textmate/release/theme';

export type LanguageId = string;

export interface JSLScopeNameInfo extends ScopeNameInfo {
  path: string;
}

export interface ScopeNameInfo {
  language?: LanguageId;
  injections?: ScopeName[];
}

export type TextMateGrammar = {
  type: 'json' | 'plist';
  grammar: string;
};
