---
name: finalrun-mcp-install
description: Install, update, and troubleshoot FinalRun DEV MCP on macOS Apple Silicon using the official dev installer script and wrapper command. Use when FinalRun DEV MCP is missing, not on PATH, failing to start, needs config updates, or needs an upgrade.
---

# FinalRun MCP Install

Install and maintain FinalRun MCP from the official dev/staging installer.

## Canonical Install Command

```bash
curl -fsSL https://get-mcp-dev.finalrun.app/install-dev.sh | bash
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
curl -fsSL https://get-mcp-dev.finalrun.app/install-dev.sh | bash -s -- --no-prompt
```

3. Verify wrapper command works:

```bash
finalrun-dev-mcp --help
```

4. If command is not found, reload shell profile (`source ~/.zshrc` or equivalent) and retry.
5. Add IDE MCP config:

**Cursor** — create or update `.cursor/mcp.json` in the project root (or globally):

```json
{
  "mcpServers": {
    "finalrun-dev": {
      "command": "finalrun-dev-mcp"
    }
  }
}
```

**Claude Code** — run:

```bash
claude mcp add --transport stdio finalrun-dev -- finalrun-dev-mcp
```

Verify with `claude mcp list` or `/mcp` inside Claude Code.

**Windsurf / Claude Desktop** — add to MCP settings:

```json
{
  "mcpServers": {
    "finalrun-dev": {
      "command": "finalrun-dev-mcp"
    }
  }
}
```

6. Run a ping check from the IDE assistant.

## API Key

- The installer prompts for an API key interactively.
- If using `--no-prompt`, pass `--api-key <key>` or edit `~/.finalrun/dev-mcp/config` manually.
- Get your API key from [FinalRun Dashboard](https://studio.finalrun.app) → Account → API Key.
- The wrapper reads the key from config at runtime; no need to pass it in IDE MCP config.

## Config and Flags

Use installer flags when needed:

- `--api-key <key>`
- `--base-url <url>`
- `--test-runner-url <url>`
- `--binary-url <url>`
- `--no-prompt`

Persisted config file: `~/.finalrun/dev-mcp/config`

## Update Workflow

Update to latest dev/staging binary:

```bash
finalrun-dev-mcp update
```

Then restart the IDE MCP server/session.

## Install Paths

- Wrapper command: `~/.finalrun/bin/finalrun-dev-mcp`
- Binary: `~/.finalrun/dev-mcp/bin/finalrun-mcp-macos-arm64`
- Config: `~/.finalrun/dev-mcp/config`

## Troubleshooting

Use references for quick diagnostics:

- Install flow details: [install-flow.md](references/install-flow.md)
- Config, env, and PATH behavior: [config-and-paths.md](references/config-and-paths.md)
- Failure handling and fixes: [troubleshooting.md](references/troubleshooting.md)
