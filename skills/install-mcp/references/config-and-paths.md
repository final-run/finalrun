# Config and Paths

## Directory Layout

- Install root: `~/.finalrun`
- Wrapper bin dir: `~/.finalrun/bin`
- MCP home: `~/.finalrun/dev-mcp`
- Binary dir: `~/.finalrun/dev-mcp/bin`
- Config file: `~/.finalrun/dev-mcp/config`

## Wrapper Behavior

Wrapper command name: `finalrun-dev-mcp`

At runtime the wrapper:

1. Reads `~/.finalrun/dev-mcp/config`.
2. Reads env overrides if present.
3. Appends missing args (`--api-key`, `--base-url`, `--test-runner-url`) before executing binary.
4. Supports `finalrun-dev-mcp update` by rerunning dev installer with `--no-prompt`.
5. Allows MCP home override via `FINALRUN_DEV_MCP_HOME`.

## Config Keys

- `FINALRUN_API_KEY`
- `FINALRUN_BASE_URL`
- `FINALRUN_TEST_RUNNER_URL`

Defaults used by installer when not supplied:

- Base URL: `https://dev-api.finalrun.app`
- Test runner URL: `https://dev-testrun.finalrun.app/api`

## PATH Update Behavior

Installer appends `~/.finalrun/bin` to profile based on shell:

- zsh: `~/.zshrc`
- bash: `~/.bash_profile` or `~/.bashrc`
- fish: `~/.config/fish/config.fish`
- fallback: `~/.profile`

## IDE MCP Config Locations

- **Cursor**: `.cursor/mcp.json` in project root (project-level) or `~/.cursor/mcp.json` (global)
- **Claude Code**: managed via `claude mcp add` CLI command
- **Windsurf**: MCP settings in IDE preferences
- **Claude Desktop**: `~/Library/Application Support/Claude/claude_desktop_config.json`

