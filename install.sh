#!/bin/zsh
# X Content Factory — Installer
#
# Yeni cihaza (MacBook / başka Mac) deploy ederken çalıştır.
# Yapar:
#   1. Eksik klasörleri oluştur (drafts/, logs/, data/, swipe-file/, pinned/, swipe-file/inbox-archive/)
#   2. config/ içindeki eksik inbox şablonlarını oluştur
#   3. launchd plist template'lerini $HOME ile rendere edip ~/Library/LaunchAgents/'a kopyala
#   4. Script'lere executable izni ver
#
# NE YAPMAZ:
#   - launchctl load (bunu opsiyonel — istersen sonradan yap)
#   - claude CLI login (her cihazda manuel: `claude` → /login)
#   - iCloud sync (zaten otomatik)
#
# Kullanım:
#   cd ~/x-content-factory
#   ./install.sh
#
# Veya zorla yeniden kur:
#   ./install.sh --force-launchd

set -euo pipefail

FACTORY_DIR="$HOME/x-content-factory"
LAUNCHD_DIR="$HOME/Library/LaunchAgents"
FORCE_LAUNCHD=false

if [ "${1:-}" = "--force-launchd" ]; then
    FORCE_LAUNCHD=true
fi

echo "→ Factory dizini: $FACTORY_DIR"
echo "→ Launchd hedefi: $LAUNCHD_DIR"
echo ""

# ---------- 1. Klasör yapısı ----------
echo "1) Klasörleri oluşturuyorum..."
mkdir -p "$FACTORY_DIR"/{drafts,logs,data,swipe-file/inbox-archive,pinned}
echo "   OK"

# ---------- 2. Inbox şablonları ----------
echo "2) Eksik inbox şablonlarını yaratıyorum..."
if [ ! -f "$FACTORY_DIR/config/reply-inbox.md" ]; then
    cat > "$FACTORY_DIR/config/reply-inbox.md" <<'EOF'
# Reply Inbox

Balina hesaplardan reply atmak istediğin postları buraya kopyala.

Format:

## @hesap_adi
Tweet linki: https://x.com/...

Post metni buraya tam yapıştır.

---
EOF
    echo "   reply-inbox.md oluşturuldu"
fi

if [ ! -f "$FACTORY_DIR/config/swipe-inbox.md" ]; then
    cat > "$FACTORY_DIR/config/swipe-inbox.md" <<'EOF'
# Swipe Inbox

Bu hafta gördüğün niş içi iyi/viral postları buraya kopyala.

Format:

## @hesap_adi
Post linki: https://x.com/...

Post metni...

---
EOF
    echo "   swipe-inbox.md oluşturuldu"
fi

if [ ! -f "$FACTORY_DIR/config/daily-metrics.md" ]; then
    cat > "$FACTORY_DIR/config/daily-metrics.md" <<'EOF'
# Günlük X Post Metrikleri

Her akşam ~21:00'de X Analytics'ten bugünkü postların verilerini buraya yaz.

## YYYY-MM-DD
### Post 1 — 09:00 (Format)
- Tweet:
- Impression:
- Like:
- Repost:
- Bookmark:
- Reply:

---
EOF
    echo "   daily-metrics.md oluşturuldu"
fi

# ---------- 3. Script'lere executable izin ----------
echo "3) Script'lere executable izin..."
chmod +x "$FACTORY_DIR"/scripts/*.sh
echo "   OK"

# ---------- 4. launchd plist'lerini render et + kopyala ----------
echo "4) launchd plist'leri kuruluyor..."
mkdir -p "$LAUNCHD_DIR"
for template in "$FACTORY_DIR"/launchd-templates/*.plist.template; do
    plist_name=$(basename "$template" .template)
    target="$LAUNCHD_DIR/$plist_name"

    if [ -f "$target" ] && [ "$FORCE_LAUNCHD" = false ]; then
        echo "   $plist_name ZATEN var, atlandı (--force-launchd ile zorla yenile)"
        continue
    fi

    # __HOME__ placeholder'ı gerçek $HOME ile değiştir
    sed "s|__HOME__|$HOME|g" "$template" > "$target"
    plutil -lint "$target" >/dev/null && echo "   $plist_name kuruldu"
done

echo ""
echo "✅ Install tamam."
echo ""
echo "Sıradaki manuel adımlar:"
echo "  1. claude CLI'da login (her cihazda ayrı): "
echo "     $HOME/.local/bin/claude   →   /login"
echo ""
echo "  2. iMac PRIMARY ise launchd'i yükle:"
echo "     launchctl load $LAUNCHD_DIR/com.cemal.x.morning.plist"
echo "     launchctl load $LAUNCHD_DIR/com.cemal.x.reply.plist"
echo "     launchctl load $LAUNCHD_DIR/com.cemal.x.evening.plist"
echo "     launchctl load $LAUNCHD_DIR/com.cemal.x.weekly.plist"
echo ""
echo "  3. MacBook SECONDARY ise launchd YÜKLEME — sadece manuel komut çalıştır."
echo "     iMac iCloud'a yazıyor, MacBook iCloud'dan okuyor."
echo ""
echo "Test komutu:"
echo "  $FACTORY_DIR/scripts/morning_brief.sh"
