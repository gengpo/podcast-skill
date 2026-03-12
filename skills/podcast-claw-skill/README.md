# Podcast Claw Skill

OpenClaw Skill for converting web articles and text content into audio podcasts.

## Features

- Extract content from URLs or local files
- Generate podcast scripts using AI (single-host narration style)
- Synthesize speech using Edge TTS (free, good Chinese support)
- **Multiple AI providers support** (China domestic + International)
- Auto-select available AI service

## Supported AI Providers

### China Domestic (Recommended)
| Provider | Environment Variable |
|----------|---------------------|
| Alibaba Tongyi Qianwen | `DASHSCOPE_API_KEY` |
| DeepSeek | `DEEPSEEK_API_KEY` |
| Moonshot/Kimi | `MOONSHOT_API_KEY` |
| Zhipu GLM | `ZHIPU_API_KEY` |
| Baidu Qianfan | `QIANFAN_API_KEY` |

### International
| Provider | Environment Variable |
|----------|---------------------|
| OpenRouter | `OPENROUTER_API_KEY` |
| OpenAI | `OPENAI_API_KEY` |

## Installation

```bash
# Copy to OpenClaw skills directory
cp -r podcast-claw-skill ~/.openclaw/skills/

# Run environment check
~/.openclaw/skills/podcast-claw-skill/scripts/check-and-install.sh
```

## Configuration

Create `~/.podcastfy/.env`:

```bash
# Choose one (domestic API recommended)
DASHSCOPE_API_KEY=sk-your-key-here
DEEPSEEK_API_KEY=sk-your-key-here
MOONSHOT_API_KEY=sk-your-key-here
ZHIPU_API_KEY=your-key-here
QIANFAN_API_KEY=your-key-here

# Or international
OPENROUTER_API_KEY=sk-or-v1-your-key-here
OPENAI_API_KEY=sk-your-key-here
```

### Get API Key

- Alibaba: https://dashscope.console.aliyun.com/
- DeepSeek: https://platform.deepseek.com/
- Moonshot: https://platform.moonshot.cn/
- Zhipu: https://open.bigmodel.cn/
- Baidu: https://console.bce.baidu.com/qianfan/overview

## Usage

```bash
~/.openclaw/skills/podcast-claw-skill/scripts/generate-podcast.sh "https://example.com/article"
```

Output files:
- `podcast_transcript.txt` - Podcast script
- `podcast_transcript.mp3` - Audio file

## Requirements

- Python 3.8+
- edge-tts
- openai (for OpenRouter/OpenAI)

## License

MIT
