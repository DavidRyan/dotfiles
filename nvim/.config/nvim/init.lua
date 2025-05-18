-- Bootstrap lazy.nvim
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

vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "LSP Hover (type info)" })


vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover,
  {
    border = "rounded",
    max_width = 80,
  }
)

-- randon config
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.api.nvim_set_keymap("n", "<CR>", "<Nop>", { noremap = true })
---vim.g.mapleader=" "
vim.keymap.set("n", "<leader>a", function() print "hi" end)
vim.keymap.set("n", "<Esc>", "")
-- Forward (jump to the next location)
--#regio
vim.keymap.set("n", "<C-]>", "<C-i>", { desc = "Jump Forward" })
vim.keymap.set("n", "<leader>[", "echo i", { desc = "Jump Forward" })
-- Backward (jump to the previous location)
vim.keymap.set("n", "<C-[>", "<C-o>", { desc = "Jump Backward" })
vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
    expr = true,
    replace_keycodes = false
})
vim.g.copilot_no_tab_map = true
vim.keymap.set("n", "]g", vim.diagnostic.goto_next)
vim.keymap.set("n", "[g", vim.diagnostic.goto_prev)
vim.opt.scrolloff = 5
vim.o.termguicolors = true
vim.o.relativenumber = true
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })

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
vim.api.nvim_set_keymap("n", "<C-\\>", [[<Cmd>lua require"fzf-lua".buffers()<CR>]], {})
vim.api.nvim_set_keymap("n", "<C-k>", [[<Cmd>lua require"fzf-lua".builtin()<CR>]], {})
vim.api.nvim_set_keymap("n", "<C-p>", [[<Cmd>lua require"fzf-lua".files()<CR>]], {})
vim.api.nvim_set_keymap("n", "<C-l>", [[<Cmd>lua require"fzf-lua".live_grep_glob()<CR>]], {})
vim.api.nvim_set_keymap("n", "<C-g>", [[<Cmd>lua require"fzf-lua".grep_project()<CR>]], {})
vim.api.nvim_set_keymap("n", "<F1>", [[<Cmd>lua require"fzf-lua".help_tags()<CR>]], {})
--vim.cmd([[colorscheme nightfox]])



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

                local capabilities = require("cmp_nvim_lsp").default_capabilities()

                require("mason-lspconfig").setup({
                    automatic_installation = false, -- no longer needed, but safe to leave false
                    automatic_enable = true, -- ✅ new setting
                })

                -- Custom LSP configuration
                local lspconfig = require("lspconfig")

                lspconfig.kotlin_language_server.setup({
                    cmd = {
                        vim.fn.stdpath("data") .. "/mason/packages/kotlin-language-server/server/bin/kotlin-language-server",
                    },
                    capabilities = capabilities,
                    init_options = {
                        storagePath = vim.fn.stdpath("cache") .. "/kotlin-language-server-workspace",
                    },
                    root_dir = function(fname)
                        local dir = require("lspconfig.util").path.dirname(fname)
                        vim.notify("📁 Kotlin root_dir = " .. dir)
                        return dir
                    end,
                })
            end,
        }
        ,

        { "github/copilot.vim" },
        { "nvim-lualine/lualine.nvim" },
        { "nvim-lua/plenary.nvim" },
        { "CopilotC-Nvim/CopilotChat.nvim" },
        { "EdenEast/nightfox.nvim" },
        {
            "catppuccin/nvim",
            name = "catppuccin",
            priority = 1000
        },
        { "ibhagwan/fzf-lua" },
        { "m4xshen/autoclose.nvim" },
        { "neovim/nvim-lspconfig" },
        { "j-hui/fidget.nvim" },
        { "hrsh7th/nvim-cmp" },
        { "lewis6991/gitsigns.nvim" },
        { "hrsh7th/nvim-cmp" },
        { "hrsh7th/cmp-nvim-lsp" },
        { "nvim-lua/popup.nvim" },
        { "nvim-treesitter/nvim-treesitter" },
        {
            'nvim-telescope/telescope.nvim',
            tag = '0.1.2',
            dependencies = { 'nvim-lua/plenary.nvim' },
            config = function()
                require('telescope').setup{
                    defaults = {
                        mappings = {
                            i = {
                                ["<C-u>"] = false, -- Disable Ctrl+u in insert mode
                                ["<C-d>"] = false, -- Disable Ctrl+d in insert mode
                            },
                        },
                    }
                }
            end
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
                "rcarriga/nvim-notify",
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
        }
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
    })

vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>s', '<cmd>Telescope lsp_workspace_symbols<CR>', { noremap = true, silent = true })


vim.keymap.set("n", "<leader>cc", function()
  vim.cmd("CopilotChat")
  vim.cmd("vertical resize -40")
end)

require("catppuccin").setup({
  flavour = "mocha", -- latte, frappe, macchiato, mocha
  transparent_background = true, -- ✅ enable transparency
  integrations = {
    nvimtree = true, 
    treesitter = true,
    telescope = true,
    },
})

vim.cmd.colorscheme "catppuccin-mocha"
--vim.cmd("colorscheme nightfox")

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


require("fidget").setup()
require("gitsigns").setup()
require("autoclose").setup()
require('lualine').setup()
require("CopilotChat").setup {}
require('nightfox').setup()
require("fzf-lua").setup()



vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.kt",
  callback = function()
    vim.notify("Entered Kotlin file: " .. vim.fn.expand("%:p"))
  end,
})

---- below is CMP and LSP setup
---
-- Setup Completion
-- See https://github.com/hrsh7th/nvim-cmp#basic-configuration
local cmp = require("cmp")
cmp.setup({
    preselect = cmp.PreselectMode.None,
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
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
        { name = "nvim_lsp" },
        { name = "vsnip" },
        { name = "path" },
        { name = "buffer" },
    },
})

vim.opt.signcolumn = 'yes'
vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
        local opts = {buffer = event.buf}

        vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
        vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
        vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
        vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
        vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
        vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
        vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
        vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
        vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
        vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
        vim.diagnostic.config({
            virtual_text = {
                prefix = "●", -- Customize the prefix symbol (e.g., ●, ■, ▶)
                spacing = 2,  -- Adjust spacing between the diagnostic and the code
            },
            signs = true,       -- Enable signs in the gutter
            underline = true,   -- Underline the problematic code
            update_in_insert = false, -- Update diagnostics in insert mode
            severity_sort = true, -- Sort diagnostics by severity
        })
    end,
})

cmp.setup({
    sources = {
        {name = 'nvim_lsp'},
    },
    snippet = {
        expand = function(args)
            -- You need Neovim v0.10 to use vim.snippet
            vim.snippet.expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({}),
})
