# Daily GitHub commit

Scheduled safety-net: if this repo has no log line for today (Korea time), append one and commit. Days you already logged are skipped.

The commit is authored as you (not `github-actions[bot]`) so it can count on your contribution graph. That only works after the secrets below are set, the commit email is **verified** on GitHub, and the change lands on the default branch.

Private repos are fine if GitHub → Settings → Profile → **Include private contributions** is on.

## Create the GitHub repo and push

This repo already has an initial commit on `main`. Creating the GitHub remote needs you to be logged in (`gh auth login` or GitHub.com).

```bash
gh auth login
gh repo create workflows --private --source=. --remote=origin --push
```

If `workflows` is already taken on your account, pass another name as the first argument. Private is fine if **Include private contributions** is on in your GitHub profile.

Then add the two Actions secrets below and run the workflow once by hand.

## One-time GitHub secrets

Repo → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**:

| Secret | Value |
| --- | --- |
| `COMMIT_EMAIL` | A **verified** email on your GitHub account, or the `noreply` address shown at [GitHub email settings](https://github.com/settings/emails) (often `ID+username@users.noreply.github.com`). |
| `GH_PAT` | A classic [personal access token](https://github.com/settings/tokens) with the `repo` scope. Used so checkout/push is attributed to you. Do not use the default `GITHUB_TOKEN` for this — those commits show as `github-actions[bot]` and do not count on your graph. |

No secrets belong in this repository’s files.

## Manual test

1. Confirm `COMMIT_EMAIL` and `GH_PAT` are saved.
2. GitHub → **Actions** → **Daily commit** → **Run workflow** → **Run workflow**.
3. Open the run. It should commit `chore: daily log YYYY-MM-DD` as **you**, not `github-actions[bot]`.
4. Check `log/daily.md` and your [contribution graph](https://github.com) (can take a few minutes). Running it twice the same day should skip.

The schedule is `0 14 * * *` (23:00 KST). GitHub’s graph uses the timezone on your GitHub profile — set that to Seoul if it is not already.
