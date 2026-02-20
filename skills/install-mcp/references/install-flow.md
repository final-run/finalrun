# Install Flow (From `install.sh`)

## Sequence

1. Parse CLI args.
2. Check prerequisites (`curl`, `uname`).
3. Enforce platform guardrails:
- `uname -s` must be `Darwin`
- `uname -m` must be `arm64` or `aarch64`
4. Download binary from default or overridden `--binary-url`.
5. Install wrapper script at `~/.finalrun/bin/finalrun-mcp`.
6. Write config at `~/.finalrun/mcp/config`.
7. Append `~/.finalrun/bin` to shell profile PATH if missing.
8. Verify install by running `finalrun-mcp --help`.
9. Print IDE MCP config and update instructions.

## Interactive vs Non-Interactive

- Interactive mode prompts for API key if not already provided.
- Non-interactive mode uses `--no-prompt` and skips API key prompt.

## Canonical Commands

```bash
curl -fsSL https://get-mcp.finalrun.app/install.sh | bash
```

# use --no-prompt during `finalrun-mcp update`
```bash
curl -fsSL https://get-mcp.finalrun.app/install.sh | bash -s -- --no-prompt
```
