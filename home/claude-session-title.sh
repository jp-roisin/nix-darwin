#!/bin/sh
# Claude Code hook: show the session title in herdr's agent sidebar
# (idle · <title>, falls back to idle · claude). Runs beside herdr's managed herdr-agent-state.sh.
# https://github.com/herdrdev/herdr/discussions/433#discussioncomment-17180676
[ "${HERDR_ENV:-}" = "1" ] || exit 0
[ -n "${HERDR_PANE_ID:-}" ] || exit 0

input=$(cat)
# Skip subagents
[ -z "$(printf '%s' "$input" | jq -r '.agent_id // empty')" ] || exit 0
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty')
[ -f "$transcript" ] || exit 0

# /rename title, else Claude's auto title. Transcript format is undocumented.
title=$(grep -h '"type":"custom-title"' "$transcript" | tail -n 1 | jq -r '.customTitle // empty')
[ -n "$title" ] || title=$(grep -h '"type":"ai-title"' "$transcript" | tail -n 1 | jq -r '.aiTitle // empty')
[ -n "$title" ] || exit 0

herdr pane report-metadata "$HERDR_PANE_ID" \
  --source user:claude-session-title \
  --agent claude \
  --display-agent "$title" --clear-custom-status >/dev/null 2>&1 || true
