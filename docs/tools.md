# Tools Reference

この dotfiles に含まれるツールの一覧と使い方。

## Terminal

### Ghostty

GPU-accelerated ターミナルエミュレータ。設定はプレーンテキスト。

- 設定: `.config/ghostty/config`
- テーマ: `.config/ghostty/themes/`
- macOS のダーク/ライトモードに自動追従

## Shell

### Sheldon (プラグインマネージャ)

Rust 製の高速 Zsh プラグインマネージャ。

```bash
sheldon lock    # プラグインのインストール/更新
sheldon source  # プラグインの読み込み (.zshrc 内で eval)
```

導入済みプラグイン:
- **zsh-autosuggestions**: 履歴ベースのコマンド候補表示 (右矢印キーで補完)
- **zsh-syntax-highlighting**: コマンドのシンタックスハイライト
- **zsh-completions**: 追加の補完定義

### Starship (プロンプト)

Rust 製のカスタマイズ可能なプロンプト。Git ブランチ、言語バージョン、コマンド実行時間を表示。

- 設定: `.config/starship.toml`
- プロンプト記号: `>` (緑=成功 / 赤=エラー)
- Git ステータス: `?`=未追跡, `!`=変更あり, `+`=ステージ済み, `⇡⇣`=ahead/behind

### fzf (ファジーファインダー)

```bash
Ctrl+R     # コマンド履歴のあいまい検索
Ctrl+T     # ファイルのあいまい検索
Alt+C      # ディレクトリのあいまい検索 & cd
```

### zoxide (スマート cd)

訪問したディレクトリを学習し、部分一致でジャンプ。

```bash
z docs         # 最もよく行く "docs" を含むディレクトリにジャンプ
z prog dotf    # 複数キーワードで絞り込み
zi             # fzf を使ったインタラクティブ選択
```

## Modern CLI Tools

### eza (ls の上位互換)

```bash
ls             # → eza (エイリアス設定済み)
ll             # eza -la --git --icons (詳細 + Git ステータス + アイコン)
lt             # eza --tree --level=2 --icons (ツリー表示)
```

### bat (cat の上位互換)

```bash
cat file.py    # → bat (エイリアス設定済み、シンタックスハイライト付き)
bat -l json    # 言語を明示してハイライト
bat --diff     # Git diff のハイライト表示
```

### ripgrep (grep の上位互換)

```bash
rg "pattern"              # カレントディレクトリ以下を再帰検索
rg "pattern" -t py        # Python ファイルのみ
rg "pattern" -g "*.ts"    # glob パターンで絞り込み
rg "pattern" -l           # マッチしたファイル名のみ表示
rg "pattern" -C 3         # 前後 3 行のコンテキスト表示
```

`.gitignore` を自動で尊重するため、`node_modules` 等は検索対象外。

### jq (JSON プロセッサ)

```bash
cat data.json | jq '.users[0].name'   # フィールド抽出
jq -r '.[] | .id' data.json           # 値のみ出力 (raw)
curl -s api/endpoint | jq '.'         # API レスポンスを整形
```

### httpie (HTTP クライアント)

curl より直感的な構文で HTTP リクエストを送る。

```bash
http GET https://api.example.com/users        # GET リクエスト
http POST https://api.example.com/users name=John  # JSON POST
http -f POST api/upload file@image.png        # ファイルアップロード
http -v GET api/endpoint                      # ヘッダー込みの詳細出力
```

### tldr (man の要約版)

```bash
tldr tar        # tar の実用的な使い方を表示
tldr git stash  # git stash の使い方を表示
```

### ni (パッケージマネージャ自動選択)

プロジェクトのロックファイルを検出し、適切なパッケージマネージャ (npm/yarn/pnpm/bun) を自動で使い分ける。

```bash
ni                          # install (npm i / yarn / pnpm i / bun i)
ni axios                    # add (npm i axios / yarn add axios / ...)
nr dev                      # run script (npm run dev / yarn dev / ...)
nr                          # スクリプト一覧からインタラクティブに選択
nlx vitest                  # execute (npx vitest / bunx vitest / ...)
nun axios                   # uninstall
nci                         # clean install (npm ci / yarn install --frozen-lockfile / ...)
nup                         # upgrade dependencies
```

## Git

### delta (diff ハイライト)

`git diff` / `git log -p` / `git show` に自動適用。設定不要。

- サイドバイサイド表示
- 行番号付き
- シンタックスハイライト
- `n` / `N` キーでファイル間をナビゲート

### gh (GitHub CLI)

```bash
gh pr create               # PR 作成
gh pr view --web           # PR をブラウザで開く
gh pr list                 # PR 一覧
gh issue list              # Issue 一覧
gh run list                # CI 実行一覧
gh repo view --web         # リポジトリをブラウザで開く
```

