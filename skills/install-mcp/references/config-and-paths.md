# Config and Paths

## Directory Layout

- Install root: `~/.finalrun`
- Wrapper bin dir: `~/.finalrun/bin`
- MCP home: `~/.finalrun/mcp`
- Binary dir: `~/.finalrun/mcp/bin`
- Config file: `~/.finalrun/mcp/config`

## Wrapper Behavior

Wrapper command name: `finalrun-mcp`

At runtime the wrapper:

1. Reads `~/.finalrun/mcp/config`.
2. Reads env overrides if present.
3. Appends missing args (`--api-key`, `--base-url`, `--test-runner-url`) before executing binary.
4. Supports `finalrun-mcp update` by rerunning installer with `--no-prompt`.

## Config Keys

- `FINALRUN_API_KEY`
- `FINALRUN_BASE_URL`
- `FINALRUN_TEST_RUNNER_URL`

Defaults used by installer when not supplied:

- Base URL: `https://api.finalrun.app`
- Test runner URL: `https://testrun.finalrun.app/api`

## PATH Update Behavior

Installer appends `~/.finalrun/bin` to profile based on shell:

- zsh: `~/.zshrc`
- bash: `~/.bash_profile` or `~/.bashrc`
- fish: `~/.config/fish/config.fish`
- fallback: `~/.profile`
