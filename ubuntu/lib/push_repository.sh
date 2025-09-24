#!/bin/bash
# Safe, interactive script to clone a GitHub repository via HTTPS

set -euo pipefail

if [ $# -ge 1 ]; then
    repo="$1"
else
    repo=$(whiptail --inputbox "Enter repository name: " 10 60 3>&1 1>&2 2>&3)
fi

if [ -z "$repo" ]; then
    echo "❌ No Repository. Exiting."
    exit 1
fi

dest_dir="/opt/github"

sudo git -C "$dest_dir/$(basename "$repo")" push origin main

echo "Done. Repository pushed at: $dest_dir/$(basename "$repo")"