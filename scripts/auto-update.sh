#!/bin/bash
set -euo pipefail
# Runs at login via LaunchAgent. Updates brew, mise, sheldon and logs results.

LOG="$HOME/scripts/auto-update.log"
mkdir -p "$(dirname "$LOG")"

echo "=== $(date) ===" >> "$LOG"

# 各ステップの失敗をログに記録しつつ続行する
run_step() {
  local label="$1"
  shift
  echo "[$label] $*..." >> "$LOG"
  local rc=0
  "$@" >> "$LOG" 2>&1 || rc=$?
  if (( rc != 0 )); then
    echo "  [WARN] $label failed (exit $rc)" >> "$LOG"
  fi
}

# ネットワーク接続チェック (未接続なら即終了)
if ! /sbin/ping -c 1 -W 3 1.1.1.1 &>/dev/null; then
  echo "  [skip] Network unreachable. Retrying next login." >> "$LOG"
  echo "=== done ===" >> "$LOG"
  echo "" >> "$LOG"
  exit 0
fi

run_step "brew" /opt/homebrew/bin/brew update
run_step "brew" /opt/homebrew/bin/brew upgrade
run_step "brew" /opt/homebrew/bin/brew cleanup
run_step "mise" /opt/homebrew/bin/mise upgrade --yes
run_step "sheldon" /opt/homebrew/bin/sheldon lock

echo "[brew] doctor..." >> "$LOG"
DOCTOR=$(/opt/homebrew/bin/brew doctor 2>&1) || true
if echo "$DOCTOR" | grep -q "Warning"; then
  echo "$DOCTOR" >> "$LOG"
else
  echo "  No issues found." >> "$LOG"
fi

echo "=== done ===" >> "$LOG"
echo "" >> "$LOG"
