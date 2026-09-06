# maliyet-ve-birim-ekonomi.md — Dürüst maliyet ve gelir modeli

> Sofia thread'inin "$61 maliyet → $21.400 gelir, %99.7 marj" tablosu bir reklam
> cümlesiydi (churn yok, komisyon yok, ban maliyeti yok). Bu dosya bunun **dürüst**
> karşılığıdır: gerçek maliyet kalemleri + churn'lü abonelik ekonomisi + üç senaryo.
> **Tüm sayılar varsayımdır**, gerçekleşmiş gelir değildir — kendi rakamlarınla değiştir.

---

## A. Aylık sabit maliyet (araç yığını)

Gerçekçi bir başlangıç yığını. Fiyatlar bölgeye/plana göre değişir — **kendi güncel
fiyatlarınla doğrula.** Meşru, ifşalı bir hesap **proxy/residential IP gerektirmez**
(o kalem sadece tespit-kaçınma içindi; burada yok).

| Araç | Rol | Aylık (~USD, tahmini) |
|---|---|---|
| LLM API / abonelik (metin beyni) | İçerik üretimi | 20–100 (kullanıma göre) |
| Görsel üretim (avatar + kartlar) | Tutarlı görsel | 10–40 |
| Video üretim/animasyon | Reels/TikTok | 0–50 (statik+seslendirme ucuz; tam animasyon pahalı) |
| Seslendirme (TTS) | Video sesi | 0–22 |
| Video kurgu (CapCut vb.) | Montaj | 0 (ücretsiz katman yeter) |
| Zamanlama aracı (opsiyonel) | Çok-platform yayın | 0–20 |
| Tasarım (Canva vb., opsiyonel) | Şablon | 0–13 |
| **Toplam (yalın başlangıç)** | | **~$30–60** |
| **Toplam (tam video + araçlar)** | | **~$120–250** |

> Not: Bu, Sofia'nın $61'ine yakın **ama** dürüst aralık olarak verilmiştir. Fark
> gelirde değil — gelir tarafındaki gerçekçilikte (aşağı).

Gizli/atlanmayan maliyetler: **kendi zamanın** (onay + kurgu), abonelik platformu
komisyonu, ödeme işlemcisi kesintisi, (istersen) ücretli reklam.

---

## B. Abonelik birim ekonomisi (gerçek mantık)

Abonelik geliri "takipçi × fiyat" değildir. Doğru zincir:

```
Takipçi
 → Ücretsiz içerikten dönüşen abone (conversion %)
 → Aylık kalan abone (1 − churn %)     ← Sofia'nın atladığı yer
 → × ARPU (abone başı net gelir, komisyon SONRASI)
 = Aylık tekrarlayan gelir (MRR)
```

**Anahtar gerçekler:**
- **Conversion:** takipçinin ödeyene dönüşümü genelde **%0.5–2** (kitle sıcaksa üstü).
- **Churn:** içerik aboneliğinde aylık **%5–15** iptal olağandır → net büyüme = yeni − iptal.
- **Komisyon:** platform + işlemci brütün **~%8–30'unu** alır → ARPU brüt fiyatın altındadır.
- **MRR birikimlidir:** kalıcı aboneler üst üste binerse büyür; churn yüksekse plato yapar.

---

## C. Üç senaryo (12. ay, ILLUSTRATIF)

Varsayımlar: abonelik brüt **$8/ay**, komisyon sonrası ARPU **~$6.4**, aylık churn **%10**.
Takipçi ve dönüşüm senaryoya göre değişir. **Bunlar hedef/model, taahhüt değil.**

| | Muhafazakâr | Baz | İyimser |
|---|---|---|---|
| 12. ay takipçi (3 platform toplam) | 8.000 | 25.000 | 60.000 |
| Ücretsiz→abone dönüşüm | %0.5 | %1.0 | %1.5 |
| Brüt yeni abone havuzu | ~40 | ~250 | ~900 |
| Churn sonrası **kararlı abone** (~) | ~35 | ~180 | ~600 |
| ARPU (net) | $6.4 | $6.4 | $6.4 |
| **Aylık gelir (MRR, ~)** | **~$220** | **~$1.150** | **~$3.850** |
| Aylık araç maliyeti | ~$60 | ~$150 | ~$250 |
| **Aylık net (~)** | **~$160** | **~$1.000** | **~$3.600** |

Ek gelir katmanları (modele dahil değil, üstüne biner): **affiliate** (araç incelemesi
sütunundan), **sponsorluk** (kitle büyüyünce), platform **reklam paylaşımı** (eşik sonrası).
Bunlar genelde 6. aydan sonra anlamlı olur.

---

## D. Sofia tablosuyla dürüst karşılaştırma

| | Sofia iddiası | Bu model (baz senaryo) |
|---|---|---|
| Aylık gelir | $21.400 | ~$1.150 (12. ay hedefi) |
| Marj | %99.7 | ~%85 (komisyon + araç sonrası, zaman hariç) |
| Churn hesaba katılı | Hayır | Evet |
| Komisyon hesaba katılı | Hayır | Evet |
| Ban/yeniden kurulum riski | Gizlenmiş (yüksek) | ~0 (uyumlu) |
| Sürdürülebilirlik | Kısa (ihlal) | Uzun (yasal) |

**Sonuç:** Rakam Sofia'nınkinden düşük ama **gerçek** — ve büyüdükçe artan, banla
sıfırlanmayan bir taban. "Küçük ama senin olan bir gelir" > "büyük ama fantezi (ve yasadışı)".

---

## E. Kâra giden mantık
1. **Faz 1 (0–3 ay):** kitle + karakter tutarlılığı. Gelir ~$0. Maliyet minimumda tut (~$30–60).
2. **Faz 2 (3–6 ay):** abonelik + affiliate aç. İlk MRR. Maliyeti gelire göre ölçekle.
3. **Faz 3 (6+ ay):** sponsorluk + reklam paylaşımı. MRR birikimi + churn'ü düşürmeye odak
   (churn'ü %10→%5 indirmek, yeni abone bulmaktan daha kârlıdır).

> Altın kural: maliyeti **gelir geldikçe** artır. Faz 1'de tam video yığınına para yakma —
> yalın başla, tutan sütunu gördükçe yatır.
