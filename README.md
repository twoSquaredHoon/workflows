# Daily GitHub commit

Local safety-net: every time you log into your Mac — and once an hour after
that while you're logged in — a script checks whether `log/daily.md` has an
entry for today (Korea time). If not, it appends one, commits, and pushes,
authored as you, so it counts on your GitHub contribution graph. Days you've
already logged (by hand or by the script) are skipped.

No GitHub Actions, no repo secrets, no PAT — it runs on your machine using
whatever git credentials already let you push here.

Private repos are fine if GitHub → Settings → Profile → **Include private
contributions** is on.

## One-time setup

1. Confirm `git push` already works from a normal terminal in this repo
   (SSH key or credential helper already set up — nothing extra needed if
   you can already push here today).
2. Install the LaunchAgent so macOS runs the script automatically:

   ```bash
   mkdir -p ~/Library/LaunchAgents
   cp launchd/com.twosquaredhoon.workflows.dailypush.plist ~/Library/LaunchAgents/
   launchctl unload ~/Library/LaunchAgents/com.twosquaredhoon.workflows.dailypush.plist 2>/dev/null
   launchctl load ~/Library/LaunchAgents/com.twosquaredhoon.workflows.dailypush.plist
   ```

That's it. It now fires at every login, plus once an hour while you're
logged in (harmless — it's a no-op if today's already logged; the hourly
run just means it doesn't depend on logging out and back in). Remove the
`StartInterval` key from the plist before installing if you only want it
to run at login.

## Manual test / one-off run

Run it by hand any time, one line:

```bash
bash ~/Documents/2.Area/workflows/scripts/daily_push.sh
```

Then check `log/daily.md` and your [contribution
graph](https://github.com) (can take a few minutes). Running it twice the
same day is a no-op the second time.

## Uninstall

```bash
launchctl unload ~/Library/LaunchAgents/com.twosquaredhoon.workflows.dailypush.plist
rm ~/Library/LaunchAgents/com.twosquaredhoon.workflows.dailypush.plist
```
