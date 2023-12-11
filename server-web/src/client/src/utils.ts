import { grammars } from './config';

export const createUrl = (
  hostname: string,
  port: number,
  path: string,
  searchParams: Record<string, any> = {},
  secure: boolean = location.protocol === 'https:',
): string => {
  const protocol = secure ? 'wss' : 'ws';
  const url = new URL(`${protocol}://${hostname}:${port}${path}`);

  for (let [key, value] of Object.entries(searchParams)) {
    if (value instanceof Array) {
      value = value.join(',');
    }
    if (value) {
      url.searchParams.set(key, value);
    }
  }

  return url.toString();
};

export function getScopeNameForLanguage(language: string): string | null {
  for (const [scopeName, grammar] of Object.entries(grammars)) {
    if (grammar.language === language) {
      return scopeName;
    }
  }
  return null;
}
