#!/bin/zsh
# X Content Factory — Video Motor (Hyperframes)
# Bir hook/brief'i markalı dikey X video kartına (1080x1350, ~11s MP4) çevirir.
#
# İki mod:
#   Manuel:  ./scripts/video_factory.sh "hook metni buraya"
#   Brief'ten: ./scripts/video_factory.sh          (argümansız → bugünün brief'inden ilk hook)
#
# Çıktı:
#   drafts/video-YYYY-MM-DD-HHMM.mp4   (iCloud symlink → telefonda Obsidian'da görünür)
#   drafts/video-YYYY-MM-DD-HHMM.md    (X caption + kullanılan alanlar + kaynak)
#
# Gereksinim (Mac'te): Node 22+, ffmpeg. Bkz. install.sh kontrolü.
# GSAP lokal vendor'lı, fontları Hyperframes çekiyor → render offline/deterministik.

set -euo pipefail
setopt null_glob 2>/dev/null || true

FACTORY_DIR="$HOME/x-content-factory"
VIDEO_DIR="$FACTORY_DIR/video"
TEMPLATE_DIR="$VIDEO_DIR/templates"
COMPOSITION="$VIDEO_DIR/index.html"
INJECTOR="$VIDEO_DIR/inject.mjs"
PROMPT_FILE="$FACTORY_DIR/prompts/video_factory.md"
NIS_BAGLAM="$FACTORY_DIR/config/nis-baglam.md"

HANDLE="@cemaltindal"                     # video kartındaki sabit hesap etiketi
HF_VERSION="0.8.30"                        # package.json ile aynı tutulmalı

TODAY=$(date +%Y-%m-%d)
STAMP=$(date +%Y-%m-%d-%H%M)
LOG_FILE="$FACTORY_DIR/logs/video_factory_$TODAY.log"
OUT_MP4="$FACTORY_DIR/drafts/video-$STAMP.mp4"
OUT_MD="$FACTORY_DIR/drafts/video-$STAMP.md"

mkdir -p "$FACTORY_DIR/logs"

log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"; }
notify() { osascript -e "display notification \"$1\" with title \"X Factory · Video\" sound name \"$2\"" 2>/dev/null || true; }

# ---------- 0. Ön kontrol ----------
command -v node >/dev/null || { log "HATA: node yok"; notify "node bulunamadı" "Basso"; exit 1; }
command -v ffmpeg >/dev/null || { log "HATA: ffmpeg yok — brew install ffmpeg"; notify "ffmpeg yok — brew install ffmpeg" "Basso"; exit 1; }

