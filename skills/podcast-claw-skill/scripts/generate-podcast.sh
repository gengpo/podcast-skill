#!/bin/bash
# 生成单主播播客 - 支持多种 AI API（国内+国际）

set -e

if [ -z "$1" ]; then
    echo "用法: $0 <文章URL或文件路径>"
    echo ""
    echo "支持的 AI 提供商（按优先级）:"
    echo "  1. 百度文心一言 (QIANFAN_API_KEY)"
    echo "  2. 阿里通义千问 (DASHSCOPE_API_KEY)"
    echo "  3. 智谱 GLM (ZHIPU_API_KEY)"
    echo "  4. DeepSeek (DEEPSEEK_API_KEY)"
    echo "  5. Moonshot/Kimi (MOONSHOT_API_KEY)"
    echo "  6. OpenRouter (OPENROUTER_API_KEY)"
    echo "  7. OpenAI (OPENAI_API_KEY)"
    exit 1
fi

INPUT="$1"
export PATH="$HOME/.local/bin:$PATH"

echo "🎙️  Podcast Generator Skill"
echo "   输入: $INPUT"

python3 << 'PYTHON'
import os
import sys
import urllib.request
import json

sys.path.insert(0, os.path.expanduser("~/.local/lib/python3.12/site-packages"))

def load_env():
    """加载环境变量"""
    env_file = os.path.expanduser("~/.podcastfy/.env")
    if os.path.exists(env_file):
        with open(env_file, 'r') as f:
            for line in f:
                if '=' in line and not line.startswith('#'):
                    key, value = line.strip().split('=', 1)
                    os.environ[key] = value

def fetch_url(url):
    try:
        jina_url = f"https://r.jina.ai/http://{url.replace('https://', '').replace('http://', '')}"
        req = urllib.request.Request(jina_url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=30) as response:
            return response.read().decode('utf-8')
    except Exception as e:
        print(f"⚠️  URL 获取失败: {e}")
        return None

def load_content(input_source):
    if input_source.startswith('http'):
        print("📥 正在获取 URL 内容...")
        content = fetch_url(input_source)
        if content:
            return content
        print("尝试作为本地文件读取...")
    
    print(f"📖 读取文件: {input_source}")
    with open(input_source, 'r', encoding='utf-8') as f:
        return f.read()

def get_ai_client():
    providers = [
        ("QIANFAN_API_KEY", "qianfan", "百度文心一言"),
        ("DASHSCOPE_API_KEY", "dashscope", "阿里通义千问"),
        ("ZHIPU_API_KEY", "zhipu", "智谱 GLM"),
        ("DEEPSEEK_API_KEY", "deepseek", "DeepSeek"),
        ("MOONSHOT_API_KEY", "moonshot", "Moonshot/Kimi"),
        ("OPENROUTER_API_KEY", "openrouter", "OpenRouter"),
        ("OPENAI_API_KEY", "openai", "OpenAI"),
    ]
    
    for env_var, api_type, name in providers:
        key = os.environ.get(env_var)
        if key:
            return {"type": api_type, "key": key, "name": name}
    
    return None

def generate_with_dashscope(api_key, content):
    """阿里通义千问"""
    url = "https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation"
    payload = json.dumps({
        "model": "qwen-turbo",
        "input": {
            "messages": [
                {"role": "system", "content": "你是一位专业的播客主播。请将内容转换为单人讲述形式的播客脚本，风格亲切自然，像在对听众讲故事一样。使用第一人称'我'来叙述。包含：开场白、内容主体、结尾总结。"},
                {"role": "user", "content": f"请将以下文章转换为单主播播客脚本（中文，约1000字）：\n\n{content[:8000]}"}
            ]
        }
    }).encode('utf-8')
    
    headers = {'Content-Type': 'application/json', 'Authorization': f'Bearer {api_key}'}
    req = urllib.request.Request(url, data=payload, headers=headers)
    
    try:
        with urllib.request.urlopen(req, timeout=120) as response:
            result = json.loads(response.read().decode('utf-8'))
            text = result.get('output', {}).get('text', '')
            if text:
                return text
    except Exception as e:
        print(f"阿里API错误: {e}")
    
    return None

def generate_with_deepseek(api_key, content):
    """DeepSeek"""
    url = "https://api.deepseek.com/chat/completions"
    payload = json.dumps({
        "model": "deepseek-chat",
        "messages": [
            {"role": "system", "content": "你是一位专业的播客主播。请将内容转换为单人讲述形式的播客脚本，风格亲切自然，像在对听众讲故事一样。"},
            {"role": "user", "content": f"请将以下文章转换为单主播播客脚本（中文）：\n\n{content[:8000]}"}
        ]
    }).encode('utf-8')
    
    headers = {'Content-Type': 'application/json', 'Authorization': f'Bearer {api_key}'}
    req = urllib.request.Request(url, data=payload, headers=headers)
    
    try:
        with urllib.request.urlopen(req, timeout=120) as response:
            result = json.loads(response.read().decode('utf-8'))
            return result.get('choices', [{}])[0].get('message', {}).get('content', '')
    except Exception as e:
        print(f"DeepSeek错误: {e}")
    
    return None

