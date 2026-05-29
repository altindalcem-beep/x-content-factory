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

# Son 7 günün brief'lerini oku (tekrar etmemek için)
# Sadece günlük brief dosyaları: YYYY-MM-DD.md (replies-*.md, weekreview-*.md hariç)
# Önemli: zsh null_glob ile boş klasörde glob silinir → cat argumansız kalır → stdin'i bekler (donar)
# Bu yüzden önce array olarak topla, boyutu kontrol et.
DRAFT_FILES=("$FACTORY_DIR/drafts/"[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].md)
if [ ${#DRAFT_FILES[@]} -gt 0 ]; then
    RECENT_DRAFTS=$(printf '%s\n' "${DRAFT_FILES[@]}" | sort -r | head -7 | while IFS= read -r f; do cat "$f"; echo ""; done)
else
    RECENT_DRAFTS="(henüz brief yok)"
fi

# En son haftalık review (varsa) — arc devamlılığı için
WEEKREVIEW_FILES=("$FACTORY_DIR/drafts/"weekreview-*.md)
if [ ${#WEEKREVIEW_FILES[@]} -gt 0 ]; then
    LATEST_REVIEW=$(printf '%s\n' "${WEEKREVIEW_FILES[@]}" | sort -r | head -1)
    LAST_WEEKREVIEW=$(cat "$LATEST_REVIEW")
else
    LAST_WEEKREVIEW="(henüz weekly review yok — ilk hafta)"
fi

# claude CLI yolu (PATH'te yoksa absolute path kullan)
CLAUDE_BIN=$(command -v claude || echo "$HOME/.local/bin/claude")

# Prompt'u tek dosyaya topla (retry için tekrar tekrar okunacak)
PROMPT_INPUT=$(mktemp)
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
  echo "## En son haftalık review (geçen haftanın doygunluk uyarıları + gelecek hafta önerileri)"
  echo "$LAST_WEEKREVIEW"
  echo ""
  echo "# TASK"
  cat "$PROMPT_FILE"
} > "$PROMPT_INPUT"

# Brief üret — boş çıktıya karşı 3 deneme, mevcut iyi brief'i ASLA boşla ezme
TMP_OUT=$(mktemp)
ATTEMPTS=0
MAX_ATTEMPTS=3
while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
    ATTEMPTS=$((ATTEMPTS + 1))
    "$CLAUDE_BIN" -p --output-format text < "$PROMPT_INPUT" > "$TMP_OUT" 2>> "$LOG_FILE" || true
    [ -s "$TMP_OUT" ] && break
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Deneme $ATTEMPTS boş çıktı verdi, 10 sn sonra tekrar" >> "$LOG_FILE"
    sleep 10
done
rm -f "$PROMPT_INPUT"

# 3 denemede de boşsa: mevcut dosyaya dokunma, hata bildir, çık
if [ ! -s "$TMP_OUT" ]; then
    rm -f "$TMP_OUT"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] HATA: $MAX_ATTEMPTS denemede de boş çıktı. Brief üretilemedi (claude usage limit / auth?)" >> "$LOG_FILE"
    osascript -e "display notification \"BRIEF ÜRETİLEMEDİ — claude boş döndü. Manuel dene: ./scripts/morning_brief.sh\" with title \"X Factory · HATA\" sound name \"Basso\"" 2>/dev/null || true
    exit 1
fi

# Önsöz temizliği: claude bazen başa açıklama ekliyor — ilk '# ' (H1) satırından itibaren al
awk 'f{print} /^# /{if(!f){f=1; print}}' "$TMP_OUT" > "$DRAFT_FILE"
# H1 bulunamadıysa ham çıktıyı kullan (boş bırakma)
[ -s "$DRAFT_FILE" ] || cp "$TMP_OUT" "$DRAFT_FILE"
rm -f "$TMP_OUT"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Morning brief tamam: $DRAFT_FILE ($ATTEMPTS. denemede)" >> "$LOG_FILE"

# macOS bildirimi
# (drafts/, pinned/ klasörleri zaten iCloud'a symlink — ekstra sync gerekmez)
osascript -e "display notification \"Bugünün X brief'i hazır: $TODAY.md\" with title \"X Content Factory\" sound name \"Glass\"" 2>/dev/null || true
