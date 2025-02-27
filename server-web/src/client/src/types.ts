export type LanguageId = string;

export interface JSLScopeNameInfo extends ScopeNameInfo {
  path: string;
}

export interface ScopeNameInfo {
  language?: LanguageId;
  injections?: string[];
}

export type TextMateGrammar = {
  type: 'json' | 'plist';
  grammar: string;
};
