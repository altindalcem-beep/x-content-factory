# VERA — Avatar Stil Kilidi v1

> Bu dosya, VERA'nın **tekrarlanabilir görsel kimliğidir.** Her yeni görselde bu spec
> kullanılır → karakter kare-kare aynı kalır (Sofia modelinin "yüz drift" hatasına düşmez).
> `visual-identity.md`'nin somut, üretime hazır karşılığı.

## Üretim parametreleri (birebir)
- **Araç:** Higgsfield · model `nano_banana_pro` (motor: nano_banana_2)
- **Kompozisyon:** split-screen karakter sayfası (tam boy + yakın portre)
- **Aspect ratio:** `16:9` · çözünürlük 2K (2752×1536)
- **Maliyet:** ~2 kredi / görsel
- **Preset:** 3D-stilize (kasıtlı **fotogerçekçi değil** → açıkça yapay, ifşa uyumlu)

## Referans üretim (v1) — SEÇİLEN: v1c ✅
Kilit turunda 3 varyant üretildi (generation widget'ta görünür — hepsi aynı prompt/params):
- v1a — job `a5a6720b-28f5-4fca-bbb3-cb6e9de2ea01`
- v1b — job `251fdd51-e960-410d-9c57-901301c8f0e0`
- **v1c — job `a82a86fa-b362-421b-8690-7be2a5214df7` ← VERA'nın SABİT YÜZÜ (kanonik)**

**Kanonik referans:** `a82a86fa-b362-421b-8690-7be2a5214df7` (v1c). Bundan sonraki
tüm VERA görsellerinde bu, kimlik referansı olarak beslenir. Diğer varyantlar arşiv.

### Bundan sonra her üretimde (tutarlılık reçetesi)
Yeni poz/sahne/kıyafet üretirken karakteri sıfırdan tarif etme — **v1c'yi referans besle:**
```
generate_image(params: {
  model: "soul_2",
  medias: [{ value: "a82a86fa-b362-421b-8690-7be2a5214df7", role: "reference" }],
  prompt: "<yeni sahne/poz> — same original stylized 3D AI character as reference,
           identical face, hair (charcoal-navy with teal streak), outfit and palette",
  aspect_ratio: "<sahneye göre>"
})
```
- job_id doğrudan `medias[].value` olarak kullanılabilir (ayrı upload gerekmez).
- Daha da sağlam tutarlılık istenirse: v1c'yi indirip **trained Soul** oluştur
  (`show_characters(action:'train')`) → kalıcı `soul_id` ile her üretimde birebir yüz.
- Her durumda **Sabit karakter özellikleri** (aşağıda) korunur; sadece istenen değişir.

> Not: Görseller Higgsfield widget'ında görüntülenip indirilebilir; repoya binary olarak
> eklenemedi (proxy CDN'i engelledi). Kilit = bu spec + v1c referans job_id'si.

## Sabit karakter özellikleri (asla değişmez)
- **Tip:** stilize 3D dijital/AI karakter — açıkça gerçek insan değil
- **Yüz:** oval, belirgin çene/elmacık, olgun yetişkin oran (babyface değil), sakin-güven veren ifade
- **Göz:** badem, hafif teal iris + soluk cyan catchlight (AI sinyali, markaya ait)
- **Saç:** omuz hizası, koyu charcoal-navy, tek canlı **teal aksan tutamı**, parlak düz teller
- **İmza motifi:** küçük geometrik/devre benzeri monogram aksanı
- **Kıyafet:** yapılandırılmış minimalist yüksek yakalı ceket (koyu charcoal) + ince teal
  aksan çizgisi (yaka/dikişler), sade iç üst, dar koyu pantolon, minimalist sneaker
- **Aksesuar:** küçük gümüş kulak cuff'ı · çanta yok
- **Palet:** koyu charcoal + teal/cyan aksan + nötr
- **Işık:** yumuşak global illumination, üç nokta stüdyo, hafif teal rim light

## Kilit prompt (kopyala-kullan)
```
Split-screen character sheet composition, left side a full-body shot of the character
standing upright in a neutral straight standing pose facing the camera with both feet
flat on the ground and arms relaxed at the sides, full head-to-toe framing with the
whole body and both feet visible, right side a tight close-up chest-up portrait of the
same character, identical original stylized character on both sides, single subject only
exactly one person with only the character in frame, pure white seamless studio
background, professional character sheet presentation, an original stylized 3D animated
character clearly reading as a digital/AI persona and not a real human, androgynous-
leaning young adult with warm light-neutral skin, oval face with defined jawline and
cheekbones and mature adult proportions not a babyface, calm friendly confident
expression, almond eyes with a subtle soft teal iris and a faint cyan catchlight, neat
defined eyebrows, sleek shoulder-length deep charcoal-navy hair with one vivid teal
accent streak framing the face, smooth glossy strands, a small geometric circuit-like
monogram motif as a subtle signature accent, stylized 3D character render with appealing
slightly exaggerated proportions, smooth subsurface-scattering skin, soft rounded yet
defined features, detailed hair strands and cloth simulation, slender balanced body with
natural proportions, wearing a structured minimalist high-collar jacket in deep near-
black charcoal with a thin glowing teal accent line along the collar and seams, a simple
fitted top underneath, tapered dark trousers, clean minimalist sneakers, no visible
branding, small delicate silver ear cuff, no bag, deep charcoal and teal-cyan accent
color palette with neutral tones, soft global illumination, three-point studio lighting,
gentle teal rim light, high-end 3D animation studio quality, octane and Unreal-style
render, clean neutral background, 4K, single subject only exactly one person only the
character in frame, no other people, no duplicate figures, no mannequin, no reflections,
no props, no furniture, no background objects, empty seamless studio, left panel standing
full-body head-to-toe not cropped not sitting, right panel tight close-up not full body,
no text, no watermark, no logos, no frame borders, no babyface, no overly youthful
rounded proportions, original character not resembling any real person or existing IP
```

## Yeni görsel üretirken (varyasyon kuralı)
Poz/sahne/kıyafet değişse bile **yukarıdaki "Sabit karakter özellikleri" birebir korunur.**
Sadece istenen şey değişir; gerisi olduğu gibi tekrar yazılır (drift'i önler).
Tutarlılık için en sağlam yol: v1'den seçilen varyantı **referans görsel** olarak besleyip
(soul_2 reference / trained Soul) üretmek.

## İfşa hatırlatma
Bu avatar bilerek stilizedir; hiçbir üretimde fotogerçekçi "gerçek insan" görünümüne
çekilmez ve gerçek bir kişiye benzetilmez (bkz. `../brand/disclosure.md`).
```