def generate_with_moonshot(api_key, content):
    """Moonshot/Kimi"""
    url = "https://api.moonshot.cn/v1/chat/completions"
    payload = json.dumps({
        "model": "moonshot-v1-8k",
        "messages": [
            {"role": "system", "content": "你是一位专业的播客主播。请将内容转换为单人讲述形式的播客脚本，风格亲切自然。"},
            {"role": "user", "content": f"请将以下文章转换为单主播播客脚本（中文）：\n\n{content[:8000]}"}
        ]
    }).encode('utf-8')
    
    headers = {'Content-Type': 'application/json', 'Authorization': f'Bearer {api_key}'}
    req = urllib.request.Request(url, data=payload, headers=headers)
    
    try:
        with urllib.request.urlopen(req, timeout=120) as response:
            result = json.loads(response.read().decode('utf-8'))
            return result.get('choices', [{}])[0].get('message', {}).get('content', '')
    except Exception as e:
        print(f"Moonshot错误: {e}")
    
    return None

def generate_with_zhipu(api_key, content):
    """智谱 GLM"""
    url = "https://open.bigmodel.cn/api/paas/v4/chat/completions"
    payload = json.dumps({
        "model": "glm-4-flash",
        "messages": [
            {"role": "system", "content": "你是一位专业的播客主播。请将内容转换为单人讲述形式的播客脚本，风格亲切自然。"},
            {"role": "user", "content": f"请将以下文章转换为单主播播客脚本（中文）：\n\n{content[:8000]}"}
        ]
    }).encode('utf-8')
    
    headers = {'Content-Type': 'application/json', 'Authorization': api_key}
    req = urllib.request.Request(url, data=payload, headers=headers)
    
    try:
        with urllib.request.urlopen(req, timeout=120) as response:
            result = json.loads(response.read().decode('utf-8'))
            return result.get('choices', [{}])[0].get('message', {}).get('content', '')
    except Exception as e:
        print(f"智谱错误: {e}")
    
    return None

def generate_with_openai_compatible(api_key, content, base_url=None, model=None):
    """通用 OpenAI 兼容接口"""
    from openai import OpenAI
    
    if base_url:
        client = OpenAI(base_url=base_url, api_key=api_key)
    else:
        client = OpenAI(api_key=api_key)
    
    response = client.chat.completions.create(
        model=model or "gpt-4o",
        messages=[
            {"role": "system", "content": "你是一位专业的播客主播。请将内容转换为单人讲述形式的播客脚本，风格亲切自然，像在对听众讲故事一样。"},
            {"role": "user", "content": f"请将以下文章转换为单主播播客脚本（中文）：\n\n{content[:8000]}"}
        ],
        temperature=0.7,
        max_tokens=4000
    )
    
    return response.choices[0].message.content

def generate_podcast(content, client_info):
    api_type = client_info['type']
    api_key = client_info['key']
    name = client_info['name']
    
    print(f"🤖 使用 {name} 生成播客脚本...")
    
    try:
        if api_type == "dashscope":
            result = generate_with_dashscope(api_key, content)
            if result: return result
        elif api_type == "deepseek":
            result = generate_with_deepseek(api_key, content)
            if result: return result
        elif api_type == "moonshot":
            result = generate_with_moonshot(api_key, content)
            if result: return result
        elif api_type == "zhipu":
            result = generate_with_zhipu(api_key, content)
            if result: return result
        elif api_type == "openrouter":
            return generate_with_openai_compatible(api_key, content, 
                "https://openrouter.ai/api/v1", "openai/gpt-4o")
        elif api_type == "openai":
            return generate_with_openai_compatible(api_key, content, None, "gpt-4o")
    except Exception as e:
        print(f"⚠️  {name} 生成失败: {e}")
    
    return None

def main():
    load_env()
    
    input_source = """$INPUT"""
    content = load_content(input_source)
    
    if not content:
        print("❌ 无法加载内容")
        sys.exit(1)
    
    print(f"📄 内容长度: {len(content)} 字符")
    
    if len(content) > 12000:
        content = content[:12000]
        print("⚠️  内容过长，已截断至 12000 字符")
    
    client_info = get_ai_client()
    if not client_info:
        print("❌ 未找到可用的 AI API Key")
        print("请配置 ~/.podcastfy/.env，添加以下任一：")
        print("  DASHSCOPE_API_KEY, DEEPSEEK_API_KEY, MOONSHOT_API_KEY,")
        print("  ZHIPU_API_KEY, OPENROUTER_API_KEY, OPENAI_API_KEY")
        sys.exit(1)
    
    print(f"✅ 使用 AI 提供商: {client_info['name']}")
    
    transcript = generate_podcast(content, client_info)
    
    if not transcript:
        print("❌ 所有 AI 提供商均失败")
        sys.exit(1)
    
    with open("podcast_transcript.txt", "w", encoding="utf-8") as f:
        f.write(transcript)
    
    print(f"✅ 播客脚本已保存")
    print(f"\n📝 预览:\n{'-'*50}")
    print(transcript[:400])
    print("...")
    
    print("\n🔊 生成音频...")
    try:
        import asyncio
        import edge_tts
        
        async def gen():
            await edge_tts.Communicate(transcript, "zh-CN-XiaoxiaoNeural").save("podcast_transcript.mp3")
        
        asyncio.run(gen())
        
        size = os.path.getsize("podcast_transcript.mp3") / 1024
        print(f"✅ 音频已保存: podcast_transcript.mp3 ({size:.1f} KB)")
    except Exception as e:
        print(f"⚠️  音频失败: {e}")

if __name__ == "__main__":
    main()
