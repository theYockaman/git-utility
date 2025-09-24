#!/bin/bash
# Safe, interactive script to clone a GitHub repository via HTTPS

set -euo pipefail

if [ $# -ge 1 ]; then
    owner="$1"
else
    owner=$(whiptail --inputbox "Enter GitHub owner (user or org): " 10 60 3>&1 1>&2 2>&3)
fi

if [ -z "$owner" ]; then
    echo "❌ No Owner. Exiting."
    exit 1
fi

if [ $# -ge 2 ]; then
    repo="$2"
else
    repo=$(whiptail --inputbox "Enter repository name: " 10 60 3>&1 1>&2 2>&3)
fi

if [ -z "$repo" ]; then
    echo "❌ No Repository. Exiting."
    exit 1
fi

dest_dir="/opt/github"

echo "Creating destination directory $dest_dir (if needed) with sudo..."
sudo mkdir -p "$dest_dir"
sudo chown "$USER":"$USER" "$dest_dir"

clone_url="https://github.com/${owner}/${repo}.git"

echo "Cloning $clone_url into $dest_dir..."
# Use the system git which will pick up credential helper configuration
sudo git clone "$clone_url" "$dest_dir/$(basename "$repo")"

echo "Done. Repository cloned to $dest_dir/$(basename "$repo")"
