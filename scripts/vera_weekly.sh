#!/bin/zsh
# X Content Factory — VERA Weekly Review Motor
#
# Pazar 21:30'da çalışır (morning/vera/weekly çakışmasın diye offset).
# İşi:
#   1. VERA marka beyni + son 7 günün VERA brief'lerini okur
#   2. Önceki VERA weekreview varsa bağlama katar (arc devamlılığı)
#   3. Claude'a gönderir: bu hafta hangi SÜTUN'lar işlendi, denge nasıl, doygunluk var mı,
#      ifşa her post'ta korundu mu, gelecek hafta somut açılar
#   4. Çıktı: drafts/vera/weekreview-YYYY-Wnn.md  (vera_brief.sh bunu okuyup dengeler)
#
# Manuel çağrı: ./scripts/vera_weekly.sh
# Metrik input istemez — sıfır manuel girdi, qualitative arc.

set -euo pipefail
setopt null_glob 2>/dev/null || true

FACTORY_DIR="$HOME/x-content-factory"
TODAY=$(date +%Y-%m-%d)
YEAR=$(date +%Y)
WEEK_NUM=$(date +%V)
LOG_FILE="$FACTORY_DIR/logs/vera_weekly_$TODAY.log"
VERA_DRAFT_DIR="$FACTORY_DIR/drafts/vera"
PROMPT_FILE="$FACTORY_DIR/prompts/vera_weekly.md"
OUTPUT_FILE="$VERA_DRAFT_DIR/weekreview-$YEAR-W$WEEK_NUM.md"

BRAND_DIR="$FACTORY_DIR/virtual-character/brand"

# Uzun ömürlü auth: .env varsa yükle (CLAUDE_CODE_OAUTH_TOKEN)
# launchd arka planda çalışırken OAuth oturumu süresi dolmasın diye. Üret: claude setup-token
if [ -f "$FACTORY_DIR/.env" ]; then set -a; . "$FACTORY_DIR/.env"; set +a; fi

CLAUDE_BIN=$(command -v claude || echo "$HOME/.local/bin/claude")

mkdir -p "$VERA_DRAFT_DIR" "$FACTORY_DIR/logs"

# ---------- Son 7 günün VERA brief'leri ----------
# drafts/vera/YYYY-MM-DD.md formatındaki günlük brief'ler (weekreview-*.md hariç)
BRIEF_FILES=("$VERA_DRAFT_DIR/"[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].md)
if [ ${#BRIEF_FILES[@]} -gt 0 ]; then
    RECENT_BRIEFS=$(printf '%s\n' "${BRIEF_FILES[@]}" | sort -r | head -7 | while IFS= read -r f; do
        echo "===== $(basename "$f") ====="
        cat "$f"
        echo ""
    done)
else
    RECENT_BRIEFS="(henüz VERA brief yok)"
fi

# ---------- Bir önceki VERA weekreview (varsa) ----------
PREV_REVIEW_FILES=("$VERA_DRAFT_DIR/"weekreview-*.md)
PREV_REVIEW="(önceki VERA weekreview yok — ilk hafta)"
if [ ${#PREV_REVIEW_FILES[@]} -gt 0 ]; then
    PREV_FILE=$(printf '%s\n' "${PREV_REVIEW_FILES[@]}" | sort -r | head -1)
    if [ "$PREV_FILE" != "$OUTPUT_FILE" ]; then
        PREV_REVIEW=$(cat "$PREV_FILE")
    fi
fi

# ---------- Prompt'u tek dosyaya topla ----------
PROMPT_INPUT=$(mktemp)
{
    echo "# CONTEXT"
    echo ""
    echo "## VERA — içerik sütunları (arc analizinin ekseni)"
    cat "$BRAND_DIR/content-pillars.md"
    echo ""
    echo "## VERA — ses / üslup (doygunluk/ton kayması ölçütü)"
    cat "$BRAND_DIR/voice.md"
    echo ""
    echo "## VERA — İFŞA KURALLARI (her post uyum kontrolü için)"
    cat "$BRAND_DIR/disclosure.md"
    echo ""
    echo "## Bir önceki haftanın VERA review'i (varsa)"
    echo "$PREV_REVIEW"
    echo ""
    echo "## Son 7 günün VERA brief'leri"
    echo "$RECENT_BRIEFS"
    echo ""
    echo "# TASK"
    cat "$PROMPT_FILE"
} > "$PROMPT_INPUT"

# ---------- Claude'a gönder — boş VE hata-çıktısına karşı 3 deneme ----------
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
    "$CLAUDE_BIN" -p < "$PROMPT_INPUT" > "$TMP_OUT" 2>> "$LOG_FILE" || true
    if is_valid_output "$TMP_OUT"; then break; fi
    REASON="boş"; [ -s "$TMP_OUT" ] && REASON="geçersiz ($(head -1 "$TMP_OUT" | cut -c1-80))"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Deneme $ATTEMPTS $REASON, 15 sn sonra tekrar" >> "$LOG_FILE"
    sleep 15
done
rm -f "$PROMPT_INPUT"

if ! is_valid_output "$TMP_OUT"; then
    LAST_ERR=$(head -1 "$TMP_OUT" 2>/dev/null | cut -c1-100)
    rm -f "$TMP_OUT"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] HATA: $MAX_ATTEMPTS denemede de geçersiz çıktı. Son: $LAST_ERR" >> "$LOG_FILE"
    osascript -e "display notification \"VERA WEEKLY REVIEW ÜRETİLEMEDİ — $LAST_ERR\" with title \"VERA · HATA\" sound name \"Basso\"" 2>/dev/null || true
    exit 1
fi

# Önsöz temizliği: ilk '# ' (H1) satırından itibaren al
awk 'f{print} /^# /{if(!f){f=1; print}}' "$TMP_OUT" > "$OUTPUT_FILE"
[ -s "$OUTPUT_FILE" ] || cp "$TMP_OUT" "$OUTPUT_FILE"
rm -f "$TMP_OUT"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] VERA Weekly Review tamam: $OUTPUT_FILE ($ATTEMPTS. denemede)" >> "$LOG_FILE"

osascript -e "display notification \"VERA Hafta $WEEK_NUM review hazır — gelecek hafta açıları ayarlandı\" with title \"VERA · Weekly Review\" sound name \"Glass\"" 2>/dev/null || true
