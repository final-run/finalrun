# Troubleshooting

## Unsupported Platform

Symptom:
- Installer exits with macOS-only or Apple-Silicon-only error.

Action:
- Stop install.
- Report that current installer supports only `Darwin` + `arm64/aarch64`.

## Download Failure

Symptom:
- Binary URL cannot be reached or download fails.

Action:
1. Verify network access.
2. Retry install command.
3. If needed, pass a known-good binary URL with `--binary-url`.

## Command Not Found After Install

Symptom:
- `finalrun-dev-mcp` not found.

Action:
1. Verify wrapper exists at `~/.finalrun/bin/finalrun-dev-mcp`.
2. Reload shell profile (`source ~/.zshrc` or equivalent).
3. Retry `finalrun-dev-mcp --help`.

## Wrapper Exists but Runtime Fails

Action:
1. Confirm binary exists and is executable:
- `~/.finalrun/dev-mcp/bin/finalrun-mcp-macos-arm64`
2. Check config file presence and permissions:
- `~/.finalrun/dev-mcp/config` should be mode `600`.
3. Re-run installer.
4. Retry with explicit args (`--api-key`, `--base-url`, `--test-runner-url`) to rule out config parsing issues.

## Update Issues

Symptom:
- `finalrun-dev-mcp update` fails.

Action:
1. Re-run dev installer command directly:
   - `curl -fsSL https://get-mcp-dev.finalrun.app/install-dev.sh | bash`
2. Restart IDE MCP server after successful update.
