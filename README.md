# ⚡ Portable Tools (THEVOIDKERNEL)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows%2010%2B-0078D6?logo=windows)](Windows/)
[![Platform: Linux](https://img.shields.io/badge/Platform-Linux%20x64%20%7C%20arm64-FCC624?logo=linux&logoColor=black)](Linux/)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS%20Intel%20%7C%20Apple%20Silicon-000000?logo=apple)](Mac/)
[![Platform: Android](https://img.shields.io/badge/Platform-Android%20Termux-3DDC84?logo=android&logoColor=white)](Android/)
[![Engines: Ollama | llama.cpp | SD.cpp | Piper](https://img.shields.io/badge/Engines-Ollama%20%7C%20llama.cpp%20%7C%20SD.cpp%20%7C%20Piper-purple)](#engines--technologies)
[![Agents: Hermes | OpenClaw](https://img.shields.io/badge/Agents-Hermes%20%7C%20OpenClaw-orange)](#autonomous-agent-workspaces)

> **The ultimate self-contained, offline-capable, zero-installation AI workstation on a USB drive.**  
> Run local LLMs, generate photorealistic images, synthesize ultra-fast speech, and deploy full autonomous AI agents on any machine—without touching the host OS, modifying system registries, or installing global dependencies.

---

## 📑 Table of Contents

- [Overview & Philosophy](#-overview--philosophy)
- [Architecture & Key Features](#-architecture--key-features)
- [Suite Components](#-suite-components)
  - [1. Portable Offline AI Suite (FastChat)](#1-portable-offline-ai-suite-fastchat)
  - [2. Hermes Portable Agent](#2-hermes-portable-agent)
  - [3. OpenClaw Portable Agent](#3-openclaw-portable-agent)
- [Hardware & System Requirements](#-hardware--system-requirements)
- [Directory Structure](#-directory-structure)
- [Quick Start Guide](#-quick-start-guide)
  - [Windows Setup & Launch](#windows)
  - [Linux Setup & Launch](#linux)
  - [macOS Setup & Launch](#macos)
  - [Android (Termux) Setup & Launch](#android-termux)
- [Curated Model Catalog](#-curated-model-catalog)
  - [Large Language Models (LLMs)](#large-language-models-llms)
  - [Stable Diffusion Image Generation](#stable-diffusion-image-generation)
  - [Piper Text-to-Speech (TTS) Voices](#piper-text-to-speech-tts-voices)
- [Autonomous Agents Usage](#-autonomous-agents-usage)
  - [Hermes Agent Guide](#hermes-agent-guide)
  - [OpenClaw Agent Guide](#openclaw-agent-guide)
- [Network & Remote Access](#-network--remote-access)
- [Uninstallation & Maintenance](#-uninstallation--maintenance)
- [Troubleshooting & FAQ](#-troubleshooting--faq)
- [License & Acknowledgements](#-license--acknowledgements)

---

## 💡 Overview & Philosophy

Modern AI tools typically require gigabytes of system-level runtimes, Python virtual environments, CUDA toolkits, Node.js packages, and invasive registry modifications. If you switch to another workstation, classroom PC, or server, you have to reinstall everything from scratch.

**Portable Tools (THEVOIDKERNEL)** solves this problem completely:

1. **100% Self-Contained:** Every engine (Ollama, `llama.cpp`, `stable-diffusion.cpp`, Piper TTS), interpreter (isolated Python 3.11/3.12, Node.js v22/v24), runtime library, cache, and model lives strictly within your portable folder or USB root.
2. **Drive-Letter Agnostic:** Dynamic path resolution and on-the-fly `pyvenv.cfg` updating guarantee that your suite functions seamlessly whether mounted as `D:`, `E:`, `F:`, `/media/usb`, or `~/storage/shared`.
3. **Zero Host Contamination:** Host `%APPDATA%`, `~/.config`, and system environment variables remain completely untouched. Temporary directories and state databases are routed into `.cache` and `data/` folders on the portable drive.
4. **Multi-Model & Multimodal:** Run state-of-the-art text generation (standard and uncensored models), on-device image synthesis via Vulkan/CPU, and crystal-clear text-to-speech without an active internet connection.
5. **Plug-and-Play Autonomous Agents:** Includes ready-to-run, isolated workspaces for **Nous Research's Hermes Agent** and **OpenClaw Agent**, complete with background messaging gateways (Telegram, WhatsApp, Slack) and tool ecosystems.

---

## 🏛 Architecture & Key Features

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                               PORTABLE TOOLS WORKSPACE                                  │
└─────────────────────────────────────────────────────────────────────────────────────────┘
        │                                   │                                  │
        ▼                                   ▼                                  ▼
┌───────────────────────┐       ┌───────────────────────┐      ┌──────────────────────────┐
│   PORTABLE AI SUITE   │       │  HERMES AGENT ENGINE  │      │  OPENCLAW AGENT ENGINE   │
├───────────────────────┤       ├───────────────────────┤      ├──────────────────────────┤
│ • Ollama / llama.cpp  │       │ • Nous Hermes CLI/TUI │      │ • OpenClaw Autonomous    │
│ • Stable Diffusion    │       │ • Standalone Python   │      │ • Isolated Node.js v24   │
│ • Piper Neural TTS    │       │ • UV + MinGit + Tools │      │ • Gateway on Port 18789  │
│ • Python Chat Server  │       │ • Telegram Gateway    │      │ • Sandboxed Workspace    │
│ • FastChat Dark Web UI│       │ • Session Management  │      │ • Interactive Shell      │
└───────────────────────┘       └───────────────────────┘      └──────────────────────────┘
        │                                   │                                  │
        └───────────────────────────────────┼──────────────────────────────────┘
                                            ▼
                        ┌───────────────────────────────────────┐
                        │   SHARED ISOLATED STORAGE & RUNTIME   │
                        ├───────────────────────────────────────┤
                        │ • GGUF Models & Safetensors           │
                        │ • Standalone Python & Node Runtimes   │
                        │ • Offline UI Vendor Assets            │
                        │ • Local Session & Chat Persistence    │
                        └───────────────────────────────────────┘
```

- **Hardware Acceleration:** Native support for NVIDIA CUDA, AMD Radeon (Vulkan, ROCm, HIP), Apple Metal, Intel Arc, and ARM NEON on Android.
- **Offline First Web Interface:** `FastChatUI.html` renders full markdown with code syntax highlighting, handles multi-turn chats, provides real-time hardware telemetry (CPU, RAM, GPU, VRAM), and loads locally cached vendor assets (`Inter`, `JetBrains Mono`, `FontAwesome`, `highlight.js`, `pdf.js`).
- **Integrated CORS Bypass & Server Proxy:** Built-in zero-dependency Python server (`chat_server.py`) proxies API calls, manages image generation jobs asynchronously, and exposes the chat interface to the local area network (LAN).
- **Interactive Management & Diagnostic Tools:** Built-in wizards for automated model downloading, integrity validation, repair, and selective uninstallation.

---

## 📦 Suite Components

### 1. Portable Offline AI Suite (FastChat)
- **Engines:** Ollama (Windows/Linux/macOS) and `llama-server` (`llama.cpp` compiled natively for Android Termux or desktop).
- **Image Generation:** `stable-diffusion.cpp` Vulkan/CPU binary paired with the `CyberRealistic v3.3 FP16` model.
- **Voice Synthesis:** Piper Neural TTS binary with 6 natural voice models.
- **Frontend & Proxy:** `chat_server.py` serving `FastChatUI.html` on `http://localhost:3333`.

### 2. Hermes Portable Agent
- Autonomous agent powered by [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent).
- Self-bootstrapping runtime: downloads standalone CPython 3.11, Node.js 22, `uv`, `ripgrep`, and MinGit on first run.
- Supports interactive TUI chat, diagnostic doctor, configuration editor, system prompts (`SOUL.md`), sessions management, and background messaging gateways (Telegram bot, Slack, webhooks).
- Launch via `hermes.bat` (Windows) or `hermes.sh` (macOS / Linux).

### 3. OpenClaw Portable Agent
- Autonomous agent workspace built on the OpenClaw framework.
- Fully portable Node.js v24 environment with isolated `npm-global`, `npm-cache`, state directories, and sandboxed workspaces.
- Integrated background Gateway service on port `18789` with health checks, auto-repair, and diagnostic logging.
- Launch via `openclaw.bat` (Windows) or `openclaw.sh` (macOS / Linux).

---

## 💻 Hardware & System Requirements

| Specification | Minimum | Recommended | Heavy Agent / Model Mode |
| :--- | :--- | :--- | :--- |
| **Operating System** | Windows 10 x64, macOS 12+, Ubuntu 20.04+, Android 10+ (Termux) | Windows 11 x64, macOS 13+ (Apple Silicon), modern Linux | Same |
| **Processor (CPU)** | 4-Core x86_64 or ARM64 | 8-Core modern CPU (Intel 12th+ Gen, AMD Ryzen 5000+, Apple M-series) | 8+ Cores with AVX2 / NEON support |
| **System Memory (RAM)** | 8 GB | 16 GB | 32 GB+ |
| **GPU / Acceleration** | CPU Only (AVX2) | NVIDIA RTX (4GB+ VRAM), AMD Radeon (Vulkan), Apple Silicon (Metal) | NVIDIA RTX 3060/4060+ (8GB–16GB+ VRAM) |
| **USB / Storage Drive** | USB 3.0 Drive with 16 GB free space | USB 3.1 / 3.2 Gen 2 Portable SSD (500+ MB/s read speed) with 64 GB+ | Fast NVMe Portable SSD with 128 GB+ |

> [!TIP]
> While high-speed USB flash drives work, running large language models and image generation directly from a **Portable USB SSD (e.g., Samsung T7, SanDisk Extreme, Crucial X8)** will provide dramatically faster model loading times and response generation.

---

## 📂 Directory Structure

```text
Portable Tools/
│
├── hermes.bat                  # Root Windows launcher for Hermes Agent
├── hermes.sh                   # Root Unix/macOS launcher for Hermes Agent
├── openclaw.bat                # Root Windows launcher for OpenClaw Agent
├── openclaw.sh                 # Root Unix/macOS launcher for OpenClaw Agent
├── LICENSE                     # MIT License (Mohd Abuzar, 2026)
├── README.md                   # Complete documentation
│
├── Android/                    # Android (Termux) subsystem
│   ├── install.sh              # Compiles llama.cpp natively & sets up environment
│   ├── start.sh                # Starts native engine & FastChat server
│   └── uninstall.sh            # Safe cleanup script for Android
│
├── Hermes/                     # Hermes Agent portable subsystem
│   ├── scripts/
│   │   ├── COMMANDS.md         # Full Hermes CLI & Gateway command reference
│   │   ├── setup-windows.ps1   # Bootstraps Windows runtimes (Python, Node, uv)
│   │   ├── setup-unix.sh       # Bootstraps Linux/macOS runtimes
│   │   ├── reset-windows.ps1   # Soft / full reset utility for Windows
│   │   └── reset-unix.sh       # Soft / full reset utility for Unix/macOS
│   ├── data/                   # (Generated) Config, API keys, sessions, SOUL.md
│   ├── src/                    # (Generated) Cloned hermes-agent source
│   └── .cache/                 # (Generated) Isolated runtimes & packages
│
├── Linux/                      # Linux offline AI subsystem
│   ├── install.sh              # Multi-model interactive installer for Linux
│   ├── start.sh                # Launches Ollama engine & FastChat UI
│   └── uninstall.sh            # Selective model / engine uninstaller
│
├── Mac/                        # macOS offline AI subsystem
│   ├── install.command         # Double-clickable macOS setup wizard
│   ├── start.command           # Double-clickable macOS launcher
│   └── uninstall.command       # macOS removal & cleanup tool
│
├── openclaw/                   # OpenClaw Agent portable subsystem
│   ├── bin/
│   │   ├── windows.ps1         # Windows interactive launcher & manager
│   │   ├── unix.sh             # Linux/macOS launcher & manager
│   │   ├── portable-env.ps1    # Sandboxed environment builder for Windows
│   │   └── portable-env.sh     # Sandboxed environment builder for Unix
│   ├── templates/              # Default configuration templates
│   ├── data/                   # (Generated) Sandboxed workspace & states
│   └── packages/               # (Generated) Portable Node & npm packages
│
├── Shared/                     # Core engine assets, models, and UI server
│   ├── FastChatUI.html         # Responsive, dark-mode web application
│   ├── chat_server.py          # Zero-dependency Python server & API proxy
│   ├── bin/                    # (Generated) Ollama, SD.cpp, Piper, 7-Zip binaries
│   ├── models/                 # (Generated) GGUF LLMs, SD safetensors, TTS voices
│   ├── config/
│   │   ├── models.json         # Master catalog of preset LLMs & voices
│   │   └── ui-vendor-assets.json # Offline web assets definition
│   ├── scripts/
│   │   ├── config_query.py     # JSON parser utility for shell scripts
│   │   ├── download-ui-assets.ps1 # Offline UI assets downloader (PowerShell)
│   │   ├── download-ui-assets.sh  # Offline UI assets downloader (Bash)
│   │   └── uninstall-common.sh # Cross-platform removal logic
│   └── vendor/                 # (Generated) Cached offline fonts, JS & CSS
│
└── Windows/                    # Windows offline AI subsystem
    ├── install.bat             # Batch launcher for Windows setup
    ├── install-core.ps1        # 7-Step automated installation pipeline
    ├── start-fast-chat.bat     # Launches Ollama, Python server, and browser UI
    ├── uninstall.bat           # Batch launcher for Windows uninstaller
    └── uninstall-core.ps1      # Safe model & runtime deletion utility
```

---

## 🚀 Quick Start Guide

### Windows

#### 1. Setup Offline AI (FastChat)
1. Open the `Windows/` folder.
2. Double-click `install.bat` (or run in PowerShell: `.\Windows\install.bat`).
3. Follow the numbered wizard:
   - Select one or more AI models to download (e.g. `1` for Gemma 2 2B, or `all`).
   - The installer automatically configures 7-Zip, Visual C++ Redistributable, Ollama, Stable Diffusion, Piper TTS, and offline UI assets.
4. Once completed, double-click `Windows\start-fast-chat.bat`.
5. Your browser will automatically open `http://localhost:3333` with the FastChat UI ready to chat.

#### 2. Setup & Run Hermes Agent
1. In the repository root, double-click `hermes.bat` (or run in terminal: `.\hermes.bat`).
2. On first run, it downloads and provisions isolated Python 3.11, Node.js 22, `uv`, and MinGit (~600MB).
3. The interactive console menu will appear:
   - Press `[2]` to run the **Setup Wizard** (configure API keys, model provider, Telegram gateway).
   - Press `[1]` to start **Hermes Chat** (interactive terminal TUI).
   - Press `[3]` to toggle the **Background Gateway**.

#### 3. Setup & Run OpenClaw Agent
1. In the repository root, double-click `openclaw.bat`.
2. The launcher automatically provisions portable Node.js v24 and downloads OpenClaw packages into an isolated environment.
3. Use the interactive menu to manage the OpenClaw Gateway service, inspect sessions, configure channels, or open an isolated portable shell.

---

### Linux

Ensure `curl` and `python3` are available on your distribution (`sudo apt install curl python3` on Debian/Ubuntu):

#### 1. Setup Offline AI (FastChat)
```bash
cd Linux
chmod +x install.sh start.sh uninstall.sh
./install.sh
```
Follow the interactive prompt to choose your models. Once setup finishes:
```bash
./start.sh
```
The AI engine initializes and opens the web chat interface.

#### 2. Launch Hermes Agent
```bash
chmod +x hermes.sh
./hermes.sh
```
Launches the Hermes interactive launcher. Select option `2` for setup, or option `1` to chat.

#### 3. Launch OpenClaw Agent
```bash
chmod +x openclaw.sh
./openclaw.sh
```
Starts OpenClaw portable environment, checks gateway health, and presents the interactive management console.

---

### macOS

#### 1. Setup Offline AI (FastChat)
1. Navigate to the `Mac/` folder.
2. Right-click `install.command` and select **Open** (or run `bash Mac/install.command` in Terminal).
3. Select your desired model(s) from the menu.
4. Launch by double-clicking `Mac/start.command`. The Ollama engine and FastChat UI will load automatically.

> [!NOTE]
> On macOS, gatekeeper quarantine attributes are automatically stripped by `start.command`. Ensure Xcode command line tools or standard Python 3 is installed (`xcode-select --install` or `brew install python`).

#### 2. Launch Hermes Agent
```bash
chmod +x hermes.sh
./hermes.sh
```

#### 3. Launch OpenClaw Agent
```bash
chmod +x openclaw.sh
./openclaw.sh
```

---

### Android (Termux)

Turn any Android smartphone into a completely self-contained AI server with hardware-accelerated CPU inference!

1. Install **Termux** from [F-Droid](https://f-droid.org/en/packages/com.termux/) (do not use Google Play version).
2. Connect your USB drive via OTG, or copy the `Portable Tools` directory into your internal storage.
3. Open Termux and navigate to the project directory:
   ```bash
   cd /sdcard/Portable\ Tools/Android   # Or your respective USB mount path
   chmod +x install.sh start.sh uninstall.sh
   bash install.sh
   ```
4. The installer automatically:
   - Requests Termux storage permissions.
   - Updates packages and installs `clang`, `cmake`, `git`, `python`, and `ninja`.
   - **Compiles `llama.cpp` natively** for your device's ARM64 processor with NEON vector extensions.
   - Downloads your chosen mobile-optimized model (e.g. Liquid AI 230M or Gemma 2B).
5. Start the engine:
   ```bash
   bash start.sh
   ```
6. Choose between:
   - **[1] USB FastChat UI** (`http://localhost:3333`) — Dark-mode browser interface with chat auto-saving.
   - **[2] Llama.cpp Default UI** (`http://localhost:8080`) — Raw developer interface.
7. Termux automatically acquires a wake-lock to prevent Android battery optimizations from sleeping the engine during inference.

---

## 🧠 Curated Model Catalog

The suite includes a curated catalog defined in `Shared/config/models.json`. Each model is optimized in GGUF format with 4-bit/5-bit quantization (`Q4_K_M`):

### Large Language Models (LLMs)

| # | Model Name | Quantization | Size | Type | Highlight / Best Use Case |
| :-: | :--- | :---: | :---: | :---: | :--- |
| **1** | **Liquid AI LFM2.5 230M** | `Q4_K_M` | 0.15 GB | Standard | Ultra-fast & lightweight. Perfect for low-spec PCs & phones. |
| **2** | **Gemma 2 2B Abliterated** | `Q4_K_M` | 1.60 GB | Uncensored | **Recommended for all**. Blazing fast response, uncensored guidance. |
| **3** | **Gemma 4 E4B Ultra Heretic** | `Q4_K_M` | 5.34 GB | Uncensored | Deep reasoning without moralizing filters. |
| **4** | **Qwen 3.5 9B Aggressive** | `Q4_K_M` | 5.20 GB | Uncensored | Raw, direct answers with strong instruction-following capability. |
| **5** | **NemoMix Unleashed 12B** | `Q4_K_M` | 7.00 GB | Uncensored | Heavyweight creative writing, complex analysis, and roleplay. |
| **6** | **Dolphin 2.9 Llama 3 8B** | `Q4_K_M` | 4.90 GB | Uncensored | Versatile general-purpose coding and uncensored conversation. |
| **7** | **Phi-3.5 Mini 3.8B** | `Q4_K_M` | 2.20 GB | Standard | Microsoft's state-of-the-art compact reasoning model. |

> [!NOTE]
> **Custom Models Support:** During installation, select option `[C]` to paste any direct HuggingFace GGUF download URL. The installer automatically downloads the file and builds a customized Modelfile for Ollama.

### Stable Diffusion Image Generation

| Engine | Model | Format | Size | Description |
| :--- | :--- | :---: | :---: | :--- |
| `stable-diffusion.cpp` (Vulkan/CPU) | **CyberRealistic v3.3 FP16** | `.safetensors` | 1.99 GB | High-detail photorealistic image synthesis. Runs on Vulkan-compatible GPUs or multicore CPUs. |

### Piper Text-to-Speech (TTS) Voices

All voices are high-quality, low-latency neural models (.onnx) bundled via Piper:

- `en_US-amy-medium`: US Female (Clear & expressive)
- `en_US-lili-medium`: US Female (Soft & conversational)
- `en_US-kusal-medium`: US Female (Natural pacing)
- `en_US-arctic-medium`: US Female (Smooth narration)
- `en_US-lessac-medium`: US Female (High precision & clarity)
- `en_GB-alan-medium`: UK Male (British accent)

---

## 🤖 Autonomous Agents Usage

### Hermes Agent Guide

Hermes Agent is a fully featured AI assistant framework designed by Nous Research.

#### Main Menu Options
When running `hermes.bat` or `hermes.sh`:
- **[1] Start Hermes Chat:** Opens the rich interactive terminal user interface.
- **[2] Setup / Reconfigure:** Run the interactive wizard to select LLM providers (Local Ollama, OpenAI, DeepSeek, OpenRouter, Anthropic, etc.).
- **[3] Gateway Daemon:** Start or stop the background messaging daemon.
- **[4] Advanced Options:** Run diagnostics (`doctor`), inspect last 20 log lines, edit `config.yaml`, or perform an in-place update.

#### Direct CLI Execution
You can bypass the interactive menu by appending CLI arguments:
```bash
# Windows
launch.bat hermes --version
launch.bat hermes -z "Explain quantum computing in three bullets"
launch.bat hermes doctor
launch.bat hermes gateway restart

# macOS / Linux
./hermes.sh hermes --version
./hermes.sh hermes -z "Write a python script to parse CSV files"
./hermes.sh hermes doctor
```

#### Messaging Gateways
Hermes can connect directly to your communication channels:
- **Telegram Bot:** Create a bot with `@BotFather`, set the token via `hermes setup gateway`, and run `hermes gateway`. Send `/start`, `/stop`, or prompts directly in Telegram!
- **System Prompts (`SOUL.md`):** Customize the agent's core personality and instructions by editing `Hermes/data/SOUL.md`.

---

### OpenClaw Agent Guide

OpenClaw provides a sandboxed autonomous execution environment.

#### Key Functions:
- **Health Check & Auto-Repair:** Verifies Node.js runtime, npm dependencies, gateway ports, and workspace structure.
- **Gateway Server (Port 18789):** Runs a local loopback gateway daemon that handles agent interactions, channels, and tool executions.
- **Isolated Portable Shell:** Opens a subshell with `OPENCLAW_HOME`, `npm_config_prefix`, and execution paths set strictly to the USB drive.

---

## 🌐 Network & Remote Access

The Python chat server (`chat_server.py`) automatically discovers your machine's local network IP address on startup.

### Accessing FastChat from Other Devices:
1. Make sure your host machine and mobile device / laptop are connected to the same Wi-Fi network.
2. Note the LAN address printed in the console when running `start-fast-chat.bat` (e.g. `http://192.168.1.50:3333`).
3. Open that URL on your phone, tablet, or secondary PC to chat with the AI running on your main machine!

---

## 🧹 Uninstallation & Maintenance

Every platform includes a dedicated, safe uninstaller that guarantees files outside the `Shared` folder are never touched:

- **Windows:** Double-click `Windows\uninstall.bat`
- **Linux:** Run `bash Linux/uninstall.sh`
- **macOS:** Double-click `Mac/uninstall.command`
- **Android:** Run `bash Android/uninstall.sh`

### Uninstaller Modes:
1. **Uninstall Specific Model:** Remove an individual GGUF model and its Modelfile while keeping the rest intact.
2. **Uninstall All Models:** Free up disk space by removing all installed LLMs.
3. **Uninstall Runtimes / Engines:** Remove Ollama, Stable Diffusion, or Piper binaries.
4. **Full Clean Wipe:** Reset the shared directory to factory clean status. You can choose whether to keep or delete your saved conversation history in `Shared/chat_data/`.

### Hermes Reset Utilities:
To reset Hermes Agent state without affecting the rest of the drive:
```powershell
# Windows
cd Hermes\scripts
.\reset-windows.ps1 -Mode soft   # Keeps API keys & config
.\reset-windows.ps1 -Mode full   # Complete wipe of Hermes data
```
```bash
# macOS / Linux
cd Hermes/scripts
bash reset-unix.sh soft
bash reset-unix.sh full
```

---

## ❓ Troubleshooting & FAQ

### Q1: Ollama gives `llama-server.exe not found` or crashes on Windows.
- **Cause:** Partial extraction of Ollama runners or missing Visual C++ Redistributable.
- **Fix:** Re-run `Windows\install.bat`. It will verify and reinstall the `lib/ollama/` runners and install `vc_redist.x64.exe` automatically.

### Q2: Android Termux compile fails during `install.sh`.
- **Cause:** Corrupted package cache or out-of-date Termux repositories.
- **Fix:** In Termux, run `pkg update -y && pkg install clang cmake git python -y` and ensure storage permissions are granted with `termux-setup-storage`.

### Q3: On macOS, `start.command` says "Cannot be opened because it is from an unidentified developer".
- **Fix:** Right-click `start.command` in Finder and select **Open**. Alternatively, open Terminal and strip the quarantine flag:
  ```bash
  xattr -dr com.apple.quarantine "/Volumes/YourUSB/Portable Tools"
  ```

### Q4: Stable Diffusion image generation fails or produces black images.
- **Cause:** Insufficient VRAM or unsupported GPU driver.
- **Fix:** Ensure your GPU supports Vulkan. If you have less than 4GB VRAM, the engine will automatically fallback to CPU mode (which takes longer but completes reliably).

### Q5: Can I move the folder to a different drive letter or machine?
- **Yes!** The entire suite is 100% portable. When you plug the USB into a different computer with a different drive letter, all batch files and shell scripts recalculate their absolute paths dynamically.

---

## 📄 License & Acknowledgements

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

Copyright (c) 2026 **Mohd Abuzar**

### Upstream Open-Source Projects:
- [Ollama](https://github.com/ollama/ollama) — Local LLM runner.
- [llama.cpp](https://github.com/ggerganov/llama.cpp) — Efficient LLM inference in C/C++.
- [stable-diffusion.cpp](https://github.com/leejet/stable-diffusion.cpp) — Lightweight C/C++ Stable Diffusion implementation.
- [Piper](https://github.com/rhasspy/piper) — Fast, local neural text-to-speech engine.
- [Nous Research / Hermes Agent](https://github.com/NousResearch/hermes-agent) — Open-source agentic assistant.
- [OpenClaw](https://github.com/openclaw) — Portable autonomous agent system.
- [CyberRealistic](https://huggingface.co/cyberdelia/CyberRealistic) — Photorealistic SD 1.5 model.
- [Hugging Face](https://huggingface.co) — Model repository & community.
