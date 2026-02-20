---
name: finalrun-mcp-install
description: Install, update, and troubleshoot FinalRun MCP on macOS Apple Silicon using the official installer script and wrapper command. Use when FinalRun MCP is missing, not on PATH, failing to start, needs config updates, or needs an upgrade.
---

# FinalRun MCP Install

Install and maintain FinalRun MCP from the official production installer.

## Canonical Install Command

```bash
curl -fsSL https://get-mcp.finalrun.app/install.sh | bash
```

## Preflight Checks

1. Confirm `curl` is available.
2. Confirm platform is macOS (`Darwin`).
3. Confirm architecture is Apple Silicon (`arm64` or `aarch64`).

If platform/architecture does not match, stop and report unsupported environment.

## Install Workflow

1. Run the canonical install command.
2. If non-interactive install is required, run:

```bash
curl -fsSL https://get-mcp.finalrun.app/install.sh | bash -s -- --no-prompt
```

3. Verify wrapper command works:

```bash
finalrun-mcp --help
```

4. If command is not found, reload shell profile (`source ~/.zshrc` or equivalent) and retry.
5. Add IDE MCP config:

```json
{
  "mcpServers": {
    "finalrun": {
      "command": "finalrun-mcp"
    }
  }
}
```

6. Run a ping check from the IDE assistant.

## Config and Flags

Use installer flags when needed:

- `--api-key <key>`
- `--base-url <url>`
- `--test-runner-url <url>`
- `--binary-url <url>`
- `--no-prompt`

Persisted config file: `~/.finalrun/mcp/config`

## Update Workflow

Update to latest production binary:

```bash
finalrun-mcp update
```

Then restart the IDE MCP server/session.

## Install Paths

- Wrapper command: `~/.finalrun/bin/finalrun-mcp`
- Binary: `~/.finalrun/mcp/bin/finalrun-mcp-macos-arm64`
- Config: `~/.finalrun/mcp/config`

## Troubleshooting

Use references for quick diagnostics:

- Install flow details: [install-flow.md](references/install-flow.md)
- Config, env, and PATH behavior: [config-and-paths.md](references/config-and-paths.md)
- Failure handling and fixes: [troubleshooting.md](references/troubleshooting.md)
