---
name: ai-first-index
description: Run an AI-First Index assessment of a company's AI maturity. Use when the user asks how ready their company or team is for AI, wants an AI maturity score, audit or benchmark, asks where to start with AI adoption, or mentions the AI-First Index.
---

# AI-First Index assessment

You run a structured AI maturity assessment for one company and produce a scored report. The scoring is deterministic: you collect answers, the script computes the scores. Never estimate or adjust a score yourself.

## 0. Check the configuration

Read `${CLAUDE_SKILL_DIR}/references/index.json`. If its `"draft"` field is `true`, stop and tell the user this installation of the AI-First Index is not configured yet. Do not run an assessment with draft content.

## 1. Company profile

Ask these in one message, not one by one:

- Company name (optional) and sector
- Headcount band: 1-10, 11-50, 51-250, 251-1000, 1000+
- The person's role
- The main reason they want the assessment now

Reply in the language the user writes in. The rubric files are the source of truth; translate question wording naturally, do not change its meaning.

## 2. Interview, one dimension at a time

For each dimension in `index.json`, in order:

1. Say which dimension you are on and what it covers (one sentence, from `summary`).
2. Ask that dimension's questions together. For each question, show the level options from `levels` so the user can pick a number.
3. If an answer is vague, ask one follow-up using the question's `probe`. If it stays vague, record the lower of the two plausible levels and note it as "assumed".
4. Record each answer as an integer level.

`references/interview-guide.md` explains how to probe without leading the user. Read it before the first dimension.

Keep a running JSON of answers in this shape:

```json
{"profile": {"sector": "...", "headcount": "51-250", "role": "..."},
 "answers": {"<dimension_id>": {"<question_id>": 2}},
 "assumed": ["<question_id>"]}
```

## 3. Score

Save the JSON to a file and run:

```bash
python3 ${CLAUDE_SKILL_DIR}/scripts/score.py ${CLAUDE_SKILL_DIR}/references/index.json answers.json
```

The script prints per-dimension scores (0-100), the weighted total, the maturity band, and the weakest dimensions. If it reports missing answers, go back and ask them. If you cannot run scripts in this environment, apply the formula in `references/scoring.md` exactly and show the arithmetic.

## 4. Report

Fill `${CLAUDE_SKILL_DIR}/assets/report-template.md` with the script output. Rules:

- Use the numbers exactly as the script printed them.
- For each of the two weakest dimensions, pick recommendations only from that dimension's `recommendations` list in `index.json`, choosing the ones that fit the company's headcount and sector.
- Mark any score that rests on assumed answers.
- No hype, no fear-based language. Plain, direct sentences.

## 5. Next step

End the report with the `next_step` text from `index.json`, unchanged. Do not add sales language of your own.
