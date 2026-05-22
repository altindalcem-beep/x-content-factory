#!/bin/zsh
# X Content Factory — Weekly Review Motor
#
# Pazar 21:00'de çalışır.
# İşi:
#   1. Niş bağlamı + son 7 günün brief'lerini okur
#   2. Bir önceki weekreview varsa onu da bağlama katar (arc devamlılığı)
#   3. Claude'a gönderir: bu hafta hangi tema/açı işlendi, doygunlaştı mı,
#      gelecek hafta hangi yeni açı, Pazar Storm için input
#   4. Çıktı: drafts/weekreview-YYYY-Wnn.md
#
# Manuel çağrı: ./scripts/weekly_review.sh
# Metrik input istemez — sıfır manuel girdi.

set -euo pipefail
setopt null_glob 2>/dev/null || true

FACTORY_DIR="$HOME/x-content-factory"
TODAY=$(date +%Y-%m-%d)
YEAR=$(date +%Y)
WEEK_NUM=$(date +%V)
LOG_FILE="$FACTORY_DIR/logs/weekly_review_$TODAY.log"
NIS_BAGLAM="$FACTORY_DIR/config/nis-baglam.md"
PROMPT_FILE="$FACTORY_DIR/prompts/weekly_review.md"
OUTPUT_FILE="$FACTORY_DIR/drafts/weekreview-$YEAR-W$WEEK_NUM.md"

CLAUDE_BIN=$(command -v claude || echo "$HOME/.local/bin/claude")

mkdir -p "$FACTORY_DIR/logs"

# ---------- Son 7 günün brief'leri ----------
# drafts/YYYY-MM-DD.md formatındaki günlük brief'leri al (replies-*.md ve weekreview-*.md hariç)
BRIEF_FILES=("$FACTORY_DIR/drafts/"[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].md)
if [ ${#BRIEF_FILES[@]} -gt 0 ]; then
    RECENT_BRIEFS=$(printf '%s\n' "${BRIEF_FILES[@]}" | sort -r | head -7 | while IFS= read -r f; do
        echo "===== $(basename "$f") ====="
        cat "$f"
        echo ""
    done)
else
    RECENT_BRIEFS="(henüz brief yok)"
fi

# ---------- Bir önceki weekreview (varsa) ----------
PREV_REVIEW_FILES=("$FACTORY_DIR/drafts/"weekreview-*.md)
PREV_REVIEW="(önceki weekreview yok — ilk hafta)"
if [ ${#PREV_REVIEW_FILES[@]} -gt 0 ]; then
    # Bu haftanın dosyası yazılmadan önce çağrıldığı için en yenisi = önceki
    PREV_FILE=$(printf '%s\n' "${PREV_REVIEW_FILES[@]}" | sort -r | head -1)
    if [ "$PREV_FILE" != "$OUTPUT_FILE" ]; then
        PREV_REVIEW=$(cat "$PREV_FILE")
    fi
fi

# ---------- Claude'a gönder ----------
{
    echo "# CONTEXT"
    echo ""
    echo "## Niş bağlamı"
    cat "$NIS_BAGLAM"
    echo ""
    echo "## Bir önceki haftanın review'i (varsa)"
    echo "$PREV_REVIEW"
    echo ""
    echo "## Son 7 günün brief'leri"
    echo "$RECENT_BRIEFS"
    echo ""
    echo "# TASK"
    cat "$PROMPT_FILE"
} | "$CLAUDE_BIN" -p > "$OUTPUT_FILE" 2>> "$LOG_FILE"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Weekly Review tamam: $OUTPUT_FILE" >> "$LOG_FILE"

# (drafts/ klasörü zaten iCloud'a symlink — ekstra sync gerekmez)
osascript -e "display notification \"Hafta $WEEK_NUM review hazır — yarına input ayarlandı\" with title \"X Factory · Weekly Review\" sound name \"Glass\"" 2>/dev/null || true
