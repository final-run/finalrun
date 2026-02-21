#!/usr/bin/env bash
set -euo pipefail

SKILLS_REPO="${SKILLS_REPO:-final-run/finalrun}"
AGENTS_CSV="${AGENTS:-claude,cursor,codex}"

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

install_skills() {
  print_header "Install FinalRun skills"
  local npx_checked=false

  IFS=',' read -r -a agents <<< "${AGENTS_CSV}"
  for agent in "${agents[@]}"; do
    local trimmed
    trimmed="$(echo "$agent" | xargs)"
    if [[ -z "$trimmed" ]]; then
      continue
    fi
    if [[ "$trimmed" == "claude" ]]; then
      if command -v claude >/dev/null 2>&1; then
        echo "Installing skills for agent: claude (claude plugin add)"
        claude plugin add "github:${SKILLS_REPO}" || true
      else
        echo "Skipped Claude skills install: claude CLI not found."
        echo "Run manually:"
        echo "  claude plugin add github:${SKILLS_REPO}"
      fi
      continue
    fi

    if [[ "$npx_checked" == "false" ]]; then
      require_cmd npx
      npx_checked=true
    fi
    echo "Installing skills for agent: $trimmed"
    npx -y ai-agent-skills install "${SKILLS_REPO}" --agent "$trimmed"
  done
}

main() {
  install_skills

  print_header "Done"
  echo "If needed, restart your IDE so skills are picked up."
}

main "$@"
