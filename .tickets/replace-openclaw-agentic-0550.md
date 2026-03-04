---
id: replace-openclaw-agentic-0550
stage: triage
status: closed
deps: []
links: []
created: 2026-03-04T01:15:15Z
type: task
priority: 2
parent: rebrand-fireclaw-firellm-844c
---
# Replace OpenClaw with agentic dev toolchain in Dockerfile

Rewrite image/Dockerfile to install agentic dev tools: tmux, neovim, git, curl, jq, ripgrep, fd-find, bat, fzf, htop, bun (for claude code + opencode), claude code (@anthropic-ai/claude-code), opencode-ai, python3, go. Remove OpenClaw install and openclaw.service. Replace with a firellm.service or remove the service entirely. Update root password from fireclaw to firellm.
