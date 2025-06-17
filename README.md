# NeoTron

This repository contains my personal Neovim configuration and infrastructure code.

## Repository Structure

```
.
├── nvim/           # Neovim configuration
│   ├── init.lua    # Main Neovim configuration
│   └── lua/        # Lua modules and plugins
│       ├── core/   # Core Neovim settings
│       ├── plugins/# Plugin configurations
│       └── themes/ # Theme configurations
│
├── infra/          # Infrastructure as Code
│   ├── modules/    # Terraform modules
│   ├── *.tf        # Terraform configuration files
│   └── scripts/    # Infrastructure scripts
│
└── scripts/        # General utility scripts
```

## Neovim Setup

1. Install Neovim (v0.9.0 or later)
2. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/NeoTron.git ~/.config/nvim
   ```
3. Start Neovim and let it install plugins:
   ```bash
   nvim
   ```

## Infrastructure Setup

1. Install Terraform
2. Navigate to the infra directory:
   ```bash
   cd infra
   ```
3. Initialize Terraform:
   ```bash
   terraform init
   ```

## Features

### Neovim Configuration
- Modern plugin management with lazy.nvim
- Optimized startup time
- Comprehensive plugin setup
- Custom keymaps and commands

### Infrastructure
- Modular Terraform configuration
- Reusable infrastructure components
- Automated deployment scripts

## Contributing

Feel free to submit issues and enhancement requests!

## License

[MIT]
