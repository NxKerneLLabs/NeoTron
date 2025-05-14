nvim/
├── init.lua                      # Entry point with lazy.nvim bootstrap
├── lazy-lock.json                # Plugin lockfile
├── lua/
│   ├── core/                     # Core Neovim settings
│   │   ├── init.lua              # Core module entry
│   │   ├── options.lua           # Global editor options
│   │   ├── autocmds.lua          # Automated commands
│   │   ├── debug.lua             # Enhanced debugging with profiling
│   │   └── keymaps.lua           # Central keymap loader
│   ├── ui/                       # UI and visual elements
│   │   ├── theme.lua             # Theme (tokyonight) customization
│   │   ├── statusline.lua        # Lualine configuration
│   │   ├── dashboard.lua         # Alpha-nvim dashboard
│   │   ├── notify.lua            # Styled notifications
│   │   └── misc.lua              # Indent guides, dressing, etc.
│   ├── plugins/                  # Plugin specifications and configs
│   │   ├── init.lua              # Central plugin loader with lazy.nvim
│   │   ├── lsp.lua               # LSP configurations
│   │   ├── mcp.lua               # MCP protocols and server integrations
│   │   ├── ai.lua                # AI and LLM integrations
│   │   ├── completion.lua        # nvim-cmp and snippet setup
│   │   ├── git.lua               # Git tools (gitsigns, fugitive, etc.)
│   │   ├── debug.lua             # DAP and debugging tools
│   │   ├── navigation.lua        # Telescope, project.nvim, etc.
│   │   ├── explorer.lua          # File explorer ( neo-tree/nvim-tree)
│   │   ├── terminal.lua          # Terminal integration (toggleterm)
│   │   ├── treesitter.lua        # Syntax highlighting and code manipulation
│   │   └── tools.lua             # Miscellaneous tools (vim-surround, commentary)
│   ├── keymaps/                  # Modular keymap definitions
│   │   ├── init.lua              # Central keymap loader
│   │   ├── general.lua           # General editor keymaps
│   │   ├── lsp.lua               # LSP-specific keymaps
│   │   ├── ai.lua                # AI and completion keymaps
│   │   ├── git.lua               # Git-related keymaps
│   │   ├── debug.lua             # Debugging keymaps
│   │   ├── navigation.lua        # Navigation and search keymaps
│   │   └── whichkey.lua          # Which-key UI and grouped mappings
│   ├── functions/                # Utility functions for keymaps and plugins
│   │   ├── init.lua              # Utility loader
│   │   ├── cmp.lua               # Completion utilities
│   │   ├── copilot.lua           # AI assistant utilities
│   │   ├── dap.lua               # Debugging utilities
│   │   ├── git.lua               # Git operation utilities
│   │   └── telescope.lua         # Navigation and search utilities
│   ├── config/                   # Environment and technology-specific configs
│   │   ├── cloud.lua             # Cloud (Azure, AWS) integrations
│   │   ├── docker.lua            # Docker container support
│   │   ├── kubernetes.lua        # Kubernetes cluster management
│   │   └── security.lua          # Security settings (mTLS, SPIFFE)
│   ├── mcp/                      # MCP server protocols and agents
│   │   ├── init.lua              # MCP module entry
│   │   ├── agents.lua            # Inline MCP agents for AI/LLM
│   │   └── servers.lua           # MCP server configurations
│   └── utils/                    # Shared utilities and helpers
│       ├── init.lua              # Utility loader
│       └── icons.lua             # Icon definitions for UI
├── snippets/                     # Custom snippets for LuaSnip
└── templates/                    # File templates for new projects

