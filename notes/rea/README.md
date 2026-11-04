# REA (Reverse Engineer Anything): Çalışma Notları

Bu dosya Claude ile REA üzerinde çalışırken bağlam hafızası olarak kullanılır.
Son güncelleme: 2026-11-04. Kaynak: morluto/rea, commit d7df9df, README okundu.

## Ne bu

- Resmi repo: https://github.com/morluto/rea
- Resmi kaynaklar: github.com/morluto/rea, rea.tools, npm paketi `rea-agents`
- Lisans: MIT
- Tek bir MCP sunucusu. Ajanı (Claude Code, Codex, Cursor, Gemini CLI vb.) şu hedeflere bağlar:
  native binary, JavaScript/Electron uygulaması, .NET assembly, web sitesi.
- Analiz yerelde çalışır. Sonuçlar kanıt ve sınırlamalarla gelir.
- Dikkat: NabilRFG12/Reverse-Engineer-anything aynı açıklamayı taşıyan kopya/türev. Orijinal değil.
- Topluluk repoları (resmi değil): aicodeking/leanrea, JoasASantos/REA-Prompts,
  AIshihzong/awesome-reverse-engineer-anything.

## Kurulum (Mac)

Gereksinim: Node.js 22.23.4+, 24.22.1+ veya 26.12.1+ ve npm.

```bash
npx rea-agents setup
```

Ajan seçilir, değişiklikler onaylanır, mevcut ayarlar yedeklenir. Sonra ajan yeniden başlatılır.
Kalıcı CLI için:

```bash
npm install --global rea-agents
rea --help
rea update
```

Terminalden JS/Electron analizi:

```bash
npx -y rea-agents@latest analyze-javascript-application /absolute/path/to/app --json
```

Güncelleme sonrası ajan kaydını yenilemek için: `npx rea-agents@latest setup`

## Hedefe göre gereksinim

- JavaScript/Electron: ek araç gerekmez.
- Native binary: Hopper, Ghidra, IDA veya Kuna'dan biri gerekir.
- Go binary, GPU code object, masaüstü kurulum dizini: yerleşik statik inceleme, ek araç yok.
- Linux'ta ayrıca procps uyumlu `ps` gerekir (bu bizim için Mac'te geçerli değil).

## Kurallar

- Sadece sahibi olduğumuz veya analiz izni olduğumuz yazılımlarda kullan.
- Üçüncü taraf uygulamanın özelliğini kopyalamadan önce repodaki DISCLAIMER.md okunur.
- Paket çalıştırmadan önce güvenilir bir dizinde çalış, hedef proje içinde değil.

## Kurulum durumu (Mac, 2026-11-04)

- Node 26.13.0 (Homebrew). `brew install node@24` sırasında simdjson yükselip Node 26.8.1'i bozdu, `brew upgrade node` ile düzeltildi. node@24 hâlâ kurulu, gereksiz.
- REA 6.8.0: Claude Code'a MCP olarak kayıtlı (`~/.claude.json`, yedek `~/.claude.json.rea.backup`). Skill: `~/.claude/skills/reverse-engineer-anything`.
- Ghidra 12.1.4 (resmi zip, SHA-256 doğrulandı): `~/tools/ghidra_12.1.4_PUBLIC`. macOS arm64 decompiler elle derlendi (docs/installation.md "macOS arm64 native decompiler").
- JDK 25 (Homebrew openjdk@25). `JAVA_HOME` ve `GHIDRA_INSTALL_DIR` MCP kaydının env bölümünde.
- `rea doctor --provider ghidra` sağlıklı. Gerçek bir analiz henüz denenmedi.
- Homebrew'daki Ghidra 12.2 de kurulu ama REA 6.8.0 onu reddediyor (yalnızca 12.1.x kabul). Kullanılmıyor.
- Hopper, IDA, JADX, Kuna kurulu değil.

## Açık sorular (doldurulacak)

- [ ] Hedef türü: Electron mı, native mi, web mi?
- [ ] Native ise hangi motor: Hopper (ücretli) mi, Ghidra (ücretsiz) mı?

## Referans

- Kurulum rehberi: docs/installation.md (repo içinde)
- CLI rehberi: docs/cli.md
- Native analiz: docs/native-investigation.md
- MCP tool kataloğu: docs/mcp-contracts.md
