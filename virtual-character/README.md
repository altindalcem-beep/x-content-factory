# Virtual Character Modülü — "VERA" (açık kaynak AI karakteri)

> Bu modül, **açıkça yapay** bir teknoloji/AI karakterinin (kod adı: **VERA**) içerik
> üretim, yayın ve abonelik-gelir sistemidir. Mevcut `x-content-factory` altyapısının
> (Claude Code + launchd + zero-input felsefe) üzerine oturur.
>
> **Ad "VERA" bir placeholder'dır** — istediğin adla değiştir. (Öneri gerekçesi:
> *Virtual Explainer* + Latince *veritas / doğruluk* → şeffaflık sinyali.)

---

## Sofia modelinden farkı (neden bu meşru?)

| | Sofia thread'i (reddedilen) | VERA (bu tasarım) |
|---|---|---|
| Kimlik | Gerçek insan gibi sunulan sahte kişi | **Açıkça AI** — bio'da, görselde, sabit ifşa |
| Yüz | Rızasız iki gerçek yüzün birleşimi | **Stilize/sentetik avatar** — kimsenin yüzü değil |
| Gelir | Sahte yakınlık → ödeme (istismar) | **Gerçek içerik değeri** → abonelik |
| Kitleyle ilişki | 1:1 kandırma, "tek kişisin" yanılgısı | 1:çok, şeffaf, eğitici |
| Platform durumu | Tespit-kaçınma (ban zamanı meselesi) | İfşa kurallarına uyumlu → kalıcı |
| Claude politikası | İhlal (impersonation) | Uyumlu (araç açıkça AI olarak kullanılıyor) |

**Tek cümle:** Sofia insan gibi davranan bir AI'dı; VERA, AI olduğunu söyleyen bir AI.
Kandırma çıkarılınca geriye kalan — tutarlı karakter + otomatik üretim + gerçek içerik —
tamamen yasal ve sürdürülebilir.

---

## Konsept

**VERA** = AI/teknolojiyi sade, dürüst ve biraz kuru mizahla anlatan yapay bir karakter.
Kendisi bir AI olduğu için niş ile karakter arasında **meta bir tutarlılık** var: "AI'ı
en iyi bir AI anlatır." Şeffaflık zafiyet değil, markanın imzası.

- **Niş:** Teknoloji / AI (haber çözümleme, araç incelemesi, "nasıl çalışır" açıklayıcıları)
- **Gelir:** İçerik aboneliği (derinlemesine içerik, prompt/şablon paketleri, erken erişim)
- **Platform:** X (merkez) + Instagram + TikTok
- **Üretim:** Otomatik taslak → **insan onayı (Cem)** → yayın. (Tam otonom değil — editoryal kontrol sende.)

---

## Modül yapısı

```
virtual-character/
├── README.md                        ← buradasın
├── brand/                           ← karakterin "beyni" (etik versiyon)
│   ├── persona.md                   ← kim, açıkça AI kimliği
│   ├── voice.md                     ← ton, üslup, yapılacak/yapılmayacaklar
│   ├── content-pillars.md           ← içerik sütunları (ne anlatır)
│   ├── disclosure.md                ← ŞEFFAFLIK SİSTEMİ (Sofia'nın escalation.md'sinin etik karşılığı)
│   └── visual-identity.md           ← tutarlı görünüm, avatar üretim kuralları
├── pipeline/
│   ├── uretim-akisi.md              ← fikir → 3 platform → yayın akışı
│   └── platform-adaptasyon.md       ← tek fikir nasıl X/IG/TikTok'a bölünür
├── ekonomi/
│   └── maliyet-ve-birim-ekonomi.md  ← dürüst maliyet + abonelik P&L modeli
└── uyumluluk/
    └── ifsa-checklist.md            ← platform ifşa + yasal uyum kontrol listesi
```

## Mevcut fabrikaya nasıl bağlanır

Aynı `morning_brief.sh` / `weekly_review.sh` deseni kullanılır, sadece VERA'nın
`brand/` dosyaları bağlam olarak beslenir. Yani sıfırdan altyapı kurmuyorsun —
var olan launchd + Claude Code motoruna ikinci bir "karakter profili" ekliyorsun.

Detaylar: `pipeline/uretim-akisi.md`.

---

## Okuma sırası

1. `brand/persona.md` — karakteri tanı
2. `brand/disclosure.md` — etik çekirdek (bunu atlama)
3. `pipeline/uretim-akisi.md` — nasıl çalışır
4. `ekonomi/maliyet-ve-birim-ekonomi.md` — gerçek maliyet ve gelir modeli
5. `uyumluluk/ifsa-checklist.md` — yayına çıkmadan önce
