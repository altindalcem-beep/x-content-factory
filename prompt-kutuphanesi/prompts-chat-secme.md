# Prompt Kütüphanesi (prompts.chat kitabından seçme)

Kaynak: f/prompts.chat deposundaki "Interactive Book of Prompting" (src/content/book, MIT lisanslı). Kitapta 277 örnek prompt var. Buradakiler seçilmiş 19 tanesi, Türkçeye ve Cem'in işine uyarlanmış hali. Her birinin başında kitaptaki bölüm numarası yazıyor.

Bu klasör `prompts/` dışında duruyor, çünkü `prompts/` altındaki dosyaları launchd script'leri okuyor. Buradakiler elle kullanım için.

## Nasıl kullanılır

1. Önce Bölüm 0'daki bağlam bloğunu bir kere doldur, bir yere kaydet.
2. Her prompt'un başına bağlam bloğunu yapıştır, `{süslü parantezli}` yerleri doldur.
3. Çıktı ortalamaysa prompt'u değiştirme, önce Bölüm 1'deki teşhis prompt'unu çalıştır.

Kitabın kendi uyarısı: rol vermek (örn. "sen bir pazarlama uzmanısın") üslubu ve odağı değiştirir, bilgi eklemez. Tek başına olgusal doğruluğu artırmaz. Bu yüzden aşağıdaki prompt'larda rol cümlesi yok, yerine bağlam, kriter ve çıktı formatı var.

---

## 0. Bağlam bloğu (her prompt'un başına)

```
BAĞLAM
Ben: {kim olduğun, ne iş yaptığın, 1-2 cümle}
Kitle: {kime yazıyorum / kimin için karar veriyorum}
Ses: otoriter ama samimi, profesyonel sohbet tonu. Düz cümle kur.
Benzetme: spor, mutfak, mimari, doğa. Savaş ve askeri benzetme yok.

KURALLAR
- Bilmediğin şeyi "bilmiyorum" diye yaz. Kaynak, rakam, alıntı uydurma.
- Doğrulanmamış sayı yazma. Sayı gerekiyorsa {boşluk} bırak.
- Övgü ve dolgu cümlesi yok. Önce zayıf noktaları göster.
- Uzun tire kullanma, nokta veya virgül kullan.
- Emoji yok.
- Şu kelimeleri kullanma: günümüzde, bu bağlamda, sonuç olarak, çığır açan, devrim niteliğinde, katma değer sağlamak.
- "Bu sadece X değil, aynı zamanda Y" kalıbını kullanma.
```

---

## 1. Temel: prompt'u düzelt

### 1.1 Belirsiz isteği keskinleştir (kitap bölüm 15)

Ne zaman: Yazmadan önce, fikrin bulanıksa.

```
Elimde belirsiz bir istek var: "{belirsiz istek}"

Bunu şu altı eksenle somutlaştır ve tek bir net prompt olarak yeniden yaz:
1. Okuyucu / kullanıcı kim
2. Çıktı formatı
3. Uzunluk
4. Ses ve ton
5. Durum ve amaç
6. Zorunlu ve yasak olanlar

Eksik bilgi varsa tahmin etme, en fazla 3 soru sor, sonra yaz.
```

### 1.2 Çıktı tutmadı, teşhis et (kitap bölüm 15)

Ne zaman: Sonuç ortalama veya yanlış geldiğinde.

```
Prompt'um:
"""{prompt}"""

Aldığım çıktı:
"""{çıktı}"""

Neyi beğenmedim:
"""{sorun}"""

Şunu yap:
1. Teşhis: prompt neden bu çıktıyı üretti
2. Eksik: neyi açıkça söylemedim
3. Yeni prompt: düzeltilmiş hali
4. Kontrol: yeni çıktıda nelere bakmalıyım
```

### 1.3 Doğrulama notu (kitap bölüm 15, halüsinasyon azaltma)

Ne zaman: Gerçek bilgi içeren her şeyde, yayınlamadan önce.

