#!/usr/bin/env bash
set -euo pipefail

# Collect all arguments as a single prompt string
prompt="$*"

if [[ -z "$prompt" ]]; then
  echo "Error: no prompt provided" >&2
  exit 1
fi

# Ensure claude (Claude Code) is in PATH; fall back to full path if needed
if ! command -v claude >/dev/null 2>&1; then
  CLAUDE_CMD="$HOME/.local/bin/claude"
else
  CLAUDE_CMD="claude"
fi

# Run Claude Code in non-interactive print mode
$CLAUDE_CMD -p "$prompt"
