# ⚡ Portable Agents Suite (THEVOIDKERNEL)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows%2010%2B-0078D6?logo=windows)](#windows)
[![Platform: Linux](https://img.shields.io/badge/Platform-Linux%20x64%20%7C%20arm64-FCC624?logo=linux&logoColor=black)](#linux)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS%20Intel%20%7C%20Apple%20Silicon-000000?logo=apple)](#macos)
[![Agent: OpenClaw](https://img.shields.io/badge/Agent-OpenClaw-green)](#1-openclaw-portable-agent)
[![Agent: Hermes](https://img.shields.io/badge/Agent-Hermes%20Agent-purple)](#2-hermes-portable-agent)
[![Agent: Claude Code](https://img.shields.io/badge/Agent-Claude%20Code%20(OpenClaude)-orange)](#3-claude-code--openclaude-portable-agent)

> **The ultimate USB-ready, zero-installation AI Agent workstation.**  
> Run top-tier autonomous AI coding and workflow agents—**OpenClaw**, **Hermes**, and **Claude Code (OpenClaude)**—directly from a portable drive or folder without touching host system files, polluting global environment variables, or requiring system-wide dependencies.

---

## 📑 Table of Contents

- [Overview & Philosophy](#-overview--philosophy)
- [The 3 Autonomous Agents](#-the-3-autonomous-agents)
  - [1. OpenClaw Portable Agent](#1-openclaw-portable-agent)
  - [2. Hermes Portable Agent](#2-hermes-portable-agent)
  - [3. Claude Code / OpenClaude Portable Agent](#3-claude-code--openclaude-portable-agent)
- [Architecture & Isolation Model](#-architecture--isolation-model)
- [Directory Structure](#-directory-structure)
- [Quick Start Guide](#-quick-start-guide)
  - [Windows](#windows)
  - [Linux](#linux)
  - [macOS](#macos)
- [Detailed Agent Guides & Features](#-detailed-agent-guides--features)
  - [OpenClaw Operations](#openclaw-operations)
  - [Hermes Agent Operations](#hermes-agent-operations)
  - [Claude Code (OpenClaude) Operations](#claude-code-openclaude-operations)
- [Maintenance & Reset](#-maintenance--reset)
- [Troubleshooting & FAQ](#-troubleshooting--faq)
- [License & Acknowledgements](#-license--acknowledgements)

---

## 💡 Overview & Philosophy

Setting up agentic AI environments usually requires installing complex developer toolchains: specific Python releases, virtual environments, Node.js runtimes, package managers, browser automators, and background services. When moving between computers, labs, or servers, everything breaks or has to be reconfigured.

**Portable Agents Suite (THEVOIDKERNEL)** provides an all-in-one, completely isolated triad of cutting-edge AI agents that travel with you on any USB drive or external SSD:

1. **100% Host-Isolated:** Every agent ships with its own sandboxed interpreter (standalone Python 3.11, isolated Node.js v22/v24), package caches, config stores, and session databases.
2. **Drive-Letter Agnostic:** Dynamic path resolution automatically adapts whether your drive mounts as `D:`, `E:`, `X:`, `/Volumes/USB`, or `/media/usb`.
3. **Zero Host Contamination:** Host `%APPDATA%`, `~/.config`, and system PATH variables remain strictly untouched.
4. **Three Specialized Agents:**
   - 🦞 **OpenClaw:** Robust autonomous agent framework with background gateway, loopback daemon, and multi-channel capabilities.
   - ⚕ **Hermes Agent:** Nous Research's versatile agent with TUI chat, messaging gateways (Telegram, Slack, WhatsApp), custom personas (`SOUL.md`), and MCP support.
   - 🤖 **Claude Code (OpenClaude):** Full-featured AI coding agent with multi-model provider support (Anthropic, DeepSeek, Gemini, OpenAI, Ollama), smart system-prompt trimming proxy, and web dashboard.

---

## 🤖 The 3 Autonomous Agents

### Comparison Matrix

| Feature | OpenClaw | Hermes Agent | Claude Code (OpenClaude) |
| :--- | :--- | :--- | :--- |
| **Primary Focus** | Autonomous tasks & workflows | Versatile assistant & messaging | Coding, refactoring & development |
| **Runtime Base** | Isolated Node.js v24 | Standalone CPython 3.11 + Node 22 | Isolated Node.js v22 |
| **Interface Options** | Interactive CLI + Gateway | Terminal TUI + CLI + Gateway | CLI + Web Dashboard UI |
| **Messaging Gateways** | Loopback Gateway (port 18789) | Telegram, WhatsApp, Slack, Webhooks | Local Speed Proxy + Web Dashboard |
| **Provider Support** | Configurable via OpenClaw | Local Ollama, OpenAI, DeepSeek, OpenRouter | Anthropic, DeepSeek, Gemini, OpenAI, Ollama |
| **Primary Launchers** | `openclaw.bat` / `openclaw.sh` | `hermes.bat` / `hermes.sh` | `claude.bat` / `claude.sh` |

---

### 1. OpenClaw Portable Agent
- **Powered by:** OpenClaw framework.
- **Environment:** Portable Node.js v24 runtime across Windows x64, Linux (x64/arm64), and macOS (x64/arm64).
- **Core Features:**
  - Sandboxed `OPENCLAW_HOME`, `OPENCLAW_STATE_DIR`, and workspace folders.
  - Background Gateway daemon on port `18789` with health checks, loopback binding, and auto-restart.
  - Interactive management menu for sessions, channels, diagnostic logs, and portable subshell.

### 2. Hermes Portable Agent
- **Powered by:** [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent).
- **Environment:** Standalone CPython 3.11, Node.js 22, `uv` package manager, MinGit, ripgrep, and Playwright.
- **Core Features:**
  - Dynamic `pyvenv.cfg` rewriting on boot to ensure portability across different drive mount letters.
  - Rich ANSI-styled TUI chat interface (`hermes chat` or menu option `[1]`).
  - Interactive setup wizard for choosing LLM backends (OpenAI, DeepSeek, OpenRouter, Ollama, etc.).
  - Background messaging daemon for controlling the agent via **Telegram Bot**, WhatsApp, Slack, or cron jobs.
  - Persona customization via `Hermes/data/SOUL.md`.

### 3. Claude Code / OpenClaude Portable Agent
- **Powered by:** [OpenClaude](https://github.com/gitlawb/openclaude) (Open-source Claude Code implementation).
- **Environment:** Bundled portable Node.js runtime and isolated npm cache.
- **Core Features:**
  - **9 AI Providers:** Anthropic Claude, DeepSeek, Google Gemini, OpenAI, OpenRouter, NVIDIA NIM, local Ollama (offline), LM Studio, and custom OpenAI-compatible APIs.
  - **Local Speed Proxy:** Built-in proxy (`tools/local-proxy.js`) that trims system prompts by up to 90% for offline models on CPU hardware.
  - **Web Dashboard:** ChatGPT-style browser user interface with thinking visualization and tool cards.
  - **Autonomy Modes:** Normal Mode (prompts before disk write / execution) and Limitless Mode (fully autonomous execution).
  - **Session Resume:** Seamlessly recover interrupted sessions with full context.

---

## 🏛 Architecture & Isolation Model

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                              PORTABLE TOOLS WORKSPACE                                  │
└────────────────────────────────────────────────────────────────────────────────────────┘
            │                                 │                                │
            ▼                                 ▼                                ▼
┌───────────────────────┐         ┌───────────────────────┐        ┌─────────────────────────┐
│       OPENCLAW        │         │     HERMES AGENT      │        │  CLAUDE CODE (OPENCLAUDE│
├───────────────────────┤         ├───────────────────────┤        ├─────────────────────────┤
│ • Launcher:           │         │ • Launcher:           │        │ • Launcher:             │
│   openclaw.bat / .sh  │         │   hermes.bat / .sh    │        │   claude.bat / .sh      │
│ • Node.js v24 runtime │         │ • Python 3.11 + uv    │        │ • Node.js runtime       │
│ • Gateway: port 18789 │         │ • Node 22 + MinGit    │        │ • Speed Proxy           │
│ • Sandboxed workspace │         │ • Telegram / Slack GW │        │ • Web Dashboard UI      │
│ • Isolated npm-cache  │         │ • SOUL.md system prompt│       │ • 9 Provider options    │
└───────────────────────┘         └───────────────────────┘        └─────────────────────────┘
            │                                 │                                │
            ▼                                 ▼                                ▼
┌───────────────────────┐         ┌───────────────────────┐        ┌─────────────────────────┐
│     openclaw/data/    │         │     Hermes/data/      │        │    OpenClaude/data/     │
│ (State, keys, config) │         │ (Sessions, keys, logs)│        │  (Sessions, keys, logs) │
└───────────────────────┘         └───────────────────────┘        └─────────────────────────┘
```

---

## 📂 Directory Structure

```text
Portable Tools/
│
├── claude.bat                  # Root Windows launcher for Claude Code (OpenClaude)
├── claude.sh                   # Root Unix/macOS launcher for Claude Code
├── openclaude.bat              # Convenience alias launcher
├── openclaude.sh               # Convenience alias launcher
│
├── hermes.bat                  # Root Windows launcher for Hermes Agent
├── hermes.sh                   # Root Unix/macOS launcher for Hermes Agent
│
├── openclaw.bat                # Root Windows launcher for OpenClaw Agent
├── openclaw.sh                 # Root Unix/macOS launcher for OpenClaw Agent
│
├── LICENSE                     # MIT License
├── README.md                   # Complete documentation
├── .gitignore                  # Prevents cached runtimes and data from git tracking
│
├── Hermes/                     # Hermes Agent portable subsystem
│   ├── scripts/
│   │   ├── COMMANDS.md         # Detailed Hermes CLI & Gateway command reference
│   │   ├── setup-windows.ps1   # Windows runtime bootstrap (Python, Node, uv)
│   │   ├── setup-unix.sh       # Unix runtime bootstrap
│   │   ├── reset-windows.ps1   # Soft & full reset utility (Windows)
│   │   └── reset-unix.sh       # Soft & full reset utility (Unix)
│   ├── data/                   # (Runtime generated) Keys, config.yaml, sessions, SOUL.md
│   ├── src/                    # (Runtime generated) hermes-agent source
│   └── .cache/                 # (Runtime generated) Isolated runtimes & packages
│
├── openclaw/                   # OpenClaw Agent portable subsystem
│   ├── bin/
│   │   ├── windows.ps1         # Windows interactive launcher & manager
│   │   ├── unix.sh             # Linux/macOS launcher & manager
│   │   ├── portable-env.ps1    # Environment isolator for Windows
│   │   └── portable-env.sh     # Environment isolator for Unix
│   ├── templates/              # Default configuration templates
│   ├── data/                   # (Runtime generated) Sandboxed workspace & state
│   ├── packages/               # (Runtime generated) Portable Node & npm packages
│   └── runtime/                # (Runtime generated) Platform Node binaries
│
└── OpenClaude/                 # Claude Code (OpenClaude) portable subsystem
    ├── START.bat               # Windows entry point
    ├── start.sh                # Linux/macOS entry point
    ├── dashboard/              # Web dashboard UI
    │   ├── server.mjs          # Dashboard server
    │   └── index.html          # Web UI interface
    ├── tools/                  # Helper utilities
    │   ├── local-proxy.js      # System-prompt trimming speed proxy
    │   ├── install-openclaude-engine.ps1 # Engine installer
    │   ├── Change_Provider.bat / .sh     # Quick provider switcher
    │   ├── Open_Dashboard.bat / .sh      # Standalone dashboard launcher
    │   └── setup_local_models.ps1 / .sh  # Local model downloader
    ├── data/                   # (Runtime generated) Keys, sessions, proxy logs
    └── engine/                 # (Runtime generated) Bundled Node & OpenClaude npm
```

---

## 🚀 Quick Start Guide

### Windows

#### 1. Launch Claude Code (OpenClaude)
Double-click `claude.bat` (or `OpenClaude\START.bat`):
- On first launch, it downloads portable Node.js and the OpenClaude engine.
- Choose your preferred AI provider (Anthropic, DeepSeek, Gemini, OpenAI, or local Ollama).
- Start coding or open the Web Dashboard!

#### 2. Launch Hermes Agent
Double-click `hermes.bat`:
- On first launch, it bootstraps standalone Python 3.11, Node.js 22, `uv`, and MinGit.
- Press `[2]` to configure your model/provider or Telegram credentials.
- Press `[1]` to launch the rich terminal chat interface.

#### 3. Launch OpenClaw Agent
Double-click `openclaw.bat`:
- Sets up the isolated Node.js environment and checks Gateway health on port `18789`.
- Use the menu to inspect sessions, channels, or run tasks.

---

### Linux

Ensure `bash` and `curl` are available (`sudo apt install curl` on Debian/Ubuntu):

```bash
# Make launchers executable
chmod +x claude.sh hermes.sh openclaw.sh

# Run Claude Code
./claude.sh

# Run Hermes Agent
./hermes.sh

# Run OpenClaw Agent
./openclaw.sh
```

---

### macOS

Make scripts executable and run:
```bash
chmod +x claude.sh hermes.sh openclaw.sh

# Run Claude Code
./claude.sh

# Run Hermes Agent
./hermes.sh

# Run OpenClaw Agent
./openclaw.sh
```

> [!NOTE]
> On macOS, if you encounter Gatekeeper security warnings on first launch, strip quarantine flags with:
> ```bash
> xattr -dr com.apple.quarantine "/Volumes/YourUSB/Portable Tools"
> ```

---

## 🛠 Detailed Agent Guides & Features

### OpenClaw Operations

The OpenClaw manager menu provides automated management of the background gateway:
- **Full Setup:** Downloads runtime packages and initializes workspace paths.
- **Health Check / Auto-Repair:** Tests socket connection on port `18789`, cleans stale PID files, and verifies package integrity.
- **Sessions & Channels:** View active communication channels and agent sessions.
- **Portable Shell:** Spawns a dedicated subshell where all npm/node commands execute in the USB context.

---

### Hermes Agent Operations

#### Interactive Menu:
- `[1] Start Hermes Chat` — Launches the conversational TUI.
- `[2] Setup / Reconfigure` — Interactive configuration wizard.
- `[3] Gateway Toggle` — Starts/stops background daemon for messaging apps.
- `[4] Advanced Options` — Run diagnostic doctor, view gateway logs, edit `config.yaml`, or fetch updates.

#### Direct CLI Usage:
Pass arguments directly through the root launcher:
```bash
# Windows
hermes.bat hermes --version
hermes.bat hermes -z "Generate a bash script to backup my project"
hermes.bat hermes doctor
hermes.bat hermes gateway status

# Linux / macOS
./hermes.sh hermes --version
./hermes.sh hermes -z "Analyze code structure"
./hermes.sh hermes doctor
```

#### Custom Persona (`SOUL.md`):
Edit `Hermes/data/SOUL.md` to define instructions, behavioral tone, and constraints that are loaded every time the agent boots.

---

### Claude Code (OpenClaude) Operations

#### 9 Supported Providers:
1. **NVIDIA NIM** (High-speed inference via NVIDIA API)
2. **DeepSeek** (DeepSeek-V3 and DeepSeek-R1 reasoning models)
3. **OpenRouter** (Aggregator access to Claude 3.7, Sonnet, GPT-4o, etc.)
4. **Google Gemini** (Gemini 2.0 Flash / Pro)
5. **Anthropic Claude** (Native Claude 3.5 Sonnet & Claude 3.7 Sonnet)
6. **OpenAI** (GPT-4o, o1, o3-mini)
7. **Ollama (Offline)** (100% local models like Qwen 2.5 Coder, DeepSeek-Coder)
8. **LM Studio** (Local OpenAI-compatible API server)
9. **Custom OpenAI Endpoint** (Any custom inference endpoint)

#### Autonomy Modes:
- **Normal Mode:** Prompts the user before executing shell commands or writing files.
- **Limitless Mode:** Full autonomy; executes tasks without requiring confirmation.

#### Speed Proxy for Local Models:
When using local models (e.g. Ollama), the bundled proxy (`tools/local-proxy.js`) strips repetitive tool descriptions and trims prompts by up to 90%, enabling responsive coding performance even on CPU-only machines.

---

## 🧹 Maintenance & Reset

Every agent includes clean reset procedures to wipe temporary files while keeping configuration intact, or perform a total factory reset:

### Hermes Reset:
```powershell
# Windows
cd Hermes\scripts
.\reset-windows.ps1 -Mode soft   # Retains API keys & config
.\reset-windows.ps1 -Mode full   # Complete wipe of Hermes data
```
```bash
# Linux / macOS
cd Hermes/scripts
bash reset-unix.sh soft
bash reset-unix.sh full
```

### Claude Code Reset:
To switch provider or clear API keys:
- **Windows:** Run `OpenClaude\tools\Change_Provider.bat`
- **Linux/macOS:** Run `bash OpenClaude/tools/change_provider.sh`
- To completely reset Claude Code, delete `OpenClaude/data` and `OpenClaude/engine`.

### OpenClaw Reset:
Use option `Health Check / Repair` in the `openclaw.bat` menu, or delete `openclaw/data/` to start fresh.

---

## ❓ Troubleshooting & FAQ

### Q1: Can I run these agents without internet?
- **Claude Code (OpenClaude):** Yes! Select provider `[7] Ollama` to use locally hosted coding models completely offline.
- **Hermes Agent:** Yes! Configure Hermes with a local Ollama or OpenAI-compatible endpoint in `hermes setup`.
- *(Note: First-time setup of runtime packages requires internet to download Node/Python binaries).*

### Q2: What happens if the USB drive letter changes?
All batch files and shell scripts dynamically calculate `%~dp0` / `$(pwd)` at startup. In Hermes, `pyvenv.cfg` is updated on the fly to match the current drive path. You can move the drive to any port or machine seamlessly.

### Q3: How do I access Claude Code's Web Dashboard?
Run `OpenClaude\tools\Open_Dashboard.bat` (Windows) or `bash OpenClaude/tools/open_dashboard.sh` (Linux/macOS), or select the dashboard option from the main menu. The web UI will launch in your default browser.

### Q4: Are my API keys safe on the USB drive?
All API keys and configuration files are stored strictly inside the portable folder (`Hermes/data/`, `openclaw/data/`, `OpenClaude/data/`). Make sure to keep your physical USB drive secure, and use a BitLocker or LUKS-encrypted drive for maximum privacy.

---

## 📄 License & Acknowledgements

This suite is open-source software licensed under the **MIT License** — see [LICENSE](LICENSE) for details.

Copyright (c) 2026 **Mohd Abuzar**

### Upstream Open-Source Projects:
- [OpenClaude](https://github.com/gitlawb/openclaude) & [OpenClaude-Portable](https://github.com/techjarves/OpenClaude-Portable) — Portable Claude Code agent.
- [Nous Research / Hermes Agent](https://github.com/NousResearch/hermes-agent) — Open-source agentic assistant.
- [OpenClaw](https://github.com/openclaw) — Portable autonomous agent system.
- [Astral uv](https://github.com/astral-sh/uv) — Blazing-fast Python package installer.
- [Node.js](https://nodejs.org) — Portable JavaScript runtime.
