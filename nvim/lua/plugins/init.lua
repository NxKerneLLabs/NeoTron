require("lazy").setup({
    -- Core
    { "nvim-lua/plenary.nvim" },

    -- File Explorer
    { "nvim-tree/nvim-tree.lua" },

    -- Telescope FZF
    { "nvim-telescope/telescope.nvim", tag = "0.1.4" },

    -- Treesitter
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

    -- LSP
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },

    -- Autocomplete
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "L3MON4D3/LuaSnip" },
    { "saadparwaiz1/cmp_luasnip" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },

    -- Formatter e Linter
    { "jose-elias-alvarez/null-ls.nvim" },

    -- Debugger
    { "mfussenegger/nvim-dap" },
    { "rcarriga/nvim-dap-ui" },

    -- Git
    { "lewis6991/gitsigns.nvim" },

    -- UI e Temas
    { "nvim-lualine/lualine.nvim" },
    { "catppuccin/nvim", name = "catppuccin" },
})

