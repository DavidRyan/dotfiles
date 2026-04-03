-- Bootstrap lazy.nvim
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
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

-- LSP hover style
vim.api.nvim_set_hl(0, "LspHover", { bg = "#2d3149" })
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover,
    { border = "rounded", max_width = 80, silent = true }
)

-- Options
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.scrolloff = 5
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.completeopt = "menuone,noinsert,noselect"
vim.opt.shortmess:append("c")
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.signcolumn = "yes"

-- Navigation
vim.keymap.set("n", "<leader>w", "<C-w>w", { noremap = true })
vim.keymap.set("n", "<C-]>", "<C-i>", { desc = "Jump Forward" })
vim.keymap.set("n", "<C-[>", "<C-o>", { desc = "Jump Backward" })
vim.keymap.set("n", "]g", vim.diagnostic.goto_next)
vim.keymap.set("n", "[g", vim.diagnostic.goto_prev)

-- Fuzzy finder (ivy layout, no preview — works on narrow screens)
vim.keymap.set("n", "<C-p>",    "<cmd>FzfLua files<CR>",              { silent = true, desc = "Find files" })
vim.keymap.set("n", "<C-\\>",   "<cmd>FzfLua buffers<CR>",            { silent = true, desc = "Find buffers" })
vim.keymap.set("n", "<C-l>",    "<cmd>FzfLua live_grep_glob<CR>",     { silent = true, desc = "Live grep" })
vim.keymap.set("n", "<F1>",     "<cmd>FzfLua helptags<CR>",           { silent = true, desc = "Help tags" })
vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<CR>",            { silent = true, desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep_glob<CR>",   { silent = true, desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<CR>",          { silent = true, desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua helptags<CR>",         { silent = true, desc = "Help tags" })
vim.keymap.set("n", "<leader>s",  "<cmd>FzfLua lsp_workspace_symbols<CR>", { silent = true, desc = "LSP Workspace Symbols" })
vim.keymap.set("n", "<leader>gd", "<cmd>FzfLua lsp_definitions<CR>",       { silent = true, desc = "LSP Definition" })
vim.keymap.set("n", "<leader>gr", "<cmd>Trouble lsp_references toggle<cr>", { silent = true, desc = "LSP References" })

-- File explorer
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>t", "<cmd>NvimTreeToggle<CR>", { silent = true })

-- CopilotChat
vim.keymap.set("n", "<leader>cc", function()
    vim.cmd("CopilotChat")
    vim.cmd("vertical resize -40")
end)

