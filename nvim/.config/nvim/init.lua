-- Bootstrap lazy.nvim
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Set the hover handler with updated API
vim.api.nvim_set_hl(0, "LspHover", { bg = "#2d3149" })
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover,
  {
    border = "rounded",
    max_width = 80,
    silent = true,
  }
)

-- randon config
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
--vim.keymap.set("n", "<CR>", "<Nop>", { noremap = true })
vim.keymap.set('n', '<leader>w', '<C-w>w', { noremap = true })
vim.keymap.set("n", "<leader>a", function() print "hi" end)
vim.keymap.set("n", "<Esc>", "")
-- Forward (jump to the next location)
--#regio
vim.keymap.set("n", "<C-]>", "<C-i>", { desc = "Jump Forward" })
vim.keymap.set("n", "<leader>[", "echo i", { desc = "Jump Forward" })
-- Backward (jump to the previous location)
vim.keymap.set("n", "<C-[>", "<C-o>", { desc = "Jump Backward" })
vim.keymap.set("n", "]g", vim.diagnostic.goto_next)
vim.keymap.set("n", "[g", vim.diagnostic.goto_prev)
vim.opt.scrolloff = 5
vim.o.number = true
vim.o.relativenumber = true

-- Set completeopt to have a better completion experience
-- :help completeopt
-- menuone: popup even when there's only one match
-- noinsert: Do not insert text until a selection is made
-- noselect: Do not auto-select, nvim-cmp plugin will handle this for us.
vim.o.completeopt = "menuone,noinsert,noselect"
-- Avoid showing extra messages when using completion
vim.opt.shortmess = vim.opt.shortmess + "c"
vim.cmd("set tabstop=4")       
vim.cmd("set shiftwidth=4")       
vim.cmd("set softtabstop=4")       
vim.cmd("set expandtab")       
vim.keymap.set("n", "<C-p>", "<cmd>Telescope find_files<CR>", { noremap = true, silent = true, desc = "Find files" })
vim.keymap.set("n", "<C-\\>", "<cmd>Telescope buffers<CR>", { noremap = true, silent = true, desc = "Find buffers" })
vim.keymap.set("n", "<C-l>", "<cmd>Telescope live_grep<CR>", { noremap = true, silent = true, desc = "Live grep" })
vim.keymap.set("n", "<F1>", "<cmd>Telescope help_tags<CR>", { noremap = true, silent = true, desc = "Help tags" })



-- Plugins

