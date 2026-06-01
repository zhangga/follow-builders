#!/usr/bin/env bash
set -euo pipefail

APP_ID="cli_aa9d2f96f8381cbd"
RECEIVER_OPEN_ID="ou_1a698174d06fdc75f9f5567d41da0ac2"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_dir="$repo_root/submodules/zarazhangrui-follow-builders"
scripts_dir="$skill_dir/scripts"
config_template="$repo_root/templates/follow-builders.config.json"
automation_prompt="$repo_root/templates/codex-follow-builders-automation.prompt.md"
local_automation="$HOME/.codex/automations/follow-builders/automation.toml"
digest_prompt_template="$repo_root/templates/follow-builders-prompts/digest-intro.md"
user_digest_prompt="$HOME/.follow-builders/prompts/digest-intro.md"

ok_count=0

pass() {
  ok_count=$((ok_count + 1))
  printf 'PASS: %s\n' "$*"
}

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

need_file() {
  local path="$1"
  [ -f "$path" ] || fail "Missing file: $path"
  pass "Found $path"
}

need_command() {
  local name="$1"
  command -v "$name" >/dev/null 2>&1 || fail "Missing command: $name"
  pass "Found command $name"
}

printf 'Verifying Follow Builders Feishu restore setup in %s\n\n' "$repo_root"

need_command git
need_command node
need_command npm
need_command lark-cli

need_file "$config_template"
need_file "$automation_prompt"
need_file "$local_automation"
need_file "$digest_prompt_template"
need_file "$user_digest_prompt"
need_file "$scripts_dir/package.json"
need_file "$scripts_dir/prepare-digest.js"
need_file "$skill_dir/feed-x.json"
need_file "$skill_dir/feed-podcasts.json"
need_file "$skill_dir/feed-blogs.json"
need_file "$skill_dir/prompts/digest-intro.md"

if [ -d "$scripts_dir/node_modules" ]; then
  pass "Node dependencies are installed"
else
  fail "Node dependencies missing; run make setup"
fi

if node -e 'const fs=require("fs"); JSON.parse(fs.readFileSync(process.argv[1], "utf8"));' "$config_template"; then
  pass "Config template is valid JSON"
else
  fail "Config template is invalid JSON"
fi

if cmp -s "$digest_prompt_template" "$user_digest_prompt"; then
  pass "Installed digest prompt matches repository template"
else
  fail "Installed digest prompt differs from repository template; rerun bash scripts/bootstrap-feishu-follow-builders.sh"
fi

grep -Fq '## 📌 今日速览' "$digest_prompt_template" || fail "Digest prompt missing overview emoji heading"
grep -Fq '## 🧵 X / Twitter' "$digest_prompt_template" || fail "Digest prompt missing X/Twitter emoji heading"
grep -Fq '## 🏢 Official Blogs' "$digest_prompt_template" || fail "Digest prompt missing Official Blogs emoji heading"
grep -Fq '## 🎙 Podcasts' "$digest_prompt_template" || fail "Digest prompt missing Podcasts emoji heading"
grep -Fq '🔗 **来源：**' "$digest_prompt_template" || fail "Digest prompt missing link source prefix"
grep -Fq -- '---' "$digest_prompt_template" || fail "Digest prompt missing section divider"
pass "Digest prompt contains emoji headings, link source prefix, and section dividers"

tmp_json="$(mktemp "${TMPDIR:-/tmp}/follow-builders-prepared.XXXXXX.json")"
if (cd "$scripts_dir" && node prepare-digest.js > "$tmp_json" 2>/tmp/follow-builders-prepare.err); then
  node -e 'const fs=require("fs"); const j=JSON.parse(fs.readFileSync(process.argv[1], "utf8")); console.log(`PASS: prepare-digest.js returned status=${j.status}, xBuilders=${j.stats?.xBuilders ?? 0}, podcastEpisodes=${j.stats?.podcastEpisodes ?? 0}, blogPosts=${j.stats?.blogPosts ?? 0}`);' "$tmp_json"
  ok_count=$((ok_count + 1))
  node -e 'const fs=require("fs"); const j=JSON.parse(fs.readFileSync(process.argv[1], "utf8")); const p=j.prompts?.digest_intro || ""; for (const marker of ["## 📌 今日速览", "## 🧵 X / Twitter", "## 🏢 Official Blogs", "## 🎙 Podcasts", "🔗 **来源：**"]) if (!p.includes(marker)) process.exit(1);' "$tmp_json" \
    && pass "prepare-digest.js loaded repository-backed visual Feishu daily layout prompt" \
    || fail "prepare-digest.js did not load the visual Feishu daily layout prompt"
