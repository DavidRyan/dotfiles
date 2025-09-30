# Agent Guidelines for Neovim Configuration

## Build/Lint/Test Commands
- No build/test commands - this is a Neovim configuration file
- Validate syntax: `nvim --headless -c "lua dofile('init.lua')" -c "quit"`
- Check lazy.nvim plugins: `:Lazy check` or `:Lazy sync`

## Code Style Guidelines

### Language & Format
- Language: Lua for Neovim configuration
- Indentation: 4 spaces (set in lines 63-66)
- Use `vim.keymap.set()` for keybindings, not `vim.api.nvim_set_keymap()` (prefer newer API)

### Structure & Conventions
- Plugin specs go inside `require("lazy").setup({ spec = { ... } })`
- Plugin setup/config should be in plugin's `config` function when possible
- Use lazy loading (`lazy = false` or event-based) for performance
- LSP setup: use mason-lspconfig for language server management
- Keybindings: leader key is space (`<leader>` = ` `), local leader is backslash

### Imports & Dependencies
- Use `require()` for Lua modules (e.g., `require("lspconfig")`)
- Declare plugin dependencies in the `dependencies` table within plugin specs
- Common dependencies: plenary.nvim, nvim-lspconfig, nvim-cmp, telescope

### Error Handling & LSP
- LSP capabilities: use `require("cmp_nvim_lsp").default_capabilities()`
- Diagnostic config in LspAttach autocmd (virtual_text, signs, underline)
- Use `vim.lsp.buf.*` for LSP actions (hover, definition, references, etc.)
