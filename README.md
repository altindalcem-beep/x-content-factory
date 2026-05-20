# X Content Factory

Tek kişilik X büyüme stüdyosu. Claude Code + launchd + cron ile 4 motorlu içerik fabrikası.
AI üretir, manuel post atılır.

## Mimari

| Motor | Tetikleyici | İşi |
|---|---|---|
| `morning_brief.sh` | 07:00 hergün | Günün 3 post brief'i + reply hedefi |
| `reply_radar.sh` | 12:00 + 17:00 / manuel | Balina hesaplara reply önerisi |
| `evening_report.sh` | 21:30 hergün | Gün sonu performans + yarına input |
| `weekly_swipe.sh` | Pazar 23:00 | Niş içi viral pattern analizi |

Üretim verileri **iCloud Drive** içinde tutulur:
`~/Library/Mobile Documents/com~apple~CloudDocs/Obsidian/x-factory/`

`drafts/`, `pinned/`, `swipe-file/` klasörleri factory dizininde **symlink**'tir → script'ler doğrudan iCloud'a yazar (launchd TCC izin sorununu bypass eder).

Bu sayede Mac ↔ MacBook ↔ iPhone Obsidian üzerinden tek vault.

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
launchctl load ~/Library/LaunchAgents/com.cemal.x.evening.plist
launchctl load ~/Library/LaunchAgents/com.cemal.x.weekly.plist
launchctl list | grep com.cemal.x
# → 4 satır görmeli
```

## Cihaz rolleri

**PRIMARY (iMac, sabit, hep açık):**
- launchd 4 agent çalışır
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
│   ├── evening_report.sh
│   └── weekly_swipe.sh
├── prompts/                      # ← repo
│   ├── morning_brief.md
│   ├── reply_radar.md
│   ├── evening_report.md
│   └── weekly_swipe.md
├── config/
│   ├── nis-baglam.md            # ← repo (private)
│   ├── balina-listesi.txt       # ← repo
│   ├── daily-metrics.md         # ← gitignore (lokal)
│   ├── reply-inbox.md           # ← gitignore (lokal)
│   └── swipe-inbox.md           # ← gitignore (lokal)
├── launchd-templates/            # ← repo
│   └── *.plist.template
├── drafts/                       # ← gitignore (iCloud'a sync)
├── swipe-file/                   # ← gitignore (iCloud'a sync)
├── logs/                         # ← gitignore
├── data/                         # ← gitignore
├── pinned/                       # ← gitignore
├── install.sh                    # ← repo
├── .gitignore                    # ← repo
└── README.md                     # ← repo
```

## Günlük kullanım

**Sabah 07:00** — bildirim gelir, Obsidian'da brief'i aç
**Gün boyu** — balina post gördükçe `./scripts/reply_radar.sh "@hesap" "metin"`
**Akşam 21:00** — X Analytics'ten sayılar → `config/daily-metrics.md`
**Pazar 20:00** — `pinned/storm-final.md` Storm'unu at

## Niş

AI Otomasyon Atölyesi — Claude Code + n8n + cron ile gelir motorları.
Hedef kitle: 25-40 yaş TR yazılımcı/freelancer + global indie hacker.
Dil: %70 TR + %30 EN.

Detay: `config/nis-baglam.md`