-- Plugins
require("lazy").setup({ spec = {

    -- Trouble: diagnostics + LSP references panel
    {
        "folke/trouble.nvim",
        opts = {},
        cmd = "Trouble",
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                          desc = "Diagnostics (Trouble)" },
            { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",             desc = "Buffer Diagnostics (Trouble)" },
            { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>",                  desc = "Symbols (Trouble)" },
            { "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                              desc = "Location List (Trouble)" },
            { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                              desc = "Quickfix List (Trouble)" },
        },
    },

    -- LSP
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
            "hrsh7th/cmp-nvim-lsp",
        },
        lazy = false,
        config = function()
            require("mason").setup()

            local on_attach = function(client, bufnr)
                vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
                local opts = { buffer = bufnr, noremap = true, silent = true }

                vim.keymap.set("n", "K",  vim.lsp.buf.hover,                                         opts)
                vim.keymap.set("n", "gd", vim.lsp.buf.definition,                                    opts)
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration,                                   opts)
                vim.keymap.set("n", "gi", vim.lsp.buf.implementation,                                opts)
                vim.keymap.set("n", "go", vim.lsp.buf.type_definition,                               opts)
                vim.keymap.set("n", "gr", "<cmd>Trouble lsp_references toggle<cr>",                  opts)
                vim.keymap.set("n", "gs", vim.lsp.buf.signature_help,                                opts)
                vim.keymap.set("n", "<F2>", vim.lsp.buf.rename,                                      opts)
                vim.keymap.set({ "n", "x" }, "<F3>", function() vim.lsp.buf.format({ async = true }) end, opts)
                vim.keymap.set("n", "<F4>",     vim.lsp.buf.code_action,                             opts)
                vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "LSP Code Action" })
            end

            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            vim.diagnostic.config({
                virtual_text = { prefix = "●", spacing = 2 },
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
            })

            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "rust_analyzer" },
                handlers = {
                    function(server_name)
                        require("lspconfig")[server_name].setup({
                            on_attach = on_attach,
                            capabilities = capabilities,
                        })
                    end,
                    ["elixirls"] = function()
                        require("lspconfig").elixirls.setup({
                            cmd = { vim.fn.stdpath("data") .. "/mason/bin/elixir-ls" },
                            on_attach = on_attach,
                            capabilities = capabilities,
                        })
                    end,
                },
            })
        end,
    },

    -- fzf-lua: fuzzy finder, ivy layout, no preview
    {
        "ibhagwan/fzf-lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("fzf-lua").setup({
                "ivy",
                winopts = { preview = { hidden = true } },
            })
        end,
    },

    -- Theme
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                flavour = "mocha",
                transparent_background = true,
                integrations = {
                    nvimtree = true,
                    treesitter = true,
                    cmp = true,
                },
                highlight_overrides = {
                    mocha = function(colors)
                        return {
                            CmpPmenu       = { bg = colors.base,     fg = colors.text },
                            CmpPmenuSel    = { bg = colors.surface1, fg = colors.text },
                            CmpPmenuBorder = { bg = colors.base,     fg = colors.surface2 },
                            CmpPmenuSbar   = { bg = colors.surface0 },
                            CmpPmenuThumb  = { bg = colors.surface2 },
                            CmpItemAbbr      = { fg = colors.text },
                            CmpItemAbbrMatch = { fg = colors.peach, bold = true },
                            CmpItemKind      = { fg = colors.blue },
                            CmpItemMenu      = { fg = colors.subtext0 },
                            NormalFloat      = { bg = colors.mantle },
                            CursorLine       = { bg = colors.surface0 },
                            CursorLineNr     = { fg = colors.peach, bold = true },
                        }
                    end,
                },
            })
            vim.cmd.colorscheme("catppuccin-mocha")
        end,
    },

    -- UI
    { "nvim-lualine/lualine.nvim",       config = function() require("lualine").setup() end },
    { "j-hui/fidget.nvim",               config = function() require("fidget").setup() end },
    { "lewis6991/gitsigns.nvim",         config = function() require("gitsigns").setup() end },
    { "m4xshen/autoclose.nvim",          config = function() require("autoclose").setup() end },
    { "nvim-tree/nvim-web-devicons",     lazy = true },
    { "onsails/lspkind.nvim" },
    { "EdenEast/nightfox.nvim",          config = function() require("nightfox").setup() end },
    {
        "brenoprata10/nvim-highlight-colors",
        config = function()
            require("nvim-highlight-colors").setup({
                render = "background",
                enable_named_colors = true,
                enable_tailwind = false,
            })
        end,
    },
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = { "MunifTanjim/nui.nvim" },
        config = function()
            require("noice").setup({
                lsp = {
                    hover     = { enabled = true },
                    signature = { enabled = true },
                },
                presets = {
                    bottom_search = true,
                    command_palette = true,
                    long_message_to_split = true,
                    inc_rename = false,
                    lsp_doc_border = true,
                },
            })
        end,
    },
    {
        "folke/which-key.nvim",
        config = function() require("which-key").setup({}) end,
    },
    {
        "goolord/alpha-nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local startify = require("alpha.themes.startify")
            startify.file_icons.provider = "devicons"
            require("alpha").setup(startify.config)
        end,
    },

    -- File explorer
    {
        "nvim-tree/nvim-tree.lua",
        config = function() require("nvim-tree").setup() end,
    },
    {
        "stevearc/oil.nvim",
        lazy = false,
        dependencies = { { "echasnovski/mini.icons", opts = {} } },
        opts = {},
    },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "go", "html" },
                sync_install = false,
                auto_install = true,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
            })
        end,
    },

    -- Completion
    { "nvim-lua/plenary.nvim" },
    { "nvim-lua/popup.nvim" },
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/vim-vsnip" },
    { "hrsh7th/cmp-vsnip" },
    { "hrsh7th/cmp-nvim-lsp" },

    -- Copilot
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        config = function() require("CopilotChat").setup({}) end,
    },

    -- AI completion
    {
        "supermaven-inc/supermaven-nvim",
        config = function()
            require("supermaven-nvim").setup({
                keymaps = {
                    accept_suggestion = "<Tab>",
                    clear_suggestion  = "<C-]>",
                    accept_word       = "<C-j>",
                },
                ignore_filetypes = { cpp = true },
                color = { suggestion_color = "#ffffff", cterm = 244 },
                log_level = "info",
                disable_inline_completion = false,
                disable_keymaps = false,
                condition = function() return false end,
            })
        end,
    },

    -- Leetcode
    {
        "kawre/leetcode.nvim",
        build = ":TSUpdate html",
        dependencies = {
            "ibhagwan/fzf-lua",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
        },
        opts = { lang = "kotlin" },
    },

    -- ThePrimeagen/99
    {
        "ThePrimeagen/99",
        config = function()
            local _99 = require("99")
            local cwd = vim.uv.cwd()
            local basename = vim.fs.basename(cwd)
            _99.setup({
                logger = {
                    level = _99.DEBUG,
                    path = "/tmp/" .. basename .. ".99.debug",
                    print_on_error = true,
                },
                completion = { source = "cmp" },
            })
            vim.keymap.set("n", "<leader>9f", function() _99.fill_in_function() end)
            vim.keymap.set("v", "<leader>9v", function() _99.visual() end)
            vim.keymap.set("v", "<leader>9s", function() _99.stop_all_requests() end)
        end,
    },

}})

-- Completion setup
local cmp = require("cmp")
local lspkind = require("lspkind")
cmp.setup({
    preselect = cmp.PreselectMode.None,
    snippet = {
        expand = function(args) vim.fn["vsnip#anonymous"](args.body) end,
    },
    formatting = {
        format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "…",
        }),
    },
    window = {
        completion  = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    mapping = {
        ["<C-p>"]     = cmp.mapping.select_prev_item(),
        ["<C-n>"]     = cmp.mapping.select_next_item(),
        ["<S-Tab>"]   = cmp.mapping.select_prev_item(),
        ["<Tab>"]     = cmp.mapping.select_next_item(),
        ["<C-d>"]     = cmp.mapping.scroll_docs(-4),
        ["<C-f>"]     = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"]     = cmp.mapping.close(),
        ["<CR>"]      = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),
    },
    sources = {
        { name = "supermaven" },
        { name = "nvim_lsp" },
        { name = "vsnip" },
        { name = "path" },
        { name = "buffer" },
    },
})

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*.kt",
    callback = function() end,
})
