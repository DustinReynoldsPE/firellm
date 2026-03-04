#!/bin/bash
# /etc/profile.d/firellm-login.sh
# First-boot auth helper — prompts for claude login if not authenticated.
# Runs on each interactive login; goes silent once auth is configured.

# Only run in interactive shells
[[ $- != *i* ]] && return

# Check Claude Code auth status
if command -v claude &>/dev/null; then
    auth_json=$(claude auth status 2>/dev/null)
    logged_in=$(echo "$auth_json" | jq -r '.loggedIn' 2>/dev/null)

    if [ "$logged_in" != "true" ]; then
        echo ""
        echo "========================================="
        echo "  firellm — first-time setup"
        echo "========================================="
        echo ""
        echo "  Claude Code is not authenticated."
        echo "  Run 'claude login' to authenticate"
        echo "  with your Claude subscription."
        echo ""
        echo "  This only needs to be done once —"
        echo "  credentials persist across restarts."
        echo ""
        echo "========================================="
        echo ""
    fi
fi
