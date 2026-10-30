#!/bin/bash
# File operation safety guard for bypass mode
# Exit 0 = allow, Exit 2 = block with message to stderr

if ! command -v jq >/dev/null 2>&1; then
    echo "ERROR: jq is required for safety hooks but not found. Install with: brew install jq" >&2
    exit 2
fi

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null)

# Normalize path
PATH_LOWER=$(echo "$FILE_PATH" | tr '[:upper:]' '[:lower:]')

# === READS ===

# Only the secrets written by secrets-refresh are off limits; every other
# rule below is about writes.
if [[ "$TOOL_NAME" == "Read" ]]; then
    if [[ "$FILE_PATH" == "$HOME/.config/secrets/.env" || "$FILE_PATH" == "~/.config/secrets/.env" ]]; then
        echo "BLOCKED: Cannot read secrets file: $FILE_PATH - use ! to override" >&2
        exit 2
    fi
    exit 0
fi

# === BLOCKED PATHS ===

# 1. System directories
if echo "$PATH_LOWER" | grep -qE '^(/etc/|/usr/|/bin/|/sbin/|/var/|/lib/|/boot/)'; then
    echo "BLOCKED: Cannot write to system directory: $FILE_PATH - use ! to override" >&2
    exit 2
fi

# 2. Home directory config files (outside project)
if echo "$PATH_LOWER" | grep -qE '^(/users/[^/]+|~|/home/[^/]+)/\.(ssh|aws|gnupg|config|zshrc|bashrc|profile|netrc)'; then
    echo "BLOCKED: Cannot modify user config files: $FILE_PATH - use ! to override" >&2
    exit 2
fi

# 3. Credential files
if echo "$PATH_LOWER" | grep -qE '(credentials|secrets?\.json|\.env$|\.pem$|\.key$|id_rsa|id_ed25519)'; then
    # Allow .env.example or .env.local within project
    if echo "$FILE_PATH" | grep -qE '\.env\.(example|sample|template)$'; then
        exit 0
    fi
    # Check if in project directory (CLAUDE_PROJECT_DIR)
    if [[ -n "$CLAUDE_PROJECT_DIR" ]] && [[ "$FILE_PATH" == "$CLAUDE_PROJECT_DIR"* ]]; then
        # Allow .env files in project, but warn
        if echo "$PATH_LOWER" | grep -qE '\.env$'; then
            exit 0 # Allow project .env files
        fi
    fi
    echo "BLOCKED: Cannot write credential/secret file: $FILE_PATH - use ! to override" >&2
    exit 2
fi

# 4. Package manager config (outside project)
if echo "$PATH_LOWER" | grep -qE '^(/users/|~|/home/).*(\.npmrc|\.yarnrc|\.bunfig)'; then
    echo "BLOCKED: Cannot modify global package manager config: $FILE_PATH - use ! to override" >&2
    exit 2
fi

# 5. Git global config
if echo "$PATH_LOWER" | grep -qE '^(/users/|~|/home/)[^/]+/\.gitconfig$'; then
    echo "BLOCKED: Cannot modify global git config: $FILE_PATH - use ! to override" >&2
    exit 2
fi

# 6. Shell history
if echo "$PATH_LOWER" | grep -qE '\.(bash_history|zsh_history|history)$'; then
    echo "BLOCKED: Cannot modify shell history: $FILE_PATH - use ! to override" >&2
    exit 2
fi

# 7. Launchd/cron
if echo "$PATH_LOWER" | grep -qE '(launchagents|launchdaemons|cron)'; then
    echo "BLOCKED: Cannot modify scheduled tasks: $FILE_PATH - use ! to override" >&2
    exit 2
fi

# === ALLOWED ===
exit 0
