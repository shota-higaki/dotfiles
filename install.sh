#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Parse flags
AUTO_UPDATE=false
for arg in "$@"; do
  case "$arg" in
    --auto-update) AUTO_UPDATE=true ;;
  esac
done

# ============================================================
# 1. Homebrew
# ============================================================
if ! command -v brew &> /dev/null; then
  echo "==> Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Apple Silicon の場合は PATH を通す
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  echo "==> Homebrew found: $(brew --version | head -1)"
fi

echo "==> Installing Homebrew packages..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# ============================================================
# 2. Deploy config files
# ============================================================
echo ""
echo "==> Deploying config files..."

deploy() {
  local src="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"

  # シンボリックリンクが残っていれば削除してからコピー
  if [ -L "$dest" ]; then
    rm "$dest"
    cp "$src" "$dest"
    echo "  $dest (replaced symlink with copy)"
    return
  fi

  # ファイルが存在しない場合はそのままコピー
  if [ ! -e "$dest" ]; then
    cp "$src" "$dest"
    echo "  $dest (new)"
    return
  fi

  # 差分がなければスキップ
  if diff -q "$src" "$dest" > /dev/null 2>&1; then
    echo "  $dest (no changes)"
    return
  fi

  # 差分がある場合は確認
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

# Shell
deploy "$DOTFILES_DIR/.zshrc"    "$HOME/.zshrc"
deploy "$DOTFILES_DIR/.zshenv"   "$HOME/.zshenv"
deploy "$DOTFILES_DIR/.zprofile" "$HOME/.zprofile"

# Git
deploy "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"

# Sheldon
deploy "$DOTFILES_DIR/.config/sheldon/plugins.toml" "$HOME/.config/sheldon/plugins.toml"

# Starship
deploy "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"

# Git global hooks
deploy "$DOTFILES_DIR/.config/git/hooks/pre-commit" "$HOME/.config/git/hooks/pre-commit"

# mise
deploy "$DOTFILES_DIR/.config/mise/config.toml" "$HOME/.config/mise/config.toml"

# Ghostty
deploy "$DOTFILES_DIR/.config/ghostty/config" "$HOME/.config/ghostty/config"
if [ -d "$DOTFILES_DIR/.config/ghostty/themes" ]; then
  for theme in "$DOTFILES_DIR/.config/ghostty/themes/"*; do
    theme_name=$(basename "$theme")
    deploy "$theme" "$HOME/.config/ghostty/themes/$theme_name"
  done
fi

# ============================================================
# 3. Sheldon plugins
# ============================================================
echo ""
echo "==> Installing sheldon plugins..."

# Ensure brew-installed binaries are in PATH for this script session
if [[ -d /opt/homebrew/bin ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
fi

sheldon lock

# ============================================================
# 4. mise runtimes
# ============================================================
echo ""
echo "==> Installing mise runtimes..."
mise install

# ============================================================
# 5. Git user config (interactive)
# ============================================================
echo ""
echo "==> Setting up Git user config (~/.gitconfig.local)..."

GITCONFIG_LOCAL="$HOME/.gitconfig.local"

if [[ -f "$GITCONFIG_LOCAL" ]]; then
  echo "  ~/.gitconfig.local already exists:"
  echo "    name:  $(git config --file "$GITCONFIG_LOCAL" user.name 2>/dev/null || echo '(not set)')"
  echo "    email: $(git config --file "$GITCONFIG_LOCAL" user.email 2>/dev/null || echo '(not set)')"
  echo ""
  read -rp "  Overwrite? [y/N] " overwrite
  if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
    echo "  Skipped."
    echo ""
    echo "==> Done!"
    exit 0
  fi
fi

# Name
current_name="$(git config --file "$GITCONFIG_LOCAL" user.name 2>/dev/null || true)"
read -rp "  Git user.name [${current_name:-}]: " git_name
git_name="${git_name:-$current_name}"

# Email
current_email="$(git config --file "$GITCONFIG_LOCAL" user.email 2>/dev/null || true)"
read -rp "  Git user.email [${current_email:-}]: " git_email
git_email="${git_email:-$current_email}"

# Write
git config --file "$GITCONFIG_LOCAL" user.name "$git_name"
git config --file "$GITCONFIG_LOCAL" user.email "$git_email"

echo ""
echo "  Saved: $git_name <$git_email>"

# GPG signing (optional)
echo ""
read -rp "  Enable GPG commit signing? [y/N] " enable_gpg
if [[ "$enable_gpg" =~ ^[Yy]$ ]]; then
  echo ""
  echo "  Available GPG keys:"
  gpg --list-secret-keys --keyid-format=long 2>/dev/null | grep -E '^\s+[A-F0-9]' || echo "    (no keys found)"
  echo ""
  read -rp "  GPG signing key ID (or Enter to skip): " gpg_key
  if [[ -n "$gpg_key" ]]; then
    git config --file "$GITCONFIG_LOCAL" user.signingkey "$gpg_key"
    git config --file "$GITCONFIG_LOCAL" commit.gpgsign true
    echo "  GPG signing enabled with key: $gpg_key"
  else
    echo "  Skipped GPG setup."
  fi
else
  echo "  Skipped GPG setup."
fi

# ============================================================
# 6. Auto-update (optional)
# ============================================================
if [[ "$AUTO_UPDATE" == true ]]; then
  echo ""
  echo "==> Setting up auto-update (LaunchAgent)..."

  PLIST_SRC="$DOTFILES_DIR/scripts/com.dotfiles.auto-update.plist"
  PLIST_DEST="$HOME/Library/LaunchAgents/com.dotfiles.auto-update.plist"

  # Generate plist with actual paths
  sed \
    -e "s|__DOTFILES_DIR__|$DOTFILES_DIR|g" \
    -e "s|__HOME__|$HOME|g" \
    "$PLIST_SRC" > "$PLIST_DEST"

  # Unload if already loaded, then load
  launchctl bootout "gui/$(id -u)" "$PLIST_DEST" 2>/dev/null || true
  launchctl bootstrap "gui/$(id -u)" "$PLIST_DEST"

  echo "  Installed: $PLIST_DEST"
  echo "  Log: ~/scripts/auto-update.log"
  echo "  brew, mise, sheldon will auto-update on login."
fi

# ============================================================
# Done
# ============================================================
echo ""
echo "==> Done! Open a new terminal to apply changes."
