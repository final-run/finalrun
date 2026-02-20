# FinalRun Skills

AI skills for [FinalRun](https://finalrun.app) — manage and run mobile app tests from your AI coding assistant.

## Skills

| Skill | What it does |
|---|---|
| `generate-test` | Generate test cases from your codebase and upload to FinalRun |
| `run-test` | Run tests/suites on cloud or local devices |
| `update-test` | Update existing test prompts when code changes break them |
| `install-mcp` | Install, update, or troubleshoot FinalRun MCP server |

## Commands

| Command | Triggers |
|---|---|
| `/generate-tests` | Invoke `generate-test` skill |
| `/run-test` | Invoke `run-test` skill |
| `/update-tests` | Invoke `update-test` skill |
| `/install-mcp` | Invoke `install-mcp` skill |

## Setup

### 1. Install FinalRun MCP Server

```bash
curl -fsSL https://get-mcp-dev.finalrun.app/install-dev.sh | bash
```

Or ask your AI assistant: _"Install FinalRun MCP"_ (uses the `install-mcp` skill).

### 2. Configure Your IDE

**Claude Code:**

```bash
# Add MCP server
claude mcp add --transport stdio finalrun-dev -- finalrun-dev-mcp

# Install skills plugin
claude plugin add github:AshishYUO/finalrun-skills
```

**Cursor:**

1. Add MCP server — create `.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "finalrun-dev": {
      "command": "finalrun-dev-mcp"
    }
  }
}
```

2. Copy rules to your project:

```bash
cp -r <path-to-finalrun-skills>/rules/*.mdc .cursor/rules/
```

**Windsurf / Claude Desktop:**

Add to MCP settings:

```json
{
  "mcpServers": {
    "finalrun-dev": {
      "command": "finalrun-dev-mcp"
    }
  }
}
```

### 3. Verify

Ask your AI assistant: _"Ping FinalRun"_

You should see your organization name.

## API Key

Get your API key from [FinalRun Dashboard](https://studio.finalrun.app) → Account → API Key.

The installer prompts for the key during setup. It's stored in `~/.finalrun/dev-mcp/config` and read automatically by the wrapper command.