### Git 便利設定

`.gitconfig` に設定済み:

| 設定 | 効果 |
|------|------|
| `rerere.enabled` | 一度解決したコンフリクトを記憶し、次回自動解決 |
| `push.autoSetupRemote` | 初回 push 時に `--set-upstream` が不要になる |
| `fetch.prune` | fetch 時に削除済みリモートブランチを自動整理 |
| `pull.rebase` | pull 時に rebase (不要なマージコミットを防止) |

### Git エイリアス

`.gitconfig` に設定済み:

```bash
git s          # git status --short
git l          # git log --oneline --graph -20
git sw <branch> # git switch <branch>
git unstage    # git reset HEAD --
```

## Environment

### direnv (プロジェクト別の環境変数)

ディレクトリに `.envrc` を置くと、`cd` で入った時に自動で環境変数が読み込まれ、出た時にアンロードされる。

```bash
# プロジェクトに .envrc を作成
echo 'export DATABASE_URL="postgres://localhost/mydb"' > .envrc

# 初回は許可が必要
direnv allow

# 以降は cd するだけで自動適用
cd my-project/   # → DATABASE_URL が設定される
cd ..            # → DATABASE_URL がアンロードされる
```

## Security

### gitleaks (シークレット漏洩防止)

全リポジトリの `git commit` 時にグローバル pre-commit フックとして自動実行される。API キー、トークン、パスワード等のパターンを検出し、コミットをブロックする。

```bash
# 手動でリポジトリ全体をスキャン
gitleaks git --verbose

# ステージされたファイルのみスキャン
gitleaks git --pre-commit --staged --verbose
```

誤検知がある場合は `.gitleaksignore` をリポジトリルートに作成し、Fingerprint を記載することで除外できる:

```
# .gitleaksignore
config.yml:generic-api-key:5
```

## Kubernetes

### kubectl (クラスタ操作)

```bash
k get pods                  # Pod 一覧 (エイリアス設定済み)
k get svc -n staging        # namespace 指定
kn production get deploy    # kn = kubectl -n (エイリアス設定済み)
k logs -f pod-name          # ログをフォロー
k exec -it pod-name -- sh  # Pod にシェルアクセス
```

### k9s (クラスタ TUI)

```bash
k9s                         # デフォルトコンテキストで起動
k9s -n kube-system          # namespace を指定して起動
k9s --context production    # コンテキストを指定して起動
```

主なキーバインド:
- `:pods`, `:svc`, `:deploy` — リソース種別の切替
- `/` — フィルタリング
- `l` — ログ表示
- `s` — シェルアクセス
- `Ctrl+D` — リソース削除

### stern (マルチ Pod ログ)

複数 Pod のログをまとめてテール表示する。

```bash
stern web                   # "web" にマッチする全 Pod のログ
stern web -n staging        # namespace 指定
stern web --since 5m        # 直近 5 分のログ
stern web -o json           # JSON 形式で出力
```

### kubectx / kubens (コンテキスト・namespace 切替)

```bash
kubectx                     # コンテキスト一覧
kubectx production          # コンテキスト切替
kubectx -                   # 直前のコンテキストに戻る
kubens                      # namespace 一覧
kubens staging              # namespace 切替
```

### helm (パッケージ管理)

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm search repo nginx      # チャート検索
helm install my-app bitnami/nginx              # インストール
helm upgrade my-app bitnami/nginx              # アップグレード
helm list                   # インストール済みリリース一覧
helm uninstall my-app       # アンインストール
```

## Infrastructure

### awscli (AWS 操作)

```bash
aws configure               # 認証情報の設定
aws s3 ls                   # S3 バケット一覧
aws s3 cp file.txt s3://bucket/  # ファイルアップロード
aws ec2 describe-instances  # EC2 インスタンス一覧
aws sts get-caller-identity # 現在の認証情報を確認
```

### terraform (IaC)

```bash
terraform init              # プロバイダ・モジュールの初期化
terraform plan              # 変更内容のプレビュー
terraform apply             # 変更の適用
terraform destroy           # リソースの削除
terraform fmt               # 設定ファイルのフォーマット
terraform state list        # 管理中リソースの一覧
```

## Version Manager

### mise

Node.js, Ruby, Python 等のランタイムを統一管理。

```bash
mise list                   # インストール済みランタイム一覧
mise use --global node@22   # グローバルバージョンの変更
mise use node@20            # プロジェクト単位のバージョン指定 (.mise.toml 生成)
mise install                # 設定ファイルに基づき全ランタイムをインストール
mise outdated               # 更新可能なバージョンの確認
```
