#!/bin/bash
# Debug script to identify human-written lines

echo "=== Analyzing all files for human-written lines ==="

for file in README.md update-vibe-badge.sh action.yml .github/workflows/example.yml LICENSE; do
    if [ ! -f "$file" ]; then
        continue
    fi
    
    echo ""
    echo "=== File: $file ==="
    
    # Get all unique commit hashes from blame
    commits=$(git blame --line-porcelain "$file" 2>/dev/null | grep '^[a-f0-9]\{40\}' | awk '{print $1}' | sort -u)
    
    for commit in $commits; do
        if [ "$commit" = "0000000000000000000000000000000000000000" ]; then
            line_count=$(git blame "$file" 2>/dev/null | grep -c "^$commit")
            echo "  UNCOMMITTED: $line_count lines"
            continue
        fi
        
        # Check if it's a merge commit
        parent_count=$(git rev-list --parents -n 1 "$commit" 2>/dev/null | wc -w)
        if [ "$parent_count" -gt 2 ]; then
            line_count=$(git blame "$file" 2>/dev/null | grep -c "^$commit")
            echo "  MERGE COMMIT $commit: $line_count lines (should be excluded)"
            continue
        fi
        
        # Get author info
        author=$(git show -s --format='%an' "$commit" 2>/dev/null)
        author_email=$(git show -s --format='%ae' "$commit" 2>/dev/null)
        
        # Check if it's AI
        is_ai=false
        ai_type="HUMAN"
        
        # Check for various AI patterns
        if git show --format=%B "$commit" 2>/dev/null | grep -iE 'Co-authored-by:.*terragon' >/dev/null; then
            is_ai=true
            ai_type="Terragon"
        elif echo "$author" | grep -iE 'claude|anthropic' >/dev/null || echo "$author_email" | grep -iE 'claude|anthropic' >/dev/null; then
            is_ai=true
            ai_type="Claude"
        elif echo "$author" | grep -i 'cursor' >/dev/null; then
            is_ai=true
            ai_type="Cursor"
        elif echo "$author" | grep -i 'windsurf' >/dev/null; then
            is_ai=true
            ai_type="Windsurf"
        elif echo "$author" | grep -i 'zed' >/dev/null; then
            is_ai=true
            ai_type="Zed"
        elif echo "$author" | grep -i 'openai' >/dev/null; then
            is_ai=true
            ai_type="OpenAI"
        elif echo "$author" | grep -i 'qwen code' >/dev/null || echo "$author_email" | grep -E 'noreply@alibaba\.com' >/dev/null; then
            is_ai=true
            ai_type="Qwen"
        elif echo "$author" | grep -i 'gemini' >/dev/null || echo "$author_email" | grep -E 'noreply@google\.com' >/dev/null; then
            is_ai=true
            ai_type="Gemini"
        elif echo "$author" | grep -i 'opencode' >/dev/null; then
            is_ai=true
            ai_type="OpenCode"
        elif echo "$author" | grep -i '\[bot\]' >/dev/null || echo "$author" | grep -iE 'renovate|semantic-release' >/dev/null; then
            is_ai=true
            ai_type="Bot"
        elif echo "$author" | grep -i 'github-actions' >/dev/null; then
            is_ai=true
            ai_type="GH-Actions"
        fi
        
        # Count lines for this commit in this file
        line_count=$(git blame "$file" 2>/dev/null | grep -c "^$commit")
        
        if [ "$is_ai" = "false" ]; then
            echo "  HUMAN - $author <$author_email>: $line_count lines (commit: ${commit:0:7})"
            # Show the commit message
            msg=$(git show -s --format='%s' "$commit" 2>/dev/null)
            echo "    Commit: $msg"
        fi
    done
done
