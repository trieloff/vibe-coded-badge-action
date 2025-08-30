#!/bin/bash
# Find the remaining human lines

for file in README.md update-vibe-badge.sh action.yml .github/workflows/example.yml LICENSE; do
    if [ ! -f "$file" ]; then
        continue
    fi
    
    while IFS= read -r LINE; do
        if [[ "$LINE" =~ ^([a-f0-9]{40})[[:space:]] ]]; then
            COMMIT_HASH="${BASH_REMATCH[1]}"
            
            if [ "$COMMIT_HASH" = "0000000000000000000000000000000000000000" ]; then
                continue
            fi
            
            PARENT_COUNT=$(git rev-list --parents -n 1 "$COMMIT_HASH" 2>/dev/null | wc -w)
            if [ "$PARENT_COUNT" -gt 2 ]; then
                continue
            fi
            
            AUTHOR=$(git show -s --format='%an' "$COMMIT_HASH" 2>/dev/null)
            AUTHOR_EMAIL=$(git show -s --format='%ae' "$COMMIT_HASH" 2>/dev/null)
            
            IS_AI=false
            
            # Check all AI patterns
            if git show --format=%B "$COMMIT_HASH" 2>/dev/null | grep -iE 'Co-authored-by:.*terragon' >/dev/null; then
                IS_AI=true
            elif echo "$AUTHOR" | grep -iE 'claude|anthropic|cursor|windsurf|zed|openai|opencode|qwen code|gemini|\[bot\]|renovate|semantic-release|github-actions' >/dev/null; then
                IS_AI=true
            elif echo "$AUTHOR_EMAIL" | grep -iE 'claude|anthropic|noreply@alibaba\.com|noreply@google\.com' >/dev/null; then
                IS_AI=true
            fi
            
            if [ "$IS_AI" = "false" ]; then
                echo "HUMAN in $file: $AUTHOR (${COMMIT_HASH:0:7})"
                git blame "$file" 2>/dev/null | grep "^$COMMIT_HASH" | head -1
            fi
        fi
    done < <(git blame --line-porcelain "$file" 2>/dev/null | grep '^[a-f0-9]\{40\}')
done
