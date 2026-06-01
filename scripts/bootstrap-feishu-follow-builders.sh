#!/usr/bin/env bash
set -euo pipefail

APP_ID="cli_aa9d2f96f8381cbd"
RECEIVER_OPEN_ID="ou_1a698174d06fdc75f9f5567d41da0ac2"
BOT_NAME="小强Bot"
dry_run=false

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config_template="$repo_root/templates/follow-builders.config.json"
user_config_dir="$HOME/.follow-builders"
user_config="$user_config_dir/config.json"

log() {
  printf '[follow-builders bootstrap] %s\n' "$*"
}

require_command() {
  local name="$1"
  if ! command -v "$name" >/dev/null 2>&1; then
    printf 'Required command not found: %s\n' "$name" >&2
    return 1
  fi
}

usage() {
  cat <<'EOF'
Usage:
  bash scripts/bootstrap-feishu-follow-builders.sh
  bash scripts/bootstrap-feishu-follow-builders.sh --dry-run

Options:
  --dry-run   Show planned actions and run safe checks only. Does not write
              ~/.follow-builders/config.json, initialize lark-cli, ask for
              appSecret, or send a real Feishu message.
  -h, --help  Show this help.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run)
      dry_run=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

log "Repository: $repo_root"

require_command git
require_command node
require_command npm

if ! command -v lark-cli >/dev/null 2>&1; then
  cat >&2 <<'EOF'
lark-cli was not found in PATH.

Install or restore lark-cli first, then rerun:
  bash scripts/bootstrap-feishu-follow-builders.sh
EOF
  exit 1
fi

if [ ! -f "$config_template" ]; then
  printf 'Config template missing: %s\n' "$config_template" >&2
  exit 1
fi

if [ "$dry_run" = true ]; then
  log "Dry run: would run make setup in $repo_root"

  if [ -f "$user_config" ] && cmp -s "$config_template" "$user_config"; then
    log "Dry run: existing $user_config already matches the template"
  elif [ -f "$user_config" ]; then
    log "Dry run: would back up existing $user_config, then copy $config_template"
  else
    log "Dry run: would create $user_config from $config_template"
  fi

  if lark-cli config show 2>/dev/null | grep -q "$APP_ID"; then
    log "Dry run: lark-cli already shows expected appId $APP_ID"
    lark-cli im +messages-send \
      --as bot \
      --user-id "$RECEIVER_OPEN_ID" \
      --text "Follow Builders restore dry-run" \
      --dry-run
  else
    log "Dry run: would initialize lark-cli with appId $APP_ID via appSecret stdin"
    log "Dry run: would send a Feishu test message to $RECEIVER_OPEN_ID after lark-cli init"
  fi

  log "Dry run complete; no files, secrets, or Feishu messages were changed."
  exit 0
fi

log "Running make setup..."
make -C "$repo_root" setup

mkdir -p "$user_config_dir"
if [ -f "$user_config" ] && ! cmp -s "$config_template" "$user_config"; then
  backup="$user_config.backup.$(date +%Y%m%d%H%M%S)"
  cp "$user_config" "$backup"
  log "Backed up existing config to $backup"
fi
cp "$config_template" "$user_config"
log "Wrote $user_config"

cat <<EOF

Next, initialize lark-cli for $BOT_NAME.
App ID: $APP_ID

Paste the Feishu appSecret when prompted. It will not be echoed and will not be
written to this repository.
EOF

printf 'Feishu appSecret: '
stty_state="$(stty -g 2>/dev/null || true)"
if [ -n "$stty_state" ]; then
  stty -echo
fi
IFS= read -r app_secret
if [ -n "$stty_state" ]; then
  stty "$stty_state"
fi
printf '\n'

if [ -z "$app_secret" ]; then
  echo 'Empty appSecret; aborting without changing lark-cli config.' >&2
  exit 1
fi

log "Initializing lark-cli profile for $BOT_NAME..."
printf '%s' "$app_secret" | lark-cli config init \
  --app-id "$APP_ID" \
  --app-secret-stdin \
  --brand feishu \
  --lang zh

unset app_secret

test_message="Follow Builders restore test: ${BOT_NAME} can send Feishu messages from $(hostname) at $(date '+%Y-%m-%d %H:%M:%S %Z')."

log "Sending Feishu test message to $RECEIVER_OPEN_ID..."
lark-cli im +messages-send \
  --as bot \
  --user-id "$RECEIVER_OPEN_ID" \
  --text "$test_message" \
  --idempotency-key "follow-builders-bootstrap-$(date +%Y%m%d%H%M%S)"

cat <<EOF

Bootstrap complete.

Next step in Codex:
  Paste the contents of templates/codex-follow-builders-automation.prompt.md
  and ask Codex to create the automation.

Optional verification:
  bash scripts/verify-feishu-follow-builders.sh
EOF