require("lazy").setup({
    spec = {
        {
            "folke/trouble.nvim",
            opts = {}, -- for default options, refer to the configuration section for custom setup.
            cmd = "Trouble",
            keys = {
                {
                    "<leader>xx",
                    "<cmd>Trouble diagnostics toggle<cr>",
                    desc = "Diagnostics (Trouble)",
                },
                {
                    "<leader>xX",
                    "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                    desc = "Buffer Diagnostics (Trouble)",
                },
                {
                    "<leader>cs",
                    "<cmd>Trouble symbols toggle focus=false<cr>",
                    desc = "Symbols (Trouble)",
                },
                {
                    "<leader>cl",
                    "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                    desc = "LSP Definitions / references / ... (Trouble)",
                },
                {
                    "<leader>xL",
                    "<cmd>Trouble loclist toggle<cr>",
                    desc = "Location List (Trouble)",
                },
                {
                    "<leader>xQ",
                    "<cmd>Trouble qflist toggle<cr>",
                    desc = "Quickfix List (Trouble)",
                },
            },
        },
        {
            "williamboman/mason-lspconfig.nvim",
            dependencies = {
                "williamboman/mason.nvim",
                "neovim/nvim-lspconfig",
                "hrsh7th/cmp-nvim-lsp",
            },
            lazy = false,
            config = function()
                print("🔧 Setting up mason-lspconfig")

                require("mason").setup()

                -- Define common on_attach function for consistent keybindings
                local on_attach = function(client, bufnr)
                    -- Enable completion triggered by <c-x><c-o>
                    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

                    -- Buffer local mappings
                    local opts = { buffer = bufnr, noremap = true, silent = true }
                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                    vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)
                    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                    vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)
                    vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
                    vim.keymap.set({'n', 'x'}, '<F3>', function() vim.lsp.buf.format({async = true}) end, opts)
                    vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, opts)
                    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr, desc = "LSP Code Action" })
                end

                -- Setup capabilities
                local capabilities = require("cmp_nvim_lsp").default_capabilities()
                
                -- Setup diagnostics configuration
                vim.diagnostic.config({
                    virtual_text = {
                        prefix = "●", -- Customize the prefix symbol
                        spacing = 2,  -- Adjust spacing
                    },
                    signs = true,
                    underline = true,
                    update_in_insert = false,
                    severity_sort = true,
                })

                -- Configure mason-lspconfig
                require("mason-lspconfig").setup({
                    ensure_installed = { "lua_ls", "rust_analyzer" },
                    handlers = {
                        -- Default handler
                        function(server_name)
                            require("lspconfig")[server_name].setup({
                                on_attach = on_attach,
                                capabilities = capabilities,
                            })
                        end,
                        
                        -- Special handler for Elixir
                        ["elixirls"] = function()
                            require("lspconfig").elixirls.setup({
                                cmd = { vim.fn.stdpath("data") .. "/mason/bin/elixir-ls" },
                                on_attach = on_attach,
                                capabilities = capabilities,
                            })
                        end,
                        
                        -- Special handler for Kotlin
                        ["kotlin_language_server"] = function()
                            require("lspconfig").kotlin_language_server.setup({
                                cmd = {
                                    vim.fn.stdpath("data") .. "/mason/packages/kotlin-language-server/server/bin/kotlin-language-server",
                                },
                                on_attach = on_attach,
                                capabilities = capabilities,
                                init_options = {
                                    storagePath = vim.fn.stdpath("cache") .. "/kotlin-language-server-workspace",
                                },
                                root_dir = function(fname)
                                    return require("lspconfig.util").find_git_ancestor(fname) or 
                                           require("lspconfig.util").path.dirname(fname)
                                end,
                            })
                        end,
                    },
                })
            end,
        }
        ,

        { "nvim-lualine/lualine.nvim" },
        { "nvim-lua/plenary.nvim" },
        { "CopilotC-Nvim/CopilotChat.nvim" },
        { "EdenEast/nightfox.nvim" },
        {
            "catppuccin/nvim",
            name = "catppuccin",
            priority = 1000
        },
        { "m4xshen/autoclose.nvim" },
        { "j-hui/fidget.nvim" },
        { "hrsh7th/nvim-cmp" },
        { "hrsh7th/vim-vsnip" },
        { "hrsh7th/cmp-vsnip" },
        { "lewis6991/gitsigns.nvim" },
        { "hrsh7th/cmp-nvim-lsp" },
        { "nvim-lua/popup.nvim" },
        { "nvim-treesitter/nvim-treesitter" },
        { "nvim-tree/nvim-tree.lua" },
        {
            'nvim-telescope/telescope.nvim',
            tag = '0.1.2',
            dependencies = { 'nvim-lua/plenary.nvim' },
            config = function()
                require('telescope').setup{
                    defaults = {
                        mappings = {
                            i = {
                                ["<C-u>"] = false,
                                ["<C-d>"] = false,
                            },
                        },
                    },
                    pickers = {
                        lsp_references = {
                            previewer = true,
                        },
                    },
                }
            end,
        },
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            build = 'make',
            config = function()
                require('telescope').load_extension('fzf')
            end
        },
        {
            "folke/which-key.nvim",
            config = function()
                require("which-key").setup({})
            end,
        },
        {
            "brenoprata10/nvim-highlight-colors",
            config = function()
                require("nvim-highlight-colors").setup {
                    render = 'background', -- Options: 'background', 'foreground', 'first_column'
                    enable_named_colors = true,
                    enable_tailwind = false,
                }
            end,
        },
        {
            "folke/noice.nvim",
            event = "VeryLazy",
            dependencies = {
                "MunifTanjim/nui.nvim",
                --"rcarriga/nvim-notify",
            },
            config = function()
                require("noice").setup({
                    lsp = {
                        hover = {
                            enabled = true,
                        },
                        signature = {
                            enabled = true,
                        },
                    },
                    presets = {
                        bottom_search = true,
                        command_palette = true,
                        long_message_to_split = true,
                        inc_rename = false,
                        lsp_doc_border = true,
                    },
                })
            end
        },
        { "nvim-tree/nvim-web-devicons", lazy = true },
        {
            "kawre/leetcode.nvim",
            build = ":TSUpdate html", -- if you have `nvim-treesitter` installed
            dependencies = {
                "nvim-telescope/telescope.nvim",
                -- "ibhagwan/fzf-lua",
                "nvim-lua/plenary.nvim",
                "MunifTanjim/nui.nvim",
            },
            opts = {
                lang = "kotlin"
            },
        },
        {
             "goolord/alpha-nvim",
             -- dependencies = { 'echasnovski/mini.icons' },
            dependencies = { 'nvim-tree/nvim-web-devicons' },
            config = function()
                local startify = require("alpha.themes.startify")
                -- available: devicons, mini, default is mini
                -- if provider not loaded and enabled is true, it will try to use another provider
                startify.file_icons.provider = "devicons"
                require("alpha").setup(
                    startify.config
                )
            end,
        },
        { "onsails/lspkind.nvim" },
        {
            "supermaven-inc/supermaven-nvim"
        },
        {
            'stevearc/oil.nvim',
            ---@module 'oil'
            ---@type oil.SetupOpts
            opts = {},
            -- Optional dependencies
            dependencies = { { "echasnovski/mini.icons", opts = {} } },
            -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
            -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
            lazy = false,
        }
    }})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

