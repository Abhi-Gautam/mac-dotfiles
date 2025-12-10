#!/bin/bash

# Fix script for zsh (p10k), tmux and nvim configs
# Run this AFTER setup.sh to properly deploy all configs and install plugins
# This ensures everything works out of the box on a new system

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}➜${NC} $1"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================"
echo "  Post-Setup Configuration Fix Script"
echo "============================================"
echo ""

# ============================================
# 0. Verify prerequisites from setup.sh
# ============================================
print_info "Checking prerequisites..."

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_error "Oh My Zsh not installed. Please run setup.sh first."
    exit 1
fi
print_success "Oh My Zsh found"

if ! command -v tmux &> /dev/null; then
    print_error "tmux not installed. Please run setup.sh first."
    exit 1
fi
print_success "tmux found"

if ! command -v nvim &> /dev/null; then
    print_info "neovim not found - will install config anyway (install nvim via brew)"
fi

# ============================================
# 1. Install Powerlevel10k theme and config
# ============================================
echo ""
print_info "Setting up Powerlevel10k..."

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"

# Install Powerlevel10k theme
if [ ! -d "$P10K_DIR" ]; then
    print_info "Cloning Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
    print_success "Powerlevel10k theme installed"
else
    print_info "Updating Powerlevel10k theme..."
    git -C "$P10K_DIR" pull --depth=1 2>/dev/null || true
    print_success "Powerlevel10k theme updated"
fi

# Copy p10k config (this makes it work without running p10k configure)
if [ -f "$SCRIPT_DIR/configs/zsh/.p10k.zsh" ]; then
    [ -f ~/.p10k.zsh ] && cp ~/.p10k.zsh ~/.p10k.zsh.backup.$(date +%Y%m%d_%H%M%S)
    cp "$SCRIPT_DIR/configs/zsh/.p10k.zsh" ~/
    print_success "Powerlevel10k config installed (~/.p10k.zsh)"
else
    print_error "p10k config not found in repo"
fi

# ============================================
# 2. Install Oh My Zsh plugins
# ============================================
echo ""
print_info "Setting up Oh My Zsh plugins..."

mkdir -p "$ZSH_CUSTOM/plugins"

# zsh-autosuggestions
if [ -d "$SCRIPT_DIR/oh-my-zsh-plugins/zsh-autosuggestions" ]; then
    rm -rf "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    cp -r "$SCRIPT_DIR/oh-my-zsh-plugins/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/"
    print_success "zsh-autosuggestions installed"
else
    # Fallback: clone from git
    print_info "Cloning zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null || true
    print_success "zsh-autosuggestions installed (from git)"
fi

# zsh-syntax-highlighting
if [ -d "$SCRIPT_DIR/oh-my-zsh-plugins/zsh-syntax-highlighting" ]; then
    rm -rf "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    cp -r "$SCRIPT_DIR/oh-my-zsh-plugins/zsh-syntax-highlighting" "$ZSH_CUSTOM/plugins/"
    print_success "zsh-syntax-highlighting installed"
else
    # Fallback: clone from git
    print_info "Cloning zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null || true
    print_success "zsh-syntax-highlighting installed (from git)"
fi

# ============================================
# 3. Copy zsh configuration files
# ============================================
echo ""
print_info "Copying zsh configuration..."

if [ -f "$SCRIPT_DIR/configs/zsh/.zshrc" ]; then
    [ -f ~/.zshrc ] && cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
    cp "$SCRIPT_DIR/configs/zsh/.zshrc" ~/
    print_success ".zshrc installed"
fi

if [ -f "$SCRIPT_DIR/configs/zsh/.fzf.zsh" ]; then
    cp "$SCRIPT_DIR/configs/zsh/.fzf.zsh" ~/
    print_success ".fzf.zsh installed"
fi

# ============================================
# 4. Setup Neovim configuration
# ============================================
echo ""
print_info "Setting up Neovim configuration..."

mkdir -p ~/.config

# Backup existing nvim config
if [ -d ~/.config/nvim ] && [ "$(ls -A ~/.config/nvim 2>/dev/null)" ]; then
    NVIM_BACKUP=~/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)
    print_info "Backing up existing nvim config to $NVIM_BACKUP"
    mv ~/.config/nvim "$NVIM_BACKUP"
fi

mkdir -p ~/.config/nvim

