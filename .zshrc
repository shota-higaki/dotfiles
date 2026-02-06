# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_ALL_DUPS  # 重複を履歴に残さない
setopt HIST_FIND_NO_DUPS     # 検索時に重複を飛ばす
setopt HIST_REDUCE_BLANKS    # 余分な空白を削除
setopt SHARE_HISTORY         # 複数ターミナル間で履歴を共有
setopt APPEND_HISTORY        # 履歴ファイルに追記
setopt CORRECT               # コマンド名のタイプミスを修正提案

# --- eval キャッシュ ---
# ツールの初期化スクリプトをキャッシュし、シェル起動を高速化する。
# ツールのバイナリが更新されるとキャッシュを自動再生成する。
_zsh_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d "$_zsh_cache_dir" ]] || mkdir -p "$_zsh_cache_dir"

_cached_eval() {
  local cmd="$1" name="${2:-${1%% *}}" config="${3:-}"
  local cache="$_zsh_cache_dir/$name.zsh"
  local bin="${cmd%% *}"
  if [[ ! -f "$cache" ]] \
    || [[ "$(command -v "$bin")" -nt "$cache" ]] \
    || { [[ -n "$config" ]] && [[ "$config" -nt "$cache" ]]; }; then
    eval "$cmd" > "$cache"
  fi
  source "$cache"
}

# Sheldon (plugin manager) — 他の設定より先に読み込む
_cached_eval 'sheldon source' sheldon "$HOME/.config/sheldon/plugins.toml"

# Completion (Sheldon の zsh-completions が fpath に追加された後に呼ぶ)
autoload -Uz compinit && compinit

# Starship prompt
_cached_eval 'starship init zsh' starship

# mise (version manager - replaces rbenv/pyenv)
_cached_eval 'mise activate zsh' mise

# fzf keybindings & completion
_cached_eval 'fzf --zsh' fzf

# zoxide (smart cd)
_cached_eval 'zoxide init zsh' zoxide

# Aliases
alias ls="eza"
alias ll="eza -la --git --icons"
alias lt="eza --tree --level=2 --icons"
alias cat="bat --paging=never"
alias k="kubectl"
alias kn="kubectl -n"

# direnv (per-project env vars)
_cached_eval 'direnv hook zsh' direnv
