# X Content Factory

Tek kişilik X büyüme stüdyosu. Claude Code + launchd ile 3 motorlu içerik fabrikası.
AI üretir, manuel post atılır. Cem sadece X üzerinde çalışır — hiçbir config dosyası doldurmaz.

## Mimari

| Motor | Tetikleyici | İşi |
|---|---|---|
| `morning_brief.sh` | 07:00 hergün | Günün 3 post brief'i + 10 balina için reply DNA şablonu |
| `reply_radar.sh` | 12:00 + 17:00 / manuel | `config/reply-inbox.md`'ye yapıştırılan balina postlarına reply önerisi (telefon workflow) |
| `weekly_review.sh` | Pazar 21:00 | Son 7 brief'in arc analizi + doygunluk uyarıları + gelecek hafta açı önerileri |

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

**PRIMARY (iMac, sabit, hep açık):**
- launchd 3 agent çalışır
- Brief'leri üretir, iCloud'a yazar

**SECONDARY (MacBook, mobil):**
- Kod aynı (git pull ile güncel)
- launchd YOK (çakışmayı önlemek için)
- Manuel komut çalıştırılabilir: `./scripts/reply_radar.sh "@hesap" "metin"`
- iCloud üzerinden iMac'in çıktısını görür

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
│   └── weekly_review.md
├── config/
│   ├── nis-baglam.md            # ← repo (private)
│   ├── balina-listesi.txt       # ← repo
│   └── reply-inbox.md           # ← gitignore (lokal, telefon workflow için)
├── launchd-templates/            # ← repo
│   └── *.plist.template
├── drafts/                       # ← gitignore (iCloud'a symlink)
│   ├── YYYY-MM-DD.md            # günlük brief'ler
│   ├── replies-YYYY-MM-DD-HHMM.md   # reply_radar çıktıları
│   └── weekreview-YYYY-Wnn.md   # haftalık review
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

## Niş

AI Otomasyon Atölyesi — Claude Code + n8n + cron ile gelir motorları.
Hedef kitle: 25-40 yaş TR yazılımcı/freelancer + global indie hacker.
Dil: %70 TR + %30 EN.

Detay: `config/nis-baglam.md`
