#!/usr/bin/env python3
import subprocess
import re
import os
import time

class CloudflareTunnel:
    def __init__(self):
        self.process = None
        self.url = None
        self.logfile = None
    
    def start(self, port):
        self.logfile = f"/tmp/cf_{port}.log"
        
        if not self._check_cloudflared():
            self._install_cloudflared()
        
        cmd = f"cloudflared tunnel --url http://127.0.0.1:{port} --logfile {self.logfile}"
        self.process = subprocess.Popen(cmd, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        
        for _ in range(30):
            time.sleep(1)
            if os.path.exists(self.logfile):
                with open(self.logfile, 'r') as f:
                    content = f.read()
                    match = re.search(r'https://[a-zA-Z0-9-]+\.trycloudflare\.com', content)
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
        result = subprocess.run(["which", "cloudflared"], capture_output=True)
        return result.returncode == 0
    
    def _install_cloudflared(self):
        os.system("wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /tmp/cloudflared")
        os.system("chmod +x /tmp/cloudflared")
        os.system("sudo mv /tmp/cloudflared /usr/local/bin/ 2>/dev/null || mv /tmp/cloudflared $HOME/.local/bin/")
