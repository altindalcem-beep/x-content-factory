#!/bin/zsh
# X Content Factory — Evening Report Motor
#
# Her gün 21:30'da çalışır.
# İşi:
#   1. config/daily-metrics.md dosyasından BUGÜNÜN metrik bölümünü okur
#   2. drafts/YYYY-MM-DD.md (sabahki brief) okur
#   3. Claude'a gönderir: hangi post tuttu, niye, yarın için ne öner
#   4. Output: drafts/eveningreport-YYYY-MM-DD.md
#   5. data/weekly-rollup.md dosyasına özet append eder
#
# Bugünün metrik bölümü yoksa: bildirim + atla (Cemal manuel tekrar çağırabilir)

set -euo pipefail
setopt null_glob 2>/dev/null || true

FACTORY_DIR="$HOME/x-content-factory"
TODAY=$(date +%Y-%m-%d)
WEEKDAY=$(date +%A)
LOG_FILE="$FACTORY_DIR/logs/evening_report_$TODAY.log"
NIS_BAGLAM="$FACTORY_DIR/config/nis-baglam.md"
METRICS_FILE="$FACTORY_DIR/config/daily-metrics.md"
TODAYS_DRAFT="$FACTORY_DIR/drafts/$TODAY.md"
WEEKLY_ROLLUP="$FACTORY_DIR/data/weekly-rollup.md"
PROMPT_FILE="$FACTORY_DIR/prompts/evening_report.md"
OUTPUT_FILE="$FACTORY_DIR/drafts/eveningreport-$TODAY.md"

CLAUDE_BIN=$(command -v claude || echo "$HOME/.local/bin/claude")

mkdir -p "$FACTORY_DIR/data"

# ---------- Bugünün metrik bölümü var mı kontrol et ----------
if [ ! -f "$METRICS_FILE" ]; then
    echo "[$TODAY] Metrik dosyası yok, evening report atlandı" >> "$LOG_FILE"
    osascript -e "display notification \"Metrik dosyasını oluştur ve bugünün verilerini gir\" with title \"X Factory · Evening Report (atlandı)\"" 2>/dev/null || true
    exit 0
fi

if ! grep -q "^## $TODAY" "$METRICS_FILE"; then
    echo "[$TODAY] $TODAY için metrik bölümü bulunamadı" >> "$LOG_FILE"
    osascript -e "display notification \"Bugünün metrik bölümünü daily-metrics.md'ye ekle, sonra manuel çağır\" with title \"X Factory · Evening Report (atlandı)\"" 2>/dev/null || true
    exit 0
fi

# Bugünün bölümünü çıkar (## $TODAY başlığından sonraki "## YYYY-..." başlığına kadar)
TODAYS_METRICS=$(awk -v today="^## $TODAY" '
    $0 ~ today { found=1; print; next }
    found && /^## [0-9]{4}-[0-9]{2}-[0-9]{2}/ { found=0 }
    found { print }
' "$METRICS_FILE")

# ---------- Bugünün brief'i ----------
TODAYS_BRIEF="(bugünün brief'i bulunamadı)"
if [ -f "$TODAYS_DRAFT" ]; then
    TODAYS_BRIEF=$(cat "$TODAYS_DRAFT")
fi

# ---------- Claude'a gönder ----------
{
    echo "# CONTEXT"
    echo ""
    echo "## Niş bağlamı"
    cat "$NIS_BAGLAM"
    echo ""
    echo "## Bugün için üretilmiş sabah brief'i (planlanmış postlar)"
    echo "$TODAYS_BRIEF"
    echo ""
    echo "## Bugünün post metrikleri (Cemal elle girdi)"
    echo "$TODAYS_METRICS"
    echo ""
    echo "# TASK"
    cat "$PROMPT_FILE"
} | "$CLAUDE_BIN" -p > "$OUTPUT_FILE" 2>> "$LOG_FILE"

# ---------- Weekly rollup'a append et ----------
{
    echo ""
    echo "==============================="
    echo "## $TODAY ($WEEKDAY)"
    echo "==============================="
    echo ""
    echo "### Ham metrikler"
    echo "$TODAYS_METRICS"
    echo ""
    echo "### Akşam değerlendirmesi"
    cat "$OUTPUT_FILE"
    echo ""
} >> "$WEEKLY_ROLLUP"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Evening Report tamam: $OUTPUT_FILE" >> "$LOG_FILE"

# (drafts/ klasörü zaten iCloud'a symlink — ekstra sync gerekmez)
osascript -e "display notification \"Bugünün raporu hazır + yarına input ayarlandı\" with title \"X Factory · Evening Report\" sound name \"Glass\"" 2>/dev/null || true
