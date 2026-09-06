#!/usr/bin/env bash
# Set Terminal Title
echo -ne "\033]0;THEVOIDKERNEL - PORTABLE AGENTS (Hermes, OpenClaw & Claude Code)\007"

RESET="\033[0m"
BOLD="\033[1m"
BRIGHT_CYAN="\033[96m"
BRIGHT_YELLOW="\033[93m"
GRAY="\033[90m"

echo -e "${BRIGHT_CYAN}===================================================${RESET}"
echo -e "${BOLD}${BRIGHT_YELLOW}                   THEVOIDKERNEL${RESET}"
echo -e "${BRIGHT_CYAN}===================================================${RESET}"
echo -e "${GRAY}[ 🤖 Claude Code (OpenClaude) - Portable Workspace Setup & Run ]${RESET}"
echo ""

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/OpenClaude
cd "$SCRIPT_DIR"
exec bash "$SCRIPT_DIR/start.sh" "$@"
