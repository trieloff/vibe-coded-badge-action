#!/bin/bash
set -euo pipefail

# Environment variables with defaults
README_PATH="${README_PATH:-README.md}"
BADGE_STYLE="${BADGE_STYLE:-for-the-badge}"
BADGE_COLOR="${BADGE_COLOR:-ff69b4}"
BADGE_TEXT="${BADGE_TEXT:-Vibe_Coded}"
COMMIT_MESSAGE="${COMMIT_MESSAGE:-Update vibe-coded badge}"
DEBUG="${DEBUG:-false}"
SKIP_ON_ERROR="${SKIP_ON_ERROR:-true}"

# Parse debug flag from environment or command line
if [[ "${1:-}" == "--debug" || "${1:-}" == "-d" || "$DEBUG" == "true" ]]; then
  DEBUG=true
fi

# Line-based calculation using git blame
TOTAL_LINES=0
AI_LINES=0

# Initialize line counts by AI type
CLAUDE_LINES=0
CURSOR_LINES=0
WINDSURF_LINES=0
ZED_LINES=0
OPENAI_LINES=0
TERRAGON_LINES=0
GEMINI_LINES=0
BOT_LINES=0
RENOVATE_LINES=0
SEMANTIC_LINES=0

# Find all relevant source files
SOURCE_FILES=$(find . -type f \
  \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \
  -o -name "*.py" -o -name "*.sh" -o -name "*.bash" -o -name "*.zsh" \
  -o -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" \
  -o -name "*.swift" -o -name "*.go" -o -name "*.rs" -o -name "*.java" \
  -o -name "*.cpp" -o -name "*.c" -o -name "*.h" -o -name "*.hpp" \
  -o -name "*.rb" -o -name "*.php" -o -name "*.css" -o -name "*.scss" \
  -o -name "*.html" -o -name "*.xml" -o -name "*.sql" \) \
  -not -path "./.git/*" \
  -not -path "./node_modules/*" \
  -not -path "./.build/*" \
  -not -path "./dist/*" \
  -not -path "./build/*" \
  -not -path "./vendor/*" \
  -not -name "*.min.js" -not -name "*.min.css" 2>/dev/null)

# Process each source file
for FILE in $SOURCE_FILES; do
  if [ -f "$FILE" ] && [ -r "$FILE" ]; then
    # Use git blame to analyze each line
    # Get line number counter
    LINE_NUM=0
    while IFS= read -r LINE; do
      LINE_NUM=$((LINE_NUM + 1))
      if [[ -n "$LINE" ]]; then
        # Extract author and commit info from git blame for this specific line
        BLAME_INFO=$(git blame --line-porcelain -L ${LINE_NUM},${LINE_NUM} "$FILE" 2>/dev/null)
        AUTHOR=$(echo "$BLAME_INFO" | grep "^author " | cut -d' ' -f2-)
        AUTHOR_EMAIL=$(echo "$BLAME_INFO" | grep "^author-mail " | cut -d' ' -f2- | tr -d '<>')
        COMMIT_HASH=$(echo "$BLAME_INFO" | head -n1 | cut -d' ' -f1)
        
        # Skip merge commits (commits with more than one parent)
        if [ -n "$COMMIT_HASH" ] && [ "$COMMIT_HASH" != "0000000000000000000000000000000000000000" ]; then
          PARENT_COUNT=$(git rev-list --parents -n 1 "$COMMIT_HASH" 2>/dev/null | wc -w)
          # If parent count > 2 (commit hash + 2 or more parents), it's a merge commit
          if [ "$PARENT_COUNT" -gt 2 ]; then
            continue
          fi
        fi
        
        # Skip empty lines and obvious boilerplate
        if [[ -n "$(echo "$LINE" | tr -d '[:space:]')" ]] && 
           [[ ! "$LINE" =~ ^[[:space:]]*# ]] && 
           [[ ! "$LINE" =~ ^[[:space:]]*// ]] &&
           [[ ! "$LINE" =~ ^[[:space:]]*\* ]] &&
           [[ ! "$LINE" =~ ^[[:space:]]*\*/ ]] &&
           [[ ! "$LINE" =~ ^[[:space:]]*import\  ]] &&
           [[ ! "$LINE" =~ ^[[:space:]]*package\  ]] &&
           [[ ! "$LINE" =~ ^[[:space:]]*\{?[[:space:]]*\}?$ ]] &&
           [[ ! "$LINE" =~ ^[[:space:]]*$ ]]; then
          
          TOTAL_LINES=$((TOTAL_LINES + 1))
          
          # Determine AI type based on author
          IS_AI=false
          AI_TYPE=""
          
          # Check for Terragon (via Co-authored-by in commit message)
          if git show --format=%B "$COMMIT_HASH" 2>/dev/null | grep -iE 'Co-authored-by:.*terragon' >/dev/null; then
            AI_TYPE="Terragon"
            TERRAGON_LINES=$((TERRAGON_LINES + 1))
            IS_AI=true
          # Check for Claude/Anthropic
          elif echo "$AUTHOR" | grep -iE 'claude|anthropic' >/dev/null || echo "$AUTHOR_EMAIL" | grep -iE 'claude|anthropic' >/dev/null; then
            AI_TYPE="Claude"
            CLAUDE_LINES=$((CLAUDE_LINES + 1))
            IS_AI=true
          # Check for Cursor
          elif echo "$AUTHOR" | grep -i 'cursor' >/dev/null; then
            AI_TYPE="Cursor"
            CURSOR_LINES=$((CURSOR_LINES + 1))
            IS_AI=true
          # Check for Windsurf
          elif echo "$AUTHOR" | grep -i 'windsurf' >/dev/null; then
            AI_TYPE="Windsurf"
            WINDSURF_LINES=$((WINDSURF_LINES + 1))
            IS_AI=true
          # Check for Zed
          elif echo "$AUTHOR" | grep -i 'zed' >/dev/null; then
            AI_TYPE="Zed"
            ZED_LINES=$((ZED_LINES + 1))
            IS_AI=true
          # Check for OpenAI
          elif echo "$AUTHOR" | grep -i 'openai' >/dev/null; then
            AI_TYPE="OpenAI"
            OPENAI_LINES=$((OPENAI_LINES + 1))
            IS_AI=true
          # Check for Gemini
          elif echo "$AUTHOR" | grep -i 'gemini' >/dev/null || echo "$AUTHOR_EMAIL" | grep -E 'noreply@google\.com' >/dev/null; then
            AI_TYPE="Gemini"
            GEMINI_LINES=$((GEMINI_LINES + 1))
            IS_AI=true
          # Check for bots
          elif echo "$AUTHOR" | grep -i '\[bot\]' >/dev/null || echo "$AUTHOR" | grep -iE 'renovate|semantic-release'; then
            if echo "$AUTHOR" | grep -i 'renovate' >/dev/null; then
              AI_TYPE="Renovate"
              RENOVATE_LINES=$((RENOVATE_LINES + 1))
            elif echo "$AUTHOR" | grep -iE 'semantic-release|semantic' >/dev/null; then
              AI_TYPE="Semantic"
              SEMANTIC_LINES=$((SEMANTIC_LINES + 1))
            else
              AI_TYPE="Bot"
              BOT_LINES=$((BOT_LINES + 1))
            fi
            IS_AI=true
          fi
          
          if $IS_AI; then
            AI_LINES=$((AI_LINES + 1))
          fi
        fi
      fi
    done < "$FILE"
  fi
