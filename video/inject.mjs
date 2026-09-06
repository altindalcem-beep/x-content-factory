// X Content Factory — template alanlarını index.html'e enjekte eder.
// Claude sadece kopya üretir; bu script template'e güvenli (HTML-escape'li) yerleştirir.
//
// Kullanım: node inject.mjs <template.html> <out.html>
// Alanlar HF_ önekli env değişkenlerinden okunur: HF_HOOK, HF_BEAT1..3, HF_CTA, HF_HANDLE
import { readFileSync, writeFileSync } from "node:fs";

const [, , templatePath, outPath] = process.argv;
if (!templatePath || !outPath) {
  console.error("kullanım: node inject.mjs <template.html> <out.html>");
  process.exit(2);
}

const esc = (s) =>
  String(s)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");

const fields = ["HOOK", "BEAT1", "BEAT2", "BEAT3", "CTA", "HANDLE"];
let html = readFileSync(templatePath, "utf8");

for (const f of fields) {
  const v = process.env["HF_" + f] ?? "";
  html = html.split("{{" + f + "}}").join(esc(v));
}

// Doldurulmamış placeholder kaldıysa hata ver (sessiz bozuk çıktı olmasın)
const leftover = html.match(/\{\{[A-Z0-9_]+\}\}/g);
if (leftover) {
  console.error("enjekte edilmemiş placeholder: " + leftover.join(", "));
  process.exit(1);
}

writeFileSync(outPath, html);
