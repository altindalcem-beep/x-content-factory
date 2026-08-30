#!/bin/zsh
# X Content Factory — VERA Brief Motor
# Açık kaynak AI karakteri "VERA" için GÜNLÜK çok-platform içerik brief'i üretir.
# (X + Instagram + TikTok uyarlaması + görsel brief). Morning brief'ten AYRI çalışır.
# Çıktı: drafts/vera/YYYY-MM-DD.md
#
# Bağımsız test: ./scripts/vera_brief.sh

set -euo pipefail
setopt null_glob 2>/dev/null || true   # zsh: boş glob = boş, hata atma

FACTORY_DIR="$HOME/x-content-factory"
TODAY=$(date +%Y-%m-%d)
WEEKDAY_EN=$(date +%A)
LOG_FILE="$FACTORY_DIR/logs/vera_brief_$TODAY.log"
VERA_DRAFT_DIR="$FACTORY_DIR/drafts/vera"
DRAFT_FILE="$VERA_DRAFT_DIR/$TODAY.md"
PROMPT_FILE="$FACTORY_DIR/prompts/vera_brief.md"

BRAND_DIR="$FACTORY_DIR/virtual-character/brand"
CALENDAR_REF="$FACTORY_DIR/virtual-character/content/hafta-01-takvim.md"
STYLE_LOCK="$FACTORY_DIR/virtual-character/assets/style-lock.md"

mkdir -p "$VERA_DRAFT_DIR" "$FACTORY_DIR/logs"

# Son 7 günün VERA brief'lerini oku (tekrar etmemek + sütun dengesi için)
# Sadece günlük brief dosyaları: YYYY-MM-DD.md (weekreview-*.md hariç)
DRAFT_FILES=("$VERA_DRAFT_DIR/"[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].md)
if [ ${#DRAFT_FILES[@]} -gt 0 ]; then
    RECENT_DRAFTS=$(printf '%s\n' "${DRAFT_FILES[@]}" | sort -r | head -7 | while IFS= read -r f; do cat "$f"; echo ""; done)
else
    RECENT_DRAFTS="(henüz VERA brief yok — ilk gün. hafta-01 takvimini başlangıç noktası kabul et.)"
fi

# En son haftalık review (varsa) — arc devamlılığı için
WEEKREVIEW_FILES=("$VERA_DRAFT_DIR/"weekreview-*.md)
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
  echo "## VERA marka beyni — persona (kim)"
  cat "$BRAND_DIR/persona.md"
  echo ""
  echo "## VERA — ses / üslup"
  cat "$BRAND_DIR/voice.md"
  echo ""
  echo "## VERA — içerik sütunları"
  cat "$BRAND_DIR/content-pillars.md"
  echo ""
  echo "## VERA — İFŞA KURALLARI (İHLAL EDİLEMEZ — her çıktı buna uyar)"
  cat "$BRAND_DIR/disclosure.md"
  echo ""
  echo "## VERA — görsel kimlik (görsel brief'i için)"
  cat "$BRAND_DIR/visual-identity.md"
  echo ""
  if [ -f "$STYLE_LOCK" ]; then
    echo "## Avatar stil kilidi (kanonik yüz referansı — görsel brief'te an)"
    cat "$STYLE_LOCK"
    echo ""
  fi
  echo "## Format + üslup referansı — 1. hafta takvimi"
  if [ -f "$CALENDAR_REF" ]; then cat "$CALENDAR_REF"; else echo "(takvim bulunamadı)"; fi
  echo ""
  echo "## Son 7 gün VERA brief'leri (tekrarı önle + sütun dengesini gözet)"
  echo "$RECENT_DRAFTS"
  echo ""
  echo "## En son haftalık review (doygunluk uyarıları + gelecek hafta önerileri)"
  echo "$LAST_WEEKREVIEW"
  echo ""
  echo "# TASK"
  cat "$PROMPT_FILE"
} > "$PROMPT_INPUT"

# Brief üret — boş VE hata-çıktısına karşı 3 deneme, mevcut iyi brief'i ASLA ezme
is_valid_output() {
    local f="$1"
    [ -s "$f" ] || return 1
    grep -q "^# " "$f" || return 1
    grep -qE "^(API Error|Error:|Invalid API key)" "$f" && return 1
    return 0
}

TMP_OUT=$(mktemp)
ATTEMPTS=0
MAX_ATTEMPTS=3
while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
    ATTEMPTS=$((ATTEMPTS + 1))
    "$CLAUDE_BIN" -p --output-format text < "$PROMPT_INPUT" > "$TMP_OUT" 2>> "$LOG_FILE" || true
    if is_valid_output "$TMP_OUT"; then break; fi
    REASON="boş"; [ -s "$TMP_OUT" ] && REASON="geçersiz ($(head -1 "$TMP_OUT" | cut -c1-80))"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Deneme $ATTEMPTS $REASON, 15 sn sonra tekrar" >> "$LOG_FILE"
    sleep 15
done
rm -f "$PROMPT_INPUT"

# 3 denemede de geçersizse: mevcut dosyaya dokunma, hata bildir, çık
if ! is_valid_output "$TMP_OUT"; then
    LAST_ERR=$(head -1 "$TMP_OUT" 2>/dev/null | cut -c1-100)
    rm -f "$TMP_OUT"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] HATA: $MAX_ATTEMPTS denemede de geçersiz çıktı. Son: $LAST_ERR" >> "$LOG_FILE"
    osascript -e "display notification \"VERA BRIEF ÜRETİLEMEDİ — $LAST_ERR\" with title \"VERA · HATA\" sound name \"Basso\"" 2>/dev/null || true
    exit 1
fi

# Önsöz temizliği: ilk '# ' (H1) satırından itibaren al
awk 'f{print} /^# /{if(!f){f=1; print}}' "$TMP_OUT" > "$DRAFT_FILE"
[ -s "$DRAFT_FILE" ] || cp "$TMP_OUT" "$DRAFT_FILE"
rm -f "$TMP_OUT"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] VERA brief tamam: $DRAFT_FILE ($ATTEMPTS. denemede)" >> "$LOG_FILE"

# macOS bildirimi
osascript -e "display notification \"Bugünün VERA brief'i hazır: vera/$TODAY.md\" with title \"VERA Content Factory\" sound name \"Glass\"" 2>/dev/null || true
