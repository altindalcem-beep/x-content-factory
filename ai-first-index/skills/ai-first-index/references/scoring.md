# Scoring formula

Use this only when `scripts/score.py` cannot run. Show every step.

1. Each question has an integer level from `scale.min` to `scale.max` (0 to 4).
2. Dimension score = (average level of its questions - min) / (max - min) x 100, rounded to one decimal.
3. Total = sum of (dimension weight x dimension score) / sum of weights, rounded to one decimal.
4. Band = the band in `bands` with the highest `min` that is less than or equal to the total.
5. Weakest dimensions = the two lowest dimension scores.
6. Flag a dimension if any of its answers is in the `assumed` list.
