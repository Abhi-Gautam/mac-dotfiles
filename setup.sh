#!/bin/bash

# Mac Mini Development Environment Setup Script
# This script will set up your complete development environment

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}➜${NC} $1"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS only"
    exit 1
fi

print_info "Starting Mac Mini Development Environment Setup..."

# 1. Install Xcode Command Line Tools
if ! xcode-select -p &> /dev/null; then
    print_info "Installing Xcode Command Line Tools..."
    xcode-select --install
    # Wait for installation
    until xcode-select -p &> /dev/null; do
        sleep 5
    done
    print_success "Xcode Command Line Tools installed"
else
    print_success "Xcode Command Line Tools already installed"
fi

# 2. Install Homebrew
if ! command -v brew &> /dev/null; then
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
    print_success "Homebrew installed"
else
    print_success "Homebrew already installed"
fi

# 3. Install packages from Brewfile
print_info "Installing Homebrew packages..."
brew bundle --file=Brewfile
print_success "Homebrew packages installed"

# 4. Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "Oh My Zsh installed"
else
    print_success "Oh My Zsh already installed"
fi

# 5. Install Powerlevel10k theme
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    print_info "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    print_success "Powerlevel10k installed"
else
    print_success "Powerlevel10k already installed"
fi

# 6. Copy Oh My Zsh custom plugins
print_info "Installing Oh My Zsh custom plugins..."
cp -r oh-my-zsh-plugins/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/
cp -r oh-my-zsh-plugins/zsh-syntax-highlighting ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/
print_success "Oh My Zsh plugins installed"

# 7. Install NVM (Node Version Manager)
if [ ! -d "$HOME/.nvm" ]; then
    print_info "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    
    # Load NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # Install latest LTS Node
    nvm install --lts
    nvm use --lts
    nvm alias default 'lts/*'
    print_success "NVM and Node.js LTS installed"
else
    print_success "NVM already installed"
    # Load NVM and install Node LTS
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm use --lts
    nvm alias default 'lts/*'
fi

# 7a. Install global npm packages
print_info "Installing global npm packages..."
npm install -g @angular/cli@19.2.7
npm install -g @anthropic-ai/claude-code@1.0.69
npm install -g @google/gemini-cli@0.1.2
npm install -g @modelcontextprotocol/server-github@2025.4.8
npm install -g task-master-ai@0.16.2
print_success "Global npm packages installed"

# 7b. Configure Java 8
print_info "Configuring Java 8..."
# Set JAVA_HOME for Java 8
echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)' >> ~/.zshrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.zshrc
print_success "Java 8 configured"

# 8. Install tmux plugin manager
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    print_info "Installing tmux plugin manager..."
    cp -r tmux-plugins/tpm ~/.tmux/plugins/
    print_success "TPM installed"
else
    print_success "TPM already installed"
fi

# 9. Create necessary directories
print_info "Creating necessary directories..."
mkdir -p ~/.local/bin
mkdir -p ~/.config

# 10. Copy configuration files
print_info "Copying configuration files..."

# Backup existing configs if they exist
if [ -f ~/.zshrc ]; then
    cp ~/.zshrc ~/.zshrc.backup
fi
if [ -f ~/.tmux.conf ]; then
    cp ~/.tmux.conf ~/.tmux.conf.backup
fi

# Copy zsh configs
cp configs/zsh/.zshrc ~/
cp configs/zsh/.p10k.zsh ~/
cp configs/zsh/.fzf.zsh ~/
cp configs/zsh/.zhistory ~/

# Copy tmux config
cp configs/tmux/.tmux.conf ~/

# Copy git config
cp configs/git/.gitconfig ~/

# Copy terminal configs (if any exist)
# Note: Terminal configs removed as not in use

# Copy local bin env
cp configs/local/bin/env ~/.local/bin/

# Copy application settings
print_info "Copying application settings..."

# VS Code settings
mkdir -p ~/Library/Application\ Support/Code/User
cp configs/vscode/settings.json ~/Library/Application\ Support/Code/User/ 2>/dev/null || echo "No VS Code settings to copy"
cp configs/vscode/keybindings.json ~/Library/Application\ Support/Code/User/ 2>/dev/null || echo "No VS Code keybindings to copy"

# IntelliJ settings
mkdir -p ~/Library/Application\ Support/JetBrains/IdeaIC2023.3
cp -r configs/intellij/colors ~/Library/Application\ Support/JetBrains/IdeaIC2023.3/ 2>/dev/null || echo "No IntelliJ colors to copy"
cp -r configs/intellij/options ~/Library/Application\ Support/JetBrains/IdeaIC2023.3/ 2>/dev/null || echo "No IntelliJ options to copy"

# Ghostty settings
cp configs/terminal/com.mitchellh.ghostty.plist ~/Library/Preferences/ 2>/dev/null || echo "No Ghostty settings to copy"

print_success "Configuration files copied"

# 11. Install tmux plugins
print_info "Installing tmux plugins..."
~/.tmux/plugins/tpm/bin/install_plugins
print_success "Tmux plugins installed"

# 12. Install Flutter (if needed)
if [ ! -d "$HOME/flutter" ]; then
    print_info "Flutter not found. Would you like to install Flutter? (y/n)"
    read -r response
    if [[ "$response" == "y" ]]; then
        git clone https://github.com/flutter/flutter.git -b stable ~/flutter
        print_success "Flutter installed"
    fi
fi

# 13. Setup FZF key bindings
print_info "Setting up FZF..."
$(brew --prefix)/opt/fzf/install --all --no-bash --no-fish
print_success "FZF configured"

# 14. Additional macOS settings
print_info "Applying macOS settings..."

# Show hidden files in Finder
defaults write com.apple.finder AppleShowAllFiles -bool true

# Enable key repeat
defaults write -g ApplePressAndHoldEnabled -bool false

# Faster key repeat
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

killall Finder

print_success "macOS settings applied"

# 15. Create a summary file
cat > ~/mac-mini-migration/SETUP_COMPLETE.md << EOF
# Development Environment Setup Complete!

## Installed Components:
- ✓ Homebrew and all packages
- ✓ Oh My Zsh with Powerlevel10k theme
- ✓ Custom zsh plugins (autosuggestions, syntax highlighting)
- ✓ tmux with plugin manager and plugins
- ✓ NVM with latest Node.js LTS
- ✓ All configuration files

## Next Steps:
1. Restart your terminal or run: source ~/.zshrc
2. Open tmux and press \`prefix + I\` to install plugins
3. Configure p10k if prompted: p10k configure
4. Set up Docker Desktop from Applications
5. Sign in to GitHub CLI: gh auth login

## Manual Installations Required:
- Ghostty (if you use it) - Settings stored in macOS preferences
- Any private SSH keys and configs
- Application-specific settings

## Backup Locations:
- Original .zshrc backed up to ~/.zshrc.backup
- Original .tmux.conf backed up to ~/.tmux.conf.backup

Enjoy your new development environment!
EOF

print_success "Setup complete! Check ~/mac-mini-migration/SETUP_COMPLETE.md for details"
print_info "Please restart your terminal or run: source ~/.zshrc"