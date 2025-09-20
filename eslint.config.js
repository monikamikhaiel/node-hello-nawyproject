// // eslint.config.js
// import js from "@eslint/js";

// export default [
//   js.configs.recommended, // ESLint's recommended rules
//   {
//     rules: {
//       "no-unused-vars": "warn",
//       "no-console": "off",
//     },
//   },
// ];
// eslint.config.js
import js from "@eslint/js";

export default [
  js.configs.recommended,
  {
    rules: {
      // --- Possible Errors ---
      "no-console": "warn", // allow console but warn
      "no-debugger": "error", // disallow debugger
      "no-extra-semi": "error", // disallow unnecessary semicolons
      "no-duplicate-case": "error", // disallow duplicate case labels

      // --- Best Practices ---
      eqeqeq: ["error", "always"], // require === and !==
      curly: ["error", "all"], // enforce braces for all control statements
      "default-case": "warn", // suggest default case in switch
      "dot-notation": "error", // enforce dot notation whenever possible
      "no-alert": "warn", // warn on alert/confirm/prompt
      "no-eval": "error", // disallow eval()

      // --- Variables ---
      "no-unused-vars": ["warn", { argsIgnorePattern: "^_" }], // ignore unused args starting with _
      "no-undef": "error", // disallow undeclared variables
      "no-shadow": "warn", // disallow shadowing variables

      // --- Style ---
      indent: ["error", 2], // enforce 2 spaces
      quotes: ["error", "double"], // enforce double quotes
      semi: ["error", "always"], // require semicolons
      "comma-dangle": ["error", "always-multiline"], // trailing commas in multiline
      "object-curly-spacing": ["error", "always"], // spaces inside {}
      "array-bracket-spacing": ["error", "never"], // no spaces inside []
      "space-before-blocks": ["error", "always"], // space before {

      // --- ES6 ---
      "prefer-const": "error", // prefer const if variable never reassigned
      "no-var": "error", // disallow var
      "arrow-spacing": ["error", { before: true, after: true }], // spacing around =>
    },
  },
];