```
Konu: {konu}

Cevabını ver. Sonuna "Doğrulama Notları" bölümü ekle:
1. Güven düzeyi: yüksek / orta / düşük, gerekçesiyle
2. En çok yanlış veya eskimiş olma ihtimali olan kısımlar
3. Benim bağımsız kontrol etmem gereken iddialar
4. Kaynak uydurma. Emin değilsen kaynağın türünü söyle (örn. "şirketin yatırımcı sunumu"), isim verme.
```

---

## 2. Zayıf nokta avcısı

Bu bölümdeki prompt'lar onay almak için değil, fikri kırmak için.

### 2.1 Argüman denetimi (kitap bölüm 23)

Ne zaman: Bir iddia, teklif fiyatı, strateji ya da post fikri yayına girmeden önce.

```
Aşağıdaki metnin argümanını denetle:

"""{metin}"""

Çıkar:
1. Ana iddia
2. İddiayı taşıyan kanıt
3. Söylenmemiş varsayımlar
4. Mantık akışı: sonuç öncüllerden çıkıyor mu
5. Hata ve boşluklar (mantık safsataları dahil)
6. En güçlü karşı argüman ve ona verilebilecek cevap
7. Alternatif yorumlar

Dengeli ol, ama beni rahatlatmak için yumuşatma. En zayıf noktayı en başa yaz.
```

### 2.2 Karar matrisi (kitap bölüm 21)

Ne zaman: Araç seçimi, teklif seçimi, fiyatlama kararı.

```
Karar: {karar}

Seçenekler: {A}, {B}, {C}

Kriterlerim ve ağırlıkları:
- {kriter 1}: yüksek
- {kriter 2}: orta
- {kriter 3}: düşük

Yap:
1. Her seçeneği her kritere 1-5 puanla, puanın gerekçesini tek cümleyle yaz
2. Ağırlıklı toplamı hesapla, hesabı göster
3. Her seçenek için en büyük risk
4. Karar öncesi bana sorman gereken sorular
5. Öneri. Verilerim yetersizse "yetersiz" de.

Bilmediğin fiyat veya özellikleri tahmin etme, "doğrulanmalı" diye işaretle.
```

### 2.3 Kök neden: 5 Neden (kitap bölüm 23)

Ne zaman: Düşen metrik, kaçan müşteri, tutmayan kampanya.

```
Sorun: {sorun, ölçülmüş haliyle}
Elimdeki veri: {veri}

5 Neden yöntemiyle ilerle. Her "neden" için kanıtın bende olup olmadığını yaz:
kanıtlı / varsayım.

Sonunda:
- Olası kök neden(ler)
- Hangi kök neden varsayım, nasıl test ederim
- İlk 2 aksiyon
```

### 2.4 Boşluk analizi (kitap bölüm 23)

Ne zaman: Bir müşterinin AI olgunluğunu ya da kendi sürecini değerlendirirken. AI-First Index'in boyutlarıyla birlikte kullanılabilir.

```
Konu: {konu}
Mevcut durum: {şu an}
Hedef durum: {olması gereken}

Tablo çıkar:
| Alan | Mevcut | Hedef | Fark | Öncelik (Y/O/D) |

Yüksek öncelikli her fark için: somut aksiyon, gereken kaynak, süre, başarı ölçüsü.
Mevcut durumda verilmemiş bir şeyi varsayma, "veri yok" yaz.
```

### 2.5 Rakip konumlandırma (kitap bölüm 21)

Ne zaman: Fiyat veya vaat yazmadan önce.

```
Rakip: {rakip}
Benim teklifim: {teklif}

Bildiğin kadarıyla çıkar: ürün ve fiyat, güçlü yan, zayıf yan, hedef segment, görünen yön.
Bildiğin ile tahmin ettiğini ayır. Güncel olmayabilecek bilgiyi işaretle.

Sonra:
- Nerede benden güçlüler
- Nerede ben güçlüyüm
- Boş kalan alan
- Bu boşluğa tek cümlelik konumlandırma önerisi, 3 alternatif
```

