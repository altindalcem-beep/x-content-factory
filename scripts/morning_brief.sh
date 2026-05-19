#!/bin/zsh
# X Content Factory — Morning Brief Motor
# Her sabah 07:00'de çalışır.
# Bugünün 3 tweet draft'ı + reply hedef listesi + (Pazara yakınsa) thread fikri üretir.
# Çıktı: drafts/YYYY-MM-DD.md
#
# Bağımsız test: ./scripts/morning_brief.sh

set -euo pipefail
setopt null_glob 2>/dev/null || true   # zsh: boş glob = boş, hata atma

FACTORY_DIR="$HOME/x-content-factory"
TODAY=$(date +%Y-%m-%d)
WEEKDAY_EN=$(date +%A)
LOG_FILE="$FACTORY_DIR/logs/morning_brief_$TODAY.log"
DRAFT_FILE="$FACTORY_DIR/drafts/$TODAY.md"
PROMPT_FILE="$FACTORY_DIR/prompts/morning_brief.md"
NIS_BAGLAM="$FACTORY_DIR/config/nis-baglam.md"
BALINA_LIST="$FACTORY_DIR/config/balina-listesi.txt"

# Son 7 günün draft'larını oku (tekrar etmemek için)
# Önemli: zsh null_glob ile boş klasörde glob silinir → cat argumansız kalır → stdin'i bekler (donar)
# Bu yüzden önce array olarak topla, boyutu kontrol et.
DRAFT_FILES=("$FACTORY_DIR/drafts/"*.md)
if [ ${#DRAFT_FILES[@]} -gt 0 ]; then
    RECENT_DRAFTS=$(printf '%s\n' "${DRAFT_FILES[@]}" | sort -r | head -7 | while IFS= read -r f; do cat "$f"; echo ""; done)
else
    RECENT_DRAFTS="(henüz draft yok)"
fi

# Swipe file (varsa) — niş içi viral örnekler
SWIPE_FILES=("$FACTORY_DIR/swipe-file/"*.md)
if [ ${#SWIPE_FILES[@]} -gt 0 ]; then
    SWIPE_CONTENT=$(cat "${SWIPE_FILES[@]}")
else
    SWIPE_CONTENT="(swipe file boş)"
fi

# claude CLI yolu (PATH'te yoksa absolute path kullan)
CLAUDE_BIN=$(command -v claude || echo "$HOME/.local/bin/claude")

# Brief üret
{
  echo "# CONTEXT"
  echo ""
  echo "## Bugün"
  echo "Tarih: $TODAY ($WEEKDAY_EN)"
  echo ""
  echo "## Niş bağlamı"
  cat "$NIS_BAGLAM"
  echo ""
  echo "## Balina hesap listem"
  cat "$BALINA_LIST"
  echo ""
  echo "## Son 7 günde attığım postlar (tekrar etmemek için referans)"
  echo "$RECENT_DRAFTS"
  echo ""
  echo "## Swipe file (niş'imde viral olmuş örnekler)"
  echo "$SWIPE_CONTENT"
  echo ""
  echo "# TASK"
  cat "$PROMPT_FILE"
} | "$CLAUDE_BIN" -p --output-format text > "$DRAFT_FILE" 2>> "$LOG_FILE"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Morning brief tamam: $DRAFT_FILE" >> "$LOG_FILE"

# iCloud'a aynalı kopya (iPhone Files app'ten erişim için)
rsync -a "$FACTORY_DIR/drafts/" "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Obsidian/x-factory/drafts/" >/dev/null 2>&1 || true

# macOS bildirimi
osascript -e "display notification \"Bugünün X brief'i hazır: $TODAY.md\" with title \"X Content Factory\" sound name \"Glass\""
