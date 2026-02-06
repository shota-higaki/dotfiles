# dotfiles

macOS 向けの開発環境セットアップ。Ghostty + Sheldon + Starship ベースの環境を 1 コマンドで再現する。

## Quick Start

```bash
# 1. このリポジトリをクローン
gh repo clone shota-higaki/dotfiles

# 2. セットアップ実行 (Homebrew 未導入なら自動インストール)
./install.sh
```

`install.sh` が対話的にすべてセットアップする:
- Homebrew のインストール (未導入の場合)
- 全ツールの一括インストール
- 設定ファイルのコピー配置 (差分がある場合は確認)
- Zsh プラグイン・ランタイムのインストール
- Git ユーザー情報の設定 (名前・メール)
- GPG コミット署名の設定 (オプション)

### Options

```bash
# ログイン時にツールを自動更新する LaunchAgent も設定する場合
./install.sh --auto-update
```

`--auto-update` を付けると、macOS ログイン時に brew, mise, sheldon を自動更新する LaunchAgent が登録される。ログは `~/scripts/auto-update.log` に記録される。

## What's Included

| カテゴリ | ツール | 説明 |
|---------|--------|------|
| Terminal | [Ghostty](https://ghostty.org) | GPU-accelerated ターミナル |
| Shell Plugins | [Sheldon](https://github.com/rossmacarthur/sheldon) | Rust 製プラグインマネージャ |
| Prompt | [Starship](https://starship.rs) | Rust 製カスタマイズ可能プロンプト |
| Version Manager | [mise](https://mise.jdx.dev) | Node/Ruby/Python 等の統一バージョン管理 |
| Git | [delta](https://github.com/dandavison/delta) / [gh](https://cli.github.com) | diff ハイライト, GitHub CLI |
| CLI | [eza](https://github.com/eza-community/eza) / [bat](https://github.com/sharkdp/bat) / [ripgrep](https://github.com/BurntSushi/ripgrep) / [fzf](https://github.com/junegunn/fzf) / [zoxide](https://github.com/ajeetdsouza/zoxide) | モダン CLI ツール群 |
| CLI (データ処理) | [jq](https://jqlang.github.io/jq/) / [httpie](https://httpie.io) / [tldr](https://tldr.sh) | JSON 処理, HTTP クライアント, man 要約 |
| Package Manager | [ni](https://github.com/antfu-collective/ni) | プロジェクトに応じたパッケージマネージャ自動選択 |
| Environment | [direnv](https://direnv.net) | プロジェクト別の環境変数管理 |
| Security | [gitleaks](https://github.com/gitleaks/gitleaks) | 全リポジトリ共通の秘密情報漏洩防止 |
| Kubernetes | [kubectl](https://kubernetes.io/docs/reference/kubectl/) / [k9s](https://k9scli.io) / [stern](https://github.com/stern/stern) / [kubectx](https://github.com/ahmetb/kubectx) / [helm](https://helm.sh) | クラスタ管理, ログ, コンテキスト切替, パッケージ管理 |
| Infrastructure | [awscli](https://aws.amazon.com/cli/) / [terraform](https://www.terraform.io) | AWS 操作, IaC |

詳細は [docs/tools.md](docs/tools.md) を参照。

## Structure

```
.
├── .config/
│   ├── ghostty/          # ターミナル設定 + カスタムテーマ
│   ├── git/hooks/        # グローバル Git フック (gitleaks)
│   ├── sheldon/          # Zsh プラグイン定義
│   └── starship.toml     # プロンプト設定
├── .gitconfig            # Git 共通設定 (delta, alias, rerere 等)
├── .gitignore            # Git 除外設定
├── .gitconfig.local.example  # Git ユーザー情報テンプレート
├── .zshrc                # メインシェル設定
├── .zshenv               # 環境変数
├── .zprofile             # ログインシェル設定
├── scripts/
│   ├── deploy.sh         # コピー対象ファイルの再デプロイ
│   ├── auto-update.sh    # 自動更新スクリプト (--auto-update 時)
│   └── com.dotfiles.auto-update.plist  # LaunchAgent テンプレート
├── Brewfile              # Homebrew パッケージ一覧
├── docs/
│   └── tools.md          # 全ツールの使い方リファレンス
└── install.sh            # セットアップスクリプト (対話式)
```

## How It Works

`install.sh` は以下を順番に実行する:

1. **Homebrew** のインストール (未導入の場合のみ)
2. `brew bundle` で **Brewfile のパッケージを一括インストール**
3. 設定ファイルを `$HOME` に**コピー** (既存ファイルと差分がある場合は確認)
4. `sheldon lock` で **Zsh プラグインをインストール**
5. `mise install` で**ランタイムをインストール**
6. **Git ユーザー情報**を対話的に設定 → `~/.gitconfig.local` に保存
7. **GPG コミット署名**を設定 (オプション)
8. **LaunchAgent** による自動更新を登録 (`--auto-update` 指定時のみ)

全ファイルはコピーで配置されるため、deploy 先を変更してもリポジトリには影響しない。リポジトリの変更を反映するには `scripts/deploy.sh` を実行する。

## Customization

- **Git ユーザー情報**: `~/.gitconfig.local` に保存 (リポジトリには含まれない)
- **Ghostty テーマ**: `.config/ghostty/themes/` にテーマファイルを追加
- **Starship プロンプト**: `.config/starship.toml` を編集
- **Zsh プラグイン**: `.config/sheldon/plugins.toml` に追加
- **ランタイムバージョン**: `mise use --global <tool>@<version>`
- **プロジェクト別環境変数**: プロジェクトに `.envrc` を作成 → `direnv allow`
