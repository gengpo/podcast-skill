---
name: podcast-generator
description: 将网络文章或文本内容转换为音频播客。当用户需要将文章、博客、新闻等内容转换为语音播客格式时使用此技能。支持单主播讲述风格，自动生成播客脚本和音频文件（MP3）。
---

# Podcast Generator

将网络文章或文本内容转换为音频播客的技能。

## 功能

- 从 URL 或文本文件提取内容
- 使用 AI 生成播客脚本（单主播讲述风格）
- 使用 Edge TTS 合成语音（免费、中文支持好）
- 输出 MP3 音频文件

## 使用方法

### 1. 环境检查与安装

首次使用前，运行环境检查脚本：

```bash
~/.openclaw/skills/podcast-generator/scripts/check-and-install.sh
```

此脚本会：
- 检查 Python3 和 pip 是否安装
- 安装 podcastfy、edge-tts、playwright、openai 等依赖
- 检查 API Key 配置

### 2. 配置 API Keys

创建配置文件 `~/.podcastfy/.env`：

```bash
# OpenRouter API Key（推荐，支持 GPT-4o）
OPENROUTER_API_KEY=sk-or-v1-...

# 或直接使用 OpenAI API Key
OPENAI_API_KEY=sk-...

# 可选：Gemini API Key（免费额度有限）
GEMINI_API_KEY=AIzaSy...
```

### 3. 生成播客

```bash
~/.openclaw/skills/podcast-generator/scripts/generate-podcast.sh <URL或文件路径>
```

**示例：**
```bash
# 从 URL 生成
~/.openclaw/skills/podcast-generator/scripts/generate-podcast.sh "https://example.com/article"

# 从文件生成
~/.openclaw/skills/podcast-generator/scripts/generate-podcast.sh ./article.txt
```

### 4. 输出文件

- `podcast_transcript.txt` - 播客文字脚本
- `podcast_transcript.mp3` - 播客音频文件（MP3 格式）

## 工作流程

1. **输入处理**：从 URL（通过 jina.ai 提取）或本地文件读取内容
2. **内容转换**：使用 GPT-4o 将文章转换为单主播讲述风格的播客脚本
3. **语音合成**：使用 Edge TTS（Xiaoxiao 中文语音）生成音频
4. **输出交付**：提供 MP3 音频和文字脚本

## 限制

- URL 内容提取依赖 jina.ai，部分网站可能不支持
- 内容长度超过 12000 字符会自动截断
- Edge TTS 为免费服务，语音质量中等
- API 调用受限于配置的 Key 额度

## 故障排除

**问题：依赖安装失败**
- 确保系统有 Python 3.8+
- 使用 `--break-system-packages` 标志（Ubuntu/Debian）

**问题：URL 内容提取失败**
- 尝试将内容保存为本地文件再处理
- 检查网络连接和代理设置

**问题：API 调用失败**
- 检查 API Key 是否有效
- 检查 API 额度是否充足
- 尝试更换 API Provider（OpenRouter/OpenAI/Gemini）

## 依赖

- Python 3.8+
- podcastfy
- edge-tts
- openai
- playwright（可选，用于网页抓取）
