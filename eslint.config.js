// eslint.config.js
import js from "@eslint/js";

export default [
  js.configs.recommended, // ESLint's recommended rules
  {
    rules: {
      "no-unused-vars": "warn",
      "no-console": "off",
    },
  },
];
