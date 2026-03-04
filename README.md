# FireLLM

**Agentic dev environment in a single binary.**

FireLLM packages a complete AI-powered development environment into a portable, sandboxed microVM that runs anywhere with a single command. No containers, no complex setup — just download and run.

Forked from [FireClaw](https://github.com/necessary129/fireclaw). Built with [Firecracker](https://firecracker-microvm.github.io/) for lightweight virtualization and [bake](https://github.com/losfair/bake) for single-binary packaging.

## What is this?

FireLLM is a hermetic, disposable microVM pre-loaded with AI coding tools. Each agent gets an isolated Linux environment with persistent workspace storage. Designed for headless agentic workstations where you need multiple sandboxed coding agents running in parallel.

```
┌────────────────────────────────────────────────────────┐
│                    firellm binary                       │
│  ┌────────────────────────────────────────────────┐    │
│  │              Firecracker microVM               │    │
│  │  ┌─────────────────────────────────────────┐   │    │
│  │  │         Ubuntu + Dev Toolchain          │   │    │
│  │  │                                         │   │    │
│  │  │   Claude Code   OpenCode   tmux  git    │   │    │
│  │  │   neovim   ripgrep   python   go  bun   │   │    │
│  │  │                                         │   │    │
│  │  └─────────────────────────────────────────┘   │    │
│  └────────────────────────────────────────────────┘    │
└────────────────────────────────────────────────────────┘
```

## Features

- **Single binary** — One ~500MB executable contains everything: kernel, filesystem, and dev toolchain
- **Sandboxed** — Runs in an isolated Firecracker microVM with no host access
- **Persistent** — Your data survives restarts via an auto-created disk image
- **Fast** — Boots in under a second on modern hardware
- **Portable** — Supports both AMD64 and ARM64 (including Apple Silicon via OrbStack)

## Requirements

- Linux with KVM support (`/dev/kvm` must be accessible)
- For macOS: Use an OrbStack Linux VM with nested virtualization enabled

## Quick Start

1. **Download the latest release:**

   ```bash
   # For AMD64 (Intel/AMD)
   curl -LO https://github.com/AFK-surf/firellm/releases/latest/download/firellm.amd64.elf
   chmod +x firellm.amd64.elf

   # For ARM64 (Apple Silicon in OrbStack VM, AWS Graviton, etc.)
   curl -LO https://github.com/AFK-surf/firellm/releases/latest/download/firellm.arm64.elf
   chmod +x firellm.arm64.elf
   ```

2. **Run it:**

   ```bash
   ./firellm.arm64.elf
   ```

   On first run, FireLLM will:
   - Create a 10GB data disk at `~/.firellm/data.img`
   - Initialize the Ubuntu environment
   - Drop you into a tmux session with all tools available

3. **Connect to the VM:**

   ```bash
   ./firellm.arm64.elf ssh
   ```

## Usage

```
firellm [OPTIONS] [-- ARGS]

Options:
  --disk <path>       Path to data disk image (default: ~/.firellm/data.img)
  -c, --cpus <N>      Number of CPUs (default: 2)
  -m, --memory <MB>   Memory in megabytes (default: 2048)
  --                  Pass remaining arguments to the VM

Commands:
  firellm ssh        Connect to a running instance via SSH
```

### Examples

```bash
# Run with custom resources
./firellm.arm64.elf -c 4 -m 4096

# Use a specific data disk
./firellm.arm64.elf --disk /mnt/storage/firellm.img

# Connect to your running instance
./firellm.arm64.elf ssh
```

## What's Inside

| Component | Description |
|-----------|-------------|
| **Linux Kernel** | Minimal 6.1 kernel optimized for microVMs |
| **Ubuntu Noble** | Full Ubuntu 24.04 userspace |
| **Claude Code** | Anthropic's CLI coding agent |
| **OpenCode** | Multi-provider AI coding assistant |
| **tmux** | Terminal multiplexer for session persistence |
| **neovim** | Terminal editor |
| **bun** | Fast JS runtime and package manager |
| **git** | Version control with git-lfs |
| **python3, go** | Language runtimes |
| **ripgrep, fd, bat, fzf, jq** | Modern CLI tools |
| **Firecracker** | Amazon's lightweight VMM for serverless |

## How It Works

FireLLM uses [bake](https://github.com/losfair/bake) to embed an entire bootable system into a single ELF binary:

1. **Build time**: Docker creates an Ubuntu image with the dev toolchain pre-installed, which gets converted to a squashfs filesystem and embedded alongside the kernel and Firecracker
2. **Runtime**: The binary extracts components to memory, boots Firecracker, and pivots to a persistent data disk for your workspace and configuration

All VM-to-host communication happens over vsock — no network namespaces or iptables rules required.

## Architecture on Mac Mini

```
macOS (host)
  └── OrbStack Linux VM (with KVM passthrough)
        └── FireLLM single-binary microVMs
              ├── agent-sandbox-1 (isolated coding agent)
              ├── agent-sandbox-2 (isolated coding agent)
              └── ...
```

## Building from Source

```bash
# Requires: Docker, squashfs-tools

# Build for your current architecture
./build.sh

# Cross-compile for a specific architecture
TARGETARCH=arm64 ./build.sh
TARGETARCH=amd64 ./build.sh

# Output will be in ./output/firellm.<arch>.elf
```

## Troubleshooting

### "KVM not available"

FireLLM requires hardware virtualization:

```bash
# Check if KVM is accessible
ls -la /dev/kvm

# If permission denied, add yourself to the kvm group
sudo usermod -aG kvm $USER
# Then log out and back in
```

### Force start without KVM check

```bash
FIRELLM_FORCE_START=1 ./firellm.arm64.elf
```

## License

MIT License - see [LICENSE](LICENSE) for details.
