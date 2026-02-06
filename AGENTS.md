# AGENTS.md

このリポジトリは macOS 向け dotfiles (開発環境設定) を管理している。

## リポジトリ構造

- シェル設定: `.zshrc`, `.zshenv`, `.zprofile`
- ツール設定: `.config/` 以下 (ghostty, sheldon, starship, git hooks)
- Git 設定: `.gitconfig` (共通) + `.gitconfig.local` (ユーザー固有、リポジトリ外)
- セキュリティ: `.config/git/hooks/pre-commit` で gitleaks によるシークレットスキャンが全リポジトリに自動適用される
- パッケージ一覧: `Brewfile`
- セットアップ: `install.sh`

## ルール

- **機密情報を含めない**: API キー、トークン、パスワード、GPG 秘密鍵をコミットしないこと。ユーザー固有の情報は `.gitconfig.local` 等のリポジトリ外ファイルに分離する
- **コピー方式**: `install.sh` は全設定ファイルをコピーで配置する (シンボリックリンクは使わない)。deploy 先で環境固有の変更を加えてもリポジトリに影響しない。リポジトリの変更を反映するには `scripts/deploy.sh` を実行する
- **上書き確認**: 既存ファイルと差分がある場合は diff を表示して上書き確認を行う。`scripts/deploy.sh --force` で確認をスキップ可能
- **Brewfile の同期**: 新しいツールを導入する場合は Brewfile にも追加すること
- **macOS 前提**: このリポジトリは macOS (Apple Silicon) を対象としている

## 設定ファイル編集時の注意

- `.zshrc` の `_cached_eval 'sheldon source'` は他の設定より先に記述する (プラグインが先に読み込まれる必要がある)
- `.zshrc` はツール初期化に `_cached_eval` キャッシュ機構を使用している。バイナリの更新時、および設定ファイル (第3引数) の変更時にキャッシュが自動再生成される。キャッシュは `~/.cache/zsh/` に保存される
- Ghostty テーマファイルはキー=値のプレーンテキスト形式。TOML ではない
- Starship 設定は TOML 形式
- `.gitconfig` は `[include] path = ~/.gitconfig.local` でユーザー固有設定を読み込む
- `.gitconfig` の `core.hooksPath` がグローバル hooks ディレクトリ (`~/.config/git/hooks/`) を指している。リポジトリ固有の hooks が必要な場合は `git config --local core.hooksPath .githooks` 等で上書き可能

## 参照ドキュメント

- [README.md](README.md) — セットアップ手順、構造、カスタマイズ方法
- [docs/tools.md](docs/tools.md) — 全ツールの使い方リファレンス
