#!/bin/zsh
# X Content Factory — Reply Radar Motor
#
# İki modlu:
#   Manuel:  ./reply_radar.sh "@hesap" "post metni..."
#            → Anlık 2 reply önerisi, hem stdout'a hem dosyaya yazar
#
#   Batch:   ./reply_radar.sh --batch
#            → config/reply-inbox.md dosyasındaki tüm postlara reply önerisi
#            → launchd 12:00 ve 17:00'de otomatik çağırır
#
# Çıktı: drafts/replies-YYYY-MM-DD-HHMM.md

set -euo pipefail
setopt null_glob 2>/dev/null || true

FACTORY_DIR="$HOME/x-content-factory"
TODAY=$(date +%Y-%m-%d)
HHMM=$(date +%H%M)
LOG_FILE="$FACTORY_DIR/logs/reply_radar_$TODAY.log"
NIS_BAGLAM="$FACTORY_DIR/config/nis-baglam.md"
BALINA_LIST="$FACTORY_DIR/config/balina-listesi.txt"
INBOX_FILE="$FACTORY_DIR/config/reply-inbox.md"
PROMPT_FILE="$FACTORY_DIR/prompts/reply_radar.md"
OUTPUT_FILE="$FACTORY_DIR/drafts/replies-$TODAY-$HHMM.md"

CLAUDE_BIN=$(command -v claude || echo "$HOME/.local/bin/claude")

# ---------- Argüman parsing ----------
MODE=""
HANDLE=""
POST_TEXT=""

if [ $# -eq 2 ]; then
    MODE="manual"
    HANDLE="$1"
    POST_TEXT="$2"
elif [ $# -eq 1 ] && [ "$1" = "--batch" ]; then
    MODE="batch"
else
    cat <<EOF
Kullanım:
  Manuel: $0 "@hesap" "post metni..."
  Toplu:  $0 --batch
EOF
    exit 1
fi

# ---------- Batch modda inbox boşsa sessiz çık ----------
if [ "$MODE" = "batch" ]; then
    # Inbox dosyası yoksa veya sadece şablon başlığı varsa atla
    if [ ! -f "$INBOX_FILE" ] || [ ! -s "$INBOX_FILE" ]; then
        echo "[$TODAY $HHMM] Inbox dosyası yok/boş, batch atlandı" >> "$LOG_FILE"
        exit 0
    fi
    # En az 1 GERÇEK "## @hesap" başlığı var mı? Template placeholder'ı (@hesap_adi) sayılmaz.
    # Count-based: ugrep'in `-qv` davranışı POSIX'ten saptığı için pipeline değil sayım kullanılıyor.
    TOTAL_HANDLES=$(grep -cE "^##[[:space:]]+@" "$INBOX_FILE" 2>/dev/null) || TOTAL_HANDLES=0
    PLACEHOLDER_HANDLES=$(grep -cE "^##[[:space:]]+@hesap_adi([^a-zA-Z0-9_]|$)" "$INBOX_FILE" 2>/dev/null) || PLACEHOLDER_HANDLES=0
    if [ "$((TOTAL_HANDLES - PLACEHOLDER_HANDLES))" -le 0 ]; then
        echo "[$TODAY $HHMM] Inbox'ta gerçek '## @hesap' yok (sadece placeholder), batch atlandı" >> "$LOG_FILE"
        exit 0
    fi
fi

# ---------- Prompt + Context oluştur ve Claude'a gönder ----------
{
    echo "# CONTEXT"
    echo ""
    echo "## Niş bağlamı"
    cat "$NIS_BAGLAM"
    echo ""
    echo "## Balina hesap listem (sadece bu listedeki hesaplara reply önerisi üret)"
    cat "$BALINA_LIST"
    echo ""
    echo "## İşlenecek balina postları"
    if [ "$MODE" = "manual" ]; then
        echo "## $HANDLE"
        echo ""
        echo "$POST_TEXT"
        echo ""
        echo "---"
    else
        cat "$INBOX_FILE"
    fi
    echo ""
    echo "# TASK"
    cat "$PROMPT_FILE"
} | "$CLAUDE_BIN" -p > "$OUTPUT_FILE" 2>> "$LOG_FILE"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Reply Radar tamam: $OUTPUT_FILE (mode: $MODE)" >> "$LOG_FILE"

# ---------- Manuel modda stdout'a da yazdır ----------
if [ "$MODE" = "manual" ]; then
    echo ""
    echo "=========================================="
    echo "  Reply Önerileri — @$(echo "$HANDLE" | tr -d '@')"
    echo "=========================================="
    cat "$OUTPUT_FILE"
    echo ""
    echo "→ Dosya: $OUTPUT_FILE"
fi

# ---------- macOS bildirim ----------
# (drafts/ klasörü zaten iCloud'a symlink — ekstra sync gerekmez)
osascript -e "display notification \"Reply önerileri hazır ($MODE)\" with title \"X Content Factory · Reply Radar\" sound name \"Glass\"" 2>/dev/null || true
