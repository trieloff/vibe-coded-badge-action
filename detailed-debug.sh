#!/bin/bash
# Detailed debug to find human lines

echo "=== Checking all commits in current files ==="

for file in README.md update-vibe-badge.sh action.yml .github/workflows/example.yml LICENSE; do
    if [ ! -f "$file" ]; then
        continue
    fi
    
    echo ""
    echo "=== File: $file ==="
    
    # Show all unique authors in this file
    git blame "$file" 2>/dev/null | sed 's/^[^ ]* (//' | sed 's/ [0-9][0-9][0-9][0-9]-.*$//' | sort | uniq -c | sort -rn
done

echo ""
echo "=== Checking for Lars Trieloff commits ==="
git log --all --format="%H %an" | grep "Lars Trieloff" | while read commit author_rest; do
    commit_hash="${commit%% *}"
    # Check if this commit has any surviving lines
    for file in README.md update-vibe-badge.sh action.yml .github/workflows/example.yml LICENSE; do
        if [ -f "$file" ]; then
            count=$(git blame "$file" 2>/dev/null | grep -c "^$commit_hash")
            if [ "$count" -gt 0 ]; then
                echo "Commit ${commit_hash:0:7} by Lars has $count lines in $file"
                git show -s --format='  Message: %s' "$commit_hash"
            fi
        fi
    done
done
