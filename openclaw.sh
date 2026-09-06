#!/usr/bin/env sh
# Set Terminal Title
echo -ne "\033]0;THEVOIDKERNEL - PORTABLE AGENTS (Hermes & Openclaw)\007"

# ANSI Colors
RESET="\033[0m"
BOLD="\033[1m"
BRIGHT_CYAN="\033[96m"
BRIGHT_GREEN="\033[92m"
GRAY="\033[90m"

echo -e "${BRIGHT_CYAN}===================================================${RESET}"
echo -e "${BOLD}${BRIGHT_GREEN}                   THEVOIDKERNEL${RESET}"
echo -e "${BRIGHT_CYAN}===================================================${RESET}"
echo -e "${GRAY}[ 🦞 OpenClaw Agent - Portable Workspace Setup & Run ]${RESET}"
echo ""

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/openclaw
exec sh "$SCRIPT_DIR/bin/unix.sh"