---

## 3. İçerik üretimi

### 3.1 Önce açı, sonra iskelet (kitap bölüm 18)

Ne zaman: Yazmaya oturmadan önce. En çok işe yarayan prompt bu.

```
Konu: {konu}
Kitle: {kitle}

Yazmadan önce:
1. 5 farklı açı öner (her biri tek cümle)
2. En iyisini seç, nedenini söyle
3. Seçilen açı için iskelet: bölümler, her bölümün ana fikri, gereken örnek veya kanıt
4. Araştırma gerektiren boşlukları listele

Henüz metni yazma.
```

### 3.2 Sesimi taklit et (kitap bölüm 18)

Ne zaman: AI metni sana benzemiyorsa.

```
Aşağıdaki örnekleri benim yazdığım metin olarak al:

"""{örnek 1}"""
"""{örnek 2}"""
"""{örnek 3}"""

Önce şunları çıkar: cümle uzunluğu kalıbı, kelime düzeyi, sık kullandığım retorik hamleler, ton.
Sonra bu özelliklere uyarak şunu yaz: {yeni içerik}

Çıkardığın ses özelliklerini ayrı bir liste olarak da ver, ileride yeniden kullanacağım.
```

### 3.3 Üç geçişli yazım (kitap bölüm 18)

Ne zaman: Uzun yazılarda. Tek seferde "mükemmel" isteme.

```
Konu: {konu}

Tek mesajda üç aşama çalış, her aşamanın çıktısını ayrı başlıkla göster:
Geçiş 1 (taslak): Fikirleri indir, mükemmellik arama.
Geçiş 2 (derleme): Cümleleri sıkılaştır, geçişleri ekle, açılışı ve kapanışı güçlendir.
Geçiş 3 (cila): Dilbilgisi, cümle ritmi, ton tutarlılığı.

Son geçişte şunları ele: dolgu cümleleri, "önemli olan şu" tipi açılışlar, gereksiz üçlü listeler.
```

### 3.4 Redaksiyon ve yapay zeka izi temizliği (kitap bölüm 18 + senin filtren)

Ne zaman: Yayına çıkmadan son adım.

```
Aşağıdaki metni {amaç} için düzenle.

Kontrol et:
- Dilbilgisi ve yazım
- Cümle uzunluğu çeşitliliği
- Zayıf kelimeler
- Akış ve geçişler
- Ton tutarlılığı
- Yapay zeka izi: "bu sadece X değil Y" kalıbı, zorunlu üçlü liste, boş açılış, abartılı sıfatlar, uzun tire

Ver:
1. Düzenlenmiş metin
2. Yaptığın büyük değişikliklerin özeti
3. Yaptırmadığın ama önerdiğin değişiklikler

Anlamı ve verilen rakamları değiştirme.

Metin:
"""{metin}"""
```

### 3.5 Tek fikir, çok platform (kitap bölüm 18)

Ne zaman: Bir fikri X, LinkedIn ve e-postaya dağıtırken.

```
Fikir: {fikir}
Kanıt veya örnek: {gerçek örnek, uydurma yok}

Platform versiyonları:
- X: tek post (280 karakter altı, ilk satır kanca) + gerekirse 5 postluk thread
- LinkedIn: 1300 karakter altı, hikaye yapısı, sonda tartışma sorusu
- E-posta bülteni: konu satırı + 2 alternatif, 120 kelimelik gövde

Her platformda aynı fikri farklı kapıdan sok, kopyala-yapıştır olmasın.
Hashtag zorunlu değil.
```

### 3.6 Hoş geldin e-posta serisi (kitap bölüm 18, Değer Merdiveni'ne göre)

Ne zaman: Ücretsiz içerikten workshop'a geçiş akışı kurarken.

