#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

FORCE=false
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
  esac
done

# コピー対象ファイル (src:dest)
FILES=(
  ".zshrc:$HOME/.zshrc"
  ".zshenv:$HOME/.zshenv"
  ".zprofile:$HOME/.zprofile"
  ".gitconfig:$HOME/.gitconfig"
  ".config/sheldon/plugins.toml:$HOME/.config/sheldon/plugins.toml"
  ".config/starship.toml:$HOME/.config/starship.toml"
  ".config/git/hooks/pre-commit:$HOME/.config/git/hooks/pre-commit"
  ".config/mise/config.toml:$HOME/.config/mise/config.toml"
  ".config/ghostty/config:$HOME/.config/ghostty/config"
)

deploy_file() {
  local src="$DOTFILES_DIR/$1"
  local dest="$2"

  if [ ! -f "$src" ]; then
    echo "  SKIP: $src not found"
    return
  fi

  mkdir -p "$(dirname "$dest")"

  # シンボリックリンクの場合は削除してコピー
  if [ -L "$dest" ]; then
    rm "$dest"
    cp "$src" "$dest"
    echo "  $dest <- $src (replaced symlink with copy)"
    return
  fi

  # ファイルが存在しない場合はそのままコピー
  if [ ! -f "$dest" ]; then
    cp "$src" "$dest"
    echo "  $dest <- $src (new)"
    return
  fi

  # 差分チェック
  if diff -q "$src" "$dest" > /dev/null 2>&1; then
    echo "  $dest (no changes)"
    return
  fi

  # 差分がある場合
  if [ "$FORCE" = true ]; then
    cp "$src" "$dest"
    echo "  $dest <- $src (updated)"
    return
  fi

  echo ""
  echo "  === $dest ==="
  diff -u "$dest" "$src" || true
  echo ""
  read -rp "  Overwrite $dest? [y/N] " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    cp "$src" "$dest"
    echo "  Updated."
  else
    echo "  Skipped."
  fi
}

# Ghostty テーマを動的に追加
if [ -d "$DOTFILES_DIR/.config/ghostty/themes" ]; then
  for theme in "$DOTFILES_DIR/.config/ghostty/themes/"*; do
    theme_name=$(basename "$theme")
    FILES+=(".config/ghostty/themes/$theme_name:$HOME/.config/ghostty/themes/$theme_name")
  done
fi

echo "==> Deploying config files from $DOTFILES_DIR ..."
echo ""

for entry in "${FILES[@]}"; do
  src="${entry%%:*}"
  dest="${entry#*:}"
  deploy_file "$src" "$dest"
done

echo ""
echo "==> Done."
