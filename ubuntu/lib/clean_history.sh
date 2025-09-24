
# Save the starting directory
START_DIR="$(pwd)"

# Path to the repository
if [ $# -ge 1 ]; then
    repo="$1"
else
    repo=$(whiptail --inputbox "Enter repository name: " 10 60 3>&1 1>&2 2>&3)
fi

if [ -z "$repo" ]; then
    echo "❌ No Repository. Exiting."
    exit 1
fi


if [ $# -ge 1 ]; then
    desc="$2"
else
    desc=$(whiptail --inputbox "Enter commit description: " 10 60 3>&1 1>&2 2>&3)
fi


if [ -z "$desc" ]; then
    desc="Initial commit (history reset)"
fi


dest_dir="/opt/github"

sudo git config --global --add safe.directory "$dest_dir/$(basename "$repo")"

cd "$dest_dir/$(basename "$repo")"

# Make sure you're on main
sudo git checkout main

# Create a fresh orphan branch (no history)
sudo git checkout --orphan latest_branch

# Add all files and commit
sudo git add -A
sudo git commit -m $desc

# Delete old branch and rename new one
sudo git branch -D main
sudo git branch -m main

# Force push to remote
sudo git push -f origin main

cd "$START_DIR"