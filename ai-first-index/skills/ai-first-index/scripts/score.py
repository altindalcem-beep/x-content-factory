"""Score an AI-First Index assessment.

Usage: python3 score.py index.json answers.json

Dimension score = mean of its question levels, scaled to 0-100.
Total = weighted mean of dimension scores. Band = highest band whose min <= total.
"""
import json
import sys


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def main():
    if len(sys.argv) != 3:
        sys.exit("usage: score.py index.json answers.json")
    index, data = load(sys.argv[1]), load(sys.argv[2])
    answers = data.get("answers", {})
    assumed = set(data.get("assumed", []))
    lo, hi = index["scale"]["min"], index["scale"]["max"]

    missing, rows = [], []
    for dim in index["dimensions"]:
        given = answers.get(dim["id"], {})
        levels = []
        for q in dim["questions"]:
            level = given.get(q["id"])
            if not isinstance(level, int) or not lo <= level <= hi:
                missing.append(q["id"])
                continue
            levels.append(level)
        if len(levels) != len(dim["questions"]):
            continue
        score = round((sum(levels) / len(levels) - lo) / (hi - lo) * 100, 1)
        uses_assumed = any(q["id"] in assumed for q in dim["questions"])
        rows.append((dim, score, uses_assumed))

    if missing:
        print("MISSING OR INVALID ANSWERS: " + ", ".join(missing))
        sys.exit(1)

    total_weight = sum(d["weight"] for d, _, _ in rows)
    total = round(sum(d["weight"] * s for d, s, _ in rows) / total_weight, 1)
    band = max((b for b in index["bands"] if b["min"] <= total), key=lambda b: b["min"])

    print(f"TOTAL: {total}/100")
    print(f"BAND: {band['label']} ({band['meaning']})")
    print("DIMENSIONS:")
    for dim, score, uses_assumed in rows:
        flag = " [assumed answers]" if uses_assumed else ""
        print(f"  {dim['id']} {dim['name']}: {score}{flag}")
    weakest = sorted(rows, key=lambda r: r[1])[:2]
    print("WEAKEST: " + ", ".join(f"{d['id']} {d['name']}" for d, _, _ in weakest))


if __name__ == "__main__":
    main()
