# Setup Walkthrough

The repo scaffolding is done. The remaining steps all happen in external dashboards (GitHub, Cursor, Alpaca, Perplexity, ClickUp). Follow these in order.

## 0. Push the repo to GitHub

```bash
# from the repo root
gh repo create trading-bot --private --source . --remote origin --push
# OR, if you don't have gh:
#   create the empty repo at https://github.com/new (private, no README/license)
#   then:
git remote add origin git@github.com:<your-username>/trading-bot.git
git push -u origin main
```

## 1. Sign up for the data providers (skip any you already have)

| Service | Where | What you need |
|---|---|---|
| Alpaca | https://alpaca.markets/ | Open a **paper** account first; copy API Key + Secret from the dashboard. Live account too if you plan to flip later. |
| Perplexity | https://www.perplexity.ai/settings/api | Generate an API key. The default `sonar` model is included in the Pro plan. |
| ClickUp | https://app.clickup.com/ | Get a personal API token from Settings -> Apps. Create a **Chat channel** for the bot and note the workspace ID + channel ID (channel ID looks like `4-XXXXXXX-X`). |

## 2. Install the Cursor GitHub App on this repo

1. Open https://cursor.com/agents (or the Cloud Agents tab in Cursor IDE).
2. When prompted, click **Install GitHub App**.
3. On GitHub, choose **Only select repositories** -> select your `trading-bot` repo -> grant **Read & write** access.
4. Back in Cursor, confirm the repo appears in the connected repos list.

This is the equivalent of the original guide's "Install the Claude GitHub App" step. Without this, Cloud Agents can't clone your repo and can't push memory updates back.

## 3. Add Secrets at the Cloud Agents dashboard

Go to https://cursor.com/dashboard/cloud-agents -> **Secrets** tab. Add each of these. **Mark every API key as redacted** (the toggle next to the value field) so the agent can never accidentally print them in a commit or chat message.

| Secret name | Example / Notes |
|---|---|
| `ALPACA_API_KEY` | from Alpaca dashboard |
| `ALPACA_SECRET_KEY` | from Alpaca dashboard |
| `ALPACA_ENDPOINT` | `https://paper-api.alpaca.markets/v2` (start here; flip to `https://api.alpaca.markets/v2` after a successful paper week) |
| `ALPACA_DATA_ENDPOINT` | `https://data.alpaca.markets/v2` |
| `PERPLEXITY_API_KEY` | from Perplexity API settings |
| `PERPLEXITY_MODEL` | `sonar` |
| `CLICKUP_API_KEY` | personal API token |
| `CLICKUP_WORKSPACE_ID` | numeric, from ClickUp URL (`app.clickup.com/<workspaceId>/...`) |
| `CLICKUP_CHANNEL_ID` | format `4-XXXXXXX-X`, from the chat channel URL |

## 4. Create the five Automations

Go to https://cursor.com/automations -> **New Automation**. Repeat five times with these settings:

For all five:
- **Repository**: your `trading-bot` repo, branch `main`
- **Model**: **Claude 4.7 Opus** (Cloud Agents always run Max Mode at API rates)
- **Trigger**: **Scheduled**, in your local timezone
- **Open pull request**: **OFF** -- the agent must push directly to `main`
- **Identity**: your account (or "team" if shared)

For each one, the cron + prompt differ. The PDF originally used `America/Chicago` (since CT market open is 8:30 AM); shift to your timezone if needed.

| # | Name | Cron (CT) | Prompt source |
|---|---|---|---|
| 1 | Trading bot - pre-market | `0 6 * * 1-5` | paste contents of [`routines/pre-market.md`](routines/pre-market.md) |
| 2 | Trading bot - market-open | `30 8 * * 1-5` | paste contents of [`routines/market-open.md`](routines/market-open.md) |
| 3 | Trading bot - midday | `0 12 * * 1-5` | paste contents of [`routines/midday.md`](routines/midday.md) |
| 4 | Trading bot - daily-summary | `0 15 * * 1-5` | paste contents of [`routines/daily-summary.md`](routines/daily-summary.md) |
| 5 | Trading bot - weekly-review | `0 16 * * 5` | paste contents of [`routines/weekly-review.md`](routines/weekly-review.md) |

