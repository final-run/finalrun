# FinalRun Skills

AI skills for [FinalRun](https://finalrun.app) — manage and run mobile app tests from your AI coding assistant.

## Prerequisites

FinalRun MCP server must be installed and configured before using these skills.
Get your API key from [FinalRun Studio](https://studio.finalrun.app) or Profile > API Key in the FinalRun macOS app.

## Skills

| Skill | What it does |
|---|---|
| `generate-test` | Generate test cases from your codebase and upload to FinalRun |
| `run-test` | Run tests/suites on cloud or local devices |
| `update-test` | Update existing test prompts when code changes break them |

## Commands

| Command | Triggers |
|---|---|
| `/generate-tests` | Invoke `generate-test` skill |
| `/run-test` | Invoke `run-test` skill |
| `/update-tests` | Invoke `update-test` skill |

## Setup

Install skills for your IDE:

```bash
./setup.sh
```

By default, installs for Claude, Cursor, and Codex. Override with:

```bash
AGENTS=claude,cursor ./setup.sh
```

### Manual Install

**Claude Code:**

```bash
claude plugin add github:final-run/finalrun
```

**Cursor / Other agents:**

```bash
npx -y ai-agent-skills install final-run/finalrun --agent cursor
```