done

# Calculate percentage
if [ "$TOTAL_LINES" -eq 0 ]; then
  PERCENT=0
else
  PERCENT=$((100 * AI_LINES / TOTAL_LINES))
fi

# Determine which logo to use based on most lines by AI type
LOGO="githubcopilot"  # default
MAX_COUNT=0
DOMINANT_AI="unknown"

# Check each AI type based on line counts
if [ "$CLAUDE_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$CLAUDE_LINES"
  LOGO="claude"
  DOMINANT_AI="Claude"
fi
if [ "$TERRAGON_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$TERRAGON_LINES"
  LOGO="claude"
  DOMINANT_AI="Terragon"
fi
if [ "$CURSOR_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$CURSOR_LINES"
  LOGO="githubcopilot"
  DOMINANT_AI="Cursor"
fi
if [ "$WINDSURF_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$WINDSURF_LINES"
  LOGO="windsurf"
  DOMINANT_AI="Windsurf"
fi
if [ "$ZED_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$ZED_LINES"
  LOGO="zedindustries"
  DOMINANT_AI="Zed"
fi
if [ "$OPENAI_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$OPENAI_LINES"
  LOGO="openai"
  DOMINANT_AI="OpenAI"
fi
if [ "$GEMINI_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$GEMINI_LINES"
  LOGO="google"
  DOMINANT_AI="Gemini"
fi
if [ "$BOT_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$BOT_LINES"
  LOGO="githubactions"
  DOMINANT_AI="Bot"
fi
if [ "$RENOVATE_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$RENOVATE_LINES"
  LOGO="renovatebot"
  DOMINANT_AI="Renovate"
fi
if [ "$SEMANTIC_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$SEMANTIC_LINES"
  LOGO="semanticrelease"
  DOMINANT_AI="Semantic"
fi

# Display debug output
if $DEBUG; then
  echo "=== Vibe Badge Debug Mode (Line-based) ==="
  echo "Total lines of code: $TOTAL_LINES"
  echo ""
  echo "AI-generated lines: $AI_LINES (${PERCENT}%)"
  echo "Human-written lines: $((TOTAL_LINES - AI_LINES)) ($((100 - PERCENT))%)"
  echo ""
  echo "AI Breakdown by lines:"
  [ "$CLAUDE_LINES" -gt 0 ] && printf "  %-10s: %d lines\n" "Claude" "$CLAUDE_LINES"
  [ "$TERRAGON_LINES" -gt 0 ] && printf "  %-10s: %d lines\n" "Terragon" "$TERRAGON_LINES"
  [ "$CURSOR_LINES" -gt 0 ] && printf "  %-10s: %d lines\n" "Cursor" "$CURSOR_LINES"
  [ "$WINDSURF_LINES" -gt 0 ] && printf "  %-10s: %d lines\n" "Windsurf" "$WINDSURF_LINES"
  [ "$ZED_LINES" -gt 0 ] && printf "  %-10s: %d lines\n" "Zed" "$ZED_LINES"
  [ "$OPENAI_LINES" -gt 0 ] && printf "  %-10s: %d lines\n" "OpenAI" "$OPENAI_LINES"
  [ "$GEMINI_LINES" -gt 0 ] && printf "  %-10s: %d lines\n" "Gemini" "$GEMINI_LINES"
  [ "$BOT_LINES" -gt 0 ] && printf "  %-10s: %d lines\n" "Bot" "$BOT_LINES"
  [ "$RENOVATE_LINES" -gt 0 ] && printf "  %-10s: %d lines\n" "Renovate" "$RENOVATE_LINES"
  [ "$SEMANTIC_LINES" -gt 0 ] && printf "  %-10s: %d lines\n" "Semantic" "$SEMANTIC_LINES"
  echo ""
  echo "Selected logo: $LOGO (Dominant AI: $DOMINANT_AI)"
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
  if perl -0777 -pi -e '
    my $content = $_;
    # Remove all existing vibe-coded badges (more flexible pattern)
    my $badge_re = qr#\[!\[\d+%[ _][^\]]*Vibe[ _]Coded[^\]]*\]\(https://img\.shields\.io/badge/\d+%25[^)]*\)\]\([^)]*\)#s;
    $content =~ s/$badge_re\s*//g;
    # Clean up excessive newlines
    $content =~ s/\n{3,}/\n\n/g;
    
    # Try to insert after first heading, fallback to beginning if no heading
    if ($content =~ /^(#+ [^\n]+)\n/m) {
      $content =~ s/^(#+ [^\n]+)\n/$1\n\n$ENV{NEW_BADGE}\n/m;
    } else {
      # Fallback: insert at the beginning
      $content = "$ENV{NEW_BADGE}\n\n$content";
    }
    $_ = $content;
  ' "$README_PATH"; then
    BADGE_CHANGED=true
  else
    echo "Error: Failed to update badge in $README_PATH"
    exit 1
  fi

  if $BADGE_CHANGED; then
    # Check if there are actually changes to commit
    if ! git diff --quiet "$README_PATH" || ! git diff --cached --quiet "$README_PATH"; then
      git config user.name 'github-actions[bot]'
      git config user.email 'github-actions[bot]@users.noreply.github.com'
      git add "$README_PATH"
      git commit -m "$COMMIT_MESSAGE to ${PERCENT}% [skip vibe-badge]"
      
      # Push the changes if we're in GitHub Actions
      if [ -n "${GITHUB_ACTIONS:-}" ]; then
        if [ "$SKIP_ON_ERROR" = "true" ]; then
          if ! git push origin HEAD 2>/dev/null; then
            echo "Warning: Failed to push changes to remote. This is usually caused by concurrent updates."
            echo "The badge has been updated locally but not pushed to the remote repository."
            echo "Set SKIP_ON_ERROR=false to fail on push errors instead of skipping."
          fi
        else
          git push origin HEAD
        fi
      fi
    else
      BADGE_CHANGED=false
    fi
  fi
fi

# Set GitHub Actions output for badge changed status
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "changed=$BADGE_CHANGED" >> "$GITHUB_OUTPUT"
fi