#!/bin/zsh
# X Content Factory — Weekly Swipe Motor
#
# Pazar 23:00'te çalışır.
# İşi:
#   1. config/swipe-inbox.md dosyasındaki hafta boyu toplanmış postları al
#   2. Claude'a gönder: pattern çıkar, açılış kalıpları, format dağılımı, Cem için 5 şablon
#   3. Output: swipe-file/hafta-YYYY-Wnn.md (analizli swipe kütüphanesi)
#   4. Eski inbox'ı swipe-file/inbox-archive/'a taşır, yeni boş şablon yazar
#
# Manuel çalıştırma: ./weekly_swipe.sh

set -euo pipefail
setopt null_glob 2>/dev/null || true

FACTORY_DIR="$HOME/x-content-factory"
TODAY=$(date +%Y-%m-%d)
YEAR=$(date +%Y)
WEEK_NUM=$(date +%V)   # ISO week number
LOG_FILE="$FACTORY_DIR/logs/weekly_swipe_$TODAY.log"
NIS_BAGLAM="$FACTORY_DIR/config/nis-baglam.md"
SWIPE_INBOX="$FACTORY_DIR/config/swipe-inbox.md"
PROMPT_FILE="$FACTORY_DIR/prompts/weekly_swipe.md"
OUTPUT_DIR="$FACTORY_DIR/swipe-file"
OUTPUT_FILE="$OUTPUT_DIR/hafta-$YEAR-W$WEEK_NUM.md"
ARCHIVE_DIR="$OUTPUT_DIR/inbox-archive"

CLAUDE_BIN=$(command -v claude || echo "$HOME/.local/bin/claude")

mkdir -p "$OUTPUT_DIR" "$ARCHIVE_DIR"

# ---------- Inbox kontrolü ----------
if [ ! -f "$SWIPE_INBOX" ] || [ ! -s "$SWIPE_INBOX" ]; then
    echo "[$TODAY] Swipe inbox yok/boş, atlandı" >> "$LOG_FILE"
    osascript -e "display notification \"Bu hafta swipe inbox boş kaldı\" with title \"X Factory · Weekly Swipe (atlandı)\"" 2>/dev/null || true
    exit 0
fi

# En az 1 "## ..." başlığı (post girdisi) var mı?
if ! grep -qE "^##\s+@" "$SWIPE_INBOX"; then
    echo "[$TODAY] Swipe inbox'ta '## @hesap' başlığı yok, atlandı" >> "$LOG_FILE"
    osascript -e "display notification \"Inbox'ta swipe yok (## @hesap formatında ekle)\" with title \"X Factory · Weekly Swipe (atlandı)\"" 2>/dev/null || true
    exit 0
fi

# ---------- Claude'a gönder ----------
{
    echo "# CONTEXT"
    echo ""
    echo "## Niş bağlamı"
    cat "$NIS_BAGLAM"
    echo ""
    echo "## Bu hafta toplanan swipe'lar (Hafta $WEEK_NUM)"
    cat "$SWIPE_INBOX"
    echo ""
    echo "# TASK"
    cat "$PROMPT_FILE"
} | "$CLAUDE_BIN" -p > "$OUTPUT_FILE" 2>> "$LOG_FILE"

# ---------- Inbox'ı arşivle ----------
ARCHIVE_FILE="$ARCHIVE_DIR/inbox-$TODAY.md"
mv "$SWIPE_INBOX" "$ARCHIVE_FILE"

# Yeni boş inbox şablonu
cat > "$SWIPE_INBOX" <<'EOF'
# Swipe Inbox

Bu hafta gördüğün niş içi iyi/viral postları buraya kopyala.
Pazar 23:00'te Weekly Swipe bunları analiz edip `swipe-file/hafta-YYYY-Wnn.md` dosyasına organize edecek.

İşlem sonrası inbox temizlenir, eski hali `swipe-file/inbox-archive/` klasörüne taşınır.

---

## Format

```
## @hesap_adi (format ipucu — micro/punch/spark/thread/storm)
Post linki: https://x.com/...

Post metni buraya tam yapıştır.
Birden fazla satır olabilir.

---
```

---

## (yeni post için yeni başlık aç ↓)
EOF

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Weekly Swipe tamam: $OUTPUT_FILE (inbox arşiv: $ARCHIVE_FILE)" >> "$LOG_FILE"

# (swipe-file/ klasörü zaten iCloud'a symlink — ekstra sync gerekmez)
osascript -e "display notification \"Hafta $WEEK_NUM swipe analizi hazır\" with title \"X Factory · Weekly Swipe\" sound name \"Glass\"" 2>/dev/null || true
