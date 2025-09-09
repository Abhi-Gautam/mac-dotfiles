# Mac Mini Development Environment Migration

This package contains all your development environment configurations from your MacBook Pro, ready to be transferred to your new Mac Mini.

## Contents

```
mac-mini-migration/
├── configs/              # All configuration files
│   ├── zsh/             # Zsh, Oh My Zsh, P10k configs
│   ├── tmux/            # Tmux configuration
│   ├── git/             # Git configuration
│   ├── terminal/        # Terminal configs (Ghostty preferences)
│   ├── vscode/          # VS Code settings and keybindings
│   ├── intellij/        # IntelliJ IDEA color schemes and options
│   └── local/bin/       # Local bin environment
├── oh-my-zsh-plugins/   # Custom Oh My Zsh plugins
├── tmux-plugins/        # Tmux plugin manager
├── Brewfile             # Homebrew packages list
├── setup.sh             # Automated setup script
└── README.md            # This file
```

## Quick Start

### On your new Mac Mini:

1. **Transfer this folder** to your new Mac Mini (via AirDrop, USB, or cloud storage)

2. **Open Terminal** and navigate to the migration folder:
   ```bash
   cd ~/mac-mini-migration
   ```

3. **Run the setup script**:
   ```bash
   ./setup.sh
   ```

The script will automatically:
- Install Xcode Command Line Tools
- Install Homebrew
- Install all your CLI tools and applications
- Set up Oh My Zsh with Powerlevel10k theme
- Install your custom plugins
- Copy all configuration files
- Set up tmux with plugins
- Install NVM and Node.js
- Configure macOS settings

## Manual Steps After Setup

### 1. SSH Keys
Transfer your SSH keys from `~/.ssh/` on your old Mac:
```bash
# On old Mac
cp -r ~/.ssh ~/mac-mini-migration/ssh-backup

# On new Mac (after transferring)
cp -r ~/mac-mini-migration/ssh-backup/* ~/.ssh/
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub
```

### 2. Application Settings
The setup script will install and configure:
- **VS Code**: Settings, themes, and keybindings automatically restored
- **IntelliJ IDEA CE**: Color schemes and editor options restored
- **Ghostty**: Terminal preferences restored
- **Postman**: Application installed (manual sign-in required)

Additional manual setup:
- **Docker Desktop**: Sign in and configure resources  
- **Android Studio**: Import any additional settings if needed

### Manual Downloads Needed:
These apps aren't available via Homebrew and need manual download:
- **Magnet**: Window management tool - [Download from Mac App Store](https://apps.apple.com/us/app/magnet/id441258766)
- **Mac Whisper**: AI transcription app - [Download from Mac App Store](https://apps.apple.com/us/app/mac-whisper/id1660757625)
- **Zed**: Modern code editor - [Download from zed.dev](https://zed.dev)
- **Raycast**: Spotlight replacement - [Download from raycast.com](https://raycast.com)

### 3. Cloud Services
Sign in to:
- GitHub CLI: `gh auth login`
- Git credentials: Your commits are already configured
- Cloud storage services

### 4. Development Projects
Transfer your project folders:
- System Design Projects
- ai-agents
- lld-projects
- Neotrix
- Any other work directories

## Included Tools

### Shell & Terminal
- Zsh with Oh My Zsh
- Powerlevel10k theme
- Plugins: git, zsh-syntax-highlighting, zsh-autosuggestions, fzf
- tmux with vim navigation, session management, and Tokyo Night theme

### CLI Utilities
- **Search & Navigation**: fzf, ripgrep, fd, zoxide, yazi
- **Git Tools**: gh, lazygit
- **Container Tools**: Docker, lazydocker
- **File Tools**: eza (better ls), bat (better cat), tree
- **Development**: neovim, tmux

### GUI Applications
- **Editors/IDEs**: VS Code, IntelliJ IDEA Community Edition
- **Terminal**: Ghostty
- **API Development**: Postman
- **Mobile Development**: Android Studio
- **Containerization**: Docker Desktop

### Programming Languages
- Python (3.10, 3.11, 3.13)
- Node.js (Latest LTS via NVM)
- Java 8 (1.8.0_202)
- Go, Rust
- Elixir/Erlang

### NPM Global Packages
- Angular CLI v19.2.7
- Claude Code v1.0.69
- Gemini CLI v0.1.2
- MCP Server GitHub v2025.4.8
- Task Master AI v0.16.2

## Troubleshooting

### If Homebrew installation fails on Apple Silicon:
```bash
# Add Homebrew to PATH manually
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### If tmux plugins don't install:
```bash
# Manual installation
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# Then in tmux, press: prefix + I
```

### If zsh is not the default shell:
```bash
chsh -s $(which zsh)
```

## Verification

After setup, verify everything works:
```bash
# Check shell
echo $SHELL  # Should show /bin/zsh

# Check tools
brew list
tmux -V
node --version
git --version
```

## Your Previous Setup Details

- **Shell**: Zsh 5.9 with Oh My Zsh
- **Theme**: Powerlevel10k (Rainbow style)
- **Terminal Font**: MesloLGS Nerd Font Mono
- **Key Tools**: 200+ Homebrew packages installed
- **Node**: Latest LTS via NVM
- **Angular**: CLI v19.2.7
- **Java**: Version 8 (1.8.0_202)
- **Python**: Multiple versions (3.10, 3.11, 3.13) via Homebrew
- **VS Code**: Catppuccin Frappé theme, custom settings restored

### Manual Apps to Download:
- **Magnet**, **Mac Whisper**, **Zed**, **Raycast** (see Manual Downloads section above)

Enjoy your new development environment! 🚀