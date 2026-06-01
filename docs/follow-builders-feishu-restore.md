# Follow Builders Feishu Restore

This guide restores the Follow Builders daily digest on a new computer.

The restored flow is:

```text
Codex Automation
  -> Follow Builders prepare-digest.js
  -> Codex remixes the JSON into a Chinese digest
  -> lark-cli sends it as 小强Bot
  -> Feishu DM to 张泽强
```

## What Is Stored

Safe to keep in this repository:

- Follow Builders source and submodule setup commands.
- `templates/follow-builders.config.json`, copied to `~/.follow-builders/config.json`.
- `templates/codex-follow-builders-automation.prompt.md`, pasted into Codex to create the automation.
- Bootstrap and verification scripts under `scripts/`.

Do not store these in git:

- `~/.lark-cli/config.json` secrets, appSecret, access tokens, refresh tokens, or OAuth device codes.
- `~/.codex/automations/*/automation.toml` from a local machine.
- `.codex_tmp/` test output.
- Any copied Feishu token or authorization URL.

## Known IDs

- Feishu app / bot: 小强Bot, appId `cli_aa9d2f96f8381cbd`
- Feishu receiver: 张泽强, open_id `ou_1a698174d06fdc75f9f5567d41da0ac2`
- Schedule: daily at 08:00 Asia/Shanghai
- Codex automation name: `Follow Builders 每日飞书摘要`

## New Computer Setup

1. Clone this repository and enter it.

   ```bash
   git clone <this-repo-url> follow-builders
   cd follow-builders
   ```

2. Ensure prerequisites are available.

   ```bash
   git --version
   node --version
   npm --version
   lark-cli --version
   ```

3. Run the bootstrap.

   ```bash
   bash scripts/bootstrap-feishu-follow-builders.sh
   ```

   To preview the actions without writing files, asking for appSecret, or sending
   a real Feishu message:

   ```bash
   bash scripts/bootstrap-feishu-follow-builders.sh --dry-run
   ```

   The script will:

   - Run `make setup`.
   - Write `~/.follow-builders/config.json`.
   - Ask for the 小强Bot appSecret without echoing it.
   - Initialize `lark-cli` with appId `cli_aa9d2f96f8381cbd`.
   - Send a Feishu test message to `ou_1a698174d06fdc75f9f5567d41da0ac2`.

4. Create the Codex automation.

   In Codex, paste the contents of:

   ```text
   templates/codex-follow-builders-automation.prompt.md
   ```

   Codex should create an ACTIVE local cron automation with the daily 08:00 schedule.

5. Verify the setup.

   ```bash
   bash scripts/verify-feishu-follow-builders.sh
   ```

   This checks local files, Node dependencies, `prepare-digest.js`, `lark-cli`, a Feishu dry-run send, and the automation prompt template.

## Manual Smoke Test

Use this when you want to confirm the bot can still send to you:

```bash
lark-cli im +messages-send \
  --as bot \
  --user-id ou_1a698174d06fdc75f9f5567d41da0ac2 \
  --text "Follow Builders restore smoke test"
```

Use this to check the Follow Builders feed payload:

```bash
cd submodules/zarazhangrui-follow-builders/scripts
node prepare-digest.js > /tmp/follow-builders-prepared.json
node -e 'const j=require("/tmp/follow-builders-prepared.json"); console.log(j.config); console.log(j.stats); console.log(j.errors || [])'
```

If `prepare-digest.js` fails with `fetch failed`, the Codex automation is expected to use bundled local feed files as a fallback and mark the digest as using local cached feed data.

## Troubleshooting

- `lark-cli` missing: install or restore `lark-cli` before running bootstrap.
- Bot message fails: confirm 小强Bot is enabled, visible to the receiver, and has message sending permission in Feishu Open Platform.
- User identity send fails: this workflow intentionally uses `--as bot`; user-sent messages may be blocked by organization policy.
- Codex automation missing after moving computers: recreate it from `templates/codex-follow-builders-automation.prompt.md`.
- `lark-cli` prints an update notice: run `lark-cli update` when convenient, then restart Codex so updated skills are loaded.
