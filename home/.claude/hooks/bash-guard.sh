#!/bin/bash
# Bash command safety guard for bypass mode
# Exit 0 = allow, Exit 2 = block with message to stderr

if ! command -v jq >/dev/null 2>&1; then
    echo "ERROR: jq is required for safety hooks but not found. Install with: brew install jq" >&2
    exit 2
fi

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null)

# Normalize: lowercase, collapse whitespace
CMD_LOWER=$(echo "$COMMAND" | tr '[:upper:]' '[:lower:]' | tr -s ' ')

# One simple command per line, so a rule can't pair a verb in one command
# with a path in another (`mv a b && ls .env.op`)
SEGMENTS=$(printf '%s\n' "$CMD_LOWER" | awk '{ gsub(/&&|\|\||;|\|/, "\n"); print }')

# === BLOCKED PATTERNS ===

# 1. Recursive or forced rm whose target is root, a home folder or a top-level
# system folder itself; paths inside them (rm -r ~/.cache/x) are allowed
Q='["'"'"']?'
RM_TARGET='(/|~|\$home|\$\{home\}|/users(/[^/ ]+)?|/home(/[^/ ]+)?|/var|/etc|/usr|/bin|/sbin|/system|/library|/applications)'
if echo "$SEGMENTS" | grep -qE '(^|\s)rm\s+(-[a-z-]*\s+)*-[a-z]*[rf][a-z]*\s+(-[a-z-]*\s+)*'"$Q$RM_TARGET"'/?\*?'"$Q"'(\s|$)'; then
    echo "BLOCKED: Destructive operation on system directory - use ! to override" >&2
    exit 2
fi

# 2. sudo commands (should be explicit)
if echo "$CMD_LOWER" | grep -qE '^\s*sudo\s'; then
    echo "BLOCKED: sudo requires explicit approval - use ! to override" >&2
    exit 2
fi

# 3. Credential/secret file access, checked per command. Templates
# (.env.example and similar, .env.op references) hold no secrets.
CRED_SEGMENTS=$(echo "$SEGMENTS" | sed -E 's/\.env\.(op|example|sample|template)([^a-z0-9_]|$)/\2/g')
if echo "$CRED_SEGMENTS" | grep -qE '(^|[^a-z0-9_.-])(cat|less|more|head|tail|read|cp|mv|scp|grep|rg|sed|awk|source|bat|xxd|strings)\s.*(/\.ssh/|/\.aws/|/\.gnupg/|/\.netrc|credentials|\.env([^a-z0-9_]|$)|secrets?\.)'; then
    echo "BLOCKED: Accessing credential/secret files - use ! to override" >&2
    exit 2
fi

# Any command naming the secrets written by secrets-refresh (not the .env.op references)
if echo "$CMD_LOWER" | grep -qE 'secrets/\.env([^.a-z0-9_]|$)'; then
    echo "BLOCKED: Accessing ~/.config/secrets/.env - use ! to override" >&2
    exit 2
fi

# 4. System modification
if echo "$CMD_LOWER" | grep -qE '(chown|chmod)\s+.*(/etc|/usr|/bin|/var)'; then
    echo "BLOCKED: System file permission changes - use ! to override" >&2
    exit 2
fi

# 5. Dangerous curl/wget piped to shell
if echo "$CMD_LOWER" | grep -qE '(curl|wget).*\|\s*(bash|sh|zsh|python|node)'; then
    echo "BLOCKED: Piping remote content to shell is dangerous - use ! to override" >&2
    exit 2
fi

# 6. npm/yarn/bun global installs (should be explicit)
if echo "$CMD_LOWER" | grep -qE '(npm|yarn|pnpm)\s+(install|i)\s+(-g|--global)'; then
    echo "BLOCKED: Global package installs require manual approval - use ! to override" >&2
    exit 2
fi

# 7. Disk/system commands
if echo "$CMD_LOWER" | grep -qE '^\s*(mkfs|fdisk|dd\s+if=|diskutil\s+erase)'; then
    echo "BLOCKED: Disk manipulation commands - use ! to override" >&2
    exit 2
fi

# 8. Process killing (system processes)
if echo "$CMD_LOWER" | grep -qE 'kill(all)?\s+(-9\s+)?-1\b|pkill\s+-9\s+'; then
    echo "BLOCKED: Mass process termination - use ! to override" >&2
    exit 2
fi

# 9. Network exfiltration patterns
if echo "$CMD_LOWER" | grep -qE '(curl|wget|nc|netcat).*(-d|--data|<)\s*.*(\\$|`|/etc/|/users/|/home/)'; then
    echo "BLOCKED: Potential data exfiltration pattern - use ! to override" >&2
    exit 2
fi

# 10. Eval/exec of dynamic content
if echo "$CMD_LOWER" | grep -qE 'eval\s+"\$|bash\s+-c\s+"\$'; then
    echo "BLOCKED: Dynamic code execution - use ! to override" >&2
    exit 2
fi

# 11. Cron/scheduled task modification
if echo "$CMD_LOWER" | grep -qE '(crontab\s+-|launchctl\s+(load|unload|submit))'; then
    echo "BLOCKED: Scheduled task modification requires manual approval - use ! to override" >&2
    exit 2
fi

# 12. SSH key generation/modification
if echo "$CMD_LOWER" | grep -qE 'ssh-keygen|ssh-add'; then
    echo "BLOCKED: SSH key operations require manual approval - use ! to override" >&2
    exit 2
fi

# 13. Keychain/credential store access
if echo "$CMD_LOWER" | grep -qE 'security\s+(find|delete|add)-(generic|internet)-password|keychain'; then
    echo "BLOCKED: Keychain access - use ! to override" >&2
    exit 2
fi

# 14. Environment variable dumps that might leak secrets
if echo "$CMD_LOWER" | grep -qE '^\s*(env|printenv|export)\s*$|set\s*\|'; then
    echo "BLOCKED: Full environment dump may leak secrets. Use specific vars instead - use ! to override" >&2
    exit 2
fi

# === ALLOWED ===
exit 0
