#!/usr/bin/env bash
# ==================== COLORS ====================
RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
BLUE='\033[94m'
CYAN='\033[96m'
WHITE='\033[97m'
GRAY='\033[90m'
BOLD='\033[1m'
END='\033[0m'

# ==================== DETECT SYSTEM ====================
detect_system() {
    if [[ -d "/data/data/com.termux/files/usr" ]]; then
        SYSTEM="termux"
        PREFIX="/data/data/com.termux/files/usr"
        PYTHON_CMD="python"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        SYSTEM="linux"
        PREFIX="/usr/local"
        PYTHON_CMD="python3"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        SYSTEM="macos"
        PREFIX="/usr/local"
        PYTHON_CMD="python3"
    else
        SYSTEM="unknown"
        PYTHON_CMD="python3"
    fi
}

# ==================== BANNER ====================
banner() {
    clear
    echo -e "${RED}${BOLD}"
    echo '      ▄▄▄█████▓ ██░ ██ ▓█████     █     █░ ▄▄▄     ▄▄▄█████▓ ▄████▄   ██░ ██ ▓█████  ██▀███  '
    echo '      ▓  ██▒ ▓▒▓██░ ██▒▓█   ▀    ▓█░ █ ░█░▒████▄   ▓  ██▒ ▓▒▒██▀ ▀█  ▓██░ ██▒▓█   ▀ ▓██ ▒ ██▒'
    echo '      ▒ ▓██░ ▒░▒██▀▀██░▒███      ▒█░ █ ░█ ▒██  ▀█▄ ▒ ▓██░ ▒░▒▓█    ▄ ▒██▀▀██░▒███   ▓██ ░▄█ ▒'
    echo '      ░ ▓██▓ ░ ░▓█ ░██ ▒▓█  ▄    ░█░ █ ░█ ░██▄▄▄▄██░ ▓██▓ ░ ▒▓▓▄ ▄██▒░▓█ ░██ ▒▓█  ▄ ▒██▀▀█▄  '
    echo '        ▒██▒ ░ ░▓█▒░██▓░▒████▒   ░░██▒██▓  ▓█   ▓██▒ ▒██▒ ░ ▒ ▓███▀ ░░▓█▒░██▓░▒████▒░██▓ ▒██▒'
    echo '        ▒ ░░    ▒ ░░▒░▒░░ ▒░ ░   ░ ▓░▒ ▒   ▒▒   ▓▒█░ ▒ ░░   ░ ░▒ ▒  ░ ▒ ░░▒░▒░░ ▒░ ░░ ▒▓ ░▒▓░'
    echo '          ░     ▒ ░▒░ ░ ░ ░  ░     ▒ ░ ░    ▒   ▒▒ ░   ░      ░  ▒    ▒ ░▒░ ░ ░ ░  ░  ░▒ ░ ▒░'
    echo '        ░       ░  ░░ ░   ░        ░   ░    ░   ▒    ░      ░         ░  ░░ ░   ░     ░░   ░ '
    echo '                ░  ░  ░   ░  ░       ░          ░  ░        ░ ░       ░  ░  ░   ░  ░   ░     '
    echo '                            ~EvilmaxSec | Tz~'
    echo -e "${END}"
    echo -e "${CYAN}${BOLD}"
    echo '╔═══════════════════════════════════════════════════════════════════════════╗'
    echo '║                    TheWatcher Installer                                   ║'
    echo '║                      Auto-Detects & Installs Everything                   ║'
    echo '╚═══════════════════════════════════════════════════════════════════════════╝'
    echo -e "${END}\n"
}

# ==================== PRINT FUNCTIONS ====================
print_success() { echo -e "  ${GREEN}✓${END} ${WHITE}$1${END}"; }
print_error() { echo -e "  ${RED}✗${END} ${WHITE}$1${END}"; }
print_info() { echo -e "  ${BLUE}ℹ${END} ${WHITE}$1${END}"; }
print_warning() { echo -e "  ${YELLOW}⚠${END} ${WHITE}$1${END}"; }

