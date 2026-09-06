# X Content Factory

Tek kişilik X büyüme stüdyosu. Claude Code + launchd ile 3 motorlu içerik fabrikası.
AI üretir, manuel post atılır. Cem sadece X üzerinde çalışır — hiçbir config dosyası doldurmaz.

## Mimari

| Motor | Tetikleyici | İşi |
|---|---|---|
| `morning_brief.sh` | 07:00 hergün | Günün 3 post brief'i + 10 balina için reply DNA şablonu |
| `reply_radar.sh` | 12:00 + 17:00 / manuel | `config/reply-inbox.md`'ye yapıştırılan balina postlarına reply önerisi (telefon workflow) |
| `weekly_review.sh` | Pazar 21:00 | Son 7 brief'in arc analizi + doygunluk uyarıları + gelecek hafta açı önerileri |
| `video_factory.sh` | Manuel (opsiyonel Cmt 10:00) | Hook/brief → markalı dikey X video kartı (1080x1350, ~11s MP4). Hyperframes ile lokal render |

Üretim verileri **Obsidian'ın iCloud container'ında** tutulur (iOS Obsidian sync için zorunlu):
`~/Library/Mobile Documents/iCloud~md~obsidian/Documents/x-factory/`

`drafts/` ve `pinned/` klasörleri factory dizininde **symlink**'tir → script'ler doğrudan iCloud container'ına yazar (launchd TCC izin sorununu bypass eder).

Bu sayede Mac ↔ MacBook ↔ iPhone Obsidian üzerinden tek vault.

**Önemli:** Obsidian iOS, normal `iCloud Drive` klasörlerinden vault okumuyor — sadece kendi sandbox container'ı `iCloud~md~obsidian/Documents/`'ten. Bu yüzden vault buraya konuldu.

## Felsefe — Zero-Input

Brief'ler, weekly review ve reply-radar batch hepsi otomatik. Cem'in tek manuel girdisi: gün içinde balina postunu görünce `config/reply-inbox.md`'ye yapıştırma (telefondan veya Mac'ten). Performans metriği toplanmıyor — qualitative arc devamlılığı ile çalışır. Manuel "Pazar X paylaşacağım" tarzı sayı vaadleri prompt seviyesinde yasak.

## Kurulum (yeni cihaz)

```bash
# 1. Clone
cd ~
git clone <repo-url> x-content-factory
cd x-content-factory

# 2. Install (klasörler + launchd plist'leri otomatik)
./install.sh

# 3. claude CLI login (her cihazda ayrı)
~/.local/bin/claude
# → /login
# → tarayıcıdan auth → terminale dön
# → /exit

# 4. (PRIMARY cihaz ise) launchd'i yükle
launchctl load ~/Library/LaunchAgents/com.cemal.x.morning.plist
launchctl load ~/Library/LaunchAgents/com.cemal.x.reply.plist
launchctl load ~/Library/LaunchAgents/com.cemal.x.weekly.plist
launchctl list | grep com.cemal.x
# → 3 satır görmeli
```

## Cihaz rolleri

**PRIMARY (MacBook, priz takılı + lid açık):**
- launchd 3 agent çalışır
- Brief'leri üretir, iCloud'a yazar
- **Önemli:** uyku KAPALI olmalı, yoksa 07:00 morning_brief tetiklenmez:
  ```bash
  sudo pmset -c sleep 0                              # AC priz: hiç uyuma
  sudo pmset repeat wakeorpoweron MTWRFSU 06:55:00   # her gün 06:55'te uyandır (yedek)
  ```

**SECONDARY (iMac veya başka Mac):**
- Kod aynı (git pull ile güncel)
- launchd YÜKLEME (çakışmayı önlemek için) — yüklüyse `launchctl unload` + plist'leri sil
- Manuel komut çalıştırılabilir: `./scripts/reply_radar.sh "@hesap" "metin"`
- iCloud üzerinden MacBook'un çıktısını görür

## Klasör yapısı

```
x-content-factory/
├── scripts/                      # ← repo
│   ├── morning_brief.sh
│   ├── reply_radar.sh
│   └── weekly_review.sh
├── prompts/                      # ← repo
│   ├── morning_brief.md
│   ├── reply_radar.md
│   ├── weekly_review.md
│   └── video_factory.md
├── video/                        # ← repo (Hyperframes video motoru)
│   ├── templates/                # markalı kompozisyon varyantları (script rastgele seçer)
│   │   ├── hook.tmpl             # sol-ray + madde listesi
│   │   ├── quote.tmpl            # tırnak + editoryal
│   │   └── stat.tmpl             # numaralı 01/02/03 liste
│   ├── inject.mjs                # kopyayı template'e HTML-escape'li enjekte eder
│   ├── assets/gsap.min.js        # lokal vendor (render-anı network yok)
│   ├── hyperframes.json          # proje config
│   ├── package.json              # hyperframes@0.8.30 pin
│   ├── index.html                # ← gitignore (her çalışmada üretilir)
│   └── renders/                  # ← gitignore (MP4 çıktıları)
├── config/
│   ├── nis-baglam.md            # ← repo (private)
│   ├── balina-listesi.txt       # ← repo
│   └── reply-inbox.md           # ← gitignore (lokal, telefon workflow için)
├── launchd-templates/            # ← repo
│   └── *.plist.template
├── drafts/                       # ← gitignore (iCloud'a symlink)
│   ├── YYYY-MM-DD.md            # günlük brief'ler
│   ├── replies-YYYY-MM-DD-HHMM.md   # reply_radar çıktıları
│   ├── weekreview-YYYY-Wnn.md   # haftalık review
│   ├── video-YYYY-MM-DD-HHMM.mp4    # video_factory render'ı
│   └── video-YYYY-MM-DD-HHMM.md     # video caption + kullanılan alanlar
├── pinned/                       # ← gitignore (iCloud'a symlink)
│   └── storm-final.md           # Pazar Storm postu
├── logs/                         # ← gitignore
├── install.sh                    # ← repo
├── .gitignore                    # ← repo
└── README.md                     # ← repo
```

