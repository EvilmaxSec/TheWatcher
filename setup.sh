#!/bin/bash
# TheWatcher Setup Script

echo "🔥 TheWatcher - Security Awareness Framework"
echo "============================================="
echo ""

# Check if running as root (optional)
if [ "$EUID" -eq 0 ]; then 
    echo "⚠️ Running as root - be careful!"
fi

# Update system
echo "📦 Updating packages..."
sudo apt update -y

# Install PHP
echo "📦 Installing PHP..."
sudo apt install php -y

# Install Cloudflared
echo "📦 Installing Cloudflared..."
if ! command -v cloudflared &> /dev/null; then
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
    chmod +x cloudflared
    sudo mv cloudflared /usr/local/bin/
    echo "✅ Cloudflared installed"
else
    echo "✅ Cloudflared already installed"
fi

# Install Python dependencies
echo "📦 Installing Python dependencies..."
pip install -r requirements.txt

# Create directories
mkdir -p data templates

echo ""
echo "✅ Setup complete!"
echo ""
echo "🚀 To start TheWatcher:"
echo "   python3 thewatcher.py"
echo ""
echo "⚠️ Remember: Use only for authorized training!"
