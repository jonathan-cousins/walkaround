## 2024-05-19 - Temporary Dependencies For Non-Node Projects
**Learning:** When using Node tools (like jsdom or Playwright) to test vanilla HTML/JS projects, installing packages locally creates `package.json`, `package-lock.json`, and `node_modules` which bloat git tracking. Adding these to `.gitignore` mutates project configuration incorrectly.
**Action:** Always fully clean up `package.json`, `package-lock.json`, and `node_modules` before committing instead of modifying `.gitignore`, and ensure no unrelated files are staged.
