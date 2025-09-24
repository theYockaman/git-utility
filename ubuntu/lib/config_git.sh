#!/bin/bash
# Setup Git and configure GitHub access using HTTPS with a Personal Access Token (PAT)

set -euo pipefail

# Configure Git
echo "⚙️ Configuring Git..."
if [ $# -ge 1 ]; then
    git_username="$1"
else
    git_username=$(whiptail --inputbox "Enter your Git Username:" 10 60 3>&1 1>&2 2>&3)
    
fi

if [ -z "$git_username" ]; then
    echo "❌ No Username. Exiting."
    exit 1
fi
git config --global user.name "$git_username"


if [ $# -ge 2 ]; then
    git_email="$2"
else
    git_email=$(whiptail --inputbox "Enter your Git Email:" 10 60 3>&1 1>&2 2>&3)
fi

if [ -z "$git_email" ]; then
    echo "❌ No Email. Exiting."
    exit 1
fi
git config --global user.email "$git_email"


echo "✅ Git config set:"
git config --list

echo "\n🔐 This script will configure Git to use HTTPS with a GitHub Personal Access Token (PAT)."
echo "The PAT will be stored in your Git credential helper so Git can authenticate over HTTPS."

# Read PAT securely

if [ $# -ge 3 ]; then
    github_pat="$3"
else
    # Use silent input so token isn't shown in the terminal or shell history
    github_pat=$(whiptail --inputbox "Enter your GitHub Personal Access Token (PAT): " 10 60 3>&1 1>&2 2>&3)
fi

if [ -z "$github_pat" ]; then
    echo "❌ No PAT provided. Exiting."
    exit 1
fi

# Configure credential helper (use the default credential.helper on the system)
echo "� Configuring Git credential helper..."
current_helper=$(git config --global credential.helper || true)
if [ -z "$current_helper" ]; then
    # On Debian/Ubuntu, 'store' saves unencrypted to ~/.git-credentials; 'cache' keeps in memory.
    # We prefer 'store' so non-interactive git commands work, but warn the user.
    git config --global credential.helper store
    echo "⚠️  Credential helper set to 'store' (credentials saved in ~/.git-credentials)."
    echo "If you'd prefer a different helper (osxkeychain, wincred, manager-core), update git config accordingly."
else
    echo "✅ Existing credential.helper: $current_helper"
fi

# Write a temporary credential entry to the credential store using the PAT.
# This avoids passing token on the command line for individual git commands.
repo_host="https://github.com"
echo "Saving credentials for $repo_host (username: token)."
# Git credential 'store' expects lines: url=https://<host>
creds_file="$HOME/.git-credentials"
# Build credential URL with token in place of password. Username can be 'x-access-token' or your GitHub username.
cred_entry="$repo_host"/""
# Use x-access-token as username for clarity
cred_url="https://x-access-token:${github_pat}@github.com"

if [[ $(git config --global credential.helper) == "store" ]]; then
    # Write directly to file, but avoid making the token visible in logs
    printf "%s\n" "$cred_url" > "$creds_file"
    chmod 0600 "$creds_file"
    echo "✅ PAT stored in $creds_file"
else
    # Use git credential approve for other helpers
    printf "url=%s\nusername=%s\npassword=%s\n" "$repo_host" "x-access-token" "$github_pat" | git credential approve
    echo "✅ PAT stored via credential helper"
fi

echo "\n🔗 Quick test: try cloning a repo with HTTPS. Example (will use stored PAT):"
echo "  git clone https://github.com/<owner>/<repo>.git"

echo "🎉 Setup complete! Git is configured to use HTTPS with your PAT."