Paste the **entire** file contents into the prompt field, verbatim. Don't paraphrase -- the env-check block and the commit-and-push step are load-bearing.

## 5. Smoke-test the pre-market Automation

Before enabling all five schedules, click **Run now** on the **pre-market** Automation only. Watch the run logs and verify:

- [ ] Env-var preflight prints all six required vars as `set` (none `MISSING`)
- [ ] `bash scripts/alpaca.sh account` returns valid JSON (paper account equity)
- [ ] Perplexity calls succeed, or gracefully fall back to native WebSearch
- [ ] `memory/RESEARCH-LOG.md` gains a new dated entry
- [ ] No `.env` file was created (the prompt forbids this)
- [ ] Run ends with `git push origin main` succeeding (check `git log` on GitHub)
- [ ] No PR was opened -- the commit landed directly on `main`

If any of these fail, see the troubleshooting table below before re-running.

If all green, enable the schedules on the other four Automations.

## 6. Run a paper week, then go live

1. Let the bot run on the paper endpoint for **at least 5 trading days**.
2. Each evening, read the day's commits on GitHub: `memory/RESEARCH-LOG.md`, `memory/TRADE-LOG.md` deltas.
3. Watch ClickUp for daily summaries. Make sure the format and tone are reasonable.
4. After a successful paper week, swap `ALPACA_ENDPOINT` in the Cursor Secrets dashboard to `https://api.alpaca.markets/v2`. **No code changes needed.** The next scheduled run picks up the live endpoint.

## Troubleshooting (mirrors PDF Part 9)

| Symptom | Likely cause | Fix |
|---|---|---|
| "Repository not accessible" / clone fails | Cursor GitHub App not installed on this repo | Install per Step 2 |
| `git push` fails with proxy/permission error | App lacks write access, or branch protection on `main` | Re-grant write access; turn off branch protection on `main` for this repo |
| `ALPACA_API_KEY not set in environment` | Secret missing or misnamed in dashboard | Add it in Step 3 dashboard, not in any `.env` file |
| Agent creates a `.env` file anyway | Prompt was paraphrased and lost the "DO NOT create .env" block | Re-paste the prompt from `routines/*.md` exactly |
| Yesterday's trades missing from today's run | Previous run didn't commit+push | Verify `git log origin/main`; re-check STEP N of that routine |
| Push fails "fetch first" / non-fast-forward | Two runs raced | Prompt handles this with `git pull --rebase`. If looping, look for a real merge conflict |
| ClickUp message didn't arrive | One of the three CLICKUP_* vars is missing | Script falls back to a local file silently; add the missing var |
| Perplexity calls didn't happen | `PERPLEXITY_API_KEY` missing | Script exits 3, agent falls back to WebSearch. Add the key or accept fallback |
| Alpaca rejects stop with PDT error | Same-day stop on same-day buy | Prompt's fallback ladder (trailing -> fixed -> queue tomorrow) handles it. If not cascading, re-paste STEP 5 verbatim |
| Agent opens a PR instead of pushing to main | "Open pull request" wasn't disabled on the Automation | Edit the Automation; toggle PR off. The prompts also explicitly say "Do NOT open a PR" but the dashboard setting is the harder gate |

## Reference docs

- Cursor Automations: https://cursor.com/docs/cloud-agent/automations
- Cursor Cloud Agents: https://cursor.com/docs/cloud-agent
- Setup (environment.json, secrets): https://cursor.com/docs/cloud-agent/setup
- Models & pricing: https://cursor.com/docs/models-and-pricing
- Alpaca trading API: https://docs.alpaca.markets/
- Perplexity API: https://docs.perplexity.ai/