else
  if grep -q 'fetch failed' /tmp/follow-builders-prepare.err "$tmp_json" 2>/dev/null; then
    pass "prepare-digest.js hit fetch failed; bundled local feed fallback files are present"
  else
    cat /tmp/follow-builders-prepare.err >&2 2>/dev/null || true
    cat "$tmp_json" >&2 2>/dev/null || true
    fail "prepare-digest.js failed for an unexpected reason"
  fi
fi
rm -f "$tmp_json" /tmp/follow-builders-prepare.err

config_show="$(lark-cli config show 2>&1 || true)"
printf '%s\n' "$config_show" | grep -q "$APP_ID" || fail "lark-cli config does not show expected appId $APP_ID"
pass "lark-cli config has expected appId $APP_ID"

dry_run_output="$(lark-cli im +messages-send \
  --as bot \
  --user-id "$RECEIVER_OPEN_ID" \
  --markdown $'# Follow Builders Restore Dry Run\n\n2026-06-01 · Follow Builders\n\n---\n\n## 📌 今日速览\n\n- Feishu Markdown delivery target is configured.\n\n---\n\n🔗 **来源：**\nhttps://github.com/zarazhangrui/follow-builders' \
  --dry-run 2>&1)"
printf '%s\n' "$dry_run_output" | grep -q "$RECEIVER_OPEN_ID" || fail "Feishu send dry-run did not target $RECEIVER_OPEN_ID"
pass "Feishu bot Markdown send dry-run targets $RECEIVER_OPEN_ID"

grep -q 'RRULE:FREQ=WEEKLY;BYHOUR=8;BYMINUTE=0;BYDAY=SU,MO,TU,WE,TH,FR,SA' "$automation_prompt" || fail "Automation prompt missing daily 08:00 RRULE"
grep -q "$RECEIVER_OPEN_ID" "$automation_prompt" || fail "Automation prompt missing receiver open_id"
grep -Fq '~/.follow-builders/prompts/*.md' "$automation_prompt" || fail "Automation prompt missing custom prompt fallback path"
grep -q 'lark-cli im +messages-send --as bot' "$automation_prompt" || fail "Automation prompt missing bot send command"
grep -q -- '--markdown <digest>' "$automation_prompt" || fail "Automation prompt missing markdown send mode"
grep -Fq '## 📌 今日速览' "$automation_prompt" || fail "Automation prompt missing overview emoji heading"
grep -Fq '## 🧵 X / Twitter' "$automation_prompt" || fail "Automation prompt missing X/Twitter emoji heading"
grep -Fq '## 🏢 Official Blogs' "$automation_prompt" || fail "Automation prompt missing Official Blogs emoji heading"
grep -Fq '## 🎙 Podcasts' "$automation_prompt" || fail "Automation prompt missing Podcasts emoji heading"
grep -Fq '🔗 **来源：**' "$automation_prompt" || fail "Automation prompt missing link source prefix"
grep -Fq -- '---' "$automation_prompt" || fail "Automation prompt missing section divider"
pass "Automation prompt contains schedule, receiver, custom prompt fallback, markdown send mode, and visual daily-log layout"

grep -Fq '~/.follow-builders/prompts/*.md' "$local_automation" || fail "Local active automation missing custom prompt fallback path"
grep -q 'lark-cli im +messages-send --as bot' "$local_automation" || fail "Local active automation missing bot send command"
grep -q -- '--markdown <digest>' "$local_automation" || fail "Local active automation missing markdown send mode"
grep -Fq '## 📌 今日速览' "$local_automation" || fail "Local active automation missing overview emoji heading"
grep -Fq '## 🧵 X / Twitter' "$local_automation" || fail "Local active automation missing X/Twitter emoji heading"
grep -Fq '## 🏢 Official Blogs' "$local_automation" || fail "Local active automation missing Official Blogs emoji heading"
grep -Fq '## 🎙 Podcasts' "$local_automation" || fail "Local active automation missing Podcasts emoji heading"
grep -Fq '🔗 **来源：**' "$local_automation" || fail "Local active automation missing link source prefix"
grep -Fq -- '---' "$local_automation" || fail "Local active automation missing section divider"
if grep -Fq '不使用 emoji' "$local_automation"; then
  fail "Local active automation still forbids emoji"
fi
pass "Local active automation contains visual daily-log layout"

printf '\nAll checks passed (%d checks).\n' "$ok_count"
