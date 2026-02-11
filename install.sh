#!/usr/bin/env bash
set -euo pipefail

# dotfiles 管理対象ファイル（ホームディレクトリ直下）
DOTFILES=(".zshrc")

# カスタムパス（source:target、target は $HOME からの相対パス）
CUSTOM_LINKS=("ghostty/config:Library/Application Support/com.mitchellh.ghostty/config")

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# スクリプトの絶対パスを取得（どこから実行しても動作するように）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"
HOME_DIR="$HOME"

echo "=== dotfiles インストール ==="
echo "DOTFILES_DIR: $DOTFILES_DIR"
echo "HOME_DIR: $HOME_DIR"
echo ""

for file in "${DOTFILES[@]}"; do
  source_path="$DOTFILES_DIR/$file"
  target_path="$HOME_DIR/$file"

  # ソースファイルの存在確認
  if [[ ! -e "$source_path" ]]; then
    log_error "ソースファイルが存在しません: $source_path"
    exit 1
  fi

  if [[ -e "$target_path" ]] || [[ -L "$target_path" ]]; then
    # 既存ファイルまたはリンクがある場合はバックアップ
    timestamp=$(date +%Y%m%d_%H%M%S)
    backup_path="${target_path}.backup.${timestamp}"
    if mv "$target_path" "$backup_path" 2>/dev/null; then
      log_warn "既存の $file をバックアップしました: $backup_path"
    else
      log_error "バックアップに失敗しました: $target_path"
      exit 1
    fi
  fi

  # シンボリックリンク作成（絶対パスを使用）
  if ln -s "$source_path" "$target_path" 2>/dev/null; then
    log_success "$file のシンボリックリンクを作成しました"
  else
    log_error "シンボリックリンクの作成に失敗しました: $file"
    exit 1
  fi
done

# カスタムパスのシンボリックリンク
for entry in "${CUSTOM_LINKS[@]}"; do
  source_file="${entry%%:*}"
  target_rel="${entry#*:}"
  source_path="$DOTFILES_DIR/$source_file"
  target_path="$HOME_DIR/$target_rel"

  if [[ ! -e "$source_path" ]]; then
    log_error "ソースファイルが存在しません: $source_path"
    exit 1
  fi

  target_dir="$(dirname "$target_path")"
  if [[ ! -d "$target_dir" ]]; then
    mkdir -p "$target_dir"
    log_warn "ディレクトリを作成しました: $target_dir"
  fi

  if [[ -e "$target_path" ]] || [[ -L "$target_path" ]]; then
    timestamp=$(date +%Y%m%d_%H%M%S)
    backup_path="${target_path}.backup.${timestamp}"
    if mv "$target_path" "$backup_path" 2>/dev/null; then
      log_warn "既存の $target_rel をバックアップしました: $backup_path"
    else
      log_error "バックアップに失敗しました: $target_path"
      exit 1
    fi
  fi

  if ln -s "$source_path" "$target_path" 2>/dev/null; then
    log_success "$target_rel のシンボリックリンクを作成しました"
  else
    log_error "シンボリックリンクの作成に失敗しました: $target_rel"
    exit 1
  fi
done

echo ""
log_success "インストールが完了しました"
