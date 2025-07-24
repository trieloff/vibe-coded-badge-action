# Vibe Coded Badge Action

[![64% Vibe_Coded](https://img.shields.io/badge/64%25-Vibe_Coded-ff69b4?style=for-the-badge&logo=claude&logoColor=white)](https://github.com/trieloff/vibe-coded-badge-action)

A GitHub Action that automatically analyzes your repository's git history to determine what percentage of commits were made by AI tools, and updates a badge in your README accordingly.

## Features

- **Smart AI Detection**: Identifies commits from Claude, Cursor, Zed, Windsurf, OpenAI, Codex, and various bots
- **Dynamic Logo Selection**: Automatically chooses the logo based on which AI tool contributed the most
- **Flexible Configuration**: Customizable badge style, colors, text, and target file
- **Debug Mode**: Detailed analysis of commit classification
- **Skip Logic**: Prevents infinite loops with `[skip vibe-badge]` commits

## Usage

### Basic Usage

```yaml
name: Update Vibe Coded Badge

on:
  push:
    branches: [ main ]

permissions:
  contents: write

jobs:
  update-badge:
    runs-on: ubuntu-latest
    if: "!contains(github.event.head_commit.message, '[skip vibe-badge]')"
    
    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0
        
    - uses: trieloff/vibe-coded-badge-action@main
```

### Advanced Usage

```yaml
    - uses: trieloff/vibe-coded-badge-action@main
      with:
        readme-path: 'docs/README.md'
        badge-style: 'flat-square'
        badge-color: '00ff00'
        badge-text: 'AI_Generated'
        commit-message: 'Bot: Update AI percentage badge'
        debug: 'false'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `readme-path` | Path to the README file to update | No | `README.md` |
| `badge-style` | Badge style (flat, flat-square, plastic, for-the-badge, social) | No | `for-the-badge` |
| `badge-color` | Badge color (hex code without #) | No | `ff69b4` |
| `badge-text` | Text to display after percentage | No | `Vibe_Coded` |
| `commit-message` | Commit message for badge updates | No | `Update vibe-coded badge` |
| `debug` | Enable debug mode for detailed analysis | No | `false` |
| `github-token` | GitHub token for pushing changes | No | `${{ github.token }}` |

## Outputs

| Output | Description |
|--------|-------------|
| `percentage` | The calculated percentage of AI-generated lines of code |
| `changed` | Whether the badge was changed (true/false) |
| `dominant-ai` | The AI tool with the most lines of code |

## AI Detection Logic

The action identifies AI-generated code by analyzing git blame data:

1. **Author Attribution**: Uses `git blame` to determine who wrote each line of code
2. **AI Tool Detection**: Identifies authors with names/emails containing:
   - Claude, Anthropic
   - Cursor
   - Zed
   - Windsurf
   - OpenAI
   - Various bot accounts
3. **Line Filtering**: Filters out boilerplate lines (comments, empty lines, imports) for accuracy
4. **File Type Support**: Analyzes source files across multiple programming languages
5. **Bot Detection**: Identifies automated commits from tools like Renovate, semantic-release

## Logo Selection

The badge automatically selects the appropriate logo based on which AI tool has the most commits:

- **Claude** → `claude` logo
- **Codex** → `openai` logo  
- **Windsurf** → `windsurf` logo
- **Cursor** → `githubcopilot` logo
- **Zed** → `zedindustries` logo
- **Renovate** → `renovatebot` logo
- **Semantic Release** → `semanticrelease` logo
- **Other Bots** → `githubactions` logo

## Debug Mode

Enable debug mode to see detailed analysis:

```yaml
    - uses: trieloff/vibe-coded-badge-action@main
      with:
        debug: 'true'
```

This outputs:
- Total lines of code analyzed
- AI vs human line counts  
- Breakdown by AI tool type
- Selected logo information
- File type analysis

## Example Badge

The action generates badges like this:

## Git Aliases for AI Coding Tools

To improve AI detection accuracy, you can set up git aliases that automatically set the author name for different AI coding tools. This ensures commits are properly attributed and detected by the badge action.

### Recommended Aliases

Add these aliases to your git config to make AI tool detection more reliable:

```bash
# Claude Code commits
git config --global alias.claude-commit '!f() { msg="$1"; shift 1; git -c user.name="Claude Code" -c user.email="noreply@anthropic.com" -c commit.gpgsign=false commit -m "$msg" -m "Signed-off-by: $(git config user.name) <$(git config user.email)>" "$@"; }; f'

# Zed AI commits  
git config --global alias.zed-commit '!f() { msg="$1"; shift 1; git -c user.name="Zed AI" -c user.email="noreply@zed.dev" -c commit.gpgsign=false commit -m "$msg" -m "Signed-off-by: $(git config user.name) <$(git config user.email)>" "$@"; }; f'

# Cursor commits
git config --global alias.cursor-commit '!f() { msg="$1"; shift 1; git -c user.name="Cursor AI" -c user.email="noreply@cursor.com" -c commit.gpgsign=false commit -m "$msg" -m "Signed-off-by: $(git config user.name) <$(git config user.email)>" "$@"; }; f'

# Windsurf commits
git config --global alias.windsurf-commit '!f() { msg="$1"; shift 1; git -c user.name="Windsurf AI" -c user.email="noreply@codeium.com" -c commit.gpgsign=false commit -m "$msg" -m "Signed-off-by: $(git config user.name) <$(git config user.email)>" "$@"; }; f'

# OpenAI Codex commits
git config --global alias.openai-commit '!f() { msg="$1"; shift 1; git -c user.name="OpenAI Codex" -c user.email="noreply@openai.com" -c commit.gpgsign=false commit -m "$msg" -m "Signed-off-by: $(git config user.name) <$(git config user.email)>" "$@"; }; f'
```

### Usage

Instead of regular `git commit`, use the AI-specific aliases:

```bash
# Instead of: git commit -m "Add new feature"
git claude-commit "Add new feature"

# Instead of: git commit -m "Fix bug in parser"  
git zed-commit "Fix bug in parser"

# Instead of: git commit -m "Refactor database layer"
git cursor-commit "Refactor database layer"
```

### Benefits

- **Accurate Attribution**: Each AI tool gets proper credit in git history
- **Better Detection**: The badge action can distinguish between different AI tools
- **Dynamic Logos**: Badge automatically shows the logo of the dominant AI tool
- **Co-authorship**: Your name appears as co-author while AI gets primary credit
- **Consistent Format**: Standardized commit attribution across projects

### Alternative: Manual Override

You can also manually set the author for individual commits:

```bash
git -c user.name="Claude Code" -c user.email="noreply@anthropic.com" commit -m "Your message"
```

## Prerequisites

- Repository must have at least one commit
- Action needs `contents: write` permission to update README
- Use `fetch-depth: 0` to get full git history

## License

MIT License - see LICENSE file for details.

## Contributing

Pull requests welcome! Please ensure your commits follow the existing patterns for proper AI detection.
