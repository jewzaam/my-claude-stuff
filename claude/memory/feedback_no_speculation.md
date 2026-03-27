---
name: No speculation or fabricated numbers
description: Never state guesses as facts — especially timing, durations, or behavioral claims without evidence from logs, code, or documentation
type: feedback
---

Do not fabricate numbers or state speculation as fact. If a value isn't in the logs or code, say "I don't know" — don't invent a plausible-sounding number.

**Why:** User explicitly requires accuracy over positivity. Fabricated numbers (e.g., "~100ms auto-approve flash") erode trust and violate the "mark speculation clearly" rule. The user called this out directly and was angry about it.

**How to apply:** Before stating any timing, duration, or behavioral claim, verify it exists in logs, code, or documentation. If it doesn't, say you don't have data for it. Never fill gaps with guesses presented as facts.
