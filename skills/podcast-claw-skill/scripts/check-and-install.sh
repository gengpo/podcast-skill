#!/bin/bash
# 检查并安装 podcastfy 环境

set -e

echo "🔍 检查 podcastfy 环境..."

# 检查 Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 未安装"
    exit 1
fi

# 检查 pip
if ! command -v pip3 &> /dev/null && ! python3 -m pip --version &> /dev/null; then
    echo "📦 安装 pip..."
    curl -sS https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
    python3 /tmp/get-pip.py --user --break-system-packages
fi

export PATH="$HOME/.local/bin:$PATH"

# 检查 podcastfy
if python3 -c "import podcastfy" 2>/dev/null; then
    echo "✅ podcastfy 已安装"
    PODCASTFY_VERSION=$(python3 -c "import podcastfy; print(podcastfy.__version__)")
    echo "   版本: $PODCASTFY_VERSION"
else
    echo "📦 安装 podcastfy..."
    pip3 install --user --break-system-packages podcastfy edge-tts playwright openai
    
    echo "📦 安装 Playwright 浏览器..."
    python3 -m playwright install chromium
    
    echo "✅ podcastfy 安装完成"
fi

# 检查 API Keys
if [ -f ~/.podcastfy/.env ]; then
    echo "✅ API Key 配置已存在 (~/.podcastfy/.env)"
else
    echo "⚠️  API Key 配置缺失"
    echo "   请配置 ~/.podcastfy/.env 文件"
fi

echo ""
echo "🎉 环境检查完成！"
