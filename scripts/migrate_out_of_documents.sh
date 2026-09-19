#!/usr/bin/env bash
# One-time fix for the workflows daily-commit automation.
#
# Problem: the repo lives under ~/Documents, which macOS locks down for
# background processes (launchd can't touch it without Full Disk Access).
# Fix: move the repo out to ~/workflows, point the launchd job at the new
# location, load it, run it once immediately, and push any commits that
# were stuck waiting.
#
# Run this once from Terminal on your Mac:
#   bash ~/Downloads/migrate_out_of_documents.sh
# (wherever you saved it — the script finds the repo itself)

set -euo pipefail

OLD_DIR="$HOME/Documents/2.Area/workflows"
NEW_DIR="$HOME/workflows"
PLIST_NAME="com.twosquaredhoon.workflows.dailypush.plist"
LAUNCH_AGENT="$HOME/Library/LaunchAgents/$PLIST_NAME"

echo "==> Unloading existing launchd job (if loaded)..."
launchctl unload "$LAUNCH_AGENT" 2>/dev/null || true

if [ -d "$OLD_DIR" ] && [ ! -e "$NEW_DIR" ]; then
  echo "==> Moving $OLD_DIR -> $NEW_DIR"
  mv "$OLD_DIR" "$NEW_DIR"
elif [ -d "$NEW_DIR" ]; then
  echo "==> $NEW_DIR already exists, using it as-is"
else
  echo "ERROR: couldn't find the repo at $OLD_DIR or $NEW_DIR" >&2
  exit 1
fi

echo "==> Writing updated launchd job pointing at $NEW_DIR"
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$LAUNCH_AGENT" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.twosquaredhoon.workflows.dailypush</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$NEW_DIR/scripts/daily_push.sh</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>StartInterval</key>
    <integer>3600</integer>
    <key>StandardOutPath</key>
    <string>$NEW_DIR/log/launchd.out.log</string>
    <key>StandardErrorPath</key>
    <string>$NEW_DIR/log/launchd.err.log</string>
</dict>
</plist>
PLIST

echo "==> Updating the copy of the plist inside the repo too, for reference"
cp "$LAUNCH_AGENT" "$NEW_DIR/launchd/$PLIST_NAME"

echo "==> Loading and starting the job"
launchctl load "$LAUNCH_AGENT"
launchctl start com.twosquaredhoon.workflows.dailypush

sleep 3

echo "==> Recent output:"
tail -n 5 "$NEW_DIR/log/launchd.out.log" 2>/dev/null || true
echo "==> Recent errors (should be empty from here on):"
tail -n 5 "$NEW_DIR/log/launchd.err.log" 2>/dev/null || true

echo "==> Pushing any pending commits (including today's log entry)"
cd "$NEW_DIR"
git push origin main

echo
echo "Done. The repo now lives at $NEW_DIR and the daily job no longer touches Documents."
git status
