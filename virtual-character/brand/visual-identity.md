# visual-identity.md — Görsel kimlik ve avatar kuralları

> Amaç: her gönderide **tanınabilir ve tutarlı** ama **açıkça yapay** bir görünüm.
> Sofia modeli fotogerçekçilik + gerçek yüz karışımı kullanıyordu (kandırma + rıza sorunu).
> VERA bunun tersini yapar: kasıtlı olarak stilize, kimsenin yüzü olmayan bir avatar.

## Temel karar: stilize > fotogerçekçi
Fotogerçekçi "gerçek insan" avatarı üç sorun getirir: (1) kandırma vektörü, (2) rızasız
yüz/likeness riski, (3) kare-kare tutarlılık zorluğu. Stilize avatar üçünü de çözer **ve**
daha akılda kalıcıdır. Öneri: **belirgin, sabit bir illüstratif/3B-render stil.**

## Avatar spesifikasyonu (üretim tutarlılığı için)
Bir "stil kilidi" tanımla ve her üretimde aynısını kullan:
- **Stil:** (örn.) yarı-3B render / editorial illüstrasyon — net, temiz, hafif fütüristik.
- **Sabit özellikler:** saç/renk, göz, bir ayırt edici işaret (örn. karakteristik bir renk
  aksanı ya da geometrik motif). Bunlar **her görselde birebir aynı** kalır.
- **Palet:** 2-3 marka rengi + nötr. (Örn. koyu zemin + tek canlı aksan.)
- **İşaret:** köşede küçük, tutarlı bir logo/monogram — hem marka hem AI işareti.

> Not: Belirli bir üretim aracıyla karakter tutarlılığı için, bu repodaki Higgsfield
> `character-sheet` iş akışı (bkz. MCP) veya benzeri bir "karakter sayfası" üretip
> referans olarak sabitlenebilir. Amaç: aynı yüz/stil her seferinde.

## Şablon sistemi (hız + tanınırlık)
Her sütun için sabit bir görsel şablon:
- **Haber çözümleme:** başlık kartı + tek anahtar sayı.
- **Nasıl çalışır:** basit diyagram/şema.
- **Araç incelemesi:** ekran + not overlay.
- **Meta:** pipeline şeması / "arka plan" estetiği.
- **İpuçları:** kod/prompt kartı.

Şablonlar sabit tipografi + palet kullanır → feed'de VERA anında tanınır.

## Video (IG Reels / TikTok)
- Avatar animasyonu opsiyonel; başlangıçta **statik avatar + kayan metin + seslendirme**
  yeterli ve ucuz (bkz. ekonomi dosyası).
- Her videoda platformun **AI etiketi açık** (bkz. `disclosure.md`).
- Altyazı her zaman açık (sessiz izleme + erişilebilirlik).

## Tutarlılık kontrol listesi (her görsel yayından önce)
- [ ] Avatar stili/özellikleri önceki gönderilerle aynı mı?
- [ ] Marka paleti/tipografi korunmuş mu?
- [ ] AI/sentetik etiket + işaret yerinde mi?
- [ ] Gerçek bir kişinin yüzü/benzeri kullanılmadı mı?
- [ ] Fotogerçekçi "gerçek insan" izlenimi vermiyor mu?

## Yasak
- Gerçek kişilerin yüzlerinden türetme.
- Fotogerçekçi insan illüzyonu.
- Telifli karakter/marka görsellerini kopyalama.
- Görselden AI/sentetik işaretini kaldırma.