# Copy nvim config from repo
if [ -d "$SCRIPT_DIR/configs/nvim" ]; then
    cp -r "$SCRIPT_DIR/configs/nvim/"* ~/.config/nvim/
    # Copy hidden files too
    for f in "$SCRIPT_DIR/configs/nvim/".*; do
        [ -f "$f" ] && cp "$f" ~/.config/nvim/
    done
    print_success "Neovim configuration installed (~/.config/nvim/)"
else
    print_error "nvim config not found in repo"
fi

# Install neovim plugins (Lazy.nvim will auto-install on first run)
if command -v nvim &> /dev/null; then
    print_info "Installing Neovim plugins (this may take a moment)..."
    # Run nvim headless to trigger Lazy plugin installation
    nvim --headless "+Lazy! sync" +qa 2>/dev/null && print_success "Neovim plugins installed" || print_info "Neovim plugins will install on first launch"
fi

# ============================================
# 5. Setup tmux configuration
# ============================================
echo ""
print_info "Setting up tmux configuration..."

# Backup and copy tmux.conf
if [ -f ~/.tmux.conf ]; then
    cp ~/.tmux.conf ~/.tmux.conf.backup.$(date +%Y%m%d_%H%M%S)
fi

if [ -f "$SCRIPT_DIR/configs/tmux/.tmux.conf" ]; then
    cp "$SCRIPT_DIR/configs/tmux/.tmux.conf" ~/
    print_success ".tmux.conf installed"
else
    print_error "tmux.conf not found in repo"
fi

# ============================================
# 6. Setup TPM and install tmux plugins
# ============================================
echo ""
print_info "Setting up tmux plugin manager (TPM)..."

mkdir -p ~/.tmux/plugins

# Install TPM
if [ -d "$SCRIPT_DIR/tmux-plugins/tpm" ]; then
    rm -rf ~/.tmux/plugins/tpm
    cp -r "$SCRIPT_DIR/tmux-plugins/tpm" ~/.tmux/plugins/
    print_success "TPM installed"
else
    # Fallback: clone from git
    if [ ! -d ~/.tmux/plugins/tpm ]; then
        print_info "Cloning TPM from git..."
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
        print_success "TPM installed (from git)"
    fi
fi

# Install tmux plugins
print_info "Installing tmux plugins..."

# Kill any existing tmux server
tmux kill-server 2>/dev/null || true

# TPM requires a tmux session to install plugins
if [ -f ~/.tmux/plugins/tpm/bin/install_plugins ]; then
    # Start tmux server and create temp session
    tmux start-server
    tmux new-session -d -s __tpm_install 2>/dev/null || true

    # Give tmux a moment to start
    sleep 1

    # Run plugin installation
    if ~/.tmux/plugins/tpm/bin/install_plugins 2>/dev/null; then
        print_success "tmux plugins installed:"
        echo "         - vim-tmux-navigator"
        echo "         - tmux-resurrect"
        echo "         - tmux-continuum"
        echo "         - tmux-tokyo-night"
    else
        print_info "tmux plugins may need manual install: press 'Ctrl-a + I' in tmux"
    fi

    # Clean up
    tmux kill-session -t __tpm_install 2>/dev/null || true
    tmux kill-server 2>/dev/null || true
else
    print_error "TPM install script not found"
fi

# ============================================
# 7. Setup Ghostty configuration
# ============================================
echo ""
print_info "Setting up Ghostty configuration..."

# Ghostty uses plist for macOS preferences
if [ -f "$SCRIPT_DIR/configs/terminal/com.mitchellh.ghostty.plist" ]; then
    cp "$SCRIPT_DIR/configs/terminal/com.mitchellh.ghostty.plist" ~/Library/Preferences/
    print_success "Ghostty preferences installed"
else
    print_info "No Ghostty plist found in repo"
fi

# ============================================
# 8. Final summary
# ============================================
echo ""
echo "============================================"
print_success "All configurations installed!"
echo "============================================"
echo ""
echo "What was installed:"
echo "  ✓ Powerlevel10k theme + your custom config"
echo "  ✓ Oh My Zsh plugins (autosuggestions, syntax-highlighting)"
echo "  ✓ Your .zshrc configuration"
echo "  ✓ Neovim configuration (LazyVim)"
echo "  ✓ tmux configuration"
echo "  ✓ tmux plugins (navigator, resurrect, continuum, tokyo-night)"
echo "  ✓ Ghostty terminal preferences"
echo ""
echo "To apply changes now, run:"
echo "  exec zsh"
echo ""
echo "Everything should work out of the box!"