```
Marka: {marka}
Abonelik nedeni: {ücretsiz ne verdim}
Serinin hedefi: {örn. workshop kaydı}

5 e-posta yaz. Her biri için: konu satırı (+1 alternatif), önizleme metni, gövde (150-200 kelime), tek CTA.

Akış:
1. Gün 0: Hoş geldin ve hemen kullanılabilir bir değer
2. Gün 2: Hikaye ve bakış açım
3. Gün 4: Öğretici içerik
4. Gün 7: Gerçek bir sonuç örneği ve yumuşak öneri (örnek yoksa {boşluk} bırak, uydurma)
5. Gün 10: Doğrudan teklif

Korku ve sahte aciliyet kullanma. Aciliyet gerçekse gerekçesini yaz.
```

---

## 4. İş ve üretkenlik

### 4.1 SOP yaz (kitap bölüm 21)

Ne zaman: Müşteriye teslim edilen süreç dokümanında.

```
Görev: {görev}
Okuyucu: {kim kullanacak}
Seviye: {yeni başlayan / orta}

Yaz:
1. Amaç ve kapsam
2. Ön koşullar
3. Adım adım talimat (her adımda sorumlu kişi)
4. Karar noktaları (eğer X ise Y)
5. Kalite kontrol noktaları
6. Sık hatalar ve çözümleri
7. İlgili dokümanlar

Yeni gelen biri sana soru sormadan uygulayabilmeli. Belirsiz adım bırakma, bilmediğin yeri {doldurulacak} diye işaretle.
```

### 4.2 Toplantı gündemi (kitap bölüm 21)

```
Toplantı türü: {tür}
Amaç: {amaç}
Katılımcılar: {kim}
Süre: {dakika}

Tablo:
| Süre | Konu | Sahibi | Beklenen çıktı |

Ekle: toplantı öncesi hazırlık, çıktı yoksa toplantıyı kısaltma önerisi, toplantı sonrası aksiyon şablonu.
Sunum amaçlı konuşma maddelerini toplantıdan çıkarıp e-postaya taşınabilecekleri ayrıca işaretle.
```

### 4.3 Haftalık öncelik: Eisenhower (kitap bölüm 21)

Ne zaman: Pazar akşamı veya pazartesi sabahı.

```
Görevlerim:
{görev listesi, bitiş tarihleriyle}

Her görevi sınıfla: acil+önemli / önemli ama acil değil / acil ama önemli değil / hiçbiri.

Sonra ver:
- Sıralı yürütme planı
- Süre tahminleri (tahmin olduğunu belirt)
- Devredilecek veya silinecek olanlar ve gerekçesi

İtiraz et: listemde bana ait olmayan ya da hedefimle bağı kurulamayan görev varsa açıkça söyle.
```

### 4.4 Sadeleştir (kitap bölüm 18)

```
Aşağıdaki metni {kitle} için sadeleştir.

Kurallar:
- Jargonu düz kelimeyle değiştir
- Cümleyi ortalama 15-20 kelimeye indir
- Gerekli teknik terimi bir cümleyle açıkla
- Karmaşık fikri adımlara böl
- Anlamı ve rakamları koru

Metin:
"""{metin}"""
```

---

## Atladıklarım ve nedeni

- "Act as" tipi rol prompt'ları (kitap bölüm 4, 10, 18, 21, 23'te çok var): rol tek başına çıktı kalitesini artırmıyor, yerine bağlam bloğu kullan.
- Akademik makale bölümleri (yöntem yazma, tartışma yazma, literatür sentezi): işine uymuyor.
- Çocuk hikayesi, karakter profili, kısa hikaye: işine uymuyor.
- Kitap bölüm 25-28 (ajanlar, MCP, kalıcı botlar, yazılımla AI): prompt'tan çok kavram anlatıyor. Content Factory'yi geliştirirken okunur, kopyalanacak prompt yok.
- JSON/YAML prompt'ları (bölüm 9): script yazarken işe yarar, günlük kullanım için değil.