# Template varyantları — AĞIRLIKLI rastgele seç (HF_TEMPLATE=quote ile sabitlenebilir, test için)
# Ağırlıklar: templates/weights.conf (name=weight). Listede olmayan template DEFAULT_WEIGHT alır.
TEMPLATES=("$TEMPLATE_DIR"/*.tmpl)
[ ${#TEMPLATES[@]} -gt 0 ] || { log "HATA: templates/ boş: $TEMPLATE_DIR"; notify "Template yok" "Basso"; exit 1; }
WEIGHTS_FILE="$TEMPLATE_DIR/weights.conf"
DEFAULT_WEIGHT=25

tmpl_weight() {   # bir template adının ağırlığını yaz (config'te yoksa DEFAULT_WEIGHT)
    local name="$1" w=""
    [ -f "$WEIGHTS_FILE" ] && w=$(grep -m1 -E "^${name}=" "$WEIGHTS_FILE" 2>/dev/null | sed -E "s/^${name}=//" | tr -dc '0-9')
    [ -n "$w" ] && echo "$w" || echo "$DEFAULT_WEIGHT"
}

if [ "${HF_TEMPLATE:-}" != "" ] && [ -f "$TEMPLATE_DIR/${HF_TEMPLATE}.tmpl" ]; then
    TEMPLATE="$TEMPLATE_DIR/${HF_TEMPLATE}.tmpl"
else
    TOTAL=0
    for t in "${TEMPLATES[@]}"; do
        TOTAL=$((TOTAL + $(tmpl_weight "$(basename "$t" .tmpl)")))
    done
    [ "$TOTAL" -gt 0 ] || TOTAL=1
    R=$((RANDOM % TOTAL))
    ACC=0
    TEMPLATE="${TEMPLATES[1]}"   # fallback (zsh 1-indexli)
    for t in "${TEMPLATES[@]}"; do
        ACC=$((ACC + $(tmpl_weight "$(basename "$t" .tmpl)")))
        if [ "$R" -lt "$ACC" ]; then TEMPLATE="$t"; break; fi
    done
fi
TEMPLATE_NAME=$(basename "$TEMPLATE" .tmpl)
log "Template seçildi: $TEMPLATE_NAME"

# ---------- 1. Kaynak hook'u belirle ----------
if [ "${1:-}" != "" ]; then
    SOURCE_HOOK="$1"
else
    BRIEF_FILE="$FACTORY_DIR/drafts/$TODAY.md"
    if [ -f "$BRIEF_FILE" ]; then
        SOURCE_HOOK=$(cat "$BRIEF_FILE")
    else
        log "Argüman yok ve bugünün brief'i yok ($BRIEF_FILE) — çıkılıyor."
        notify "Video için hook yok (brief bulunamadı)" "Basso"
        exit 0
    fi
fi

# ---------- 2. Claude'a prompt ----------
CLAUDE_BIN=$(command -v claude || echo "$HOME/.local/bin/claude")

PROMPT_INPUT=$(mktemp)
{
  echo "# NIS BAGLAMI"
  [ -f "$NIS_BAGLAM" ] && cat "$NIS_BAGLAM"
  echo ""
  echo "# KAYNAK HOOK / BRIEF"
  echo "$SOURCE_HOOK"
  echo ""
  echo "# GOREV"
  cat "$PROMPT_FILE"
} > "$PROMPT_INPUT"

# Parse edilen alanların hepsi dolu mu?
fields_ok() {
    local f="$1"
    for key in HOOK BEAT1 BEAT2 BEAT3 CTA CAPTION; do
        grep -qE "^${key}:[[:space:]]*[^[:space:]]" "$f" || return 1
    done
    grep -qE "^(API Error|Error:|Invalid API key)" "$f" && return 1
    return 0
}

TMP_OUT=$(mktemp)
ATTEMPTS=0
MAX_ATTEMPTS=3
while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
    ATTEMPTS=$((ATTEMPTS + 1))
    "$CLAUDE_BIN" -p --output-format text < "$PROMPT_INPUT" > "$TMP_OUT" 2>> "$LOG_FILE" || true
    if fields_ok "$TMP_OUT"; then break; fi
    log "Deneme $ATTEMPTS: geçersiz kopya çıktısı, 15 sn sonra tekrar"
    sleep 15
done
rm -f "$PROMPT_INPUT"

if ! fields_ok "$TMP_OUT"; then
    LAST=$(head -1 "$TMP_OUT" 2>/dev/null | cut -c1-100)
    rm -f "$TMP_OUT"
    log "HATA: $MAX_ATTEMPTS denemede geçerli kopya üretilemedi. Son: $LAST"
    notify "Kopya üretilemedi — $LAST" "Basso"
    exit 1
fi

# ---------- 3. Alanları çıkar ----------
# "KEY: değer" satırlarından değeri al (ilk ':' sonrası, baştaki boşluk kırpılır)
extract() { grep -m1 -E "^$1:" "$TMP_OUT" | sed -E "s/^$1:[[:space:]]*//"; }
HF_HOOK=$(extract HOOK)
HF_BEAT1=$(extract BEAT1)
HF_BEAT2=$(extract BEAT2)
HF_BEAT3=$(extract BEAT3)
HF_CTA=$(extract CTA)
CAPTION=$(extract CAPTION)
rm -f "$TMP_OUT"

# ---------- 4. Template'e enjekte et ----------
export HF_HOOK HF_BEAT1 HF_BEAT2 HF_BEAT3 HF_CTA
export HF_HANDLE="$HANDLE"
if ! node "$INJECTOR" "$TEMPLATE" "$COMPOSITION" 2>> "$LOG_FILE"; then
    log "HATA: enjeksiyon başarısız"
    notify "Kompozisyon üretilemedi" "Basso"
    exit 1
fi

# ---------- 5. Lint kapısı ----------
if ! ( cd "$VIDEO_DIR" && npx --yes "hyperframes@$HF_VERSION" lint >> "$LOG_FILE" 2>&1 ); then
    log "HATA: lint başarısız — kompozisyon geçersiz"
    notify "Video kompozisyonu lint'ten geçmedi" "Basso"
    exit 1
fi

# ---------- 6. Render ----------
log "Render başlıyor..."
if ! ( cd "$VIDEO_DIR" && npx --yes "hyperframes@$HF_VERSION" render >> "$LOG_FILE" 2>&1 ); then
    log "HATA: render başarısız"
    notify "Render başarısız (log'a bak)" "Basso"
    exit 1
fi

# En yeni mp4'ü bul
RENDER_FILES=("$VIDEO_DIR/renders/"*.mp4)
if [ ${#RENDER_FILES[@]} -eq 0 ]; then
    log "HATA: render sonrası mp4 bulunamadı"
    notify "MP4 çıkmadı" "Basso"
    exit 1
fi
LATEST_MP4=$(printf '%s\n' "${RENDER_FILES[@]}" | sort | tail -1)
cp "$LATEST_MP4" "$OUT_MP4"

# ---------- 7. Caption sidecar ----------
{
  echo "# X Video — $STAMP"
  echo ""
  echo "**Video:** video-$STAMP.mp4"
  echo ""
  echo "## X caption (postla)"
  echo ""
  echo "$CAPTION"
  echo ""
  echo "---"
  echo ""
  echo "## Kartta kullanılan"
  echo "- Template: $TEMPLATE_NAME"
  echo "- HOOK: $HF_HOOK"
  echo "- BEAT1: $HF_BEAT1"
  echo "- BEAT2: $HF_BEAT2"
  echo "- BEAT3: $HF_BEAT3"
  echo "- CTA: $HF_CTA"
  echo "- HANDLE: $HANDLE"
} > "$OUT_MD"

log "Video tamam: $OUT_MP4"
notify "Video hazır: video-$STAMP.mp4" "Glass"

# stdout (manuel modda görünür)
echo "✓ $OUT_MP4"
echo "✓ $OUT_MD"
