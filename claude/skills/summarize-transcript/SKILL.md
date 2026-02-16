---
name: summarize-transcript
description: Create accurate, impartial timeline summaries from meeting transcripts. Use for Google Meet transcriptions or similar raw meeting records.
argument-hint: <transcript-file-path> [output-file-path]
disable-model-invocation: true
allowed-tools: Read, Write, Task
---

# Summarize Meeting Transcript

Create an accurate, impartial timeline summary from the meeting transcript at `$0`.

Output file: `$1` (defaults to `summary.md` in the same directory as the transcript).

## CRITICAL: Accuracy and Impartiality Requirements

You MUST follow these rules when creating the summary:

1. **Do NOT add context or assumptions** - State only what is clearly present in the transcript
2. **Preserve uncertainty** - Include phrases like "I don't know", "maybe", incomplete thoughts, trailing dialogue
3. **Preserve confusion** - Meeting confusion, scheduling issues, participants being lost are important context
4. **Keep strong language** - Don't soften phrases (e.g., keep "power sucks" not "problematic")
5. **Preserve rambling nature** - Don't over-organize rambling explanations into clean bullet points
6. **Mark editorial additions** - Use `[Editorial: ...]` format for section headers or organizational structure you add
7. **Accurate attribution** - Be careful about who said what, add clarifying notes when needed
8. **Include process issues** - Meeting logistics, confusion about agenda, people joining late, etc.

### What to Include

- Timeline of discussion in chronological order
- All significant statements and exchanges
- Uncertainty markers and incomplete thoughts
- Strong language and self-aware statements (e.g., "politically incorrect answer")
- Meeting confusion and scheduling issues
- Rambling speech patterns (run-on sentences are OK)
- Statements showing working session nature

### What to Avoid

- Over-organizing rambling content into clean structures
- Smoothing over uncertainty or disagreement
- Softening strong language
- Creating impression of more structure than existed
- Adding interpretive conclusions not stated by participants
- Clean bullet points that misrepresent exploratory discussion

### Handling Post-Summary Corrections

**CRITICAL:** If corrections are made after the summary is created (e.g., user corrects transcription errors):

1. **In Quotes:** Use square brackets `[corrected word]` to indicate the correction
   - Example: `"I know [Naveen] is out"` when transcript said "Lavin"
   - Example: `"lack of [subject matter] expertise"` when transcript said "sudden mother"

2. **Outside Quotes:** Square brackets are strongly recommended for transparency
   - Example: `**Massimo** knows [Naveen] is out.`
   - Shows the correction was made post-summary creation

3. **Document in Known Issues:** Add note about what was corrected
   - Example: `Transcription misheard "Naveen" as "Lavin" (corrected with [brackets])`

**Rationale:** This maintains transparency and doesn't mislead readers about what was in the original transcript versus what was corrected. Without brackets, corrections in quotes violate the principle of not providing interpretation.

**Note:** Square brackets in Markdown don't require escaping - `[text]` renders as literal brackets since there's no `(url)` following it.

## Process

### 1. Read the Transcript

Read `$0` to understand:
- Who the participants are
- What the meeting was about
- The overall flow and any confusion
- Transcription quality issues (accents, technical terms, etc.)

### 2. Create Initial Summary

Create the summary file with:

**Header Structure:**
```markdown
# [Meeting Title] - Timeline Summary
## Meeting Date: [Date]

### Attendees
[List of attendees]

---

## IMPORTANT NOTES ABOUT THIS SUMMARY

**Nature of the Meeting:**
[Describe if it was exploratory, structured, confused, etc.]

**Editorial Choices:**
- Section headers (e.g., "[Editorial: Topic]") are organizational additions - NOT explicit topics identified by participants
- The original transcript contains [describe quality issues]
- This summary preserves [what you're preserving]
- No content has been fabricated, but organizational structure has been added for readability

---

## Timeline of Discussion

**Note: Time ranges are approximate based on [sparse/available] timestamps in transcript**
```

**Timeline Sections:**

Use format: `### [Editorial: Descriptive Topic] (HH:MM:SS - HH:MM:SS)`

For each speaker statement:
- Use bold for speaker name: `**Name**`
- Include full context and nuance
- Preserve rambling speech with ellipses for trailing thoughts
- Add `(likely "word")` for unclear transcription
- Add `(unclear term)` for unintelligible parts
- Use quotes for direct quotes
- Add clarifying parentheticals when needed: `(Note: ...)`

**Footer Structure:**
```markdown
---

## Document Status and Limitations

**Source Accuracy:**
- All content is based solely on statements in the transcript
- No fabricated content has been added
- Direct quotes are preserved where possible, including uncertain speech and incomplete thoughts

**Known Issues:**
- [List transcription quality issues]
- [Note accent-related misinterpretations]
- [Note sparse timestamps or other limitations]

**Editorial Choices Made:**
- Section headers in brackets [Editorial: ...] are organizational additions not stated by participants
- Time ranges are approximate based on [available data]
- Rambling speech patterns preserved where they occurred
- Uncertainty markers ("I don't know", "maybe", incomplete thoughts) deliberately preserved
- Strong language preserved (e.g., [examples])
- Meeting confusion and process issues included

**What This Summary Is:**
- A timeline capturing what was said with minimal interpretation
- An attempt to preserve the exploratory, uncertain nature of the working session
- A verbatim-style capture acknowledging transcription quality issues

**What This Summary Is Not:**
- A clean, polished account of a structured meeting
- A definitive technical specification or decision record
- Free from potential misinterpretations due to transcript errors
```

### 3. Verify Accuracy and Impartiality

Use the Task tool to launch a general-purpose agent to verify the summary:

```
Verify the accuracy and impartiality of the summary file against the original transcript.

Compare both files and check:
1. Summary contains only information clearly stated in the transcript
2. No added context, assumptions, or interpretations
3. Timeline accurately reflects the order of discussion
4. No misrepresentations or bias in how information is presented
5. No significant omissions
6. Speaker attributions are correct
7. Uncertainty, confusion, and rambling nature are preserved
8. Strong language is not softened
9. Editorial additions are properly marked

Provide a detailed verification report with:
- Overall assessment of accuracy and impartiality
- Specific instances where summary adds context not in transcript (if any)
- Specific instances of inaccuracies or misattributions (if any)
- Notable omissions (if any)
- Recommendations for corrections (if needed)

Be thorough and critical. The goal is to ensure the summary is factual and doesn't add interpretations or assumptions.
```

### 4. Review and Revise

If the verification agent identifies issues:
1. Read the verification report carefully
2. Revise the summary to address all identified issues
3. Consider whether a second verification pass is needed

### 5. Present Results

Show the user:
- Summary file location
- Key findings from verification
- Any remaining concerns or limitations
- Offer to revise if they identify transcription corrections or other issues

## Additional Notes

- Transcription quality varies - watch for accent-related errors and technical term misinterpretations
- The goal is verbatim-style timeline, not polished summary
- When in doubt, preserve more detail rather than less
- Use the Task tool with general-purpose subagent for verification to get thorough review
