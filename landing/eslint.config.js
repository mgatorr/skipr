import eslint from '@eslint/js';
import tseslint from 'typescript-eslint';
import astro from 'eslint-plugin-astro';

const nodeGlobals = {
  process: 'readonly',
  Buffer: 'readonly',
  console: 'readonly',
  URL: 'readonly',
};

export default tseslint.config(
  {
    ignores: ['dist/', '.astro/', 'node_modules/', '.vercel/', 'coverage/', '.lighthouseci/'],
  },
  eslint.configs.recommended,
  ...tseslint.configs.recommended,
  ...astro.configs.recommended,
  // Node scripts / config files run in Node, not the browser.
  {
    files: ['**/*.mjs', '**/*.config.{js,mjs,ts}', 'scripts/**/*.{js,mjs}'],
    languageOptions: { globals: nodeGlobals },
  },
);
