// - https://microsoft.github.io/monaco-editor/monarch.html
// - https://github.com/microsoft/vscode-textmate/blob/main/test-cases/themes/dark_vs.json
// - https://github.com/microsoft/vscode-textmate/blob/main/test-cases/themes/dark_plus.json

import { IRawTheme } from 'vscode-textmate';
import { theme } from '../config';

export default {
  base: 'vs-dark',
  name: theme,
  settings: [],
} as IRawTheme;
