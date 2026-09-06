# uretim-akisi.md — Üretim akışı

> Fikir → taslak → **insan onayı** → çok-platform uyarlama → yayın → öğrenme.
> Mevcut `x-content-factory` (Claude Code + launchd) motoruna oturur. Fark: bağlam
> olarak Cem'in niş dosyaları yerine VERA'nın `brand/` dosyaları beslenir.

## Günlük akış (zero-input hedefi korunur)

```
07:00  vera_brief.sh (launchd)
        └─ Claude, brand/*.md + son taslaklar + haber girdisini okur
        └─ üretir: bugünün 3 fikri × sütun + görsel/video brief'i
                    + platform-başı uyarlama (X / IG / TikTok)
        └─ çıktıyı Obsidian vault'a yazar (mevcut drafts/ deseni)

Gün içi  İNSAN ONAYI (Cem, telefondan)  ← kritik kapı
        └─ taslağı gözden geçir, düzelt/onayla
        └─ görseli üret (aşağıdaki görsel adımı) veya brief'e göre onayla

Yayın   onaylı içerik zamanlayıcıya/manuel yayına gider (bkz. platform-adaptasyon.md)

Pazar   vera_weekly.sh (launchd)
        └─ haftanın arc analizi + sütun dengesi + doygunluk uyarısı + gelecek hafta açıları
```

**Neden insan onayı zorunlu:** Tam otonom yayın, karakteri risk altına sokar (yanlış
bilgi, ton kayması, ifşa eksiği). Editoryal kapı sende kalır. Otomasyon üretimi
hızlandırır; **kararı** değil.

## Görsel/video üretim adımı
1. Metin onaylanır.
2. Sütuna ait **şablon** seçilir (bkz. `visual-identity.md`).
3. Avatar/görsel üretilir — sabit stil kilidiyle (tutarlılık).
4. AI/sentetik etiket + işaret eklenir (bkz. `disclosure.md`).
5. Video ise: statik avatar + kayan metin + seslendirme + altyazı.
6. Tutarlılık kontrol listesi geçilir → yayın.

## Bağlam dosyaları (Claude'a beslenen)
- `brand/persona.md`, `voice.md`, `content-pillars.md`, `disclosure.md`, `visual-identity.md`
- Son 7 gün taslakları (tekrar/doygunluk önleme)
- Güncel haber girdisi (RSS/manuel yapıştırma — mevcut reply-inbox deseni gibi)

## Üretim promptuna gömülü sabit kurallar (her çağrıda)
- İfşa kırmızı çizgileri (`disclosure.md`) — üretim bunları asla ihlal etmez.
- "Sahte insan / yakınlık / manipülasyon" çıktısı üretme.
- Kaynaksız kesin iddia yok; emin değilse "sanırım / doğrulanmalı" işaretle.

## Ölçme (dürüst, opsiyonel)
- Nicel metrik zorlaması yok (mevcut felsefeyle uyumlu).
- Haftalık review: hangi sütun tuttu, ne kaydedildi, ne abonelik getirdi — qualitative arc.
