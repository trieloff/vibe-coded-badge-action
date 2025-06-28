# Vibe Coded Badge Action

[![100% Vibe Coded](https://img.shields.io/badge/100%25-Vibe_Coded-ff69b4?style=for-the-badge&logo=claude&logoColor=white)](https://github.com/trieloff/vibe-coded-badge-action)

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
        
    - uses: trieloff/vibe-coded-badge-action@v1
```

### Advanced Usage

```yaml
    - uses: trieloff/vibe-coded-badge-action@v1
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
| `percentage` | The calculated percentage of AI-coded commits |
| `changed` | Whether the badge was changed (true/false) |
| `dominant-ai` | The AI tool with the most commits |

## AI Detection Logic

The action identifies AI-generated commits by analyzing:

1. **Author Names**: Checks for Claude, Cursor, Zed, Windsurf, OpenAI in commit authors
2. **Commit Messages**: Looks for patterns like:
   - 🤖 emoji
   - "generated with"
   - "co-authored-by" with AI tools
   - "signed-off-by" with AI tools
3. **Bot Accounts**: Detects `[bot]` accounts like renovate[bot], semantic-release[bot]
4. **Branch Names**: Identifies commits on branches containing "codex"
5. **Merge Commits**: Detects pull requests from codex branches

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
    - uses: trieloff/vibe-coded-badge-action@v1
      with:
        debug: 'true'
```

This outputs:
- Total commit breakdown
- AI vs human commit counts  
- Detailed list of each commit type
- Selected logo information
- Chronological commit analysis

## Example Badge

The action generates badges like this:

[![85% Vibe Coded](https://img.shields.io/badge/85%25-Vibe_Coded-ff69b4?style=for-the-badge&logo=claude&logoColor=white)](https://github.com/user/repo)

## Prerequisites

- Repository must have at least one commit
- Action needs `contents: write` permission to update README
- Use `fetch-depth: 0` to get full git history

## License

MIT License - see LICENSE file for details.

## Contributing

Pull requests welcome! Please ensure your commits follow the existing patterns for proper AI detection.