#!/usr/bin/env bash
set -euo pipefail

SKILLS_REPO="${SKILLS_REPO:-final-run/finalrun}"
AGENTS_CSV="${AGENTS:-claude,cursor,codex}"
MCP_INSTALL_URL="${MCP_INSTALL_URL:-get-mcp-dev.finalrun.app/install-dev.sh}"

print_header() {
  echo ""
  echo "==> $1"
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: required command not found: $1" >&2
    exit 1
  fi
}

install_mcp() {
  print_header "Install FinalRun MCP server"
  require_cmd curl

  echo "Downloading and running MCP installer from: ${MCP_INSTALL_URL}"
  curl -fsSL "${MCP_INSTALL_URL}" | bash -s -- "$@"
}

install_skills() {
  print_header "Install FinalRun skills"
  require_cmd npx

  IFS=',' read -r -a agents <<< "${AGENTS_CSV}"
  for agent in "${agents[@]}"; do
    local trimmed
    trimmed="$(echo "$agent" | xargs)"
    if [[ -z "$trimmed" ]]; then
      continue
    fi
    echo "Installing skills for agent: $trimmed"
    npx -y ai-agent-skills install "${SKILLS_REPO}" --agent "$trimmed"
  done
}

main() {
  install_mcp "$@"
  install_skills

  print_header "Done"
  echo "FinalRun MCP server and skills installed."
  echo "If needed, restart your IDE so skills and MCP are picked up."
}

main "$@"
