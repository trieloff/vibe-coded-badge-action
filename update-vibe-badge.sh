#!/bin/bash
set -euo pipefail

# Environment variables with defaults
README_PATH="${README_PATH:-README.md}"
BADGE_STYLE="${BADGE_STYLE:-for-the-badge}"
BADGE_COLOR="${BADGE_COLOR:-ff69b4}"
BADGE_TEXT="${BADGE_TEXT:-Vibe_Coded}"
COMMIT_MESSAGE="${COMMIT_MESSAGE:-Update vibe-coded badge}"
DEBUG="${DEBUG:-false}"

# Parse debug flag from environment or command line
if [[ "${1:-}" == "--debug" || "${1:-}" == "-d" || "$DEBUG" == "true" ]]; then
  DEBUG=true
fi

TOTAL=$(git rev-list --count HEAD)
VIBE=0

# Arrays to store commits by type
declare -a AI_COMMITS=()
declare -a HUMAN_COMMITS=()

# Counters for each AI type
CLAUDE_COUNT=0
CODEX_COUNT=0
WINDSURF_COUNT=0
CURSOR_COUNT=0
ZED_COUNT=0
OPENAI_COUNT=0
BOT_COUNT=0
RENOVATE_COUNT=0
SEMANTIC_COUNT=0

for COMMIT in $(git rev-list HEAD); do
  AUTHOR="$(git show -s --format='%an <%ae>' "$COMMIT")"
  BODY="$(git show -s --format='%B' "$COMMIT")"
  SUBJECT="$(git show -s --format='%s' "$COMMIT")"
  DATE="$(git show -s --format='%ad' --date=short "$COMMIT")"
  
  IS_AI=false
  AI_TYPE=""
  
  # Check if commit is on a codex branch
  BRANCHES="$(git branch --contains "$COMMIT" --all 2>/dev/null | grep -E 'remotes/origin/.*codex/' || true)"
  
  # Check for Renovate bot commits
  if echo "$AUTHOR" | grep -F 'renovate[bot]' >/dev/null; then
    VIBE=$((VIBE + 1))
    IS_AI=true
    AI_TYPE="Renovate"
  # Check for semantic-release bot commits
  elif echo "$AUTHOR" | grep -E 'semantic-release-bot|semantic-release\[bot\]' >/dev/null; then
    VIBE=$((VIBE + 1))
    IS_AI=true
    AI_TYPE="Semantic"
  # Check for other bot commits
  elif echo "$AUTHOR" | grep -F '[bot]' >/dev/null; then
    VIBE=$((VIBE + 1))
    IS_AI=true
    AI_TYPE="Bot"
  # Check for AI-generated commits by author or message content
  elif echo "$AUTHOR" | grep -iE 'claude|cursor|zed|windsurf|openai' >/dev/null \
     || echo "$BODY" | grep -iE '🤖|generated with|co-?authored-?by:.*(claude|cursor|zed|windsurf|openai)|signed-off-by:.*(claude|cursor|zed|windsurf|openai)' >/dev/null; then
    VIBE=$((VIBE + 1))
    IS_AI=true
    if echo "$AUTHOR" | grep -i 'claude' >/dev/null || echo "$BODY" | grep -i 'claude' >/dev/null; then
      AI_TYPE="Claude"
    elif echo "$AUTHOR" | grep -i 'cursor' >/dev/null || echo "$BODY" | grep -i 'cursor' >/dev/null; then
      AI_TYPE="Cursor"
    elif echo "$AUTHOR" | grep -i 'windsurf' >/dev/null || echo "$BODY" | grep -i 'windsurf' >/dev/null; then
      AI_TYPE="Windsurf"
    elif echo "$AUTHOR" | grep -i 'zed' >/dev/null || echo "$BODY" | grep -i 'zed' >/dev/null; then
      AI_TYPE="Zed"
    elif echo "$AUTHOR" | grep -i 'openai' >/dev/null || echo "$BODY" | grep -i 'openai' >/dev/null; then
      AI_TYPE="OpenAI"
    else
      AI_TYPE="Unknown AI"
    fi
  # Check for Codex commits (merge commits or any commit on codex branches)
  elif echo "$BODY" | grep -E '^Merge pull request .* from .*/.*codex/.*' >/dev/null || [ -n "$BRANCHES" ]; then
    VIBE=$((VIBE + 1))
    IS_AI=true
    AI_TYPE="Codex"
  fi
  
  # Count AI commits by type
  if $IS_AI && [ -n "$AI_TYPE" ]; then
    case "$AI_TYPE" in
      "Claude") CLAUDE_COUNT=$((CLAUDE_COUNT + 1)) ;;
      "Codex") CODEX_COUNT=$((CODEX_COUNT + 1)) ;;
      "Windsurf") WINDSURF_COUNT=$((WINDSURF_COUNT + 1)) ;;
      "Cursor") CURSOR_COUNT=$((CURSOR_COUNT + 1)) ;;
      "Zed") ZED_COUNT=$((ZED_COUNT + 1)) ;;
      "OpenAI") OPENAI_COUNT=$((OPENAI_COUNT + 1)) ;;
      "Bot") BOT_COUNT=$((BOT_COUNT + 1)) ;;
      "Renovate") RENOVATE_COUNT=$((RENOVATE_COUNT + 1)) ;;
      "Semantic") SEMANTIC_COUNT=$((SEMANTIC_COUNT + 1)) ;;
    esac
  fi
  
  if $DEBUG; then
    if $IS_AI; then
      AI_COMMITS+=("$(printf "%-7s | %-10s | %-40.40s | %s" "$COMMIT" "$AI_TYPE" "$SUBJECT" "$DATE")")
    else
      HUMAN_COMMITS+=("$(printf "%-7s | %-40.40s | %s" "$COMMIT" "$SUBJECT" "$DATE")")
    fi
  fi