## Günlük kullanım

**Sabah 07:00** — bildirim gelir, Obsidian'da brief'i aç
**09:00** — Post 1'i at
**13:00** — Post 2'yi at
**Gün boyu** — brief'teki 10 balinayı X'te takip et → biri post atınca DNA şablonuyla doğaçla reply yaz (günde 5+ hedef)
**20:00** — Post 3'ü at
**Pazar 20:00** — `pinned/storm-final.md` Storm'unu at
**Pazar 21:00** — bildirim gelir, weekreview'i oku

## Reply Radar workflow (telefon dahil)

`reply_radar.sh` iki modlu:

**Manuel (Mac):**
```bash
./scripts/reply_radar.sh "@hesap" "post metni..."
```
Anlık 2 reply önerisi stdout'a + `drafts/replies-YYYY-MM-DD-HHMM.md`'ye yazılır.

**Batch (PRIMARY launchd, 12:00 + 17:00):**
`config/reply-inbox.md`'ye yapıştırılan tüm postlara reply önerisi üretir. iPhone'dan da Obsidian/Working Copy üzerinden inbox'a yapıştırma yapılabilir → bir sonraki 12:00 ya da 17:00 cron çıktıyı drafts/'a koyar → telefondan Obsidian'da okunur.

Batch çağrı, inbox'ta `## @hesap_adi` placeholder dışında gerçek girdi yoksa Claude'a boş çağrı atmaz.

## Video Motoru (Hyperframes)

Metin fabrikasına ek: bir hook'u markalı dikey X video kartına çevirir (1080x1350, ~11s MP4).
[Hyperframes](https://github.com/heygen-com/hyperframes) (Apache 2.0) ile lokal render. API key yok, per-render ücret yok.

**Nasıl çalışır:**
1. Script `templates/` içinden bir varyant RASTGELE seçer (hook / quote / stat). Üçü de aynı alanları kullanır.
2. Claude sadece KISA kopya üretir (hook, 3 madde, CTA, caption) — `prompts/video_factory.md` kontratı.
3. `inject.mjs` bu kopyayı seçilen template'e HTML-escape'li enjekte eder → `video/index.html`.
4. `hyperframes lint` doğrular (geçmezse üretimi tekrarlar, bozuk video çıkmaz).
5. `hyperframes render` → MP4. `drafts/`'a kopyalanır + caption sidecar `.md` yazılır (hangi template kullanıldığı da yazar).

Claude HTML yazmaz, layout/animasyon template'te sabit. Bu yüzden her render lint-geçerli, marka kimliği tutarlı. Çeşitlilik hem kopyadan hem 3 varyanttan gelir.

Test için varyantı sabitle: `HF_TEMPLATE=quote ./scripts/video_factory.sh "hook"` (hook / quote / stat).
Yeni varyant eklemek: `video/templates/` içine `*.tmpl` koy, aynı `{{HOOK}} {{BEAT1..3}} {{CTA}} {{HANDLE}}` alanlarını kullan. Script otomatik havuza alır.

**Kullanım:**
```bash
# Manuel (hook ver):
./scripts/video_factory.sh "AI icerik fabrikasi kurdum, uykumda calisiyor"

# Argümansız → bugünün brief'inden üretir:
./scripts/video_factory.sh
```

**Gereksinim (Mac):** Node 22+, ffmpeg (`brew install node ffmpeg`). `install.sh` kontrol eder.

**Zero-input notu:** Render ağır olduğu için varsayılan MANUEL. Haftalık otomatik istersen
`launchd-templates/com.cemal.x.video.plist.template.optional` içindeki talimatla elle kur (Cmt 10:00).
Diğer 3 motorun aksine bu `install.sh` tarafından otomatik yüklenmez.

**Marka:** Renkler #0D1F2D / #D6654F / #3ABFA7, fontlar Playfair Display (başlık) + Lato (gövde).
GSAP lokal vendor'lı, fontları Hyperframes derleyicisi çekip enjekte ediyor → render deterministik/offline.

## Niş

AI Otomasyon Atölyesi — Claude Code + n8n + cron ile gelir motorları.
Hedef kitle: 25-40 yaş TR yazılımcı/freelancer + global indie hacker.
Dil: %70 TR + %30 EN.

Detay: `config/nis-baglam.md`
