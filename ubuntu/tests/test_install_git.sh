#!/usr/bin/env bash
set -euo pipefail

# Minimal test for ubuntu/lib/git-utility/install_git.sh
# This test runs the script in a sandboxed environment (temporary HOME) and
# verifies that when credential.helper is 'store' the PAT is written to ~/.git-credentials

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$SCRIPT_DIR/ubuntu/lib/git-utility/install_git.sh"

if [ ! -f "$SCRIPT" ]; then
  echo "Test failure: script not found at $SCRIPT"
  exit 2
fi

TMP_HOME=$(mktemp -d)
export HOME="$TMP_HOME"
export XDG_CONFIG_HOME="$TMP_HOME/.config"
mkdir -p "$HOME"

# Use a fake git config location so we don't touch user's global config
export GIT_CONFIG_GLOBAL="$HOME/.gitconfig"

# Create a small wrapper for git to capture credential approve input when used.
# We'll place it early on PATH so the script calls this wrapper.
FAKEBIN="$TMP_HOME/fakebin"
mkdir -p "$FAKEBIN"
cat > "$FAKEBIN/git" <<'GITWRAPPER'
#!/usr/bin/env bash
# A tiny git wrapper that passes through most commands to the real git if present
# For `git config --global credential.helper` and `git credential approve` we
# mimic expected behavior by writing/reading files in $HOME.

cmd="$1"; shift || true
case "$cmd" in
  config)
    # call the real git to keep config behavior for other options
    /usr/bin/env git config "$@"
    ;;
  credential)
    subcmd="$1"; shift || true
    if [ "$subcmd" = "approve" ]; then
      # Read credential fields from stdin and append to $HOME/.git-credentials-like
      # We'll accept both formats; here we just capture password/url
      tempfile="$HOME/.git-credentials-captured"
      cat - > "$tempfile"
      # Also write a simple URL line if possible
      url_line=$(grep -Eo 'url=[^\n]+' "$tempfile" || true)
      if [ -n "$url_line" ]; then
        echo "${url_line#url=}" >> "$HOME/.git-credentials"
      fi
    else
      /usr/bin/env git credential "$subcmd" "$@"
    fi
    ;;
  *)
    /usr/bin/env git "$cmd" "$@"
    ;;
esac
GITWRAPPER
chmod +x "$FAKEBIN/git"

# Put fakebin at front of PATH
export PATH="$FAKEBIN:$PATH"

# Run the install script non-interactively by passing username, email, PAT
TEST_USER="testuser"
TEST_EMAIL="test@example.com"
TEST_PAT="ghp_testtoken1234567890"

bash "$SCRIPT" "$TEST_USER" "$TEST_EMAIL" "$TEST_PAT"

# Now assert ~/.git-credentials exists and contains the PAT
CREDS_FILE="$HOME/.git-credentials"
if [ ! -f "$CREDS_FILE" ]; then
  echo "Test failed: credentials file not created at $CREDS_FILE"
  ls -la "$HOME"
  exit 3
fi

if ! grep -q "$TEST_PAT" "$CREDS_FILE"; then
  echo "Test failed: PAT not found in $CREDS_FILE"
  echo "Contents:"; sed -n '1,200p' "$CREDS_FILE"
  exit 4
fi

echo "Test passed: PAT stored in $CREDS_FILE"

# Cleanup
rm -rf "$TMP_HOME"
exit 0