done

if [ "$TOTAL" -eq 0 ]; then
  PERCENT=0
else
  PERCENT=$((100 * VIBE / TOTAL))
fi

# Determine which logo to use based on most common AI type
LOGO="githubcopilot"  # default
MAX_COUNT=0
DOMINANT_AI="unknown"

# Check each AI type
if [ "$CLAUDE_COUNT" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$CLAUDE_COUNT"
  LOGO="claude"
  DOMINANT_AI="Claude"
fi
if [ "$CODEX_COUNT" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$CODEX_COUNT"
  LOGO="openai"
  DOMINANT_AI="Codex"
fi
if [ "$WINDSURF_COUNT" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$WINDSURF_COUNT"
  LOGO="windsurf"
  DOMINANT_AI="Windsurf"
fi
if [ "$CURSOR_COUNT" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$CURSOR_COUNT"
  LOGO="githubcopilot"
  DOMINANT_AI="Cursor"
fi
if [ "$ZED_COUNT" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$ZED_COUNT"
  LOGO="zedindustries"
  DOMINANT_AI="Zed"
fi
if [ "$OPENAI_COUNT" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$OPENAI_COUNT"
  LOGO="openai"
  DOMINANT_AI="OpenAI"
fi
if [ "$BOT_COUNT" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$BOT_COUNT"
  LOGO="githubactions"
  DOMINANT_AI="Bot"
fi
if [ "$RENOVATE_COUNT" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$RENOVATE_COUNT"
  LOGO="renovatebot"
  DOMINANT_AI="Renovate"
fi
if [ "$SEMANTIC_COUNT" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$SEMANTIC_COUNT"
  LOGO="semanticrelease"
  DOMINANT_AI="Semantic"
fi

# Display debug output
if $DEBUG; then
  echo "=== Vibe Badge Debug Mode ==="
  echo "Total commits: $TOTAL"
  echo ""
  echo "AI-generated commits: $VIBE (${PERCENT}%)"
  echo "Human commits: $((TOTAL - VIBE)) ($((100 - PERCENT))%)"
  echo ""
  echo "AI Breakdown:"
  [ "$CLAUDE_COUNT" -gt 0 ] && printf "  %-10s: %d\n" "Claude" "$CLAUDE_COUNT"
  [ "$CODEX_COUNT" -gt 0 ] && printf "  %-10s: %d\n" "Codex" "$CODEX_COUNT"
  [ "$WINDSURF_COUNT" -gt 0 ] && printf "  %-10s: %d\n" "Windsurf" "$WINDSURF_COUNT"
  [ "$CURSOR_COUNT" -gt 0 ] && printf "  %-10s: %d\n" "Cursor" "$CURSOR_COUNT"
  [ "$ZED_COUNT" -gt 0 ] && printf "  %-10s: %d\n" "Zed" "$ZED_COUNT"
  [ "$OPENAI_COUNT" -gt 0 ] && printf "  %-10s: %d\n" "OpenAI" "$OPENAI_COUNT"
  [ "$BOT_COUNT" -gt 0 ] && printf "  %-10s: %d\n" "Bot" "$BOT_COUNT"
  [ "$RENOVATE_COUNT" -gt 0 ] && printf "  %-10s: %d\n" "Renovate" "$RENOVATE_COUNT"
  [ "$SEMANTIC_COUNT" -gt 0 ] && printf "  %-10s: %d\n" "Semantic" "$SEMANTIC_COUNT"
  echo ""
  echo "Selected logo: $LOGO (Dominant AI: $DOMINANT_AI)"
  echo ""
  echo "AI Commits:"
  echo "-----------"
  echo "SHA     | Type       | Subject                                  | Date"
  echo "--------|------------|------------------------------------------|----------"
  if [ ${#AI_COMMITS[@]} -gt 0 ]; then
    printf "%s\n" "${AI_COMMITS[@]}" | sort -k4 -r
  else
    echo "None"
  fi
  echo ""
  echo "Human Commits:"
  echo "--------------"
  echo "SHA     | Subject                                  | Date"
  echo "--------|------------------------------------------|----------"
  if [ ${#HUMAN_COMMITS[@]} -gt 0 ]; then
    printf "%s\n" "${HUMAN_COMMITS[@]}" | sort -k3 -r
  else
    echo "None"
  fi
  echo ""
fi

# Set GitHub Actions outputs
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "percentage=$PERCENT" >> "$GITHUB_OUTPUT"
  echo "dominant-ai=$DOMINANT_AI" >> "$GITHUB_OUTPUT"
fi

BADGE_CHANGED=false

# Only update badge if not in debug mode
if ! $DEBUG; then
  # Get repository information for the badge URL
  REPO_URL=$(git config --get remote.origin.url 2>/dev/null || echo "")
  if [[ "$REPO_URL" =~ github\.com[:/]([^/]+)/([^/]+)\.git$ ]]; then
    REPO_OWNER="${BASH_REMATCH[1]}"
    REPO_NAME="${BASH_REMATCH[2]}"
    GITHUB_URL="https://github.com/$REPO_OWNER/$REPO_NAME"
  else
    # Fallback to a generic URL
    GITHUB_URL="https://github.com"
  fi

  NEW_BADGE="[![${PERCENT}% ${BADGE_TEXT}](https://img.shields.io/badge/${PERCENT}%25-${BADGE_TEXT}-${BADGE_COLOR}?style=${BADGE_STYLE}&logo=${LOGO}&logoColor=white)](https://github.com/trieloff/vibe-coded-badge-action)"
  
  # Export badge for perl to use
  export NEW_BADGE
  export BADGE_TEXT

  # Clean up any existing vibe-coded badges and insert new one
  perl -0777 -pi -e '
    my $content = $_;
    # Remove all existing vibe-coded badges
    my $badge_re = qr#\[!\[\d+%[ _][^\]]*\]\(https://img\.shields\.io/badge/\d+%25-[^-]+-[^?]*\?[^)]*\)\]\([^)]*\)#s;
    $content =~ s/$badge_re\s*//g;
    # Clean up excessive newlines
    $content =~ s/\n{3,}/\n\n/g;
    # Insert new badge after first heading
    $content =~ s/^(# [^\n]+)\n/$1\n\n$ENV{NEW_BADGE}\n/;
    $_ = $content;
  ' "$README_PATH"
  BADGE_CHANGED=true

  if $BADGE_CHANGED; then
    git config user.name 'github-actions[bot]'
    git config user.email 'github-actions[bot]@users.noreply.github.com'
    git add "$README_PATH"
    git commit -m "$COMMIT_MESSAGE to ${PERCENT}% [skip vibe-badge]"
    
    # Push the changes if we're in GitHub Actions
    if [ -n "${GITHUB_ACTIONS:-}" ]; then
      git push origin HEAD
    fi
  fi
fi

# Set GitHub Actions output for badge changed status
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "changed=$BADGE_CHANGED" >> "$GITHUB_OUTPUT"
fi