import type { ScopeName } from 'vscode-textmate/release/theme';
import type { IRawGrammar } from 'vscode-textmate';
import { IGrammar, INITIAL, parseRawGrammar, Registry } from 'vscode-textmate';
import { createOnigScanner, createOnigString } from 'vscode-oniguruma';
import * as monaco from 'monaco-editor';
import type { TextMateGrammar } from './types';
import VsCodeDarkTheme from './theme/vs-dark-plus-theme';
import { grammarPath, grammars, languageId } from './config';
import { getScopeNameForLanguage } from './utils';

const registry: Registry = new Registry({
  onigLib: Promise.resolve({
    createOnigScanner,
    createOnigString,
  }),
  loadGrammar: async (scopeName: ScopeName): Promise<IRawGrammar | undefined | null> => {
    const { grammar } = await fetchGrammar(scopeName);
    return parseRawGrammar(grammar, grammarPath);
  },
  theme: VsCodeDarkTheme,
});

async function fetchGrammar(scopeName: ScopeName): Promise<TextMateGrammar> {
  const { path } = grammars[scopeName];
  const uri = `/${path}`;
  const response = await fetch(uri);
  const grammar = await response.text();
  const type = path.endsWith('.json') ? 'json' : 'plist';
  return { type, grammar };
}

export async function getGrammar(scopeName: string, encodedLanguageId: number): Promise<IGrammar> {
  const grammarConfiguration = {};
  return registry
    .loadGrammarWithConfiguration(scopeName, encodedLanguageId, grammarConfiguration)
    .then((grammar: IGrammar | null) => {
      if (grammar) {
        return grammar;
      } else {
        throw Error(`failed to load grammar for ${scopeName}`);
      }
    });
}

export async function createEncodedTokensProvider(
  encodedLanguageId: number,
): Promise<monaco.languages.EncodedTokensProvider> {
  const scopeName = getScopeNameForLanguage(languageId)!;
  const grammar = await getGrammar(scopeName, encodedLanguageId);

  return {
    getInitialState() {
      return INITIAL;
    },

    tokenizeEncoded(line: string, state: monaco.languages.IState): monaco.languages.IEncodedLineTokens {
      const tokenizeLineResult2 = grammar.tokenizeLine2(line, state as any);
      const { tokens, ruleStack: endState } = tokenizeLineResult2;
      return { tokens, endState };
    },
  };
}
