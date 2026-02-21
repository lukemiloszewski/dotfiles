# Claude Code -> Logfire (Simple)
$ErrorActionPreference = "SilentlyContinue"

# Config
$LOG_FILE = "$env:USERPROFILE\.claude\state\logfire.log"
$STATE_FILE = "$env:USERPROFILE\.claude\state\logfire.json"

# Exit if disabled
if ($env:TRACE_TO_LOGFIRE -ne "true") { exit 0 }

# Read input
$input = [Console]::In.ReadToEnd() | ConvertFrom-Json
if ($input.stop_hook_active) { exit 0 }

$sessionId = $input.session_id
$transcript = $input.transcript_path -replace '^~', $env:USERPROFILE

if (-not (Test-Path $transcript)) { exit 0 }

# Load state
$state = if (Test-Path $STATE_FILE) { Get-Content $STATE_FILE -Raw | ConvertFrom-Json } else { @{} }
$lastLine = if ($state.$sessionId) { [int]$state.$sessionId } else { 0 }

# Get new messages
$lines = Get-Content $transcript
if ($lines.Count -le $lastLine) { exit 0 }

$newLines = $lines[$lastLine..($lines.Count-1)] | Where-Object { $_ }
if (-not $newLines) { exit 0 }

# Send each user->assistant pair as one trace
$user = $null
foreach ($line in $newLines) {
    $msg = $line | ConvertFrom-Json
    $role = if ($msg.message) { $msg.message.role } else { $msg.role }
    
    if ($role -eq "user" -and -not ($msg.message.content.type -contains "tool_result")) {
        $user = $msg
    }
    elseif ($role -eq "assistant" -and $user) {
        # Create trace
        $traceId = [guid]::NewGuid().ToString("N")
        $spanId = $traceId.Substring(0,16)
        $now = [long]((Get-Date).ToUniversalTime() - [datetime]'1970-01-01').TotalMilliseconds * 1000000
        
        $span = @{
            traceId = $traceId
            spanId = $spanId
            name = "Claude Turn"
            startTimeUnixNano = $now
            endTimeUnixNano = $now + 1000000000
            attributes = @(
                @{ key = "user.input"; value = @{ stringValue = ($user.message.content | ConvertTo-Json -Compress).Substring(0,500) }}
                @{ key = "assistant.output"; value = @{ stringValue = ($msg.message.content | ConvertTo-Json -Compress).Substring(0,500) }}
                @{ key = "session.id"; value = @{ stringValue = $sessionId }}
            )
        }
        
        $payload = @{
            resourceSpans = @(@{
                resource = @{ attributes = @(@{ key = "service.name"; value = @{ stringValue = "claude-code" }}) }
                scopeSpans = @(@{ scope = @{ name = "claude-code" }; spans = @($span) })
            })
        } | ConvertTo-Json -Depth 10
        
        # Send to Logfire
        try {
            Invoke-RestMethod -Uri "https://logfire-eu.pydantic.dev/v1/traces" `
                -Method Post `
                -Headers @{ "Authorization" = "Bearer $env:CC_LOGFIRE_TOKEN"; "Content-Type" = "application/json" } `
                -Body $payload
            "Sent trace" | Add-Content $LOG_FILE
        } catch {}
        
        $user = $null
    }
}

# Save state
$state.$sessionId = $lines.Count
$state | ConvertTo-Json | Set-Content $STATE_FILE
exit 0
