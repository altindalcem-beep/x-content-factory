# Niş: YouTube Shorts Motoru (AI Otomasyon Atölyesi)

X Content Factory'nin video kolu. Aynı niş, aynı ton, farklı format.
Günde 1 tam Short. Cem'in tek manuel işi: brief'i açıp kaydet + kes + yükle (~1 saat).

## Para modeli gerçeği (önce bunu oku)

**Shorts AdSense ile "para kazanmak" 1. gün hedefi DEĞİL. Bunu net yaz:**

- YPP (YouTube Partner Program) eşiği: 1000 abone + son 90 günde 10M Shorts izlenme (ya da 4000 saat long-form). Bu eşiğe gelmeden reklam geliri = $0.
- AdSense hesabı olmadan tek kuruş ödenmez. Hesap yoksa önce YPP eşiğine yaklaşırken AdSense kurulur (eşiğe gelince zaten zorunlu adım).
- Shorts RPM düşük: bin izlenme başına ~$0.01-0.07 bandında. 1M izlenme ≈ $10-70 mertebesi. Yani saf Shorts reklam geliri, 1 saat/gün emeğin karşılığı olarak zayıf.

**Gerçek gelir yolu: Shorts = huninin tepesi, para aşağıda.**
Değer Merdiveni: Ücretsiz Short → e-mail/topluluk → Workshop → Danışmanlık → Dönüşüm programı.
Her Short'un işi: izleyiciyi Cem'in AI otomasyon teklifine bir adım yaklaştırmak. Reklam kuruşu değil, huniye giren nitelikli kişi.

**Bu yüzden birincil KPI:** retention (ilk 3 sn tutma) + kaydetme/paylaşma + açıklama/pinned yorum tıklaması. İzlenme ikincil, RPM üçüncül.

## Format kararı: Faceless build-in-public (KİLİTLİ)

Cem yüz göstermiyor. Karar verildi, bütün Shorts faceless. En düşük sürtünme:
- Ekran kaydı: Claude Code terminali, n8n canvas, cron/launchd, gerçek çıktı
- Üstüne büyük on-screen metin (hook + adımlar)
- Opsiyonel voiceover ya da sessiz + altyazı
- Konuşan-kafa YOK. Her script ekran + metin + (opsiyonel) ses ile çekilebilmeli.

Bu format 1 saat/gün'e sığar: script hazır → 5-10 dk ekran kaydı → 20-30 dk kes/altyazı → yükle.

## Uzunluk ve yapı

- Süre: 20-40 sn. Sweet spot 25-35 sn (yüksek retention + tam loop şansı).
- İlk 2 sn = hook. İzleyici kaydırmayı burada karar verir. Zayıf açılış = ölü video.
- Son 2 sn = loop kancası ya da tek net CTA. Baştaki cümleye bağlanırsa video loop olur, retention patlar.
- Tek fikir, tek Short. İki fikir varsa iki gün.

## CTA / link kuralı

- Link ANA açıklamanın ilk satırına ya da pinned yoruma. Videonun içinde "linke tıkla" bağırma yok (X'teki link kuralının video karşılığı).
- CTA yumuşak: "tam pipeline pinned'de", "n8n şablonu açıklamada". Satıcı dili yasak ("kursuma gel", "DM at").
- Her Short'ta CTA olmak zorunda değil. 3 Short'ta 1 sert CTA, diğerleri sadece değer + soft mention.

## Ton (nis-baglam.md ile aynı)

- Operatör mantığı, kurs satıcısı değil.
- İçerik üçgeni: spesifik komut + spesifik sayı + spesifik hata.
- Build-in-public dürüstlüğü. Uydurma sayı yok (bkz. nis-baglam.md "Doğrulanmış verilerim").
- Zekice ironi, ucuz meme yok.

## SAYI DÜRÜSTLÜĞÜ (nis-baglam'dan devralınır, kritik)

Video başlığında, on-screen metinde, açıklamada UYDURMA rakam yok.
"$X kazandım", "Y aboneye ulaştım", "Z ayda büyüdüm" gibi rakamlar sadece nis-baglam.md
"Doğrulanmış verilerim" bölümünde varsa kullanılır. Yoksa: rakamsız üslup ya da hedef olarak çerçevele.
Thumbnail/başlıkta clickbait rakam = kanal güvenilirliği biter.

## Faz takvimi (Shorts kolu)

- Faz 1 (Isındırma): format oturt, günde 1 Short, retention öğren. Abone/izlenme takıntısı yok.
- Faz 2 (Hacim): en iyi 3 formatı tekrarla, seri yap (ör. "Claude Code 30 saniyede X").
- Faz 3 (Monetize): YPP eşiğine yaklaşınca AdSense kur; asıl para huniden (workshop/danışmanlık).

## Açık kalan tek karar (varsayım yapma)

- Huni ucu: şu an satılan somut teklif ne (workshop tarihi / danışmanlık / ücretsiz topluluk)? CTA buna bağlanır. Belli değilse CTA = e-mail/topluluk toplama (varsayılan).

Format kararı verildi: faceless (yukarıda kilitli). Swipe file kalıp arşivi: `config/shorts-swipe.md`.
