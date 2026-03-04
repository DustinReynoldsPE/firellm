FROM ubuntu:noble

# Base system: systemd, networking, core utils
RUN apt-get update && apt-get install -y \
    systemd systemd-sysv dbus \
    unminimize \
    curl wget ca-certificates gnupg \
    git git-lfs openssh-client \
    tmux neovim \
    htop jq ripgrep fd-find bat fzf \
    python3 python3-pip python3-venv \
    build-essential \
    unzip locales \
    && rm -rf /var/lib/apt/lists/*

RUN yes | unminimize

# Locale
RUN locale-gen en_US.UTF-8 || true
ENV LANG=en_US.UTF-8

# Install bun (used as JS runtime for claude code and opencode)
RUN curl -fsSL https://bun.sh/install | bash
ENV BUN_INSTALL="/root/.bun"
ENV PATH="$BUN_INSTALL/bin:$PATH"

# Install Node.js LTS (some tools need it alongside bun)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code
RUN bun install -g @anthropic-ai/claude-code

# Install OpenCode
RUN bun install -g opencode-ai@latest

# Install Go (for additional tooling)
RUN curl -fsSL https://go.dev/dl/go1.24.1.linux-$(dpkg --print-architecture).tar.gz \
    | tar -C /usr/local -xzf -
ENV PATH="/usr/local/go/bin:$PATH"

# Install tk (ticket management CLI) — resolves latest release at build time
RUN TK_VERSION=$(curl -sI https://github.com/DustinReynoldsPE/ticket/releases/latest | grep -i ^location: | sed 's|.*/v||;s/\r//') \
    && curl -fsSL "https://github.com/DustinReynoldsPE/ticket/releases/download/v${TK_VERSION}/ticket_${TK_VERSION}_linux_$(dpkg --print-architecture).tar.gz" \
    | tar -C /usr/local/bin -xzf - tk

# Configure serial console for Firecracker (ttyS0)
RUN systemctl enable serial-getty@ttyS0.service

# Mask units that are problematic in VMs/containers
RUN systemctl mask \
    systemd-resolved.service \
    systemd-networkd-wait-online.service \
    systemd-firstboot.service \
    systemd-machine-id-commit.service

# Set default root password
RUN echo 'root:firellm' | chpasswd

# First-boot auth helper — prompts for claude login if not authenticated
COPY --chmod=644 ./firellm-login.sh /etc/profile.d/firellm-login.sh

# Shell config: auto-attach tmux on serial console login
RUN echo '\n# Auto-attach tmux on login\nif [ -z "$TMUX" ] && [ -n "$TERM" ] && [ "$TERM" != "dumb" ]; then\n  tmux attach-session -t main 2>/dev/null || tmux new-session -s main\nfi' >> /root/.bashrc

COPY --chmod=755 ./init.sh /init.sh