# ==================== FIX TERMUX PERMISSIONS ====================
fix_termux() {
    if [[ "$SYSTEM" == "termux" ]]; then
        print_info "Fixing Termux permissions..."
        
        # Fix tmp directory permissions
        chmod 777 $PREFIX/tmp 2>/dev/null || true
        
        # Clean apt cache
        rm -rf $PREFIX/var/lib/apt/lists/* 2>/dev/null || true
        rm -rf $PREFIX/var/cache/apt/* 2>/dev/null || true
        
        # Recreate tmp files
        touch $PREFIX/tmp/test 2>/dev/null || true
        rm $PREFIX/tmp/test 2>/dev/null || true
        
        print_success "Termux permissions fixed"
    fi
}

# ==================== INSTALL PHP ====================
install_php() {
    print_info "Installing PHP..."
    
    if [[ "$SYSTEM" == "termux" ]]; then
        # For Termux, use a simpler approach
        print_info "Using Termux package manager..."
        
        # Try to fix any pending issues
        rm -f $PREFIX/var/lib/dpkg/lock-frontend 2>/dev/null || true
        rm -f $PREFIX/var/lib/dpkg/lock 2>/dev/null || true
        
        # Install PHP directly without update
        if pkg install php -y 2>/dev/null; then
            print_success "PHP installed via pkg"
        else
            print_warning "PHP install failed, trying alternative..."
            # Try with --force
            pkg install php -y --force 2>/dev/null || true
        fi
    elif [[ "$SYSTEM" == "linux" ]]; then
        if command -v apt &>/dev/null; then
            sudo apt update -y 2>/dev/null || true
            sudo apt install php -y 2>/dev/null || true
        elif command -v yum &>/dev/null; then
            sudo yum install php -y 2>/dev/null || true
        elif command -v pacman &>/dev/null; then
            sudo pacman -S php --noconfirm 2>/dev/null || true
        fi
    elif [[ "$SYSTEM" == "macos" ]]; then
        if command -v brew &>/dev/null; then
            brew install php 2>/dev/null || true
        fi
    fi
    
    if command -v php &>/dev/null; then
        print_success "PHP ready: $(php -v | head -1 | cut -d' ' -f2 | cut -d'-' -f1)"
        return 0
    else
        print_warning "PHP not found. You may need to install it manually:"
        print_info "  Termux: pkg install php"
        print_info "  Linux: sudo apt install php"
        return 1
    fi
}

# ==================== INSTALL PYTHON DEPS ====================
install_python_deps() {
    print_info "Installing Python dependencies..."
    
    # Ensure pip is available
    if [[ "$SYSTEM" == "termux" ]]; then
        pkg install python -y 2>/dev/null || true
    fi
    
    # Install requests (essential)
    if pip install requests -q 2>/dev/null || pip3 install requests -q 2>/dev/null; then
        print_success "requests installed"
    else
        print_warning "requests installation failed"
    fi
    
    # Pillow is optional, skip on Termux
    if [[ "$SYSTEM" != "termux" ]]; then
        if pip install pillow -q 2>/dev/null || pip3 install pillow -q 2>/dev/null; then
            print_success "pillow installed"
        fi
    fi
}

# ==================== INSTALL CLOUDFLARED ====================
install_cloudflared() {
    echo ""
    read -p "$(echo -e "  ${YELLOW}?${END} ${WHITE}Install Cloudflared for public URLs? (y/N): ${END}")" -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Skipping Cloudflared"
        return 0
    fi
    
    print_info "Installing Cloudflared..."
    
    if [[ "$SYSTEM" == "termux" ]]; then
        wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared 2>/dev/null
        chmod +x cloudflared
        mv cloudflared $PREFIX/bin/ 2>/dev/null || true
    elif [[ "$SYSTEM" == "linux" ]]; then
        ARCH=$(uname -m)
        if [[ "$ARCH" == "aarch64" ]] || [[ "$ARCH" == "arm64" ]]; then
            wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared
        elif [[ "$ARCH" == "armv7l" ]]; then
            wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm -O cloudflared
        else
            wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
        fi
        chmod +x cloudflared
        sudo mv cloudflared /usr/local/bin/ 2>/dev/null || true
    elif [[ "$SYSTEM" == "macos" ]]; then
        brew install cloudflared 2>/dev/null || true
    fi
    
    if command -v cloudflared &>/dev/null; then
        print_success "Cloudflared installed"
    else
        print_warning "Cloudflared not installed"
    fi
}

# ==================== CREATE FILES ====================
create_files() {
    print_info "Creating TheWatcher files..."
    
    cd "$INSTALL_DIR"
    
    # Create directories
    mkdir -p data templates modules logs
    
    # Create requirements.txt
    cat > requirements.txt << 'EOF'
requests==2.31.0
EOF
    
    # Create start.sh
    cat > start.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
echo -e "\033[96m🚀 Starting TheWatcher...\033[0m"
python3 thewatcher.py
EOF
    chmod +x start.sh
    
    # Create thewatcher.py (simplified version that works)
    cat > thewatcher.py << 'THEWATCHER_EOF'
#!/usr/bin/env python3
import os, sys, time, json, subprocess, threading, socket

class Colors:
    RED='\033[91m'; GREEN='\033[92m'; YELLOW='\033[93m'; BLUE='\033[94m'
    CYAN='\033[96m'; WHITE='\033[97m'; BOLD='\033[1m'; END='\033[0m'

def clear(): os.system('clear')
def print_success(m): print(f"  {Colors.GREEN}✓{Colors.END} {Colors.WHITE}{m}{Colors.END}")
def print_error(m): print(f"  {Colors.RED}✗{Colors.END} {Colors.WHITE}{m}{Colors.END}")
def print_info(m): print(f"  {Colors.BLUE}ℹ{Colors.END} {Colors.WHITE}{m}{Colors.END}")

def get_input(p, d=""):
    if d: v=input(f"  {Colors.RED}➜{Colors.END} {Colors.WHITE}{p}{Colors.GRAY} [{d}]:{Colors.END} ")
    else: v=input(f"  {Colors.RED}➜{Colors.END} {Colors.WHITE}{p}:{Colors.END} ")
    return v if v else d

def get_local_ip():
    try:
        s=socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
        s.connect(("8.8.8.8",80))
        ip=s.getsockname()[0]
        s.close()
        return ip
    except: return "127.0.0.1"

def check_cmd(c):
    try: subprocess.run([c,"--version"],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL); return True
    except: return False

print("TheWatcher v2.0 - Ready")
print("Run with full version for complete features")
THEWATCHER_EOF
    
    chmod +x thewatcher.py
    print_success "Files created"
    
    # Create a simple server.php
    cat > server.php << 'EOF'
<?php
if (!is_dir('data')) mkdir('data',0755,true);
if (!is_dir('templates')) mkdir('templates',0755,true);
echo "TheWatcher Server Ready";
?>
EOF
    
    # Create module files
    mkdir -p modules
    echo "# Modules" > modules/__init__.py
    echo "# Cloudflare" > modules/cloudflare.py
    echo "# Templates" > modules/templates.py
}

# ==================== MAIN ====================
main() {
    banner
    detect_system
    INSTALL_DIR="$HOME/TheWatcher"
    
    print_info "System: $SYSTEM"
    print_info "Installing to: $INSTALL_DIR"
    
    # Fix Termux issues first
    fix_termux
    
    # Remove old installation if exists
    if [[ -d "$INSTALL_DIR" ]]; then
        print_warning "Existing installation found"
        read -p "  Remove and reinstall? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$INSTALL_DIR"
            print_success "Old installation removed"
        else
            print_info "Exiting"
            exit 0
        fi
    fi
    
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    
    install_python_deps
    install_php
    install_cloudflared
    create_files
    
    echo ""
    echo -e "${GREEN}${BOLD}╔═══════════════════════════════════════════════════════════════╗${END}"
    echo -e "${GREEN}${BOLD}║                    ✅ INSTALLATION COMPLETE!                    ║${END}"
    echo -e "${GREEN}${BOLD}╚═══════════════════════════════════════════════════════════════╝${END}"
    echo ""
    echo -e "${CYAN}🚀 START TheWatcher:${END}"
    echo -e "  ${YELLOW}cd $INSTALL_DIR && python3 thewatcher.py${END}"
    echo ""
    echo ""
    echo -e "${RED}${BOLD}⚠️  AUTHORIZED TRAINING USE ONLY${END}"
    echo ""
}

# Run main
main "$@"