require("supermaven-nvim").setup({
    keymaps = {
        clear_suggestion = "<C-]>",
        accept_word = "<C-j>",
        accept_suggestion = "<C-k>",
    },
    ignore_filetypes = { cpp = true },
    log_level = "info",
    disable_inline_completion = false,
    disable_keymaps = false,
    condition = function()
        return false
    end
})





vim.keymap.set('n', '<leader>gr', '<cmd>Telescope lsp_references<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>s', '<cmd>Telescope lsp_workspace_symbols<CR>', { noremap = true, silent = true })


vim.keymap.set("n", "<leader>cc", function()
  vim.cmd("CopilotChat")
  vim.cmd("vertical resize -40")
end)

-- require("notify").setup({
  -- background_colour = "#000000",
-- })

require("catppuccin").setup({
  flavour = "mocha",
  transparent_background = true,
  integrations = {
    nvimtree = true,
    treesitter = true,
    telescope = true,
    cmp = true,
  },
  highlight_overrides = {
    mocha = function(colors)
      return {
        -- === Cmp ===
        CmpPmenu = { bg = colors.base, fg = colors.text },
        CmpPmenuSel = { bg = colors.surface1, fg = colors.text },
        CmpPmenuBorder = { bg = colors.base, fg = colors.surface2 },
        CmpPmenuSbar = { bg = colors.surface0 },
        CmpPmenuThumb = { bg = colors.surface2 },
        CmpItemAbbr = { fg = colors.text },
        CmpItemAbbrMatch = { fg = colors.peach, bold = true },
        CmpItemKind = { fg = colors.blue },
        CmpItemMenu = { fg = colors.subtext0 },

        -- === Floating windows ===
        NormalFloat = { bg = colors.mantle },
        --FloatBorder = { bg = colors.mantle, fg = colors.surface2 },
        CursorLine = { bg = colors.surface0 },
        CursorLineNr = { fg = colors.peach, bold = true },

        -- === Telescope ===
        TelescopeNormal        = { bg = "NONE" },
        --TelescopeBorder        = { bg = colors.mantle, fg = colors.blue },
        TelescopePromptNormal  = { bg = "NONE" },
        --TelescopePromptBorder  = { bg = colors.crust, fg = colors.blue },
        TelescopeResultsNormal = { bg = "NONE" },
        --TelescopeResultsBorder = { bg = colors.mantle, fg = colors.surface2 },
        TelescopePreviewNormal = { bg = "NONE" },
        --TelescopePreviewBorder = { bg = colors.mantle, fg = colors.surface2 },
      }
    end,
  },
})

vim.cmd.colorscheme "catppuccin-mocha"

require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the listed parsers MUST always be installed)
  ensure_installed = {"go", "html"}, -- Or specify a list of languages

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  highlight = {
    enable = true,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}


require("nvim-tree").setup()
vim.keymap.set('n', '<leader>t', '<cmd>NvimTreeToggle<CR>', { noremap = true, silent = true })
require("fidget").setup()
require("gitsigns").setup()
require("autoclose").setup()
require('lualine').setup()
require("CopilotChat").setup {}
require('nightfox').setup()



vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.kt",
  callback = function()
  end,
})

---- below is CMP and LSP setup
---
-- Setup Completion
-- See https://github.com/hrsh7th/nvim-cmp#basic-configuration
local cmp = require("cmp")
local lspkind = require("lspkind")
cmp.setup({
    preselect = cmp.PreselectMode.None,
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    formatting = {
        format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "…",
        }),
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    mapping = {
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        -- Add tab support
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
        }),
    },

    -- Installed sources
    sources = {
        { name = "supermaven"},
        { name = "nvim_lsp" },
        { name = "vsnip" },
        { name = "path" },
        { name = "buffer" },
    },
})

-- Enable sign column for displaying diagnostics
vim.opt.signcolumn = 'yes'


vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, { noremap = true, silent = true })
