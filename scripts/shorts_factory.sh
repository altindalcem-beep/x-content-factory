#!/bin/zsh
# X Content Factory — YouTube Shorts Motoru
# Her sabah 06:30'da çalışır (morning_brief'ten önce, Cem tek seferde ikisini okur).
# Bugün çekilecek TEK Short'un tam prodüksiyon dosyasını üretir:
# hook + beat-beat script + on-screen metin + başlık + açıklama + CTA.
# Çıktı: drafts/shorts-YYYY-MM-DD.md
#
# Bağımsız test: ./scripts/shorts_factory.sh

set -euo pipefail
setopt null_glob 2>/dev/null || true   # zsh: boş glob = boş, hata atma

FACTORY_DIR="$HOME/x-content-factory"
TODAY=$(date +%Y-%m-%d)
WEEKDAY_EN=$(date +%A)
LOG_FILE="$FACTORY_DIR/logs/shorts_factory_$TODAY.log"
DRAFT_FILE="$FACTORY_DIR/drafts/shorts-$TODAY.md"
PROMPT_FILE="$FACTORY_DIR/prompts/shorts_brief.md"
NIS_BAGLAM="$FACTORY_DIR/config/nis-baglam.md"
SHORTS_BAGLAM="$FACTORY_DIR/config/shorts-baglam.md"

# Son 7 günün Shorts brief'lerini oku (tekrar etmemek için)
# Sadece shorts-YYYY-MM-DD.md dosyaları
SHORTS_FILES=("$FACTORY_DIR/drafts/"shorts-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].md)
if [ ${#SHORTS_FILES[@]} -gt 0 ]; then
    RECENT_SHORTS=$(printf '%s\n' "${SHORTS_FILES[@]}" | sort -r | head -7 | while IFS= read -r f; do cat "$f"; echo ""; done)
else
    RECENT_SHORTS="(henüz Shorts brief yok — ilk gün)"
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
  echo "## Niş bağlamı (ton + sayı dürüstlüğü + doğrulanmış veriler)"
  cat "$NIS_BAGLAM"
  echo ""
  echo "## Shorts bağlamı (para modeli + format + yapı)"
  cat "$SHORTS_BAGLAM"
  echo ""
  echo "## Son 7 günde ürettiğim Shorts brief'leri (tekrar etmemek için referans)"
  echo "$RECENT_SHORTS"
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
    osascript -e "display notification \"SHORTS BRIEF ÜRETİLEMEDİ — $LAST_ERR\" with title \"X Factory · HATA\" sound name \"Basso\"" 2>/dev/null || true
    exit 1
fi

# Önsöz temizliği: ilk '# ' (H1) satırından itibaren al
awk 'f{print} /^# /{if(!f){f=1; print}}' "$TMP_OUT" > "$DRAFT_FILE"
[ -s "$DRAFT_FILE" ] || cp "$TMP_OUT" "$DRAFT_FILE"
rm -f "$TMP_OUT"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Shorts brief tamam: $DRAFT_FILE ($ATTEMPTS. denemede)" >> "$LOG_FILE"

# macOS bildirimi (drafts/ zaten iCloud'a symlink)
osascript -e "display notification \"Bugünün Shorts brief'i hazır: shorts-$TODAY.md\" with title \"X Content Factory · Shorts\" sound name \"Glass\"" 2>/dev/null || true
